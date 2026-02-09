package Chapter17.first;

public class exercise2 {
    @SuppressWarnings("null")
    public static void main(String[] args) {
        try {
            String s = null;
            System.out.println(s.length());            
        } catch (Exception e) {
            System.out.println("NullPointerException 例外を catch しました");
            System.out.println("ーースタックトレース(ここから)--");
            e.printStackTrace();
            System.out.println("ーースタックトレース(ここまで)--");

        }
    }
}
