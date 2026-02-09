package Chapter16.first.exercise3;

import java.util.*;

public class NameDisplay {
    public static void main(String[] args) {
        //インスタンス生成
        Hero hero1 = new Hero("斎藤",3);
        Hero hero2 = new Hero("鈴木",7);

        //Mapの作成と格納
        Map <String,Integer> hNameAndNum = new HashMap<String,Integer>();
        hNameAndNum.put(hero1.getName(),hero1.getKilleEnemyNum());
        hNameAndNum.put(hero2.getName(),hero2.getKilleEnemyNum());

        //Mapの取り出しと表示
        

    }
}
