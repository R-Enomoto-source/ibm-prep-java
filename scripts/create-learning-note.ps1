# LearningNote 自動作成スクリプト
# 実行日の LearningNote_yyyyMMdd.md が learningNote になければ新規作成する。
# Cursor/VSCode の「フォルダーを開いたとき」タスクから呼び出す想定。

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$learningNoteDir = Join-Path $projectRoot 'learningNote'

$today = Get-Date -Format 'yyyyMMdd'
$dateDisplay = Get-Date -Format 'yyyy-MM-dd'
$fileName = "LearningNote_$today.md"
$filePath = Join-Path $learningNoteDir $fileName

if (-not (Test-Path $filePath)) {
    if (-not (Test-Path $learningNoteDir)) {
        New-Item -ItemType Directory -Path $learningNoteDir -Force | Out-Null
    }
    $header = @"
# LearningNote $dateDisplay

## セッションログ（ユーザー入力＋回答）

"@
    Set-Content -Path $filePath -Value $header -Encoding UTF8
}
