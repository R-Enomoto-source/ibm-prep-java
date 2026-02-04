# 練習14-1 類似 コーディング問題

練習14-1で学んだ「`toString()` のオーバーライド」と「`equals()` のオーバーライド」を、実際にコードで書けるか確認するための問題です。

- **問題1** … `trim()` を使った比較
- **問題2** … `trim()` 以外の String メソッド（`toLowerCase()`）を使った比較

**条件：** 紙に書くか、エディタでクラスを1つ作成してから、各問題の「解答例」で確認してください。

---

## 問題1（trim を使う）

商品コードを表す **String 型フィールド `productCode`** と、価格を表す **int 型フィールド `price`** を持つ商品クラス `Product` を作ってください。さらに、次の①と②を満たすようにメソッドを追加・実装してください。

**①** 商品コード `"A001"`、価格 980 円の `Product` インスタンスを変数 `p` に生成し、  
`System.out.println(p);` を実行すると、画面に **`¥980(商品コード:A001)`** と表示される。

**②** 商品コードが等しければ等価と判断される。ただし、商品コードの**前後に半角スペース**が付いていても無視して比較する（`" A001 "` と `"A001"` は同じ商品とみなす）。

**ヒント：** `String` の `trim()` メソッドを使います。

---

## 問題1 動作確認用の main（任意）

実装後、次のコードで動作を確認できます。

```java
public static void main(String[] args) {
    Product p = new Product();
    p.productCode = "A001";
    p.price = 980;
    System.out.println(p);   // ① → ¥980(商品コード:A001)

    Product q = new Product();
    q.productCode = " A001 ";  // 前後にスペース
    q.price = 100;
    System.out.println(p.equals(q));  // ② → true（商品コードが同じとみなす）

    Product r = new Product();
    r.productCode = "B002";
    r.price = 980;
    System.out.println(p.equals(r));  // → false
}
```

---

## 問題1 解答例

<details>
<summary>クリックして解答例を表示</summary>

```java
public class Product {
    String productCode;   // 商品コード
    int price;            // 価格

    @Override
    public String toString() {
        return "¥¥" + this.price + "（商品コード：" + this.productCode + "）";
    }
    // 円記号を表示するため、ソースでは "¥¥" とエスケープする（書籍p67）

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o instanceof Product p) {
            String code1 = this.productCode.trim();
            String code2 = p.productCode.trim();
            return code1.equals(code2);
        }
        return false;
    }
}
```

### 補足

- **toString()**  
  - 表示が `¥980` のときは、ソースでは `"¥¥" + this.price` のように円記号をエスケープ（`¥¥`）する。
  - 括弧は設問どおり半角 `()` でも全角「（）」でもよい（表示仕様に合わせる）。

- **equals()**  
  - 自分自身との比較 `this == o` → 同じ参照なら `true`。
  - `o instanceof Product p` で「同じクラスか」を判定し、`trim()` した商品コード同士を `equals()` で比較している。

</details>

---

## 問題2（toLowerCase / toUpperCase を使う）

会員IDを表す **String 型フィールド `memberId`** と、保有ポイントを表す **int 型フィールド `points`** を持つ会員クラス `Member` を作ってください。さらに、次の①と②を満たすようにメソッドを追加・実装してください。

**①** 会員ID `"M001"`、ポイント 500 の `Member` インスタンスを変数 `m` に生成し、  
`System.out.println(m);` を実行すると、画面に **`Pt500(会員ID:M001)`** と表示される。

**②** 会員IDが等しければ等価と判断される。ただし、**大文字と小文字の違いは無視**して比較する（`"m001"` と `"M001"` は同じ会員とみなす）。

**ヒント：** `String` の `toLowerCase()` メソッド（または `toUpperCase()`）を使います。どちらかにそろえてから比較するとよいです。

---

## 問題2 動作確認用の main（任意）

```java
public static void main(String[] args) {
    Member m = new Member();
    m.memberId = "M001";
    m.points = 500;
    System.out.println(m);   // ① → Pt500(会員ID:M001)

    Member n = new Member();
    n.memberId = "m001";     // 小文字
    n.points = 100;
    System.out.println(m.equals(n));  // ② → true（大文字・小文字を無視）

    Member o = new Member();
    o.memberId = "M002";
    o.points = 500;
    System.out.println(m.equals(o));  // → false
}
```

---

## 問題2 解答例

<details>
<summary>クリックして解答例を表示</summary>

```java
public class Member {
    String memberId;   // 会員ID
    int points;        // 保有ポイント

    @Override
    public String toString() {
        return "Pt" + this.points + "（会員ID：" + this.memberId + "）";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o instanceof Member m) {
            String id1 = this.memberId.toLowerCase();
            String id2 = m.memberId.toLowerCase();
            return id1.equals(id2);
        }
        return false;
    }
}
```

### 補足

- **toString()**  
  - 「Pt」はそのまま文字列でよい（エスケープ不要）。`"Pt" + this.points` で `Pt500` になる。

- **equals()**  
  - `toLowerCase()` は「その文字列を小文字にした**新しい文字列**を返す」メソッド。元の文字列は変更されない（String は不変）。
  - 両方の会員IDを `toLowerCase()` で小文字にそろえてから `equals()` で比較する。
  - `toUpperCase()` を使う場合も同様に、両方 `toUpperCase()` でそろえてから比較する。

</details>

---

## 採点結果

**採点日：** 2025年2月4日

### Product.java（問題1）

| 項目 | 要件 | 実装 | 判定 |
|------|------|------|------|
| ① toString() | `¥980(商品コード:A001)` と表示 | `"¥¥" + this.price + "(商品コード:" + this.productCode + ")"` で実装 | ◎ 正解 |
| ② equals() | 商品コードを trim() で比較 | `productCode.trim()` を使用し、前後スペースを無視して比較 | ◎ 正解 |
| 同一参照チェック | `this == o` で自分自身との比較 | 実装済み | ◎ 正解 |
| instanceof チェック | `o instanceof Product` で型判定 | 実装済み（`Product a` でパターンマッチング使用） | ◎ 正解 |

**所見：** すべての要件を満たしています。`equals()` の `return true` は `return pc1.equals(pc2);` と簡潔に書くこともできますが、動作は同等です。

**改善案：** `@Override` アノテーションを付けると、オーバーライドの意図が明確になり、コンパイラによるチェックも受けられます。

**評価：** 満点（問題1の要件をすべて満たしている）

---

### Member.java（問題2）

| 項目 | 要件 | 実装 | 判定 |
|------|------|------|------|
| ① toString() | `Pt500(会員ID:M001)` と表示 | `"Pt" + this.points + "(会員ID:" + this.memberId + ")"` で実装 | ◎ 正解 |
| ② equals() | 会員IDを大文字・小文字無視で比較 | `memberId.toLowerCase()` を使用し、`toLowerCase()` でそろえて比較 | ◎ 正解 |
| 同一参照チェック | `this == o` で自分自身との比較 | 実装済み | ◎ 正解 |
| instanceof チェック | `o instanceof Member` で型判定 | 実装済み（`Member a` でパターンマッチング使用） | ◎ 正解 |

**所見：** すべての要件を満たしています。`equals()` のロジックも正しく実装されています。

**改善案：** `@Override` アノテーションを付けるとベストプラクティスに沿います。

**評価：** 満点（問題2の要件をすべて満たしている）

---

### 総評

**総合評価：合格（両問題とも満点）**

- **Product クラス** … `toString()` と `equals()` を正しく実装。`trim()` による前後スペースの無視も適切です。
- **Member クラス** … `toString()` と `equals()` を正しく実装。`toLowerCase()` による大文字・小文字の無視も適切です。
- 両クラスともパターンマッチング（`instanceof Product p`）を活用しており、Java 16 以降の書き方に沿っています。

これで問題1・問題2の条件は十分に満たしています。
