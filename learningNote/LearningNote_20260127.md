# LearningNote 2026-01-27

## セッションログ（ユーザー入力＋回答）

### クラスファイル名とクラス名の違い（javaコマンドでクラス名を指定する理由）

ユーザー: クラスファイル名とクラス名って大体同じじゃないですか？
.classが付くかつかないかの違いじゃないんですか？
ここでは何を問題として話しているのでしょうか？

アシスタント: 画像の内容を踏まえて、「ここで何が問題として話されているか」を整理します。

#### ここで扱っている「問題」は何か

「クラスファイル名とクラス名はほぼ同じで、.class の有無だけでは？」という感覚そのものが、この節の**出発点**になっています。  
扱っているのは、その「感覚」の背景にある**設計の違い**と**仕組み**です。

#### 1. コマンドの「指定するもの」の違い

- **`javac`**  
  - 指定するのは **ソースファイル名**（例: `Main.java`）  
  - 「このファイルをコンパイルしてね」という**ファイル指定**
- **`java`**  
  - 指定するのは **クラスファイル名**（`Main.class`）ではなく **クラス名（FQCN）**（例: `Main` や `com.example.Main`）  
  - 「このクラスを起動してね」という**クラス指定**

つまり、  
「実行するときも `Main.class` のようにファイル名を指定すればいいのに、なぜわざわざクラス名を指定するのか？」  
という点が、ここで問題にされていることです。

#### 2. 「.class の有無」だけの話ではない理由

「クラス名 ≒ クラスファイル名で、.class を付けるかどうかだけ」と感じがちですが、この節で言いたいのは次のようなことです。

- **`java` は「クラス名」を渡す前提**  
  - 「どの .class ファイルか」を直接指定するのではなく、  
    「どのクラス（論理的な名前）を実行するか」を指定する。
- そこには**意図的な設計**があり、それによる「いいこと」がある、という話をしている。
- さらに、**クラス名からどうやって .class が探されるか**（クラスローダーやクラスパスによる解決の仕組み）を説明する、という流れになっている。

なので、「.class を付けるか付けないか」という表記の違いだけでなく、

- 実行時は「ファイル名」ではなく「クラス名（FQCN）」を指定する**設計になっている**
- その設計にはどんな利点があるのか
- そのクラス名が、実際にはどのように .class ファイルへと紐づけられるのか

という**しくみの話**を問題にしている、と読むとよいです。

#### 3. まとめ

ここで問題にしているのは、主に次の3点です。

1. **`javac` はファイル名、`java` はクラス名を指定する**理由の違い**
2. 実行時にクラス名（FQCN）を指定する**設計の意図・利点**（「いいこと」の中身）
3. そのクラス名から、対応する `.class` が**どう見つけられるか**という仕組み（6.4.2「クラス名だけでクラスファイルを探し出すためのしくみ」の本題）

つまり、「クラスファイル名とクラス名はほぼ同じでは？」という違和感を入口に、「実行時はあえてクラス名の世界で扱う設計になっていて、その理由と中身のしくみを説明する」というのが、この節で話している「問題」です。

### 「The import ... is never used」の意味（同じパッケージでは import が不要）

ユーザー: The import Chapter6.exercise1.Zenhan is never used
どういう意味ですか？

アシスタント: このメッセージの意味と原因を説明します。

**「The import Chapter6.exercise1.Zenhan is never used」とは**

「`import Chapter6.exercise1.Zenhan;` は**使われていない**」という警告です。  
＝ この import を削除しても動作に影響しない、不要だということです。

**なぜこうなるか**

Main.java の1行目に次のようにあります。

```java
package Chapter6.exercise1;
```

`Main` と `Zenhan` は同じパッケージ `Chapter6.exercise1` に属しています。  
Java では**同じパッケージ内のクラスは、import しなくてもクラス名だけで参照**できます。

そのため、7〜8行目の `Zenhan.doWarusa()` と `Zenhan.doTogame()` は、  
`import Chapter6.exercise1.Zenhan` がなくてもすでに認識されます。  
だから「この import は（参照の解決に）使われていない」と判断され、警告が出ています。

**どうするか**

- **警告を消したいだけなら**  
  `import Chapter6.exercise1.Zenhan;` の行を削除して問題ありません。同じパッケージなのでそのままで動きます。

- **練習6-1のルールどおりにするなら**  
  問題文では「Main はデフォルトパッケージ」「Main の先頭では Zenhan だけを import」とあり、今の構成（`package Chapter6.exercise1`）とは少し違います。  
  ルール通りにやる場合は、Main をデフォルトパッケージに置き、`comment` パッケージの Zenhan を import する形にする必要があります。

今回の警告だけの対処であれば、**`import Chapter6.exercise1.Zenhan;` を削除**すれば「never used」は解消されます。

### デフォルトパッケージにする方法（package 文の削除）

ユーザー: デフォルトパッケージに置くには、Main.javaのパッケージ文を削除すればよいですか？

アシスタント: はい、その理解で合っています。

**Main をデフォルトパッケージにするには、Main.java の先頭の `package Chapter6.exercise1;` を消します。**

`package` 宣言がないソースファイルのクラスは、すべてデフォルトパッケージ（無名パッケージ）に属します。

練習6-1のルールに合わせる場合は、次のようにすると整合が取れます。

1. **Main.java**  
   - `package` 文を削除する（デフォルトパッケージ）。  
   - 先頭で `import comment.Zenhan;` だけ行う（Zenhan は `comment` パッケージにする想定）。  
   - Kouhan も使うなら `import comment.Kouhan;` を追加するか、`Zenhan` だけ import して Kouhan は完全修飾名で呼ぶかは、問題の指示に合わせてください。

2. **Zenhan.java / Kouhan.java**  
   - 冒頭に `package comment;` を付ける。  
   - ファイルは `comment` フォルダの下に置く（例: `comment/Zenhan.java`, `comment/Kouhan.java`）。

3. **Main.java の置き場所**  
   - デフォルトパッケージなので、`comment` の外（例えば `exercise1` の直下など、クラスパスから見て「ルート」になる場所）に置く。

このとき、Main は別パッケージの Zenhan を使うので、`import comment.Zenhan;` は**必要**になり、「The import ... is never used」という警告は出なくなります。

まとめると、「デフォルトパッケージにしたい → Main.java の `package` 文を削除する」で問題ありません。

### 「declared package が expected package と一致しない」の意味

ユーザー: The declared package "" does not match the expected package "Chapter6.exercise1"
どういう意味ですか？

アシスタント: このメッセージの意味を説明します。

**「The declared package "" does not match the expected package "Chapter6.exercise1"」とは**

- **declared package ""**  
  → ソースに書いてあるパッケージが「なし」（デフォルトパッケージ）
- **expected package "Chapter6.exercise1"**  
  → ファイルの置き場所から「このクラスは `Chapter6.exercise1` パッケージのはず」と判断されている

ということで、「**中に書いたパッケージ（なし）と、フォルダから期待されるパッケージ（Chapter6.exercise1）が一致していない**」というエラーです。

**なぜ起きるか**

Javaでは、**ディレクトリ構造とパッケージ名が一致している前提**になっています。

今、`Main.java` は次のようなパスにあります：

```
sukkiri_java_exercises/Chapter6/exercise1/Main.java
```

多くのIDEやビルド設定では、  
`Chapter6/exercise1/` の下にあるソースは  
`package Chapter6.exercise1;` を持つものとして扱います。

ここでパッケージ宣言を削除してデフォルトパッケージにすると、

- 宣言: パッケージなし（""）
- 場所から期待されるもの: `Chapter6.exercise1`

となり、不一致でこのエラーになります。

**どうするか（2通り）**

**1. 今のフォルダのまま動かす（パッケージに合わせる）**

`Main.java` を `Chapter6/exercise1/` に置いたままにするなら、パッケージを戻します。

```java
package Chapter6.exercise1;

public class Main {
    // Zenhan, Kouhan は同じパッケージなので import 不要
    public static void main(String[] args) throws Exception {
        Zenhan.doWarusa();
        Zenhan.doTogame();
        Kouhan.callDeae();
        Kouhan.showMondokoro();
    }
}
```

この場合は「デフォルトパッケージ」にはしませんが、エラーは解消します。

**2. 練習どおり「Main だけデフォルトパッケージ」にする**

その場合は、**Main.java を「パッケージに対応しないフォルダ」に置く**必要があります。

例として、`Chapter6` の直下に `Main.java` だけ置く形にする場合：

- 置き場所: `sukkiri_java_exercises/Chapter6/Main.java`  
  （`exercise1` の中には置かない）
- 中身: パッケージ宣言なし + `import comment.Zenhan;` など
- Zenhan / Kouhan は `comment` パッケージにして、`Chapter6/comment/` に配置

プロジェクトの「ソースルート」が `Chapter6` なら、  
`Chapter6/Main.java` = デフォルトパッケージ、  
`Chapter6/comment/Zenhan.java` = `package comment;`  
という対応になり、期待パッケージとの不一致も起きません。

**まとめ**

- **「declared package ""」** = ファイルに書いたパッケージは「なし」
- **「expected package "Chapter6.exercise1"」** = 今のパスからは `Chapter6.exercise1` が期待されている  
→ その不一致を指しているエラーです。

- フォルダを変えずに直すなら → `package Chapter6.exercise1;` を付ける  
- Main を本当にデフォルトパッケージにしたいなら → Main.java を `Chapter6/exercise1/` の外（例: `Chapter6/` 直下）へ移動する、という対応になります。

### コンパイル失敗の原因（ターミナル確認と javac の正しい指定）

ユーザー: コンパイルできません何故でしょうか？
ターミナルを確認して教えてください

アシスタント: ターミナルを確認しました。コンパイル失敗の原因は次の2点です。

**1. 作業ディレクトリが違う**

- プロンプトは `C:\Users\20171\IT_Learning\pre-joining-learning`
- `Main.java` は  
  `sukkiri_java_exercises\Chapter6\exercise1\Main.java`  
  にある

このため、`javac Main.java` は「カレントフォルダに Main.java がない」となり、**ファイルが見つかりません**になります。

**2. クラス名をそのままファイル名にしている**

次のように打っていました：

```
javac sukkiri_java_exercises.Chapter6.exercise1.Main.java
```

- `sukkiri_java_exercises.Chapter6.exercise1.Main` は**完全修飾クラス名**（パッケージ.クラス名）
- `javac` に渡すべきなのは**ファイルのパス**であって、クラス名ではありません
- そのため、  
  「`sukkiri_java_exercises.Chapter6.exercise1.Main.java` という名前のファイル」を探して、見つからず**ファイルが見つかりません**になります

正しくは、次のような「フォルダ区切り」のパスで指定します。

- 正: `sukkiri_java_exercises\Chapter6\exercise1\Main.java`
- 誤: `sukkiri_java_exercises.Chapter6.exercise1.Main.java`

**正しいコンパイルのやり方**

`Chapter6.exercise1` というパッケージになっているので、**「Chapter6 の親フォルダ」をカレントにしてコンパイル**します。

**手順：**

1. プロジェクトのルートで次を実行して、ソースのルートに移動する：

   ```
   cd sukkiri_java_exercises
   ```

2. そこから Main を指定してコンパイルする（パスは `\` でつなぐ）：

   ```
   javac Chapter6\exercise1\Main.java
   ```

**一行で書く場合（PowerShell）：**

```
cd C:\Users\20171\IT_Learning\pre-joining-learning\sukkiri_java_exercises; javac Chapter6\exercise1\Main.java
```

- このときの「ファイルの指定」は  
  `Chapter6\exercise1\Main.java`  
  であり、**ドットではなく `\` でフォルダを区切ったパス**になっています。
- `Main` が `Zenhan` / `Kouhan` を参照しているので、それらも同じソースツリーから自動的にコンパイルされます。

コンパイルが成功すると、次の場所に `.class` ができます。

- `sukkiri_java_exercises\Chapter6\exercise1\Main.class`
- `sukkiri_java_exercises\Chapter6\exercise1\method\Zenhan.class`
- `sukkiri_java_exercises\Chapter6\exercise1\method\Kouhan.class`

**実行するとき：**

同じ `sukkiri_java_exercises` のまま、エントリポイントのクラス名で実行します。

```
java Chapter6.exercise1.Main
```

ここでは **`java` の引数は「クラス名」**なので、`Chapter6.exercise1.Main` のように**ドットでつなぐ**のが正しい指定です。

**整理**

| 場面 | 使うもの | 例 |
|------|----------|-----|
| **javac**（どのファイルをコンパイルするか） | **ファイルパス**（フォルダは `\`） | `Chapter6\exercise1\Main.java` |
| **java**（どのクラスを起動するか） | **完全修飾クラス名**（ドット） | `Chapter6.exercise1.Main` |

ターミナルでは、上のように「`cd sukkiri_java_exercises` → `javac Chapter6\exercise1\Main.java`」まで実行すれば、コンパイルエラーの原因は解消されるはずです。

### 練習6-2の試行錯誤と実行結果のまとめ

ユーザー: 私の試行錯誤と実行結果をまとめてください
PS プロジェクトルート> javac Main.java
エラー: ファイルが見つかりません: Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート> javac sukkiri_java_exercises.Chapter6.exercise1.Main.java
エラー: ファイルが見つかりません: sukkiri_java_exercises.Chapter6.exercise1.Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート> 
PS プロジェクトルート> javac sukkiri.java.exercises.Chapter6.exercise1.Main.java^C
PS プロジェクトルート> javac sukkiri_java_exercises.Chapter6.exercise1.Main.java
エラー: ファイルが見つかりません: sukkiri_java_exercises.Chapter6.exercise1.Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート> javac sukkiri.java.exercises.Chapter6.exercise1.Main.java
エラー: ファイルが見つかりません: sukkiri.java.exercises.Chapter6.exercise1.Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート> javac sukkiri_java_exercises.Chapter6.exercise1.Main.java
エラー: ファイルが見つかりません: sukkiri_java_exercises.Chapter6.exercise1.Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート> ^C
PS プロジェクトルート> ^C
PS プロジェクトルート> cd sukkiri_java_exercises
PS プロジェクトルート\sukkiri_java_exercises> javac Main.java
エラー: ファイルが見つかりません: Main.java
使用方法: javac <options> <source files>
使用可能なオプションのリストについては、--helpを使用します
PS プロジェクトルート\sukkiri_java_exercises>    javac Chapter6\exercise1\Main.java
PS プロジェクトルート\sukkiri_java_exercises> java ^C
PS プロジェクトルート\sukkiri_java_exercises> java javac Chapter6.exercise1.Main
エラー: メイン・クラスjavacを検出およびロードできませんでした
原因: java.lang.ClassNotFoundException: javac
PS プロジェクトルート\sukkiri_java_exercises> java Chapter6\exercise1\Main      
エラー: メイン・クラスChapter6\exercise1\Mainを検出およびロードできませんでした
原因: java.lang.NoClassDefFoundError: Chapter6\exercise1\Main (wrong name: Chapter6/exercise1/Main)
PS プロジェクトルート\sukkiri_java_exercises> java Main.java
エラー: メイン・クラスMain.javaを検出およびロードできませんでした
原因: java.lang.ClassNotFoundException: Main.java
PS プロジェクトルート\sukkiri_java_exercises> java Chapter6.exercise1.Main
きなこでござる。食えませんがの。
この老いぼれの目はごまかせませんぞ。
えぇい、こしゃくな。くせ者だ! であえい!
飛車さん、角さん。もういいでしょう。
この紋所が目にはいらぬか!
この老いぼれの目はごまかせませんぞ。
PS プロジェクトルート\sukkiri_java_exercises>

アシスタント: 試行錯誤と実行結果をまとめ、`exerciseExplain2.md` に「試行錯誤と実行結果」をまとめて追記しました。

#### コンパイル時に「ファイルが見つかりません」になった例

| 実行したコマンド | カレントディレクトリ | 実行結果・原因 |
|------------------|----------------------|----------------|
| `javac Main.java` | `pre-joining-learning` | **エラー** — Main.java は `sukkiri_java_exercises\Chapter6\exercise1\` にあるため、カレントに存在しない |
| `javac sukkiri_java_exercises.Chapter6.exercise1.Main.java` | `pre-joining-learning` | **エラー** — `javac` には**ファイルパス**を渡す。ドット区切りはクラス名の書き方であって、パスではない |
| `javac sukkiri.java.exercises.Chapter6.exercise1.Main.java` | `pre-joining-learning` | **エラー** — 上と同様。パスは `\` で区切る（例: `sukkiri_java_exercises\Chapter6\exercise1\Main.java`） |
| `javac Main.java` | `sukkiri_java_exercises` | **エラー** — Main.java は `Chapter6\exercise1\` の下にあるため、やはりカレントにない |

**まとめ（コンパイル）:** ソースルート（`Chapter6` の親＝`sukkiri_java_exercises`）に移動し、**ファイルパス**で指定する必要がある。

#### コンパイルに成功したコマンド

```powershell
cd sukkiri_java_exercises
javac Chapter6\exercise1\Main.java
```

（いずれもプロジェクトルートをカレントにした状態で実行。エラーが出ずに完了。依存する Zenhan.java / Kouhan.java もまとめてコンパイルされる。）

#### 実行時にエラーになった例

| 実行したコマンド | 実行結果・原因 |
|------------------|----------------|
| `java javac Chapter6.exercise1.Main` | **エラー** — `java` の直後は「起動するクラス名」だけを書く。`javac` がクラス名として解釈され、`ClassNotFoundException: javac` に |
| `java Chapter6\exercise1\Main` | **エラー** — 実行時は**クラス名**を指定する。パス区切り `\` は使わず、**ドット**で `Chapter6.exercise1.Main` と書く。`wrong name: Chapter6/exercise1/Main` は「パス形式で渡したためクラス名として不正」という意味 |
| `java Main.java` | **エラー** — `java` の引数は `.class` のベースとなる**クラス名**。`Main.java` というクラスは存在せず、`ClassNotFoundException: Main.java` に |

**まとめ（実行）:** 起動するのは「完全修飾クラス名」であり、フォルダパスやファイル名ではない。

#### 実行に成功したコマンド

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

#### 覚えておくこと

| コマンド | 渡すもの | 正しい例 | 誤りがちな例 |
|----------|----------|----------|----------------|
| **javac** | コンパイルする**ファイルのパス**（`\` で区切る） | `Chapter6\exercise1\Main.java` | `Chapter6.exercise1.Main`、`Main.java`（別フォルダにいる場合） |
| **java** | 起動する**完全修飾クラス名**（`.` で区切る） | `Chapter6.exercise1.Main` | `Chapter6\exercise1\Main`、`Main.java`、`javac Chapter6.exercise1.Main` |

### 試行錯誤まとめの格納先指定（exercise2.md）

ユーザー: ここに格納してください
C:\Users\20171\IT_Learning\pre-joining-learning\sukkiri_java_exercises\Chapter6\exercise1\exercise2.md}

アシスタント: 指定のファイルに格納しました。

**格納先:**  
`C:\Users\20171\IT_Learning\pre-joining-learning\sukkiri_java_exercises\Chapter6\exercise1\exercise2.md`

次の内容を書き出しています。

- **コンパイルで「ファイルが見つかりません」になった例**（コマンド・カレント・原因の表）
- **コンパイルに成功したコマンド**（`cd` → `javac Chapter6\exercise1\Main.java`）
- **実行でエラーになった例**（`java javac ...` / `java Chapter6\exercise1\Main` / `java Main.java` の原因）
- **実行に成功したコマンド**（`java Chapter6.exercise1.Main`）とその出力
- **覚えておくこと**（javac はファイルパス、java は完全修飾クラス名の表）

パスの末尾の `}` はファイル名の typo と判断し、`exercise2.md` に保存しています。

### 実行を一時停止するメソッド（Thread.sleep）

ユーザー: 実行を一時的に止めるメソッドを教えてください
java.lang.Thread

アシスタント: 実行を一時的に止めるメソッドは、`java.lang.Thread` の **`sleep(long millis)`** です。

#### Thread.sleep(long millis)

- **意味:** 現在のスレッドを、指定した**ミリ秒**の間だけ停止する。
- **呼び方:** `Thread.sleep(ミリ秒)`（static メソッド）
- **例:** 3秒止めるには  
  `Thread.sleep(3000);`  
  （3秒 = 3000ミリ秒）

練習6-3の「この紋所が目にはいらぬか!」の直後に3秒待つなら、`showMondokoro` メソッドで次のように書けます。

```java
System.out.println("この紋所が目にはいらぬか!");
Thread.sleep(3000);  // 3秒間待つ
```

`Thread.sleep` は `InterruptedException` を出すので、メソッドに `throws Exception` を付けるか、`try-catch` で処理する必要があります（問題では「throws Exception はこの演習では考慮しない」とあるので、`throws Exception` のままでよいです）。

### Java でデフォルトパッケージにする方法（まとめ）

（出典: `sukkiri_java_exercisesExplanation/Chapter6/デフォルトパッケージにする方法.md`）

#### デフォルトパッケージとは

- **パッケージ宣言を書かない**クラスは、自動的に「デフォルトパッケージ（無名パッケージ）」に属する。
- `package ○○;` が先頭に**ない**ソースファイルがこれに該当する。

---

#### 方法1：コード上だけでデフォルトパッケージにする（ファイルはそのまま）

**手順**

1. 該当する `.java` の**先頭の `package ...;` を削除する**（もともとなければそのままでよい）。
2. ファイルの保存場所は変えない。

**コード例（デフォルトパッケージの Main）**

```java
import Chapter6.exercise1.method.Zenhan;  // 他パッケージは import またはフル修飾で参照

public class Main {
    public static void main(String[] args) throws Exception {
        Zenhan.doWarusa();
        Zenhan.doTogame();
        Chapter6.exercise1.method.Kouhan.callDeae();
        Chapter6.exercise1.method.Kouhan.showMondokoro();
    }
}
```

**注意点**

- ファイルが `Chapter6/exercise1/Main.java` のような**サブフォルダ内**にある場合、  
  「パッケージ宣言がない」＝デフォルトパッケージなのに、**フォルダ構造は `Chapter6.exercise1` を意味する**ため、IDE が  
  **「宣言パッケージ "" が期待パッケージ "Chapter6.exercise1" と一致しません」**  
  と警告することがある。
- **「デフォルトパッケージにしたい」「ファイルの場所は変えたくない」**の両立では、この警告は避けられない。
- コンパイル・実行は、適切なカレントディレクトリとクラスパスを指定すれば可能。

---

#### 方法2：警告も出さずにデフォルトパッケージにする（ファイルを移動する）

**考え方**

- Java では「**ソースの置き場所**」と「**パッケージ名**」が一致していることを前提とする。
- デフォルトパッケージは「**パッケージ用のサブフォルダに入っていない**」状態に対応する。
- そのため、**デフォルトパッケージにしたいクラスは、プロジェクトのソースルート直下に置く**必要がある。

**手順（IDE の場合）**

1. 該当する `.java` を開く。
2. 表示されたパッケージ不一致の警告やクイックフィックスから、  
   **「Move '○○.java' to the default package」**（または同様の「デフォルトパッケージへ移動」）を選ぶ。
3. IDE が、そのクラスをソースルート直下など「デフォルトパッケージ用の場所」に移動する。
4. 必要に応じて、他クラスへの参照（import や完全修飾名）が正しいか確認する。

**手動で行う場合**

1. デフォルトパッケージにしたい `.java` を、**ソースルート（例: `sukkiri_java_exercises`）の直下**に移動する。
2. 先頭に `package ...;` が無いことを確認する。
3. 他のパッケージのクラスを参照している場合は、  
   - `import パッケージ.クラス名;` や  
   - `パッケージ.クラス名.メソッド()` などの**完全修飾名**  
   が、新しい場所からも解決できるようにする（クラスパスやプロジェクト設定の対象に、それらのパッケージが含まれていること）。

**実行時の目安**

- カレントディレクトリをソースルート（またはクラスが出ているディレクトリ）にしておく。
- 他パッケージのクラスを使う場合は、`-cp` でクラスパスを指定する。  
  例（Windows・パス区切りは環境に合わせる）:
  ```powershell
  java -cp ".;Chapter6\exercise1\method" Main
  ```

---

#### まとめ

| やりたいこと | やること | 警告 |
|--------------|----------|------|
| とにかくデフォルトパッケージにしたい | 先頭の `package ...;` を消す（ファイルはそのまま） | フォルダと不一致なら出ることがある |
| デフォルトパッケージかつ警告を出したくない | 「デフォルトパッケージへ移動」するか、ファイルをソースルート直下に手動移動 | 出ないようにできる |
| 警告を消したいが、ファイルは動かしたくない | フォルダに合わせて `package Chapter6.exercise1;` などを**付ける** | 消えるが、デフォルトパッケージではなくなる |

- **デフォルトパッケージのまま ＋ ファイルは移動しない** → 方法1。警告は「想定内」として受け入れる。
- **デフォルトパッケージのまま ＋ 警告も消したい** → 方法2でファイルを「デフォルトパッケージ用の場所」に移す。

---

#### 参考（練習6-1・6-5で出てくる構成）

- 書籍の想定では、**Main はデフォルトパッケージ**、**Zenhan / Kouhan は `comment` パッケージ**。
- その場合は、Main はソースルート直下、Zenhan / Kouhan は `comment` フォルダ配下に配置し、`java Main` で起動する形になる。
- CLASSPATH には「Main と comment の両方を探せる基準ディレクトリ」を指定する（例: `c:\javaapp\koumon`）。
