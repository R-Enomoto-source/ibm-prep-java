package Chapter14.exercise1_1st;

public class Member {
    //フィールド
    String memberId;
    int points;

    //メソッド
    public String toString(){
        return "Pt" + this.points + "(会員ID:" + this.memberId + ")";
    }
    public boolean equals(Object o){
        if (this == o) {
            return true;            
        }
        if(o instanceof Member a){
            String md1 = this.memberId.toLowerCase();
            String md2 = a.memberId.toLowerCase();
            if (md1.equals(md2)) {
                return true;
            }
        }
        return false;
    }

}
