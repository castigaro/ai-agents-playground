param(
    [string]$RemoteAlias = "codex-home",
    [string]$RemoteDir = "/home/codex/ai-agents-playground/services/n8n",
    [switch]$Update
)

$repoRoot = $PSScriptRoot
while ($repoRoot) {
    $candidateCompose = Join-Path $repoRoot "services\n8n\docker-compose.yml"
    if (Test-Path $candidateCompose) {
        break
    }

    $parent = Split-Path $repoRoot -Parent
    if ($parent -eq $repoRoot) {
        $repoRoot = $null
        break
    }

    $repoRoot = $parent
}

if (-not $repoRoot) {
    throw "Could not locate repo root from script path: $PSScriptRoot"
}

$localDir = Join-Path $repoRoot "services\n8n"
$composeFile = Join-Path $localDir "docker-compose.yml"
$envExampleFile = Join-Path $localDir ".env.example"
$envFile = Join-Path $localDir ".env"
$localFilesDir = Join-Path $localDir "local-files"

if (-not (Test-Path $composeFile)) {
    throw "Missing compose file: $composeFile"
}

if (-not (Test-Path $envExampleFile)) {
    throw "Missing env example file: $envExampleFile"
}

if (-not (Test-Path $envFile)) {
    Copy-Item $envExampleFile $envFile
}

if (-not (Test-Path $localFilesDir)) {
    New-Item -ItemType Directory -Path $localFilesDir | Out-Null
}

ssh $RemoteAlias "mkdir -p '$RemoteDir'"
scp $composeFile ("{0}:{1}/docker-compose.yml" -f $RemoteAlias, $RemoteDir)
scp $envFile ("{0}:{1}/.env" -f $RemoteAlias, $RemoteDir)
if ($Update) {
    Write-Host "Updating n8n image before restart..."
    ssh $RemoteAlias "mkdir -p '$RemoteDir/local-files' && cd '$RemoteDir' && docker compose pull n8n"
}

ssh $RemoteAlias "mkdir -p '$RemoteDir/local-files' && cd '$RemoteDir' && docker compose up -d"
