package Chapter16.first.exercise3;

import java.util.*;

public class NameDisplay {
    public static void main(String[] args) {
        //インスタンス生成
        Hero hero1 = new Hero("斎藤",3);
        Hero hero2 = new Hero("鈴木",7);

        //Mapの作成と格納
        var hNameAndNum = new HashMap<String,Integer>();
        hNameAndNum.put(hero1.getName(),hero1.getKilleEnemyNum());
        hNameAndNum.put(hero2.getName(),hero2.getKilleEnemyNum());

        //Mapの取り出しと表示
        for(String key : hNameAndNum.keySet()){
            int value = hNameAndNum.get(key);
            System.out.println(key + "が倒した数=" + value);
        }

    }
}
