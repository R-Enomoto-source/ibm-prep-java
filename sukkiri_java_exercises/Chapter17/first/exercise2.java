package Chapter17.first;

public class exercise2 {
    public static void main(String[] args) {
        try {
            String s = null;
            System.out.println(s.length());            
        } catch (Exception e) {
            System.out.println("NullPointerException 例外を catch しました");
            System.out.println("ーースタックトレース(ここから)--");
            System.out.println();
            System.out.println("ーースタックトレース(ここまで)--");

        }
    }
}
