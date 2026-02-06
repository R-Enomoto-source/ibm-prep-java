package Chapter14.exercise1_1st;

public class CheckMember {
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
}
