# LearningNote auto-creation script
# Creates LearningNote_yyyyMMdd.md in learningNote if it does not exist.
# Intended to be called from Cursor/VSCode "when folder is opened" task.

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$learningNoteDir = Join-Path $projectRoot 'learningNote'
$templatePath = Join-Path $scriptDir 'learning-note-template.md'

$today = Get-Date -Format 'yyyyMMdd'
$dateDisplay = Get-Date -Format 'yyyy-MM-dd'
$fileName = "LearningNote_$today.md"
$filePath = Join-Path $learningNoteDir $fileName

if (-not (Test-Path $filePath)) {
    if (-not (Test-Path $learningNoteDir)) {
        New-Item -ItemType Directory -Path $learningNoteDir -Force | Out-Null
    }
    # Read template as UTF-8 (avoids mojibake regardless of script encoding)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
    $content = $content.Replace('{{date}}', $dateDisplay)
    # Write as UTF-8 without BOM
    [System.IO.File]::WriteAllText($filePath, $content, $utf8)
}
