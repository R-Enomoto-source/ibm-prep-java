# 自動コミット・プッシュのテスト手順

## 📋 テストの流れ

### ステップ1: スクリプトが実行中か確認

```powershell
# PowerShellで実行
cd "C:\Users\20171\IT_Learning\pre-joining-learning\scripts"

# ログを確認（当日のログファイル）
Get-Content "..\.git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Tail 5
```

または、タスクマネージャーで`powershell.exe`プロセスを確認してください。

### ステップ2: テスト用ファイルを作成または変更

#### 方法1: 新しいファイルを作成（推奨）

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning"

# テスト用ファイルを作成
"テスト用ファイル - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath "test-auto-commit.txt" -Encoding UTF8
```

#### 方法2: 既存のファイルを変更

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning"

# 既存のファイルに追記
Add-Content -Path "README.md" -Value "`n`n## 自動コミットテスト - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
```

#### 方法3: 簡単な変更（エディタで編集）

1. Cursor/VS Codeで任意のファイルを開く
2. 少し変更を加える（コメント追加、空白行追加など）
3. ファイルを保存（Ctrl+S）

### ステップ3: デバウンス時間を待つ

設定ファイル（`config.json`）の`debounceSeconds`で設定された時間（デフォルト30秒）待ちます。

```powershell
# 30秒待機（デフォルト設定の場合）
Start-Sleep -Seconds 35
```

**注意**: デバウンス時間内に新しい変更を加えると、タイマーがリセットされます。

### ステップ4: ログファイルで動作を確認

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning"

# 当日のログの最新10行を表示
Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Tail 10

# または、リアルタイムで監視（Ctrl+Cで停止）
Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Wait -Tail 5
```

**確認ポイント:**
- `変更を検出しました` というメッセージがあるか
- `git add . を実行中...` というメッセージがあるか
- `git commit を実行中...` というメッセージがあるか
- `git push origin main を実行中...` というメッセージがあるか
- `コミット・プッシュが完了しました` というメッセージがあるか

### ステップ5: Gitでコミットを確認

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning"

# 最新のコミットを確認
git log --oneline -5

# 詳細なコミット情報を確認
git log -1 --pretty=full

# コミットメッセージを確認
git log -1 --pretty=format:"%s%n%b"
```

### ステップ6: GitHubでプッシュを確認

1. GitHubのリポジトリページを開く
2. 最新のコミットが表示されているか確認
3. コミットメッセージが正しく表示されているか確認

## 🧪 簡単なテストスクリプト

以下のスクリプトを実行すると、自動的にテストできます：

```powershell
# test-auto-commit.ps1
cd "C:\Users\20171\IT_Learning\pre-joining-learning"

Write-Host "=== 自動コミット・プッシュテスト ===" -ForegroundColor Cyan
Write-Host ""

# 1. テストファイルを作成
$testFile = "test-auto-commit-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$testContent = "自動コミットテスト - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$testContent | Out-File -FilePath $testFile -Encoding UTF8

Write-Host "✓ テストファイルを作成しました: $testFile" -ForegroundColor Green
Write-Host ""

# 2. 現在のgit statusを確認
Write-Host "現在の変更状況:" -ForegroundColor Yellow
git status --short
Write-Host ""

# 3. デバウンス時間を表示
Write-Host "デバウンス時間（30秒）待機中..." -ForegroundColor Yellow
Write-Host "（この間にスクリプトが変更を検出し、コミット・プッシュを実行します）" -ForegroundColor Gray
Write-Host ""

# 4. 35秒待機（デバウンス時間 + 余裕）
for ($i = 35; $i -gt 0; $i--) {
    Write-Host "`r残り $i 秒... " -NoNewline -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}
Write-Host "`r完了！                                    " -ForegroundColor Green
Write-Host ""

# 5. ログファイルを確認
Write-Host "=== ログファイル（最新10行） ===" -ForegroundColor Cyan
$todayLog = ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt"
if (Test-Path $todayLog) {
    Get-Content $todayLog -Tail 10
} else {
    Write-Host "ログファイルが見つかりません" -ForegroundColor Red
}
Write-Host ""

# 6. Gitのコミット履歴を確認
Write-Host "=== 最新のコミット ===" -ForegroundColor Cyan
git log --oneline -3
Write-Host ""

# 7. 結果の確認
Write-Host "=== テスト結果 ===" -ForegroundColor Cyan
$latestCommit = git log -1 --pretty=format:"%s" 2>&1
if ($latestCommit -like "*Auto commit*") {
    Write-Host "✓ 自動コミットが成功しました！" -ForegroundColor Green
    Write-Host "  コミットメッセージ: $latestCommit" -ForegroundColor Gray
} else {
    Write-Host "⚠ 自動コミットが検出されませんでした" -ForegroundColor Yellow
    Write-Host "  ログファイルを確認してください" -ForegroundColor Gray
}
Write-Host ""

Write-Host "テスト完了！" -ForegroundColor Cyan
```

## 🔍 トラブルシューティング

### コミット・プッシュが実行されない場合

1. **スクリプトが実行中か確認**
   ```powershell
   Get-Process | Where-Object { $_.ProcessName -eq "powershell" -and $_.CommandLine -like "*auto-git-commit*" }
   ```

2. **ログファイルでエラーを確認**
   ```powershell
   Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" | Select-String "ERROR"
   ```

3. **git設定を確認**
   ```powershell
   git config --list
   git remote -v
   ```

4. **手動でgit操作をテスト**
   ```powershell
   git status
   git add .
   git commit -m "テスト"
   git push origin main
   ```

### デバウンス時間を短くしてテストする場合

`config.json`を編集：

```json
{
  "debounceSeconds": 10,  // 30秒から10秒に変更
  ...
}
```

変更後、スクリプトを再起動してください。

## 📝 テストチェックリスト

- [ ] スクリプトが実行中であることを確認
- [ ] テストファイルを作成または変更
- [ ] デバウンス時間（30秒）待機
- [ ] ログファイルで「変更を検出しました」を確認
- [ ] ログファイルで「コミット・プッシュが完了しました」を確認
- [ ] `git log`で最新のコミットを確認
- [ ] GitHubでプッシュを確認

## 💡 ヒント

- テストファイルは`.gitignore`に追加しないでください（コミット対象にするため）
- テスト後は、テストファイルを削除しても問題ありません
- ログは`.git-auto-commit/logs/`に日ごとのファイル（`log-yyyy-MM-dd.txt`）で記録されます
- リアルタイムでログを監視: `Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Wait`
