package Chapter2;

public class exerciseBrashyUp {
    public static void main(String[] args) {
        //受付部分の定数と変数
        final String WELCOME_MESSAGE = "ようこそ占いの館へ";
        final String AGE_IN = "あなたの年齢を入力してください";

        //占い部分の定数と変数
        final String RESULT_MESSAGE = "占いの結果が出ました";
        final String FORTUNE_RESULT_LIST = "1:大吉 2:中吉 3:吉 4:凶";
        String name = " ";
        String ageString = " ";
        int age = 0;
        int fortune = 0;

        //入力処理
        System.out.println(WELCOME_MESSAGE);
        java.util.Scanner sc = new java.util.Scanner(System.in);
        
        name = sc.nextLine();
        System.out.println(AGE_IN);
        ageString = sc.nextLine();
        age = Integer.parseInt(ageString);
        sc.close();

        //乱数生成処理
        fortune = new java.util.Random().nextInt(5) ;
        ++fortune;

        //占い結果表示
        System.out.println(RESULT_MESSAGE);
        System.out.println(age + "歳の" + name + "さん、あなたの運気番号は" + fortune + "です");
        System.out.println(FORTUNE_RESULT_LIST);
    }
}
