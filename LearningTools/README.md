# LearningTools

学習補助系のスクリプト・設定・ドキュメントをアプリケーションごとにまとめたフォルダです。

## フォルダ構成

| フォルダ | 説明 |
|----------|------|
| **auto-git-commit/** | 自動 Git コミット・プッシュ（変更検知 → add / commit / push） |
| **learning-note/** | 学習ノートの自動作成（日付ファイルの自動作成） |
| **docs/** | 環境構築・トラブルシューティング用ドキュメント（例: PowerShell / winget エラー対処） |
| **project-setup-example/** | Eclipse / Java 用プロジェクト設定テンプレ（.project, .classpath, .settings）。clone 直後にルートへコピーして使用。 |

## ルートにある関連ファイルとの違い

リポジトリルートには、LearningTools と**役割が違う**次のファイル・フォルダがあります。

| ルートにあるもの | 役割 | LearningTools との関係 |
|------------------|------|--------------------------|
| **AUTO_GIT_COMMIT_PLAN_REVIEW.md** | 自動コミットの**設計・計画ドキュメント**（読むだけ） | 実装は `LearningTools/auto-git-commit/`。計画書はルートに1つだけ。 |
| **auto-git-commit.ps1** | **ランチャー**（中身は LearningTools のスクリプトを呼ぶだけ） | 本体は `LearningTools/auto-git-commit/auto-git-commit.ps1`。ルートから `.\auto-git-commit.ps1` で起動できるようにするため残している。 |
| **実現プラン_LearningNote自動作成.md** | 学習ノート自動作成の**計画・手順メモ** | 同じ内容を `LearningTools/learning-note/実現プラン_LearningNote自動作成.md` にも置いている。参照するなら LearningTools 側でよい。 |
| **.git-auto-commit/** | 自動コミットスクリプトが**実行時に作る**フォルダ（ログ・一時ファイル） | スクリプトがリポジトリルートに自動作成。ツールの「置き場所」ではなく、**実行結果の出力先**。 |

## 使い方

- **自動コミット**: リポジトリ直下の `auto-git-commit.ps1` を実行するか、`LearningTools/auto-git-commit/` 内の `README.md` を参照してください。
- **学習ノート自動作成**: `LearningTools/learning-note/` 内の `create-learning-note.ps1` をタスクやフォルダオープン時などから呼び出してください。詳細は同フォルダ内の実現プランを参照してください。

## 共通

- 各ツールはリポジトリルート（`.git` があるディレクトリ）を自動検出するため、このフォルダをどこに配置しても動作します。
