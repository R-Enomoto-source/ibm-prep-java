package Chapter17.first;

public class exercise3 {
    @SuppressWarnings("unused")
    public static void main(String[] args) {
    try {
        int i = Integer.parseInt("三");
        /*
        parseIntメソッドが発生させうる例外:NumberFormatException
        意味：文字列が解析可能な整数型を含まない場合。
        */     
    } catch (NumberFormatException e) {
        System.out.println("エラー:" + e.getMessage());
        System.out.println("文字列には変換可能な数値を入力してください");
    }
    }
}
