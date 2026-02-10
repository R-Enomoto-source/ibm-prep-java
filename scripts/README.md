# scripts フォルダ

学習補助系のスクリプトは **LearningTools** にアプリケーションごとにまとめています。

## 移動先

| 用途 | 新しい場所 |
|------|------------|
| 自動 Git コミット・プッシュ | **LearningTools/auto-git-commit/** |
| 学習ノート自動作成 | **LearningTools/learning-note/** |

## 使い方

- **自動コミット**: タスクスケジューラで自動起動するか、手動のときは `LearningTools/auto-git-commit/auto-git-commit.ps1` を実行。`LearningTools/auto-git-commit/README.md` を参照してください。
- **学習ノート自動作成**: Cursor でフォルダを開くと、`.vscode/tasks.json` により `LearningTools/learning-note/create-learning-note.ps1` が実行されます。詳細は `LearningTools/learning-note/実現プラン_LearningNote自動作成.md` を参照してください。

このフォルダに残っているファイルは、移行前の参照用です。新規の利用は LearningTools 側を使ってください。
