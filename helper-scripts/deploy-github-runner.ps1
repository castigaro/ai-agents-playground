param(
    [string]$RemoteAlias = "codex-home",
    [string]$RemoteDir = "/home/codex/ai-agents-playground/services/github-runner",
    [switch]$Update
)

$repoRoot = $PSScriptRoot
while ($repoRoot) {
    $candidateCompose = Join-Path $repoRoot "services\github-runner\docker-compose.yml"
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

$localDir = Join-Path $repoRoot "services\github-runner"
$envExampleFile = Join-Path $localDir ".env.example"
$envFile = Join-Path $localDir ".env"
$files = @("docker-compose.yml", "Dockerfile", "entrypoint-rust.sh")

foreach ($name in $files) {
    if (-not (Test-Path (Join-Path $localDir $name))) {
        throw "Missing file: $(Join-Path $localDir $name)"
    }
}

if (-not (Test-Path $envFile)) {
    Copy-Item $envExampleFile $envFile
    throw "Created $envFile from the example; set RUNNER_TOKEN there and run the script again."
}

$envContent = Get-Content $envFile -Raw
if ($envContent -notmatch '(?m)^(RUNNER_TOKEN|ACCESS_TOKEN)=\S+') {
    throw "Set RUNNER_TOKEN (or ACCESS_TOKEN) in $envFile before deploying."
}

ssh $RemoteAlias "mkdir -p '$RemoteDir'"
foreach ($name in $files) {
    scp (Join-Path $localDir $name) ("{0}:{1}/{2}" -f $RemoteAlias, $RemoteDir, $name)
}
scp $envFile ("{0}:{1}/.env" -f $RemoteAlias, $RemoteDir)

if ($Update) {
    Write-Host "Pulling the upstream runner image before the rebuild..."
    ssh $RemoteAlias "cd '$RemoteDir' && docker compose build --pull"
}

ssh $RemoteAlias "cd '$RemoteDir' && docker compose up -d --build"
