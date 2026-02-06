package Chapter4;

public class exercise2 {
    public static void main(String[] args) {
        int[] moneyList = {121902 , 8302 , 55100};
        //for文で取り出す処理
        for(int i = 0 ; i < moneyList.length ; i++){
            System.out.println(moneyList[i]);
        }
        //拡張for文で取り出す処理
        for(int money : moneyList){
            System.out.println(money);
        }
    }
}
