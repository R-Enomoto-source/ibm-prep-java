# 練習6-2 試行錯誤と実行結果

## コンパイル時に「ファイルが見つかりません」になった例

| 実行したコマンド | カレントディレクトリ | 実行結果・原因 |
|------------------|----------------------|----------------|
| `javac Main.java` | `pre-joining-learning` | **エラー** — Main.java は `sukkiri_java_exercises\Chapter6\exercise1\` にあるため、カレントに存在しない |
| `javac sukkiri_java_exercises.Chapter6.exercise1.Main.java` | `pre-joining-learning` | **エラー** — `javac` には**ファイルパス**を渡す。ドット区切りはクラス名の書き方であって、パスではない |
| `javac sukkiri.java.exercises.Chapter6.exercise1.Main.java` | `pre-joining-learning` | **エラー** — 上と同様。パスは `\` で区切る（例: `sukkiri_java_exercises\Chapter6\exercise1\Main.java`） |
| `javac Main.java` | `sukkiri_java_exercises` | **エラー** — Main.java は `Chapter6\exercise1\` の下にあるため、やはりカレントにない |

**まとめ（コンパイル）:** ソースルート（`Chapter6` の親＝`sukkiri_java_exercises`）に移動し、**ファイルパス**で指定する必要がある。

## コンパイルに成功したコマンド

```powershell
cd C:\Users\20171\IT_Learning\pre-joining-learning\sukkiri_java_exercises
javac Chapter6\exercise1\Main.java
```

→ エラーが出ずに完了。依存する Zenhan.java / Kouhan.java もまとめてコンパイルされる。

---

## 実行時にエラーになった例

| 実行したコマンド | 実行結果・原因 |
|------------------|----------------|
| `java javac Chapter6.exercise1.Main` | **エラー** — `java` の直後は「起動するクラス名」だけを書く。`javac` がクラス名として解釈され、`ClassNotFoundException: javac` に |
| `java Chapter6\exercise1\Main` | **エラー** — 実行時は**クラス名**を指定する。パス区切り `\` は使わず、**ドット**で `Chapter6.exercise1.Main` と書く。`wrong name: Chapter6/exercise1/Main` は「パス形式で渡したためクラス名として不正」という意味 |
| `java Main.java` | **エラー** — `java` の引数は `.class` のベースとなる**クラス名**。`Main.java` というクラスは存在せず、`ClassNotFoundException: Main.java` に |

**まとめ（実行）:** 起動するのは「完全修飾クラス名」であり、フォルダパスやファイル名ではない。

## 実行に成功したコマンド

```powershell
java Chapter6.exercise1.Main
```

**実行結果（正常）:**

```
きなこでござる。食えませんがの。
この老いぼれの目はごまかせませんぞ。
えぇい、こしゃくな。くせ者だ! であえい!
飛車さん、角さん。もういいでしょう。
この紋所が目にはいらぬか!
この老いぼれの目はごまかせませんぞ。
```

---

## 覚えておくこと

| コマンド | 渡すもの | 正しい例 | 誤りがちな例 |
|----------|----------|----------|----------------|
| **javac** | コンパイルする**ファイルのパス**（`\` で区切る） | `Chapter6\exercise1\Main.java` | `Chapter6.exercise1.Main`、`Main.java`（別フォルダにいる場合） |
| **java** | 起動する**完全修飾クラス名**（`.` で区切る） | `Chapter6.exercise1.Main` | `Chapter6\exercise1\Main`、`Main.java`、`javac Chapter6.exercise1.Main` |
