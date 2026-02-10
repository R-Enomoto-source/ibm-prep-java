# LearningTools セキュリティ確認メモ

**確認日**: 2026-02-10  
**対象**: `LearningTools/` 以下を Git に push してよいか

## 結論: **Git に上げて問題なし**（以下の対応後）

- パスワード・APIキー・トークン・認証情報は **含まれていません**。
- 設定ファイルは機密を含まないため、`.gitignore` の追加は不要です。
- ドキュメント内の **ローカル絶対パス**（`C:\Users\20171\...`）は、プライバシー・汎用性のため相対パス等に置き換えることを推奨しました（下記「対応した点」参照）。

---

## 確認した項目

| 項目 | 結果 |
|------|------|
| パスワード・秘密鍵の記述 | なし |
| APIキー・トークン | なし |
| `config.json`（auto-git-commit） | ポーリング間隔・ブランチ名・除外パターンのみ。機密なし |
| `config.example.local.json` | テンプレートのみ。機密なし |
| 認証まわり（credential.helper） | Git の credential store を「使う」設定のみ。資格情報はスクリプトに含まれない |
| `.gitignore` | `.git-auto-commit/`、`**/config.local.json`、`.env` 等でログ・ローカル設定を除外済み |

---

## 対応した点（プライバシー・汎用性）

- 以下のドキュメントに **Windows の絶対パス**（`C:\Users\20171\...`）が含まれていました。  
  リポジトリを他人と共有する場合に、ユーザー名が露出しないよう **リポジトリルートからの相対パス** に統一しました。
  - `auto-git-commit/起動方法.md`
  - `auto-git-commit/README.md`
  - `auto-git-commit/TEST_GUIDE.md`
  - `auto-git-commit/AUTO_GIT_COMMIT_PLAN_REVIEW.md`

---

## 運用上の注意

- **個人用・社内用**でリポジトリを限定する場合、絶対パスを残したままでもセキュリティ上の問題はありません。
- **config.local.json** に個人用のパスや設定を書く場合は、すでに `.gitignore` で除外されているため Git には上がりません。
- OCR 用の Tesseract 等は「システムにインストールする別ソフト」のため、LearningTools のファイルに秘密は含まれません。
