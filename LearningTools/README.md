# LearningTools

学習補助系のスクリプト・設定・ドキュメントをアプリケーションごとにまとめたフォルダです。

## フォルダ構成

| フォルダ | 説明 |
|----------|------|
| **auto-git-commit/** | 自動 Git コミット・プッシュ（変更検知 → add / commit / push） |
| **learning-note/** | 学習ノートの自動作成（日付ファイルの自動作成） |
| **docs/** | 環境構築・トラブルシューティング用ドキュメント（例: PowerShell / winget エラー対処） |
| **project-setup-example/** | Eclipse / Java 用プロジェクト設定テンプレ（.project, .classpath, .settings）。clone 直後にルートへコピーして使用。 |

## 使い方

- **自動コミット**: タスクスケジューラで自動起動するか、手動のときは `LearningTools/auto-git-commit/auto-git-commit.ps1` を実行。詳細は `LearningTools/auto-git-commit/README.md` を参照してください。
- **学習ノート自動作成**: `LearningTools/learning-note/` 内の `create-learning-note.ps1` をタスクやフォルダオープン時などから呼び出してください。詳細は同フォルダ内の実現プランを参照してください。

## 共通

- 各ツールはリポジトリルート（`.git` があるディレクトリ）を自動検出するため、このフォルダをどこに配置しても動作します。
