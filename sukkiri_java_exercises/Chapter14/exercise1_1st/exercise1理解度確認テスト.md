## 1
¥¥1592
\¥1592
特殊文字を文字列にする場合は前に\を入れてエスケープする必要があるため。

## 2
Acountです。
比較したいのは、Accountのフィールドなので。また、Accountである変数aにしたoと Acount A.equals(Account B) 、のAと比較したいので、Accountとなる。

## 3
Account

## 4
ob.trim(); が間違っています。
変数に格納しないと戻り値を比較に使用できません。

String ban =  ob.trim();
## 5
1.　参照を比較している。メモリに格納されているのが参照先のメモリの番地・アドレスになっているから
2.　参照先が同じなら必ず値も同じ内容だから。
## 6
1. （ thisとOの参照（==） ）との比較（同じインスタンスなら true を返す）
2. （ キャストできるか否かの ）チェック（同じクラスかどうか。`instanceof` を使う）
3. （ thisとoの値（.equals()） ）の比較（口座番号を trim してから equals で比較）
## 7
if (this**.accountNumber** == o) {
→(this == o)

if (o instanceof String ob) {
    ob.trim();
    if (this.accountNumber.equals(o)) {
    }
}
→if (o instanceof Account a){
    String an1 = this.accountNumber.trim();
    String an2 = a.accountNumber.trim();
    if(an1.equals(an2)){
        return true;
    }
}

## 8
1. 短くなり、可読性が向上するため
2. ネスト（入れ子）が浅くなり、可読性が上がるため。
3. `return false` の場所　はif文の一番外側の}の直下
