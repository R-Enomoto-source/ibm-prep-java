# 入社前学習プロジェクト
2026年4月の入社に向けた、JavaおよびITスキルの学習リポジトリです。

## 学習目標
- **Java Silver SE 17**: 2026年2月8日 受験予定
- **App Development & DB Design**: 2026年2月9日〜3月8日
  - アプリ名: My Career Consultant／学習振り返りBot
  - 技術スタック: Cursor / Java 17 / Spring Boot 3 / PostgreSQL / Docker / Thymeleaf
  - 【重要】アーキテクチャ方針: Strategyパターン
    - AiServiceインターフェースを定義し、OpenAiServiceImplを注入
    - 将来のWatsonX移行にどう役立つかをCursorに質問して設計意図を言語化
- **AWS Certified Cloud Practitioner**: 2026年3月下旬 受験予定

## フォルダ構成
- `java_blackbook/`: Java Black Bookの演習ファイル
- `learningNote/`: 学習ノート（日付ごとの記録）
- `sukkiri_java_exercises/`: 「スッキリわかるJava」演習メモ
- `LearningTools/`: 学習補助（自動コミット・学習ノート自動作成・ドキュメント・プロジェクト設定テンプレなど）。詳細は `LearningTools/README.md` を参照。
- `GIT_WORKFLOW_GUIDE.md`: Git運用ルール・手順
- `SECURITY_CHECK.md`: セキュリティ観点のチェック項目
- `SETUP.md`: **環境構築**（.project / .classpath / .settings が無いときの初期設定）
- `LearningTools/project-setup-example/`: 上記 SETUP 用のテンプレ（.project.example, .classpath.example, .settings.example；clone 直後にルートへコピーして使用）
- `.gitignore`: 不要なファイルを管理から外す設定

## 開発・実行環境（このリポジトリの Run 時）

- **JDK 25**（.classpath の JavaSE-25 に対応）。JDK 21 を使う場合は .classpath を JavaSE-21 に変更してください。
- **Cursor / VS Code** と **Extension Pack for Java**
- ワークスペースルートの `.vscode/settings.json` で `java.configuration.runtimes` を指定

## 学習内容
- Java基礎文法の学習と実践
- Java Silver SE 17の試験対策
- 学習中に発生したエラーや疑問点の記録・解決
- Java Black Bookの章末演習
- 「スッキリわかるJava」演習の記録
- 日々の学習ログ（`learningNote/`）