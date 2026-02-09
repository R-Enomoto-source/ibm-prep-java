package Chapter17.first;

public class exercise3 {
    public static void main(String[] args) {
    try {
        int i = Integer.parseInt("三");
        /*
        parseIntメソッドが発生させうる例外:NumberFormatException
        意味：文字列が解析可能な整数型を含まない場合。
        */     
    } catch (Exception e) {
        // TODO: handle exception
    }
    }
}
