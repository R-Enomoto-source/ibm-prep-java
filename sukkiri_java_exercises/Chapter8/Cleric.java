package Chapter8;

import java.util.Random;

public class Cleric {
    //属性の定数
    final int defaultValueHp = 50;
    final int defaultValueMp = 10;

    //属性の定義
    String name;
    int hp = defaultValueHp;
    final int MAX_HP = defaultValueHp;
    int mp = defaultValueMp;
    final int MAX_MP = defaultValueMp;

    //操作の定義
    //セルフエイドの魔法の定義
    public void selfAid(){
        this.mp -= 5;
        this.hp = this.MAX_HP;
    }
    //祈る行動の定義
    public int pray(int second){
        int recoverMp = second + new Random().nextInt(3)  ;
     
          /*
            常に10を超えないようにしたい。
            10-this.mpをすればよい？
            */   
        int recoverActual = Math.min(this.MAX_MP - this.mp, recoverMp);
        return recoverActual;
    }
}
