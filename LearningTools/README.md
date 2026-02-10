# LearningTools

学習補助系のスクリプト・設定をアプリケーションごとにまとめたフォルダです。

## フォルダ構成

| フォルダ | 説明 |
|----------|------|
| **auto-git-commit/** | 自動 Git コミット・プッシュ（変更検知 → add / commit / push） |
| **learning-note/** | 学習ノートの自動作成（日付ファイルの自動作成） |

## 使い方

- **自動コミット**: リポジトリ直下の `auto-git-commit.ps1` を実行するか、`LearningTools/auto-git-commit/` 内の `README.md` を参照してください。
- **学習ノート自動作成**: `LearningTools/learning-note/` 内の `create-learning-note.ps1` をタスクやフォルダオープン時などから呼び出してください。詳細は同フォルダ内の実現プランを参照してください。

## 共通

- 各ツールはリポジトリルート（`.git` があるディレクトリ）を自動検出するため、このフォルダをどこに配置しても動作します。
