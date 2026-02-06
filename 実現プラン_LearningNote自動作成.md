# LearningNote 自動作成の実現プラン

## やりたいこと（要件）

1. **ファイル名**: `LearningNote_yyyyMMdd.md` を1つ自動で作る（既存の `learningNote` 内の命名に合わせる）
2. **トリガー**: Cursor（VSCode）でこのフォルダを開いたときに実行
3. **条件**: その日のファイルがすでにあれば作らない

---

## ① 最良の方法の検討（案）

### 考えられる手段

| 手段 | 概要 | メリット | デメリット |
|------|------|----------|------------|
| **A. VSCode/Cursor のタスク（folderOpen）** | `.vscode/tasks.json` で `runOn: "folderOpen"` を指定し、フォルダーを開いたときにシェルスクリプトを実行 | 標準機能のみで実現可能。拡張不要。 | 初回に「自動タスクを許可」の操作が1回必要。 |
| **B. 拡張機能** | 「Auto Run Command」等の拡張で起動時にコマンド実行 | 設定が直感的な場合がある。 | 拡張のインストール・保守に依存。 |
| **C. 外部スケジューラ** | タスクスケジューラや cron で毎日決まった時刻に作成 | エディタに依存しない。 | 「Cursor を開いたとき」というトリガーと一致しない。 |

**結論（①時点）**: **A. VSCode/Cursor のタスク（folderOpen）** が、要件「Cursor を開いたら」に合致し、追加ソフト不要で実現できる最良の方法と判断。

- 実行する「中身」は **PowerShell スクリプト** が妥当（Windows でそのまま動かせる）。
- スクリプトの役割: 今日の日付で `learningNote/LearningNote_yyyyMMdd.md` を組み立て、存在しなければ新規作成（必要なら既存の LearningNote と同じヘッダー形式で初期内容を書く）。

---

## ② インターネットで情報収集後の再検討

### 調べた内容

- **VSCode の「フォルダーを開いたときにタスクを実行」**
  - `tasks.json` の `runOptions.runOn` に **`"folderOpen"`** を指定すると、そのフォルダ（またはワークスペース）を開いたときにタスクが実行される。
  - 出典: [VSCode - Run task on folder open](https://roboleary.net/vscode/2020/10/19/vscode-task-onstartup)、[Stack Overflow - Can I automatically start a task when a folder is opened?](https://stackoverflow.com/questions/34103549/can-i-automatically-start-a-task-when-a-folder-is-opened)
- **注意点**
  - 自動タスクは既定ではオフ。**「Tasks: Allow Automatic Tasks in Folder」**（または「フォルダで自動タスクを管理」）を実行し、このフォルダで「許可」する必要がある。
  - 許可後、フォルダを開くたびにタスクが実行される。

### ②の結論

- **①で選んだ「folderOpen タスク + PowerShell スクリプト」で問題なし。** 拡張機能を入れずに実現できる。
- タスクの `presentation.reveal` を **`silent`** または **`never`** にすると、毎回ターミナルが前面に出ず、利用感が良い。
- ファイル作成だけなら **`silent`** で十分。

---

## ③ 実現プラン（実施内容）

### 1. 作成・変更するファイル

| 対象 | 内容 |
|------|------|
| **`scripts/create-learning-note.ps1`** | 今日の日付（yyyyMMdd）で `learningNote/LearningNote_yyyyMMdd.md` のパスを組み立て、存在しなければ新規作成。既存の LearningNote と同じヘッダー（`# LearningNote yyyy-MM-dd`、`## セッションログ（ユーザー入力＋回答）`）を書き込む。 |
| **`.vscode/tasks.json`** | 新規作成。`runOn: "folderOpen"` のタスクを1つ定義し、上記 PowerShell を実行。`presentation.reveal`: `silent` でターミナルを目立たせない。 |

### 2. スクリプトの仕様（create-learning-note.ps1）

- **作業ディレクトリ**: リポジトリルート（スクリプトの場所から `..` で解決、または `$PSScriptRoot` の親）。
- **保存先**: `learningNote/LearningNote_yyyyMMdd.md`（既存の学習ノートと同じ）。
- **ロジック**:
  1. 今日の日付を `Get-Date -Format "yyyyMMdd"` で取得。
  2. ファイルパス `learningNote/LearningNote_<yyyyMMdd>.md` を組み立て。
  3. `Test-Path` で存在確認。存在しなければ新規作成し、上記ヘッダー2行を書き込む。既にあれば何もしない。

### 3. 利用者が行う操作（初回のみ）

1. このプロジェクトを Cursor（または VSCode）で開く。
2. コマンドパレット（`Ctrl+Shift+P`）→ **「Tasks: Allow Automatic Tasks in Folder」**（または「フォルダで自動タスクを管理」）を実行。
3. **「Allow Automatic Tasks in Folder」** を選択して許可。
4. 次回以降、このフォルダを開くたびに、その日の `LearningNote_yyyyMMdd.md` がなければ自動作成される。

### 4. 動作確認

- フォルダを一度閉じてから開き直す。
- `learningNote` フォルダに、当日の `LearningNote_yyyyMMdd.md` が存在することを確認。
- すでに同じ日付のファイルがある状態でフォルダを開き直し、内容が上書きされず既存のままであることを確認。

---

## まとめ

- **方法**: VSCode/Cursor 標準の「フォルダーを開いたときに実行するタスク」で、PowerShell スクリプトを実行する。
- **保存先**: `learningNote/LearningNote_yyyyMMdd.md`。
- **トリガー**: Cursor でこのフォルダを開いたとき（自動タスクを許可したうえで）。
- **重複防止**: スクリプト内で「その日のファイルがなければ作成」のみ行う。

以上で、①～③の検討と実現プランを満たす構成とする。
