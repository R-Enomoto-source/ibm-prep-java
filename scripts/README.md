# 自動Gitコミット・プッシュスクリプト

PC起動時に自動でファイル変更を監視し、gitにコミット・プッシュするスクリプトです。

## 📁 ファイル構成

```
scripts/
├── auto-git-commit.ps1        # メインスクリプト（自動実行される）
├── generate-commit-msg.ps1    # コミットメッセージ生成スクリプト
├── config.json                # 設定ファイル（リポジトリに含める）
├── config.example.local.json  # 環境用設定のサンプル
├── config.local.json          # 環境ごとの上書き用（.gitignore で除外・リポジトリに載せない）
├── setup-auto-start.ps1       # 自動起動設定スクリプト
└── README.md                  # このファイル

.git-auto-commit/             # 一時ファイル（自動生成）
├── logs/                     # ログ専用フォルダ（日ごとに1ファイル）
│   └── log-yyyy-MM-dd.txt    # 実行ログ（例: log-2026-02-05.txt）
├── commit-message.txt        # コミットメッセージ（一時）
├── last-status.txt           # 前回のgit status
└── last-commit-time.txt     # 最後のコミット時刻
```

## 🚀 使い方

### 1. 初回設定（自動起動の設定）

管理者権限でPowerShellを開き、以下のコマンドを実行します：

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\scripts"
.\setup-auto-start.ps1
```

これで、PC起動時に自動でスクリプトが実行されるようになります。

### 2. 手動で実行する場合（テスト用）

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\scripts"
.\auto-git-commit.ps1
```

### 3. 自動起動を無効にする場合

```powershell
cd "C:\Users\20171\IT_Learning\pre-joining-learning\scripts"
.\setup-auto-start.ps1 -Remove
```

## ⚙️ 設定（config.json）

設定ファイルを編集することで、動作をカスタマイズできます：

```json
{
  "pollingInterval": 30,        // ポーリング間隔（秒）
  "debounceSeconds": 30,        // デバウンス時間（秒）
  "minChangeCount": 1,          // 最小変更ファイル数
  "branchName": "main",        // プッシュ先ブランチ
  "retryAttempts": 3,          // リトライ回数
  "retryDelaySeconds": 5,      // リトライ間隔（秒）
  "activeHours": {
    "enabled": false,          // アクティブ時間の有効化
    "startTime": "08:00",      // 開始時刻
    "endTime": "23:00"         // 終了時刻
  }
}
```

### 設定項目の説明

- **pollingInterval**: git statusをチェックする間隔（秒）。デフォルト: 30秒
- **debounceSeconds**: 変更検知後、コミット実行まで待つ時間（秒）。デフォルト: 30秒
- **minChangeCount**: この数以上のファイルが変更された場合のみコミット。デフォルト: 1
- **branchName**: プッシュ先のブランチ名。デフォルト: main
- **activeHours**: 指定した時間帯のみコミット・プッシュを実行（オプション）

### 環境ごとの設定（config.local.json）

**絶対パスや個人用識別子**など、環境によって変えたい値だけは **config.local.json** に書き、リポジトリには載せない運用にしてください。

- **config.local.json** は `.gitignore` で除外されているため、Git にコミットされません。
- 使い方: `config.example.local.json` をコピーして `config.local.json` を作成し、上書きしたい項目だけを書きます。ここに書いたキーが `config.json` の値を上書きします。
- 例: 監視パスを絶対パスにしたい場合などは `config.local.json` に `"watchPath": "C:\\Users\\YourName\\..."` のように記載します。

## 📝 動作の流れ

1. PC起動時に自動でスクリプトが開始
2. 30秒ごとに`git status`をチェック
3. 変更を検出したら、デバウンス時間（30秒）待機
4. デバウンス時間内に新しい変更がなければ、コミット・プッシュを実行
5. PCをシャットダウン/再起動すると、スクリプトが自動終了
6. 再起動後も自動で再開

## 📊 ログの確認

実行ログは専用フォルダに日ごとのファイルで記録されます：

```
.git-auto-commit/logs/log-yyyy-MM-dd.txt   （例: log-2026-02-05.txt）
```

ログには以下の情報が記録されます：
- スクリプトの開始・終了時刻
- 変更の検出
- コミット・プッシュの実行結果
- エラー情報

## 🔍 トラブルシューティング

### スクリプトが実行されない

1. **タスクスケジューラで確認**
   - Windowsキー + R → `taskschd.msc`
   - 「Auto Git Commit」タスクを確認
   - タスクを右クリック → 「実行」で手動実行してテスト

2. **実行ポリシーの確認**
   ```powershell
   Get-ExecutionPolicy
   ```
   もし`Restricted`の場合は、以下を実行：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **ログを確認**
   ```
   .git-auto-commit/logs/   （当日: log-yyyy-MM-dd.txt）
   ```

### コミット・プッシュが実行されない

1. **git設定の確認**
   ```powershell
   git config --list
   git remote -v
   ```

2. **認証情報の確認**
   - GitHubへの認証が正しく設定されているか確認
   - Git Credential Managerを使用している場合、認証情報を再設定

3. **ネットワーク接続の確認**
   - インターネット接続があるか確認
   - GitHubへの接続が可能か確認

### 複数のインスタンスが実行される

- タスクスケジューラの設定で「タスクが実行中の場合、新しいインスタンスを開始しない」にチェックが入っているか確認

## 🛠️ 開発者向け情報

### スクリプトの構造

- **auto-git-commit.ps1**: メインループ、ポーリング、デバウンス処理
- **generate-commit-msg.ps1**: git statusを解析してコミットメッセージを生成
- **setup-auto-start.ps1**: Windowsタスクスケジューラへの登録

### カスタマイズ

スクリプトはモジュール化されているため、必要に応じてカスタマイズ可能です：
- コミットメッセージのフォーマット変更（generate-commit-msg.ps1）
- ファイルパターンの除外（config.jsonのexcludePatterns）
- アクティブ時間の設定（config.jsonのactiveHours）

## 📚 関連ドキュメント

- [AUTO_GIT_COMMIT_PLAN_REVIEW.md](../AUTO_GIT_COMMIT_PLAN_REVIEW.md) - 詳細な実装計画と設計思想
