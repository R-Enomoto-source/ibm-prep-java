package Chapter8;

public class Cleric_2nd {
    //フィールド
    //初期値の定数
    final int DEFAULT_VALUE_HP = 50;
    final int DEFAULT_VALUE_MP = 10;
    final int SELFAID_MP_COST = 5;

    //フィールド：名前：HP：MP
    String name;
    int hp = DEFAULT_VALUE_HP;
    int mp = DEFAULT_VALUE_MP;
    final int MAX_HP = DEFAULT_VALUE_HP;
    final int MAX_MP = DEFAULT_VALUE_MP;

    //メソッド
    public void selfAid(){  //セルフエイド：回復魔法
        this.mp -= SELFAID_MP_COST ; 
        this.hp = this.MAX_HP;
    }
    public int pray(int praySecond){
        //回復MP量＝祈る秒数＋0～3
        int mpRecoveryQuantity = praySecond + new java.util.Random().nextInt(3);
        //制約下でのMP回復量
        int returnRecoveryMp = 0;
        //現在MPが最大MPでないときは、回復量分回復するが最大MPを超過することはない。
        //現在MPが最大MPのときは回復しない。
        //回復MP量+現在MP量が最大MP量を超過する時は、MAX_MP-mp分回復するようにする。
        //回復MP量+現在MP量が最大MP量を超過しない時は、mpRecoveryQuantity分回復するようにする。
        if(this.mp + mpRecoveryQuantity >= this.MAX_MP){
            returnRecoveryMp = this.MAX_MP - this.mp;
            return returnRecoveryMp;
        }else if(this.mp + mpRecoveryQuantity < this.MAX_MP){
            returnRecoveryMp = mpRecoveryQuantity;
            return returnRecoveryMp;
        }else{ //エラーを出さないための意味のない処理
            return returnRecoveryMp;
        }
    }
}
