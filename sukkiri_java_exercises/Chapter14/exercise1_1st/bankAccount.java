package Chapter14.exercise1_1st;

public class bankAccount {
    String accountNumber;
    int balance;

    public String toString() {
        return "¥" + this.balance + "(口座番号:" + this.accountNumber + ")";
    }

    public boolean equals(Object o){
        if (this.accountNumber == o) {
            return true;
        }else{}

        if (this.accountNumber.equals(o)) {
            return true;
        }
        //もし、oの値である文字列の先頭に半角スペースがつけられていた場合
        if (o instanceof String ob) {
            if(ob.startsWith(" ")){
                ob.trim();
                if (this.accountNumber.equals(ob)) {
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else{
            return false;
        }            
    }
}
