param(
    [string]$Url = "https://n8n.example.tld",
    [int]$RemoteDebugPort = 9222
)

$edgeCandidates = @(
    Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe"
    Join-Path ${env:ProgramFiles} "Microsoft\Edge\Application\msedge.exe"
)

$edgePath = $edgeCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $edgePath) {
    throw "Microsoft Edge wurde nicht gefunden. Passe den Pfad in helper-scripts\start-edge-devtools.ps1 an."
}

$profileDir = Join-Path $env:LOCALAPPDATA "Edge-MCP"
$args = @(
    "--remote-debugging-port=$RemoteDebugPort"
    "--user-data-dir=$profileDir"
    $Url
)

Start-Process -FilePath $edgePath -ArgumentList $args
