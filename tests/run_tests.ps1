param([string]$GodotExecutable = 'godot')

$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$testDataPath = Join-Path $projectPath '.godot/session-test-data'
$originalAppData = $env:APPDATA
$originalTestFlag = $env:DAWN_TEST_RUN
try {
    New-Item -ItemType Directory -Force -Path $testDataPath | Out-Null
    $env:APPDATA = $testDataPath
    $env:DAWN_TEST_RUN = '1'
    $logPath = Join-Path $testDataPath 'sessions.log'
    $output = & $GodotExecutable --headless --path $projectPath --log-file $logPath --script res://tests/test_sessions.gd 2>&1 | Out-String
    $result = $LASTEXITCODE
    Write-Output $output
    # Godot can report script errors and still exit zero; require completion too.
    if ($result -ne 0 -or $output -match '(?m)^(SCRIPT ERROR:|ERROR:)' -or $output -notmatch 'Session tests: \d+ checks, 0 failures') {
        exit 1
    }
} finally {
    $env:APPDATA = $originalAppData
    $env:DAWN_TEST_RUN = $originalTestFlag
}
