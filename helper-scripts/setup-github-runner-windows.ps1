param(
    [string]$Repo = "castigaro/spacesonar-pro",
    [string]$RunnerDir = "D:\actions-runner",
    [string]$RunnerName = $env:COMPUTERNAME.ToLowerInvariant(),
    [string]$Labels = "spacesonar",
    [string]$Token,
    [string]$TaskName = "GitHub Actions Runner"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh is required (winget install GitHub.cli) and must be logged in."
}

foreach ($tool in "git", "rustup", "cargo", "node") {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "$tool is not on the PATH of this user; the runner inherits this PATH."
    }
}

$configCmd = Join-Path $RunnerDir "config.cmd"
if (-not (Test-Path $configCmd)) {
    $release = gh api repos/actions/runner/releases/latest | ConvertFrom-Json
    $version = $release.tag_name.TrimStart("v")
    $assetName = "actions-runner-win-x64-$version.zip"
    $asset = $release.assets | Where-Object { $_.name -eq $assetName }
    if (-not $asset) {
        throw "Release $($release.tag_name) of actions/runner has no asset $assetName."
    }

    New-Item -ItemType Directory -Force -Path $RunnerDir | Out-Null
    $zip = Join-Path $env:TEMP $assetName
    Write-Host "Downloading $assetName..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $RunnerDir -Force
    Remove-Item $zip
}

if (-not (Test-Path (Join-Path $RunnerDir ".runner"))) {
    if (-not $Token) {
        $Token = gh api -X POST "repos/$Repo/actions/runners/registration-token" --jq .token
        if (-not $Token) {
            throw "No registration token; pass -Token with the one from Settings > Actions > Runners > New self-hosted runner."
        }
    }

    Write-Host "Registering runner '$RunnerName' for $Repo..."
    & $configCmd --url "https://github.com/$Repo" --token $Token --name $RunnerName --labels $Labels --work _work --unattended --replace
    if ($LASTEXITCODE -ne 0) {
        throw "config.cmd failed with exit code $LASTEXITCODE."
    }
}

$runCmd = Join-Path $RunnerDir "run.cmd"
$user = "$env:USERDOMAIN\$env:USERNAME"
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c start `"$TaskName`" /min `"$runCmd`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null

if (-not (Get-Process -Name "Runner.Listener" -ErrorAction SilentlyContinue)) {
    Start-ScheduledTask -TaskName $TaskName
}

Write-Host "Runner '$RunnerName' is set up; task '$TaskName' starts it minimised at every logon."
Write-Host "Check https://github.com/$Repo/settings/actions/runners for the status Idle."
