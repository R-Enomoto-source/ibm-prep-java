# LearningNote 2026-02-04

## セッションログ（ユーザー入力＋回答）

### toLowerCase と toUpperCase の使い方

ユーザー: toLowerCaseとtoUpperCaseのメソッドの使い方を教えてください

アシスタント:

Javaの`String`クラスに用意されている`toLowerCase`と`toUpperCase`メソッドの使い方です。

#### `toLowerCase()` - 小文字へ変換

文字列を**小文字**に変換します。

```java
String str = "Hello World";
String lower = str.toLowerCase();
System.out.println(lower);  // "hello world"
```

#### `toUpperCase()` - 大文字へ変換

文字列を**大文字**に変換します。

```java
String str = "Hello World";
String upper = str.toUpperCase();
System.out.println(upper);  // "HELLO WORLD"
```

#### 主なポイント

1. **元の文字列は変わらない**（`String`は不変）
   - `toLowerCase()`と`toUpperCase()`は新しい`String`を返すだけです。
   - 返り値を使わないと変換は意味を持ちません。

   ```java
   String str = "Hello";
   str.toLowerCase();      // str はそのまま "Hello"
   str = str.toLowerCase(); // str が "hello" に変わる
   ```

2. **ロケール付きのメソッド**
   - `toLowerCase(Locale locale)` / `toUpperCase(Locale locale)` で言語ごとの変換が可能です。
   - 特に指定しない場合は、システムのデフォルトロケールが使われます。

   ```java
   // 例：トルコ語など特殊な言語の場合
   String str = "TITLE";
   str.toLowerCase(Locale.ENGLISH);  // "title"
   str.toLowerCase(Locale.forLanguageTag("tr"));  // トルコ語では "tıtle" など
   ```

3. **よくある使い方**

   ```java
   // 大文字・小文字を無視して比較
   String input = "YES";
   if (input.equalsIgnoreCase("yes")) {
       // 条件成立
   }
   // または
   if (input.toLowerCase().equals("yes")) {
       // 条件成立
   }

   // ユーザー入力を正規化
   String userInput = "  Hello  ";
   String normalized = userInput.trim().toLowerCase();
   ```

---

### 円記号（¥）がターミナルでバックスラッシュで表示される問題とUnicodeエスケープでの対処

ユーザー: sukkiri_java_exercises\Chapter14\exercise1_1st\Product.java
がエスケープ記号で特殊文字をエスケープしても、具体的には、"¥¥"の形です。それでもターミナルの表示だと\\になってしまいます

アシスタント:

Product.java を確認しました。

**原因**
日本語環境では、**円記号「¥」とバックスラッシュ「\」が同じバイト（0x5C）**として扱われることがあります。そのため、ソースに `"¥¥"` と書いても、Java はそれを `"\\"`（＝表示上は `\` 1つ）として解釈し、ターミナルには `\` しか出ていません。

**修正内容**
円記号を **Unicode エスケープ `\u00A5`** で指定するように変更しました。`\u00A5` は「¥」（U+00A5）を表すため、**ファイルの文字コードや環境に依存せず、常に円記号「¥」が表示**されます。

```java
return "\u00A5" + this.price + "(商品コード:" + this.productCode + ")";
```

この状態で実行すると、`¥100(商品コード:xxx)` のように円記号付きで表示されるはずです。

---

### メソッドチェーン（StringBuilder と「自身を返す」設計）の解説

ユーザー: メソッドチェーン自体を分かりやすく、一つ一つ丁寧に解説してください

アシスタント:

メソッドチェーンを、順を追って説明します。

#### 1. メソッドチェーンとは

**「メソッドの戻り値に対して、続けて別のメソッドを呼び出す書き方」**のことです。

```java
sb.append("hello").append("java").append("world");
```

のように、`.append(...)` を何度も続けて書けるのがメソッドチェーンです。

#### 2. なぜこんな書き方ができるのか

ポイントは **「メソッドが何を返すか」** です。

**普通のメソッド（void）の場合**

多くの「追加するだけ」のメソッドは、戻り値が `void` です。

```java
// 仮に append が void だったら…
sb.append("hello");   // ここで終わり。何も返さない
sb.append("java");    // 別の行でまた呼ぶ必要がある
sb.append("world");
```

`void` は「何も返さない」ので、その後に `.append(...)` とは続けられません。

**StringBuilder の append の場合**

`StringBuilder` の `append` は **「このオブジェクト自身（sb）への参照」** を返します。

- メソッド宣言のイメージ: `public StringBuilder append(String s)`
- 戻り値: **このオブジェクト（sb）そのもの**

だから、

1. `sb.append("hello")`  
   → バッファに `"hello"` が追加され、**sb が返る**
2. 返ってきた sb に対して `.append("java")`  
   → `"java"` が追加され、また **sb が返る**
3. さらにその sb に対して `.append("world")`  
   → `"world"` が追加され、また **sb が返る**

と、**同じオブジェクトが返り続ける**ので、そのまま次のメソッドを続けて呼べます。これがメソッドチェーンです。

#### 3. 実行の流れを分解する

```java
StringBuilder sb = new StringBuilder();
sb.append("hello").append("java").append("world");
```

を、左から順に考えると次のようになります。

| ステップ | コード | 何が起きているか |
|---------|--------|------------------|
| ① | `sb` | いまの sb を指している |
| ② | `sb.append("hello")` | sb に `"hello"` を追加し、**sb 自身**を返す |
| ③ | `sb.append("hello").append("java")` | ②で返った sb に `"java"` を追加し、また **sb** を返す |
| ④ | `...append("world")` | ③で返った sb に `"world"` を追加し、**sb** を返す |

つまり、

- 毎回「**自分自身（sb）を返す**」から
- 返ってきたものに対して、また `.append(...)` を呼べる
- それを繰り返すと、1行で何度も `append` を続けられる

という仕組みです。

#### 4. 設計の意図

「文字を追加するだけなら `void` で十分」ですが、**「自分自身を返す」**ようにしておくことで、

- 1行で複数回の操作を書ける（メソッドチェーン）
- コードが短く読みやすくなる

というメリットが得られます。  
つまり、**チェーンしやすいように意図して設計されている**と言えます。

#### 5. まとめ

- **メソッドチェーン** = メソッドの戻り値に対して、続けてメソッドを呼ぶ書き方。
- **ポイント** = `append` が「オブジェクト自身」を返すから、`.append(...).append(...)` と続けられる。
- **イメージ** = 「自分自身を返す」→「返ってきた自分にまたメソッドを呼ぶ」の繰り返し。

参考書の図では、この「**自身への参照を返す**」部分がメソッドチェーンの核心として説明されています。ここを押さえると、他のクラスでメソッドチェーンが使われているコードも読みやすくなります。

---

### メソッドチェーンの利点

ユーザー: メソッドチェーンの利点も教えてください

アシスタント:

メソッドチェーンの主な利点を整理します。

#### 1. コードが短く・読みやすくなる

**チェーンなし（同じ処理）：**
```java
StringBuilder sb = new StringBuilder();
sb.append("こんにちは");
sb.append("、");
sb.append("Java");
sb.append("の世界へ");
```

**チェーンあり：**
```java
StringBuilder sb = new StringBuilder();
sb.append("こんにちは").append("、").append("Java").append("の世界へ");
```

- 行数が減る
- 「このオブジェクトに次々と追加している」という流れが1行で分かる

#### 2. 中間変数が不要になる

戻り値をまた使う場合に、わざわざ変数に代入しなくてよくなります。

**チェーンなし：**
```java
StringBuilder sb = new StringBuilder();
sb = sb.append("A");
sb = sb.append("B");
sb = sb.append("C");
String result = sb.toString();
```

**チェーンあり：**
```java
String result = new StringBuilder()
    .append("A")
    .append("B")
    .append("C")
    .toString();
```

「作って → 追加して → 文字列にする」という一連の処理がそのまま読めます。

#### 3. 処理の流れが「左から右」で追いやすい

チェーンは「何をしているか」の順番がそのままコードの並びになります。

```java
new StringBuilder()
    .append("名前: ")
    .append(name)
    .append(", 年齢: ")
    .append(age)
    .toString();
```

「名前を足して → 年齢を足して → 文字列にする」という流れが、上から下（左から右）で追いやすいです。

#### 4. 一時変数の削減でミスが減る

変数が少ないと、

- 代入し忘れ
- 違う変数を触ってしまう

といったミスが起きにくくなります。  
チェーンなら「返ってきたオブジェクトにそのままメソッドを呼ぶ」だけなので、変数の取り違えが少なくなります。

#### 5. フルーエントAPI（流暢なAPI）の実現

「読みやすい英文のように書けるAPI」をフルーエントAPIといい、メソッドチェーンはその典型です。

```java
// 「ビルダーで、Aを追加して、Bを追加して、ビルする」と読める
SomeObject obj = new SomeBuilder()
    .setName("太郎")
    .setAge(20)
    .setEmail("taro@example.com")
    .build();
```

`Builder` パターンなどでも、この「自分自身を返す」設計がよく使われます。

#### まとめ

| 利点 | 内容 |
|------|------|
| **簡潔さ** | 行数が減り、同じ処理を1行で書ける |
| **可読性** | 処理の流れが左から右（上から下）で追いやすい |
| **中間変数の削減** | 代入用の変数が不要になり、ミスが減る |
| **フルーエントなAPI** | メソッドを続けて呼ぶだけで、自然な流れで書ける |

「**自分自身を返す**」という設計が、これらの利点を支えています。

---

## 学習メモ（equals・toString・エスケープなど）

自作クラスで `equals()` や `toString()` をオーバーライドする際に押さえておく知識を、**別の例**で整理したメモです。

### 知識1: エスケープシーケンス

#### ポイント
文字列リテラル内で、特殊な文字（円記号、バックスラッシュ、ダブルクォートなど）をそのまま出したいときは**エスケープシーケンス**を使う。

#### 主なエスケープシーケンス
- `\\` → `\` を表示
- `\"` → `"` を表示
- `\n` → 改行
- `\t` → タブ  
（環境によっては円記号も `\` や `¥` でエスケープする）

#### 例
```java
System.out.println("名前は \"太郎\" です");   // 名前は "太郎" です
System.out.println("1行目\n2行目");           // 改行されて2行で表示
```

#### 覚え方
「文字列の中で特殊文字を出したい → エスケープシーケンスを使う」

---

### 知識2: equals() の目的と使い方

#### ポイント
`equals()` は**同じクラスのインスタンス同士**が「等しいか」を判定するためにオーバーライドする。

#### なぜ同じクラス同士か
- 「このオブジェクトとあのオブジェクトが等しいか」を判定するメソッドだから。
- 異なるクラス（例：自作の `Member` と `String`）を「等しい」と扱う意味はない。

#### 正しいパターン（イメージ）
```java
public boolean equals(Object o) {
    if (this == o) {
        return true;
    }
    if (o instanceof Member m) {   // 同じクラスかチェック
        return this.memberId.trim().equals(m.memberId.trim());
    }
    return false;
}
```

#### 覚え方
「equals() は同じクラス同士を比較する → instanceof でクラスをチェックする」

---

### 知識3: instanceof 演算子

#### ポイント
オブジェクトが**特定のクラスのインスタンスかどうか**を判定する演算子。

#### 構文
```java
オブジェクト instanceof クラス名
```

#### 例
```java
Object obj = new Member();
if (obj instanceof Member) {   // true
    // Member として扱える
}
if (obj instanceof String) {   // false
    // String ではない
}
```

#### パターンマッチング（Java 16 以降）
```java
if (o instanceof Member m) {
    // この中で m として Member 型で使える
    return this.memberId.equals(m.memberId);
}
```

#### 覚え方
「instanceof は型チェック → equals() では『同じクラスか』をチェックする」

---

### 知識4: String の不変性と trim()

#### ポイント
Java の `String` は**不変**。`trim()` は**新しい文字列を返す**だけで、元の文字列は変わらない。

#### 間違いやすい例
```java
String s = "  ABC  ";
s.trim();   // ❌ s はそのまま "  ABC  "
```

#### 正しい使い方
```java
String s = "  ABC  ";
String t = s.trim();   // ✅ 戻り値を変数に代入
// t が "ABC"、s は "  ABC  " のまま
```

#### 覚え方
「String は不変 → trim() は新しい文字列を返す → 戻り値を変数に代入する」

---

### 知識5: == と equals() の違い

#### ポイント
- **`==`** … 参照が同じか（同じインスタンスを指しているか）。プリミティブなら値の比較。
- **`equals()`** … 中身（値）が等しいか。オブジェクトの「意味的な一致」のときに使う。

#### 例
```java
String a = new String("OK");
String b = new String("OK");
a == b;        // false（別インスタンス）
a.equals(b);   // true（内容は同じ）
```

#### equals() メソッド内での使い分け
- `this == o` … 同じインスタンスなら無条件で true（最適化）。
- そのあと `instanceof` で型を確認し、**フィールド同士は `equals()` で比較**する。

#### 覚え方
「== は参照の比較、equals() は値の比較 → メソッド内では両方を使い分ける」

---

### 知識6: equals() の標準的な流れ

#### よくある3ステップ
1. **自分自身** … `this == o` なら true を返す。
2. **型チェック** … `o instanceof 自分のクラス` で、同じクラスか判定。
3. **フィールド比較** … 同じクラスなら、等価の条件になるフィールドを比較（必要なら trim してから比較）。

#### パターンマッチングを使った書き方（Java 16 以降）
```java
public boolean equals(Object o) {
    if (this == o) {
        return true;
    }
    if (o instanceof Member m) {
        String id1 = this.memberId.trim();
        String id2 = m.memberId.trim();
        return id1.equals(id2);
    }
    return false;
}
```

#### 覚え方
「equals() の流れ：1. 自分自身 2. 型チェック 3. フィールド比較」

---

### 初学者向け：equals() を1行ずつ追う

以下は、**あるクラス（ここでは Member、フィールドは memberId）**で「ID が等しければ等価（前後空白は無視）」とする equals() のイメージです。

```java
public boolean equals(Object o) {
   if (this == o) {
     return true;
   }
   if (o instanceof Member m) {
     String id1 = this.memberId.trim();
     String id2 = m.memberId.trim();
     if (id1.equals(id2)) {
       return true;
     }
   }
   return false;
}
```

#### 流れの整理
1. `this == o` … 同じインスタンスなら true で終了。
2. `o instanceof Member m` … 同じクラスでなければ、このブロックには入らない。
3. 同じクラスなら、比較用フィールド（ここでは memberId）を trim したもの同士を `equals()` で比較。
4. 一致したら true、そうでなければブロックを抜けて最後の `return false` に到達。

---

### なぜ else を書かずに return false にするか

#### 理由
- **return した時点でメソッドが終わる**ので、「そうでないとき」を表すために `else` は必須ではない。
- **早期 return** のスタイルにすると、「true になる条件を上で return し、どれにも当てはまらなければ最後に false」と一方向に読める。

#### else を付けた場合のイメージ
```java
if (this == o) {
  return true;
} else if (o instanceof Member m) {
  // ...
  return id1.equals(id2) ? true : false;
} else {
  return false;
}
```
動きは正しくても、`return false` が複数箇所に分かれ、ネストが深くなりがち。

#### 可読性
- **else なし** … 短く、ネストが浅く、「最後に1回だけ return false」でまとまる。
- **else あり** … 論理的には正しいが、長くなり、どの分岐で false になるか追いにくくなることが多い。

---

### まとめ

1. **エスケープシーケンス** … 文字列内で特殊文字を出すときはエスケープする。
2. **equals() の目的** … 同じクラスのインスタンス同士の「等価」を定義する。
3. **instanceof** … 型チェック。equals() では「同じクラスか」の判定に使う。
4. **String の不変性** … trim() の戻り値は必ず変数に代入して使う。
5. **== と equals()** … == は参照、equals() は値（内容）の比較。
6. **equals() の流れ** … 自分自身 → 型チェック → フィールド比較。

以上は、クラス名やフィールド名を別のものに置き換えても同じ考え方で使える一般的なメモです。

---

### 理解度テストで間違えたところから学ぶポイント

理解度確認テストの採点結果をもとに、**今後間違えないための知識**を整理したメモです。

#### ポイント1：クラス名のスペルミス

**起きたこと**  
自作クラス名を1文字間違えて書いた（例：`Acount` のように `c` が足りない）。

**なぜ重要か**  
- クラス名のスペルが1文字違うだけで**コンパイルエラー**になる
- 存在しないクラス名を `instanceof` に書くと動かない
- IDE があれば補完されるが、手書きや試験では自分で確認する必要がある

**対策**  
よく使うクラス名は綴りを覚えておく。書いたあとは必ず見直す。

---

#### ポイント2：equals() の3ステップは「正しい用語」で答える

**起きたこと**  
内容は合っているのに、用語の選び方で部分点になった。

**求める用語と意味**

| ステップ | 求める答え | 注意すること |
|----------|------------|--------------|
| 1 | **自分自身**（または「this と o」） | 「参照の比較」や「==」は手段であり、ステップの名前ではない。引数は小文字 `o` |
| 2 | **型**（または「クラス」） | 「キャストできるか」は結果。チェックの**目的**は「型が合っているか」 |
| 3 | **フィールド**（または比較対象の名前） | 「値」よりも「オブジェクトが持つフィールド」と答える方が正確 |

**覚えるフロー**

1. 自分自身との比較 → 同じなら true
2. 型チェック → 違う型なら false
3. フィールドの比較 → 中身が等しいか判定

---

#### ポイント3：equals() のコードは「最後まで書く」

**起きたこと**  
修正の流れは合っているが、冒頭の「自分自身との比較」と、最後の `return false` が抜けていた。

**なぜ重要か**  
`equals()` は boolean を返すので、**すべての分岐で return する**必要がある。

**忘れやすい箇所**

| 箇所 | 役割 | 忘れたときの影響 |
|------|------|------------------|
| 冒頭の `if (this == o) return true` | 同じインスタンスなら無駄な処理を省く | 動作はするが、自分自身との比較で余分な処理が走る |
| 最後の `return false` | どの条件にも当てはまらないときに false | **コンパイルエラー**（return のないパスが残る） |

**対策**  
equals() を書いたら、true を返すケースと false を返すケースの両方がカバーされているか確認する。

---

#### ポイント4：「場所」ではなく「利点・意図」を答える

**起きたこと**  
「return false はどこに書く？」と「return false を最後に1回にまとめる利点は？」を混同し、場所の説明だけで答えた。

**問い方ごとの違い**

| 聞かれ方 | 答えるべきこと |
|----------|----------------|
| 「return false はどこに書く？」 | **場所**（例：if の一番外側の直下） |
| 「return false を1回にまとめる利点は？」 | **意図・利点**（例：分散せず1か所で済むので、false を返す条件が分かりやすい） |

**利点の答え方のコツ**  
else を書かないと、どの if にも当てはまらなかったときに**最後に1回だけ** false を返すようにできる。利点は「false を返す条件が1か所に集約され、読みやすい」と説明する。

**覚えること**  
「利点」「理由」「なぜ」と聞かれたら、**場所や手順**ではなく、**その書き方によって得られる効果**を答える。

---

#### まとめ：次回のテストで気を付けること

1. **クラス名のスペル**：よく使う単語は正確に書く
2. **用語の選択**：equals() の3ステップは「自分自身」「型」「フィールド」で覚える
3. **コードの網羅性**：equals() を書いたら `if (this == o)` と `return false` を忘れていないか確認
4. **問題の意図を読む**：「利点」「理由」を聞かれたら、効果・意図を答える
