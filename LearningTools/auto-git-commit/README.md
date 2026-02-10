# 自動Gitコミット・プッシュスクリプト

PC起動時に自動でファイル変更を監視し、gitにコミット・プッシュするスクリプトです。
（本フォルダは **LearningTools** の「自動コミット」用です。）

## 📁 ファイル構成

```
LearningTools/auto-git-commit/
├── auto-git-commit.ps1        # メインスクリプト（自動実行される）
├── generate-commit-msg.ps1    # コミットメッセージ生成スクリプト
├── config.json                # 設定ファイル（リポジトリに含める）
├── config.example.local.json  # 環境用設定のサンプル
├── config.local.json          # 環境ごとの上書き用（.gitignore で除外・リポジトリに載せない）
├── setup-auto-start.ps1       # 自動起動設定スクリプト
├── test-auto-commit.ps1       # 動作テスト用スクリプト
├── messages.json              # 日本語メッセージ
└── README.md                  # このファイル

リポジトリルート/
└── .git-auto-commit/          # 一時ファイル（自動生成・リポジトリルートに作成）
    ├── logs/                  # ログ専用フォルダ（日ごとに1ファイル）
    │   └── log-yyyy-MM-dd.txt
    ├── commit-message.txt
    ├── last-status.txt
    └── last-commit-time.txt
```

## 🚀 使い方

### 1. 初回設定（自動起動の設定）

管理者権限でPowerShellを開き、このフォルダに移動して実行します：

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\LearningTools\auto-git-commit"
.\setup-auto-start.ps1
```

### 2. 手動で実行する場合（テスト用）

リポジトリルートからランチャーを実行するか、このフォルダで直接実行します：

```powershell
# リポジトリルートから（推奨）
cd "C:\Users\20171\IT_Learning\pre-joining-learning"
.\auto-git-commit.ps1

# またはこのフォルダから
cd "C:\Users\20171\IT_Learning\pre-joining-learning\LearningTools\auto-git-commit"
.\auto-git-commit.ps1
```

### 3. 自動起動を無効にする場合

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\LearningTools\auto-git-commit"
.\setup-auto-start.ps1 -Remove
```

## ⚙️ 設定（config.json）

設定ファイルを編集することで、動作をカスタマイズできます。  
項目の説明や環境ごとの上書き（config.local.json）については、リポジトリ直下の `GIT_WORKFLOW_GUIDE.md` や従来の scripts README を参照してください。

## 📝 動作の流れ

1. PC起動時に自動でスクリプトが開始（setup-auto-start 済みの場合）
2. 30秒ごとに`git status`をチェック
3. 変更を検出したら、デバウンス時間（30秒）待機
4. デバウンス時間内に新しい変更がなければ、コミット・プッシュを実行
5. ログはリポジトリルートの `.git-auto-commit/logs/` に出力

## 📚 関連ドキュメント

- [AUTO_GIT_COMMIT_PLAN_REVIEW.md](AUTO_GIT_COMMIT_PLAN_REVIEW.md) - 詳細な実装計画と設計思想
- [TEST_GUIDE.md](TEST_GUIDE.md) - テスト手順
