# 自動コミット・プッシュのテストスクリプト

$ScriptDir = $PSScriptRoot
# Find repo root (directory containing .git)
$RepoRoot = $ScriptDir
while ($RepoRoot) {
    if (Test-Path (Join-Path $RepoRoot ".git")) { break }
    $parent = Split-Path -Parent $RepoRoot
    if (-not $parent -or $parent -eq $RepoRoot) { $RepoRoot = Split-Path -Parent $ScriptDir; break }
    $RepoRoot = $parent
}
$LogDir = Join-Path $ScriptDir ".git-auto-commit\logs"
$LogFile = Join-Path $LogDir "log-$(Get-Date -Format 'yyyy-MM-dd').txt"

Write-Host "=== 自動コミット・プッシュテスト ===" -ForegroundColor Cyan
Write-Host ""

# 1. スクリプトが実行中か確認
Write-Host "1. スクリプトの実行状況を確認中..." -ForegroundColor Yellow
if (Test-Path $LogFile) {
    $latestLog = Get-Content $LogFile -Tail 1 -ErrorAction SilentlyContinue
    if ($latestLog -like "*開始します*" -or $latestLog -like "*INFO*") {
        Write-Host "   ✓ スクリプトは実行中のようです" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ スクリプトが実行されていない可能性があります" -ForegroundColor Yellow
        Write-Host "     まず、スクリプトを起動してください: .\auto-git-commit.ps1" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠ ログファイルが見つかりません" -ForegroundColor Yellow
    Write-Host "     スクリプトを起動してください: .\auto-git-commit.ps1" -ForegroundColor Gray
}
Write-Host ""

# 2. テストファイルを作成
Write-Host "2. テストファイルを作成中..." -ForegroundColor Yellow
Push-Location $RepoRoot

$testFile = "test-auto-commit-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$testContent = @"
自動コミットテストファイル
作成日時: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
このファイルは自動コミット・プッシュのテスト用です。
"@

$testContent | Out-File -FilePath $testFile -Encoding UTF8
Write-Host "   ✓ テストファイルを作成しました: $testFile" -ForegroundColor Green
Write-Host ""

# 3. 現在のgit statusを確認
Write-Host "3. 現在の変更状況:" -ForegroundColor Yellow
git status --short
Write-Host ""

# 4. デバウンス時間を待機
Write-Host "4. デバウンス時間（30秒）待機中..." -ForegroundColor Yellow
Write-Host "   （この間にスクリプトが変更を検出し、コミット・プッシュを実行します）" -ForegroundColor Gray
Write-Host ""

# カウントダウン表示
for ($i = 30; $i -gt 0; $i--) {
    Write-Host "`r   残り $i 秒... " -NoNewline -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}
Write-Host "`r   完了！                                    " -ForegroundColor Green
Write-Host ""

# 5. ログファイルを確認
Write-Host "5. ログファイル（最新15行）:" -ForegroundColor Yellow
if (Test-Path $LogFile) {
    Write-Host "   " -NoNewline
    Get-Content $LogFile -Tail 15 | ForEach-Object {
        if ($_ -like "*ERROR*") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -like "*WARN*") {
            Write-Host $_ -ForegroundColor Yellow
        } elseif ($_ -like "*変更を検出*" -or $_ -like "*コミット*" -or $_ -like "*プッシュ*") {
            Write-Host $_ -ForegroundColor Green
        } else {
            Write-Host $_
        }
    }
} else {
    Write-Host "   ⚠ ログファイルが見つかりません" -ForegroundColor Red
}
Write-Host ""

# 6. Gitのコミット履歴を確認
Write-Host "6. 最新のコミット履歴（最新3件）:" -ForegroundColor Yellow
git log --oneline -3
Write-Host ""

# 7. 結果の確認
Write-Host "7. テスト結果:" -ForegroundColor Yellow
$latestCommit = git log -1 --pretty=format:"%s" 2>&1
if ($latestCommit -like "*Auto commit*" -or $latestCommit -like "*自動*") {
    Write-Host "   ✓ 自動コミットが成功しました！" -ForegroundColor Green
    Write-Host "     コミットメッセージ: $latestCommit" -ForegroundColor Gray
    
    # プッシュの確認
    $remoteStatus = git log origin/main..HEAD --oneline 2>&1
    if ($remoteStatus -and $remoteStatus -notlike "*fatal*") {
        Write-Host "   ⚠ まだプッシュされていないコミットがあります" -ForegroundColor Yellow
        Write-Host "     手動でプッシュしてください: git push origin main" -ForegroundColor Gray
    } else {
        Write-Host "   ✓ プッシュも完了しているようです" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠ 自動コミットが検出されませんでした" -ForegroundColor Yellow
    Write-Host "     確認事項:" -ForegroundColor Gray
    Write-Host "     - スクリプトが実行中か確認してください" -ForegroundColor Gray
    Write-Host "     - ログフォルダ（.git-auto-commit\logs\）の当日ファイルを確認してください" -ForegroundColor Gray
    Write-Host "     - デバウンス時間が経過しているか確認してください" -ForegroundColor Gray
}
Write-Host ""

# 8. テストファイルの処理
Write-Host "8. テストファイルの処理:" -ForegroundColor Yellow
$delete = Read-Host "   テストファイルを削除しますか？ (Y/N)"
if ($delete -eq "Y" -or $delete -eq "y") {
    Remove-Item $testFile -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ テストファイルを削除しました" -ForegroundColor Green
} else {
    Write-Host "   ℹ テストファイルを残しました: $testFile" -ForegroundColor Gray
}
Write-Host ""

Pop-Location

Write-Host "=== テスト完了 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "ヒント:" -ForegroundColor Yellow
Write-Host "  - ログをリアルタイムで監視: Get-Content '.git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt' -Wait -Tail 5" -ForegroundColor Gray
Write-Host "  - 最新のコミットを確認: git log -1 --pretty=full" -ForegroundColor Gray
Write-Host "  - GitHubで確認: リポジトリページを開いて最新のコミットを確認" -ForegroundColor Gray
