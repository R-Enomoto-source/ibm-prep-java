# 自動コミット・プッシュのテスト手順

本フォルダ（LearningTools/auto-git-commit）のスクリプト用です。ログは**このフォルダ内**の `.git-auto-commit/logs/` に出力されます。

## 📋 テストの流れ

### ステップ1: スクリプトが実行中か確認

```powershell
# このフォルダ（LearningTools/auto-git-commit）で
cd "C:\Users\20171\IT_Learning\pre-joining-learning\LearningTools\auto-git-commit"

# ログを確認（当日のログファイル）
Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" -Tail 5
```

または、タスクマネージャーで`powershell.exe`プロセスを確認してください。

### ステップ2: テスト用ファイルを作成または変更

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning"
"テスト用ファイル - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath "test-auto-commit.txt" -Encoding UTF8
```

### ステップ3: デバウンス時間を待つ

設定の`debounceSeconds`（デフォルト30秒）待ちます。  
簡単な一括テストは **test-auto-commit.ps1** を実行してください：

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\LearningTools\auto-git-commit"
.\test-auto-commit.ps1
```

### ステップ4〜6: ログ・Git・GitHubで確認

- ログ: このフォルダの `.git-auto-commit\logs\log-yyyy-MM-dd.txt`
- `git log --oneline -5` でコミット確認
- GitHubでプッシュ確認

## 🔍 トラブルシューティング

- スクリプト実行確認: タスクスケジューラの「Auto Git Commit」または `Get-Process powershell`
- ログのエラー: `Get-Content ".git-auto-commit\logs\log-$(Get-Date -Format 'yyyy-MM-dd').txt" | Select-String "ERROR"`
- 手動テスト: `git status` → `git add .` → `git commit -m "テスト"` → `git push origin main`

## 📝 テストチェックリスト

- [ ] スクリプトが実行中であることを確認
- [ ] テストファイルを作成または変更
- [ ] デバウンス時間（30秒）待機
- [ ] ログで「変更を検出しました」「コミット・プッシュが完了しました」を確認
- [ ] `git log` と GitHubでプッシュを確認
