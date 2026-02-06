/*
ランダムに01を生成して、それをSwitch文で分岐させる
 */

package Chapter3;

public class exercise3 {
    public static void main(String[] args) {
        //変数
        int isHungry = 0;
        String food = "お好み焼き";

        //処理
        System.out.println("こんにちは");

        isHungry = new java.util.Random().nextInt(2);
        switch (isHungry) {
            case 0 -> {
                System.out.println("お腹がいっぱいです");
            }
            case 1 -> {
                System.out.println("はらぺこです");
                System.out.println(food + "をいただきます");
            }
        }
        System.out.println("ごちそうさまでした");
        
    }
}
