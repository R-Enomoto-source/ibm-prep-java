package Chapter3;

public class exercise6 {
    public static void main(String[] args) {
        //変数
        int num = 0;
        int ans = 0;
        ans = new java.util.Random().nextInt(10);

        //スタート処理
        System.out.println("【数あてゲーム】");

        //ゲーム処理
        

        for( int i = 0 ; i < 5 ; i++){
            System.out.println("0~9の数字を入力してください");
            num = new java.util.Scanner(System.in).nextInt();
            if (num == ans) {
                System.out.println("アタリ!");
                break;
            }else{
                System.out.println("違います");
            }
        }
        //エンド処理
        System.out.println("ゲームを終了します");
    }
}
