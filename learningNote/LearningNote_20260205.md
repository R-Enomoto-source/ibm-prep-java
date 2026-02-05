# LearningNote 2026-02-05

## セッションログ（ユーザー入力＋回答）

### Calendar の set の月の0始まり・表示形式・getTime() の役割

ユーザー: 何故下記のコードを実行すると、下記が表示されるのでしょうか？
特に1行目がなぜこうなるのかが分かりません。
    c.set(2023,8,18,5,53,20);　この順番での表示が出来ていないですし、曜日など指定していないものも表示されていますよね。

また、Date d = c.getTime();が何をしているのかいまいちわかりません。
Cの日付情報をDate型のdに代入しているのでしょうか。
それ以外は理解できていると思います。
分かりやすく一つ一つ丁寧に詳細に教えてください

【コード】
import java.util.Calendar;
import java.util.Date;
public class Main {
  public static void main(String[] args) {
    Calendar c = Calendar.getInstance();
    // 6つのint値からDateインスタンスを生成
    c.set(2023,8,18,5,53,20);
    c.set(Calendar.MONTH, 9);     /* 月を9（10月）に変更 */
    Date d = c.getTime();
    System.out.println(d);
    // Dateインスタンスからint値を生成
    Date now = new Date();
    c.setTime(now);
    int y = c.get(Calendar.YEAR);  /* 年を取り出す */
    System.out.println("今年は" + y + "年です");
  }
}
【実行結果】
Wed Oct 18 05:53:20 JST 2023
今年は2026年です

アシスタント:

#### 1. なぜ「Wed Oct 18 05:53:20 JST 2023」と表示されるか

**月は「0始まり」であること**

`Calendar` の **月は 0 から 11** です。

- `0` = 1月
- `1` = 2月
- …
- `7` = **8月**
- `8` = **9月**
- `9` = **10月**

なので、

```java
c.set(2023, 8, 18, 5, 53, 20);
```

は次の意味になります。

- 年: 2023
- 月: **8 → 9月**（8月ではない）
- 日: 18
- 時: 5
- 分: 53
- 秒: 20

その直後に

```java
c.set(Calendar.MONTH, 9);  // 月を9（10月）に変更
```

で月を **9（10月）** に上書きしているので、最終的な日時は **2023年10月18日 05:53:20** です。表示の「Oct 18 05:53:20 … 2023」は、この日時そのものです。

**曜日（Wed）はどこで決まるか**

曜日は **指定していなくても、日付から一意に決まります**。2023年10月18日は水曜日なので、`Date` を文字列にしたときに「Wed」と出ています。`Calendar` / `Date` は内部で「その日付＝その曜日」として持っているだけです。

**表示の順番が「2023,8,18,5,53,20」と違う理由**

`set` に渡した順番は「どの値を何番目の引数で渡したか」というだけで、**表示形式**とは無関係です。`System.out.println(d)` では `Date` の `toString()` が使われ、`Date` のデフォルト表示は **「曜日 月 日 時:分:秒 タイムゾーン 年」** という形式で固定されています。そのため、「年,月,日,時,分,秒」の順では表示されません。中身の「時刻」はあなたの設定どおりで、表示の並びだけが `Date` の仕様です。

---

#### 2. `Date d = c.getTime();` は何をしているか

その理解で合っています。**「Calendar が持っている日時を、同じ瞬間を表す `Date` に変換して、変数 `d` に代入している」** です。

- `Calendar` … 年・月・日・時・分・秒などを **バラで持つ** 型。
- `Date` … **ある一瞬の時刻**（内部では「1970年1月1日 00:00:00 UTC からのミリ秒」の `long`）を表す型。

`c.getTime()` は「今の `Calendar` の内容（2023年10月18日 05:53:20 など）が表すその瞬間」を `Date` で返します。なので、`c` に `set` で設定した日時と `d` が表す日時は **同じ瞬間** です。型が `Calendar` から `Date` に変わるだけです。

---

#### 3. まとめ（コードの流れ）

| 行 | 内容 |
|----|------|
| `c.set(2023,8,18,5,53,20)` | 2023年**9月**18日 05:53:20 をセット（月の 0 始まりのため 8=9月） |
| `c.set(Calendar.MONTH, 9)` | 月だけ 10月 に変更 → **2023年10月18日 05:53:20** になる |
| `Date d = c.getTime()` | その瞬間を `Date` に変換して `d` に代入 |
| `System.out.println(d)` | `Date` のデフォルト形式で表示 → 「Wed Oct 18 05:53:20 JST 2023」 |
| `Date now = new Date()` | **今**の日時を取得（実行した日＝2026年） |
| `c.setTime(now)` | カレンダーを「今」に合わせる |
| `c.get(Calendar.YEAR)` | その「今」の年を取り出す → 「今年は2026年です」 |

「1行目」の表示は、月の 0 始まり（8→9月、そのあと 9→10月）、曜日は日付から自動、表示順は `Date.toString()` の仕様、の3点で説明できます。

---

### getTime() と setTime() の基本（Calendar と Date）

ユーザー: getTime()とsetTimeの基本を分かりやすく詳細に一つ一つ丁寧に教えてください

アシスタント:

#### getTime() と setTime() の基本

Java では **Calendar** と **Date** の両方に `getTime()` / `setTime()` がありますが、役割が違います。整理して説明します。

---

#### 1. 前提：Calendar と Date の違い

| 種類 | 役割 | 中身のイメージ |
|------|------|----------------|
| **Calendar** | 日付を「年・月・日・時・分・秒」のように**バラで扱う** | フィールドの集まり（YEAR, MONTH, DAY...） |
| **Date** | 「ある一瞬の時刻」を**1つの値**で表す | 1970-01-01 00:00:00 UTC からの**ミリ秒数**（long） |

- **Calendar** … 人間向けの「年月日」で操作したいときに使う
- **Date** … 内部では「ミリ秒」1本で持っている

この2つを**行き来する**ためのメソッドが `getTime()` と `setTime()` です。

---

#### 2. Calendar の getTime()

**何をするメソッドか**

**「この Calendar が表している日時を、同じ瞬間を表す Date に変換して返す」** メソッドです。

- **誰のメソッドか**: `Calendar` のインスタンスメソッド
- **戻り値**: `Date`
- **引数**: なし

**イメージ**

```
Calendar c  …  「2023年10月18日 5時53分20秒」を
               年=2023, 月=9, 日=18, 時=5, 分=53, 秒=20 として保持

c.getTime() …  その「同じ瞬間」を Date で返す
               → Date は中身は「その瞬間のミリ秒数」1つ
```

**コード例**

```java
Calendar c = Calendar.getInstance();
c.set(2023, 9, 18, 5, 53, 20);   // 2023年10月18日 05:53:20

Date d = c.getTime();   // 「その瞬間」を Date に変換
System.out.println(d);  // Wed Oct 18 05:53:20 JST 2023
```

- `c` は「年月日時分秒」の情報を持っている
- `c.getTime()` で「その時刻」を **Date 型** で取り出している
- だから「Calendar の日付情報を Date 型の変数に代入している」という理解で合っています。

**いつ使うか**

- Calendar で組み立てた日時を、**Date を引数に取る API** に渡したいとき
- Calendar の日時を **1本の「時刻」として** 扱いたいとき
- `System.out.println` で Date の表示形式で出したいとき（上記のように）

---

#### 3. Calendar の setTime(Date)

**何をするメソッドか**

**「渡した Date が表す瞬間を、この Calendar の「今の日時」としてセットする」** メソッドです。

- **誰のメソッドか**: `Calendar` のインスタンスメソッド
- **戻り値**: なし（void）
- **引数**: `Date` を1つ

**イメージ**

```
Date now = new Date();   …  「今」の瞬間（例: 2026年2月5日 12:00:00）を表す Date

c.setTime(now);          …  Calendar c の「現在の日時」を、
                            その「今」の瞬間に合わせる
                            → c の年・月・日・時・分・秒がすべて「今」になる
```

- **getTime()** が「Calendar → Date」（Calendar の内容を Date で取り出す）
- **setTime()** が「Date → Calendar」（Date の時刻を Calendar に書き込む）
と覚えると対になっています。

**コード例**

```java
Date now = new Date();      // 今の日時（例: 2026年2月5日）
Calendar c = Calendar.getInstance();

c.setTime(now);             // c の内容を「今」に合わせる

int y = c.get(Calendar.YEAR);   // 年を取り出す → 2026
int m = c.get(Calendar.MONTH);  // 月（0始まり） → 1（2月）
```

- `now` は「今」という**一瞬**を表す Date
- `c.setTime(now)` で、Calendar `c` の内部を「その一瞬」に更新
- その後は `c.get(Calendar.YEAR)` などで「年・月・日」をバラで取り出せる

**いつ使うか**

- **Date で得た「ある瞬間」** から、**年・月・日・曜日など** を取り出したいとき
- ファイルの更新日時（Date）を Calendar にセットして、日だけ比較したいとき など

---

#### 4. Date の getTime()（参考）

**Date** にも `getTime()` があります。こちらは意味が違います。

- **役割**: その Date が表す瞬間を **long（ミリ秒）** で返す
- **戻り値**: `long`（1970年1月1日 00:00:00 UTC からのミリ秒）

```java
Date d = new Date();
long ms = d.getTime();   // 例: 1738732800000 のような数値
```

- **Calendar.getTime()** → Date を返す（Calendar を Date に変換）
- **Date.getTime()** → long を返す（Date をミリ秒に変換）
名前は同じでも「誰の getTime() か」で戻り値が違うので注意です。

---

#### 5. 対応関係のまとめ

| メソッド | 呼ぶ側 | 引数 | 戻り値 | 意味 |
|----------|--------|------|--------|------|
| **getTime()** | Calendar | なし | **Date** | 「この Calendar の日時」を Date で取り出す |
| **getTime()** | Date | なし | **long** | 「この Date の瞬間」をミリ秒で取り出す |
| **setTime(Date)** | Calendar | Date | void | この Calendar の日時を、渡した Date の瞬間にセットする |
| **setTime(long)** | Date | long | void | この Date の瞬間を、渡したミリ秒にセットする |

---

#### 6. 一連の流れの例

```java
// 【Calendar → Date】Calendar で作った日時を Date で取り出す
Calendar c = Calendar.getInstance();
c.set(2023, 9, 18, 5, 53, 20);
Date d = c.getTime();        // getTime: Calendar の内容を Date に変換

// 【Date → Calendar】「今」を Date で取得し、Calendar にセットしてバラで使う
Date now = new Date();
c.setTime(now);              // setTime: Date の「今」を Calendar に書き込む
int year = c.get(Calendar.YEAR);
```

- **getTime()** … Calendar の「日付情報」を Date（または Date の場合は long）に**取り出す**
- **setTime()** … 外から渡した Date（または long）の時刻を、その Calendar（または Date）に**書き込む**

この「取り出す / 書き込む」と「Calendar ⇔ Date」の対応を押さえると、基本はバッチリです。

---

### メソッド引数の修飾子エラー（static/private は不可）

ユーザー: Illegal modifier for parameter ST_NUM; only final is permitted
意味だけ教えてください

アシスタント:

このエラーの意味は次のとおりです。

**「引数（パラメータ）ST_NUM には不正な修飾子が付いています。引数に使える修飾子は final だけです」**

つまり、

- **メソッドやコンストラクタの引数**には、修飾子をつけるなら **`final` だけ**が許されます。
- `static` や `public`、`private` などを引数に付けると、このエラーになります。

例（エラーになる書き方）:
```java
void method(static int ST_NUM) { ... }   // static は引数に不可
void method(public int ST_NUM) { ... }   // public も不可
```

正しい書き方の例:
```java
void method(int ST_NUM) { ... }         // 修飾子なし OK
void method(final int ST_NUM) { ... }   // final のみ OK
```

`ST_NUM` が「定数」なら、引数ではなく **クラスやメソッド内の定数（`static final` など）** として別に宣言する必要があります。

---

### メソッド内のローカル変数に static/private は使えない

ユーザー: Illegal modifier for parameter ST_NUM; only final is permitted
@exerseise1_1st_Main.java (1-16) 
引数にはしていないと思うのですが

アシスタント:

確認しました。`ST_NUM` は引数ではなく、`main` メソッド**の中**で宣言した**ローカル変数**です。

- **ローカル変数**（メソッド内の変数）に付けられる修飾子は **`final` だけ**です。
- `static` と `private` は**クラスのフィールド**用の修飾子で、メソッド内の変数には使えません。

そのため `static private final int ST_NUM` のように書くと、コンパイラが修飾子の組み合わせを解釈する過程で「引数に不正な修飾子」というメッセージを出していると考えられます。

**修正内容**

メソッド内の定数なので、`static` と `private` を外して `final int ST_NUM = 1;` にしました。これでコンパイルは通るはずです。

クラス全体で使う定数にしたい場合は、`main` の外でクラスのフィールドとして宣言します。

```java
public class exerseise1_1st_Main {
    private static final int ST_NUM = 1;  // クラスの定数
    private static final int EN_NUM = 100;

    public static void main(String[] args) {
        // ...
    }
}
```

---

### StringBuilder の append で int を直接渡せる理由

ユーザー: @exerseise1_1st_Main.java (12-13) 
ここのiはvalueofで変換しなくてもよいのですか？

アシスタント:

**変換しなくて大丈夫です。**

`StringBuilder` の `append` は**引数の型ごとにオーバーロード**されています。

- `append(int i)` … int をそのまま受け取り、内部で文字列にして追加する
- `append(String str)` … 文字列を追加する
- その他、`long`、`boolean`、`char` なども同様

なので、

```java
s.append(i);  // int の i をそのまま渡してOK
```

と書けば、コンパイラが `append(int)` を選び、中で文字列に変換してから追加してくれます。

明示的に書くなら次のどちらでも同じ結果になります。

```java
s.append(i);                    // このままでOK
s.append(String.valueOf(i));   // わざわざ書く必要はない
```

**結論:** `i` を `valueOf` で変換する必要はなく、`s.append(i)` のままで問題ありません。

---

### StringBuilder に split メソッドはない

ユーザー: The method split(String) is undefined for the type StringBuilder
意味だけ教えてください

アシスタント:

**意味：**  
「`StringBuilder` 型には `split(String)` メソッドは定義されていません」

**補足：**  
`split(...)` は **`String` クラス**のメソッドで、**`StringBuilder` にはありません**。

`StringBuilder` の内容を `split` したい場合は、いったん `String` に変換してから呼びます。

```java
StringBuilder s = new StringBuilder("a,b,c");
String[] parts = s.toString().split(",");  // toString() で String にしてから split
```

---

### メソッドが見つからないエラー

ユーザー: The method concatenateFolderAndFile(String, String) is undefined for the type Exercise2_1st_MainJava(67108964)
意味だけ教えてください

アシスタント:

**意味：**  
「`Exercise2_1st_Main` 型には、`concatenateFolderAndFile(String, String)` というメソッドが定義されていません」

**つまり：**  
`Exercise2_1st_Main` のインスタンスやクラスに対して  
`concatenateFolderAndFile(文字列1, 文字列2)` を呼んでいるが、そのクラスにはそんな名前・引数のメソッドがない、というエラーです。

**よくある原因：**  
- `concatenateFolderAndFile` が **別のクラス**（例：`Exercise2_1st_Concat`）にだけ定義されている  
- メソッド名や引数の型が違う（スペルミスや引数の数・型の不一致）

**対処の目安：**  
- メソッドが定義されている正しいクラスを確認する  
- そのクラスのインスタンスを作って `インスタンス.concatenateFolderAndFile(...)` で呼ぶか、static なら `クラス名.concatenateFolderAndFile(...)` で呼ぶ

---

### 未使用の import 警告

ユーザー: The import java.util.Date is never used
意味だけ教えてください

アシスタント:

**意味：**  
「`import java.util.Date` は使用されていません」

**つまり：**  
コード内で `java.util.Date` をインポートしているが、実際には使っていないという警告です。

**対処：**  
- 使う予定がないなら、その `import` 文を削除してください。
- 使う予定があるなら、そのままにしておいても問題ありません（警告のみでコンパイルは通ります）。

**例：**
```java
import java.util.Date;  // ← この行を削除すれば警告が消える

public class Main {
    public static void main(String[] args) {
        // Date を使っていない
    }
}
```

未使用のインポートは削除するとコードがすっきりします。

---

### LocalDate で mm（分）を使うとエラーになる理由

ユーザー: sukkiri_java_exercises\Chapter15\exercise_1st\exercise5\Main.javaでRun出来なかったがこれは何？
PS C:\Users\20171\IT_Learning\pre-joining-learning>  c:; cd 'c:\Users\20171\IT_Learning\pre-joining-learning'; & 'C:\ForDevelop\Adoptium\OpenJDK25U-jdk_x64_windows_hotspot_25.0.1_8\bin\java.exe' '-Dfile.encoding=MS932' '-XX:+ShowCodeDetailsInExceptionMessages' '-cp' 'C:\Users\20171\IT_Learning\pre-joining-learning\bin' 'Chapter15.exercise_1st.exercise5.Main'    
Exception in thread "main" java.time.temporal.UnsupportedTemporalTypeException: Unsupported field: MinuteOfHour
        at java.base/java.time.LocalDate.get0(LocalDate.java:700)
        at java.base/java.time.LocalDate.getLong(LocalDate.java:680)
        at java.base/java.time.format.DateTimePrintContext.getValue(DateTimePrintContext.java:308)
        at java.base/java.time.format.DateTimeFormatterBuilder$NumberPrinterParser.format(DateTimeFormatterBuilder.java:2914)
        at java.base/java.time.format.DateTimeFormatterBuilder$CompositePrinterParser.format(DateTimeFormatterBuilder.java:2538)
        at java.base/java.time.format.DateTimeFormatter.formatTo(DateTimeFormatter.java:1905)
        at java.base/java.time.format.DateTimeFormatter.format(DateTimeFormatter.java:1879)
        at java.base/java.time.LocalDate.format(LocalDate.java:1799)
        at Chapter15.exercise_1st.exercise5.Main.main(Main.java:11)

アシスタント:

エラー内容を確認中です。

**エラーの原因：**

`DateTimeFormatter` のパターン文字で：
- **`mm`** = **分（minute）** → `LocalDate` には時刻情報がないためエラー
- **`MM`** = **月（month）** → `LocalDate` に存在する情報

**修正内容：**

`"西暦yyyy年mm月dd日"` → `"西暦yyyy年MM月dd日"` に変更しました。

これで実行できるはずです。`LocalDate` は日付のみ（年・月・日）を扱うため、時刻（時・分・秒）のパターンは使えません。時刻を含める場合は `LocalDateTime` を使います。

---

### DateTimeFormatter のパターン指定方法

ユーザー: DateTimeFormatterのパターン指定の方法を教えてください

アシスタント:

`DateTimeFormatter` のパターン指定方法です。

## 基本的なパターン文字

### 年（Year）
- `y` / `yyyy` = 年（例: 2025）
- `yy` = 年の下2桁（例: 25）

### 月（Month）
- `M` = 月（1-12、例: 2）
- `MM` = 月（01-12、例: 02）
- `MMM` = 月の短縮名（例: Feb）
- `MMMM` = 月の完全名（例: February）

### 日（Day）
- `d` = 日（1-31、例: 5）
- `dd` = 日（01-31、例: 05）

### 時（Hour）
- `H` / `HH` = 24時間制（0-23、例: 14）
- `h` / `hh` = 12時間制（1-12、例: 2）

### 分（Minute）
- `m` / `mm` = 分（0-59、例: 30）

### 秒（Second）
- `s` / `ss` = 秒（0-59、例: 45）

### その他
- `a` = AM/PM（12時間制と併用）
- `E` / `EEEE` = 曜日（例: Mon / Monday）

## 使用例

```java
import java.time.*;
import java.time.format.DateTimeFormatter;

// LocalDate 用（日付のみ）
LocalDate date = LocalDate.now();
DateTimeFormatter dtf1 = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
// 出力例: 2025年02月05日

DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("yyyy/MM/dd");
// 出力例: 2025/02/05

// LocalDateTime 用（日時）
LocalDateTime dateTime = LocalDateTime.now();
DateTimeFormatter dtf3 = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH時mm分ss秒");
// 出力例: 2025年02月05日 14時30分45秒

DateTimeFormatter dtf4 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
// 出力例: 2025-02-05 14:30:45

// 12時間制
DateTimeFormatter dtf5 = DateTimeFormatter.ofPattern("yyyy年MM月dd日 hh時mm分 a");
// 出力例: 2025年02月05日 02時30分 PM
```

## 注意点

1. 大文字・小文字の区別
   - `MM` = 月、`mm` = 分
   - `HH` = 24時間制、`hh` = 12時間制

2. 使用するクラスに合わせる
   - `LocalDate` → 日付のみ（年・月・日）
   - `LocalTime` → 時刻のみ（時・分・秒）
   - `LocalDateTime` → 日時（年・月・日・時・分・秒）

3. 文字列をそのまま表示したい場合
   - シングルクォートで囲む: `'西暦'yyyy年` → "西暦2025年"

## よく使うパターン例

```java
// 日本語形式
"yyyy年MM月dd日"
"yyyy年MM月dd日 HH時mm分"

// ISO形式
"yyyy-MM-dd"
"yyyy-MM-dd HH:mm:ss"

// スラッシュ区切り
"yyyy/MM/dd"
"MM/dd/yyyy"

// 曜日付き
"yyyy年MM月dd日(E)"
```

これで、目的に合わせてパターンを指定できます。
