# 復習：equals のオーバーライドとオーバーロード（問10・問11）

## 間違えた理由

### 問10
- **オーバーライドとオーバーロードの違い**を押さえていなかった。
- Main では `Object a = new Sample(10);` のように**参照型が Object**。
- `a.equals(b)` で呼ばれるのは「**Object 型を引数に取る equals**」であり、Sample の `equals(Sample obj)` は**オーバーライドではなくオーバーロード**。
- そのため **Object クラスの equals（参照の同一性比較）** が使われ、別インスタンスなので **false**。
- 「同値だから true」と考えたが、このコードでは同値性の equals は呼ばれていない。

### 問11
- **null との比較はコンパイル可能**であることを誤解していた（「コンパイルエラー」と解答）。
- Object の equals の定義は `return (this == obj);` なので、`a.equals(null)` は **false** を返す。
- 「null とは比較できない」は誤り。equals の契約として **「x.equals(null) は false を返す」** と決まっている。

---

## 重要なポイント

### 1. equals のオーバーライドに必要なシグネチャ

オーバーライドするには、**引数が Object 型**でなければならない。

```java
// オーバーライド（正しい）
@Override
public boolean equals(Object obj) {
    if (obj == null) return false;
    if (obj instanceof Sample) {
        Sample s = (Sample) obj;
        return this.num == s.num;
    }
    return false;
}
```

```java
// オーバーロード（多態では呼ばれない）
public boolean equals(Sample obj) {
    if (obj == null) return false;
    return this.num == obj.num;
}
```

- 参照型が **Object** のとき、`a.equals(b)` では「Object を引数に取るメソッド」が選ばれる。
- `equals(Sample obj)` は別シグネチャなので**オーバーロード**。Object 型の変数からは呼ばれず、Object の equals（同一性比較）が使われる。

### 2. null を渡したときの仕様

- **x.equals(null) は常に false を返す**（equals の契約）。
- コンパイルエラーにはならない。実行時にも、通常は false が返るだけ（実装を壊さなければ NPE にもならない）。

### 3. 試験で押さえること

- equals の**オーバーライド**は「引数が **Object 型**」であること。
- オーバーロードだと、参照型が Object のときは**多態で呼ばれない**。
- equals に null を渡したときは、**false が返る**という API 仕様を覚えておく。
