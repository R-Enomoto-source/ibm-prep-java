# Java実行エラーと可変長引数について - 詳細まとめ

## 1. 発生したエラー

### エラーメッセージ
```
エラー: メイン・クラスMain.javaを検出およびロードできませんでした
原因: java.lang.ClassNotFoundException: Main.java
```

### エラーの原因

**誤った実行方法：**
```bash
java Main.java
```

このエラーは、Javaが`Main.java`という名前のクラスを探そうとしたことが原因です。

## 2. Javaプログラムの実行方法

### 2.1 従来の方法（すべてのJavaバージョンで利用可能）

**ステップ1：コンパイル**
```bash
javac Main.java
```
→ `Main.class`ファイルが生成される

**ステップ2：実行**
```bash
java Main
```
→ 拡張子（`.java`や`.class`）を付けず、クラス名のみを指定

**ポイント：**
- `javac` = コンパイラ（`.java` → `.class`に変換）
- `java` = 実行環境（`.class`ファイルを実行）
- `java`コマンドでは拡張子を付けない

### 2.2 単一ファイルソースプログラム（Java SE 11以降）

Java SE 11以降では、`javac`を使わずに直接実行できます。

**環境確認：**
```bash
java -version
```
- ユーザーの環境：OpenJDK 25.0.1（Java SE 11以降の機能を使用可能）

**実行方法：**
```bash
java Main.java
```
→ `.java`拡張子を付けてファイル名を指定

**重要な注意点：**
- 正しいディレクトリにいる必要がある
- ファイルが存在するディレクトリで実行する

**解決方法：**
```bash
# 方法1：該当ディレクトリに移動してから実行（推奨）
cd sukkiri-Java-reference-code\chap00\code00-01
java Main.java

# 方法2：ルートディレクトリから相対パスを指定
java sukkiri-Java-reference-code\chap00\code00-01\Main.java
```

## 3. `String[] args` と `String... args` の違い

### 3.1 基本的な違い

Javaの`main`メソッドでは、2つの書き方が可能です：

**配列形式：**
```java
public static void main(String[] args)
```

**可変長引数形式：**
```java
public static void main(String... args)
```

### 3.2 `main`メソッドでの動作

**重要なポイント：**
- `main`メソッドでは、どちらも**機能的に同等**に動作する
- Javaの仕様で、`main`メソッドの引数として両方が許可されている
- 内部的には配列として扱われる

### 3.3 構文の違い

| 項目 | `String[] args` | `String... args` |
|------|----------------|------------------|
| **構文** | 配列の角括弧 `[]` | 3つのドット `...` |
| **意味** | 文字列の配列 | 可変長引数（varargs） |
| **mainメソッド** | ✅ 使用可能 | ✅ 使用可能 |

### 3.4 可変長引数（`String...`）とは

**定義：**
- `String... args`は、0個以上の`String`引数を受け取れることを示す
- 内部的には`String[]`として扱われる
- "可変長引数"または"varargs"と呼ばれる

**実行例：**
```bash
java Sample.java a b c
```

この場合：
- `args`は`String[]`型
- `args[0] = "a"`
- `args[1] = "b"`
- `args[2] = "c"`

### 3.5 通常のメソッドでの違い

**配列形式 `String[]` の使い方：**
```java
public void method(String[] args) {
    // 呼び出し側で配列を作成する必要がある
}

// 呼び出し
method(new String[]{"a", "b", "c"});
method(new String[0]); // 空の配列
```

**可変長引数形式 `String...` の使い方：**
```java
public void method(String... args) {
    // 呼び出し側で複数の引数を直接渡せる
}

// 呼び出し
method("a", "b", "c");  // 複数の引数を直接渡せる
method("a");             // 1つだけでもOK
method();                // 引数なしでもOK（空の配列として扱われる）
method(new String[]{"a", "b"}); // 配列でも渡せる（互換性あり）
```

### 3.6 実例コード

**配列形式の例：**
```java
public class Test1 {
    public static void printItems(String[] items) {
        for (String item : items) {
            System.out.println(item);
        }
    }
    
    public static void main(String[] args) {
        String[] fruits = {"りんご", "バナナ", "みかん"};
        printItems(fruits);
        printItems(new String[]{"コーヒー", "紅茶"});
    }
}
```

**可変長引数形式の例：**
```java
public class Test2 {
    public static void printItems(String... items) {
        for (String item : items) {
            System.out.println(item);
        }
    }
    
    public static void main(String[] args) {
        printItems("りんご", "バナナ", "みかん");
        printItems("コーヒー", "紅茶");
        printItems("パン");  // 1つだけでもOK
        printItems();        // 何も渡さなくてもOK
    }
}
```

### 3.7 可変長引数の制約

**重要な制約：**
- 可変長引数は**最後のパラメータ**でしか使用できない

```java
// ✅ OK：最後のパラメータ
public void method(String name, int... numbers) { }

// ❌ エラー：最後ではない
public void method(int... numbers, String name) { }
```

## 4. 実際の使い分け

### 4.1 `main`メソッドでの使用状況

| 形式 | 使用頻度 | 理由 |
|------|---------|------|
| `String[] args` | **圧倒的に多い** | 標準的、慣習的、歴史的経緯 |
| `String... args` | 少ない | 機能的には同等だが、慣習に合わない |

**理由：**
- Java 1.0から`String[]`が標準
- 可変長引数はJava 5（2004年）で追加された機能
- 多くの教材やコード例が`String[]`を使用
- 標準ライブラリの`main`メソッドも`String[]`を使用

### 4.2 推奨される使い分け

**`main`メソッド：**
```java
// 慣習的に配列形式を使用
public static void main(String[] args) {
    // ...
}
```

**通常のメソッド：**
```java
// 可変長引数で柔軟性と可読性を向上
public static void processItems(String... items) {
    // 呼び出し側が便利
    processItems("A", "B", "C");
}
```

### 4.3 可変長引数を使うべき場合

1. **引数の数が可変で、呼び出し側で値を直接並べたい場合**
2. **メソッドの柔軟性を高めたい場合**
3. **APIの使いやすさを重視する場合**

**良い例：**
```java
// ログを出力するメソッド
public static void log(String... messages) {
    for (String msg : messages) {
        System.out.println(msg);
    }
}

// 使い方：とても読みやすい
log("エラーが発生しました");
log("ユーザー名:", userName);
log("処理開始", "データ読み込み中", "完了");
```

```java
// 数値の合計を計算するメソッド
public static int sum(int... numbers) {
    int total = 0;
    for (int n : numbers) {
        total += n;
    }
    return total;
}

// 使い方：簡潔で読みやすい
int result1 = sum(1, 2, 3, 4, 5);
int result2 = sum(10, 20);
```

### 4.4 配列を使うべき場合

1. **`main`メソッド**（慣習）
2. **既存の配列をそのまま渡す場合**
3. **型の明確性を重視する場合**
4. **後方互換性を保つ必要がある場合**

## 5. 実践的なアドバイス

### 学習・試験
- `main`メソッドは`String[] args`を使う（標準的）
- それ以外のメソッドで可変長が適切な場合は`String...`を検討

### 実務
- チームのコーディング規約に従う
- 既存コードとの一貫性を保つ
- 可変長引数が適切な場面では積極的に使う

### 学習の進め方
- まずは`String[] args`を基本として理解する
- 可変長引数は経験を積みながら理解を深める
- 「このメソッド、引数の数を変えたい」と思ったときに可変長引数を検討する

## 6. まとめ

### 重要なポイント

1. **Javaプログラムの実行方法**
   - 従来の方法：`javac Main.java` → `java Main`
   - Java SE 11以降：`java Main.java`（単一ファイルソースプログラム）
   - 正しいディレクトリで実行することが重要

2. **`String[] args` と `String... args`**
   - `main`メソッドでは、どちらも機能的に同等
   - `String[]`が標準的で慣習的
   - `String...`は可変長引数（varargs）

3. **使い分け**
   - `main`メソッド：`String[] args`を使用（慣習）
   - 通常のメソッド：適切な場合に`String...`を使用

4. **学習方針**
   - 基本は`String[]`を理解する
   - 可変長引数は経験を積みながら習得する

## 7. 参考情報

### 使用したコード例

**基本的なMain.java：**
```java
public class Main {
  public static void main(String[] args) {
    System.out.println("Hello World");
  }
}
```

**コマンドライン引数を処理するコード：**
```java
public class Sample {
    public static void main(String... args) {
        for (String arg : args) {
            System.out.println(arg);
        }
    }
}
```

### 環境情報
- Javaバージョン：OpenJDK 25.0.1
- 単一ファイルソースプログラム機能：使用可能（Java SE 11以降）

---

# Gitの基本ワークフロー - 初学者向けガイド

## 📚 目次
1. [Gitとは何か](#gitとは何か)
2. [3つのステージングエリア](#3つのステージングエリア)
3. [基本的なワークフロー](#基本的なワークフロー)
4. [各コマンドの詳細説明](#各コマンドの詳細説明)
5. [実際の使用例](#実際の使用例)
6. [よくある質問](#よくある質問)

---

## Gitとは何か

**Git**は、ファイルの変更履歴を管理するシステムです。以下のようなことができます：

- ✅ ファイルの変更履歴を記録
- ✅ 過去の状態に戻す
- ✅ 複数人で同じプロジェクトを共同作業
- ✅ GitHubなどのリモートリポジトリにバックアップ

---

## 3つのステージングエリア

Gitには、ファイルが移動する3つのエリアがあります：

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│ ワーキング  │  →   │ ステージング  │  →   │ ローカル    │
│ ディレクトリ│      │ エリア        │      │ リポジトリ  │
│ (作業中)    │      │ (準備中)      │      │ (保存済み)  │
└─────────────┘      └──────────────┘      └─────────────┘
     ↓                      ↓                      ↓
  ファイルを編集          git add .              git commit
```

### 1. **ワーキングディレクトリ**（作業エリア）
- あなたが実際にファイルを編集する場所
- まだGitが管理していない状態

### 2. **ステージングエリア**（準備エリア）
- コミットするファイルを選ぶ場所
- `git add`でファイルをここに移動

### 3. **ローカルリポジトリ**（保存エリア）
- 変更履歴が保存される場所
- `git commit`でここに保存

---

## 基本的なワークフロー

### ステップ1: ファイルを編集
```powershell
# エディタでファイルを編集
# 例: README.mdを更新、新しいファイルを作成など
```

### ステップ2: 変更をステージングエリアに追加
```powershell
git add .
```
**意味**: すべての変更をステージングエリアに追加

### ステップ3: コミット（変更を記録）
```powershell
git commit -m "変更内容の説明"
```
**意味**: ステージングエリアの変更をローカルリポジトリに保存

### ステップ4: GitHubにプッシュ（アップロード）
```powershell
git push origin main
```
**意味**: ローカルリポジトリの変更をGitHubにアップロード

---

## 各コマンドの詳細説明

### `git add .`

#### 何をするコマンド？
- 変更したファイルを「コミットする準備ができました」とGitに伝えるコマンド
- すべての変更をステージングエリアに追加します

#### `.`（ドット）の意味
- `.` = 現在のディレクトリとその中身すべて
- つまり「このフォルダ内のすべての変更を追加」という意味

#### 他の使い方
```powershell
# 特定のファイルだけ追加
git add README.md

# 特定のフォルダだけ追加
git add learningNote/

# すべての変更を追加（.と同じ）
git add -A
```

#### 実行後の状態
```
変更前: ファイルを編集しただけ（Gitが認識していない）
変更後: Gitが「このファイルをコミットする準備ができた」と認識
```

---

### `git commit -m "変更内容の説明"`

#### 何をするコマンド？
- ステージングエリアにある変更を「確定して保存する」コマンド
- 変更履歴に「スナップショット」として記録されます

#### `-m`オプションの意味
- `-m` = message（メッセージ）の略
- その後の`"変更内容の説明"`がコミットメッセージになります

#### コミットメッセージの書き方
良い例：
```powershell
git commit -m "READMEを更新して学習目標を追加"
git commit -m "新しいJavaファイルを追加"
git commit -m "バグを修正: 計算式の誤りを修正"
```

悪い例：
```powershell
git commit -m "変更"          # 何を変更したかわからない
git commit -m "修正"          # 何を修正したかわからない
git commit -m "あああ"        # 意味がわからない
```

#### 実行後の状態
```
変更前: ステージングエリアに変更がある（まだ保存されていない）
変更後: 変更がローカルリポジトリに保存された（履歴に記録された）
```

---

### `git push origin main`

#### 何をするコマンド？
- ローカルリポジトリの変更をGitHub（リモートリポジトリ）にアップロードするコマンド
- インターネット上にバックアップを保存するイメージ

#### 各部分の意味
- `git push` = プッシュ（押し出す）コマンド
- `origin` = リモートリポジトリの名前（通常はGitHub）
- `main` = ブランチ名（メインのブランチ）

#### 実行後の状態
```
変更前: 変更はあなたのパソコンにだけある
変更後: 変更がGitHubにも保存された（他の人も見られる）
```

---

## 実際の使用例

### シナリオ: READMEファイルを更新してGitHubにアップロード

#### ステップ1: ファイルを編集
```powershell
# エディタでREADME.mdを開いて編集
# 例: 学習目標を追加、フォルダ構成を更新など
```

#### ステップ2: 変更を確認
```powershell
git status
```
**出力例:**
```
On branch main
Changes not staged for commit:
  modified:   README.md
```

#### ステップ3: 変更をステージング
```powershell
git add README.md
# または、すべての変更を追加する場合
git add .
```

#### ステップ4: コミット
```powershell
git commit -m "READMEを更新: 学習目標とフォルダ構成を追加"
```

#### ステップ5: GitHubにプッシュ
```powershell
git push origin main
```

#### 完了！
GitHubのリポジトリページで変更が確認できます。

---

## よくある質問

### Q1: `git add .`と`git add -A`の違いは？
**A:** ほぼ同じですが、微妙な違いがあります：
- `git add .` = 現在のディレクトリとその中身の変更を追加
- `git add -A` = プロジェクト全体の変更を追加（削除されたファイルも含む）

初学者の方は`git add .`で問題ありません。

---

### Q2: コミットメッセージを忘れたら？
**A:** `-m`オプションを付けずに実行すると、エディタが開きます：
```powershell
git commit
```
エディタでメッセージを書いて保存してください。

---

### Q3: 間違ったファイルを`git add`してしまった
**A:** 以下のコマンドで取り消せます：
```powershell
# ステージングエリアから取り消す（ファイルは残る）
git reset HEAD ファイル名

# すべて取り消す
git reset HEAD
```

---

### Q4: コミットしたけど、まだGitHubにプッシュしていない
**A:** 問題ありません。コミットはローカルに保存されているだけです。
プッシュするまで、GitHubには反映されません。

---

### Q5: `git push`でエラーが出た
**A:** よくある原因と対処法：

#### エラー1: "Authentication failed"
```powershell
# 認証情報を更新
git credential-manager-core erase
git push origin main
```

#### エラー2: "Updates were rejected"
```powershell
# リモートの変更を先に取得してからプッシュ
git pull origin main
git push origin main
```

---

### Q6: どのファイルが変更されたか確認したい
**A:** 以下のコマンドで確認できます：
```powershell
# 変更されたファイルの一覧
git status

# 変更内容の詳細
git diff

# ステージング済みの変更内容
git diff --staged
```

---

## 📝 まとめ

### 基本的な流れ（覚えておくこと）

```
1. ファイルを編集
   ↓
2. git add .          （変更を準備）
   ↓
3. git commit -m "説明"  （変更を記録）
   ↓
4. git push origin main   （GitHubにアップロード）
```

### 重要なポイント

1. **`git add`** = 「この変更をコミットします」と準備する
2. **`git commit`** = 「変更を確定して保存する」
3. **`git push`** = 「GitHubにアップロードする」

### 初心者向けのコツ

- ✅ コミットメッセージは具体的に書く
- ✅ 小さな変更を頻繁にコミットする（大きな変更を一度にしない）
- ✅ プッシュ前に`git status`で確認する習慣をつける
- ✅ エラーが出たら、エラーメッセージを読んで対処する

---

## 🎯 練習問題

以下のシナリオで練習してみましょう：

1. 新しいファイル`test.txt`を作成
2. `git add test.txt`で追加
3. `git commit -m "テストファイルを追加"`でコミット
4. `git push origin main`でプッシュ

これで基本的なGitワークフローをマスターできます！

---

**参考資料:**
- [Git公式ドキュメント](https://git-scm.com/doc)
- [GitHub公式ガイド](https://docs.github.com/ja/get-started)