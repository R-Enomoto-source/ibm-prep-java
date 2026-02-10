# Launcher: scripts/auto-git-commit.ps1 を実行
$scriptDir = $PSScriptRoot
if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) { $scriptDir = $PWD.Path }
$scriptPath = Join-Path $scriptDir "LearningTools\auto-git-commit\auto-git-commit.ps1"
if (Test-Path $scriptPath) {
    & $scriptPath @args
} else {
    Write-Error "LearningTools\auto-git-commit\auto-git-commit.ps1 が見つかりません: $scriptPath"
    exit 1
}
