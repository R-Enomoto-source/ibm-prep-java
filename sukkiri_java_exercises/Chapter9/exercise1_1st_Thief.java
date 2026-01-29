package Chapter9;

public class exercise1_1st_Thief {
    //フィールド
    String name;
    int hp;
    int mp;
    //初期値
    final int MP_DEFAULT_VALUE = 5;
    final int HP_DEFAULT_VALUE = 40;
    //メソッド
    //①のコンストラクタ
    public exercise1_1st_Thief(String name , int hp , int mp){
        this.name = name;
        this.hp = hp;
        this.mp = mp;
    }
    //②のコンストラクタ
    public exercise1_1st_Thief(String name , int hp){
        this(name , hp , 5);
        
    }
    //③のコンストラクタ
    public exercise1_1st_Thief(String name){
        this(name , 40 , 5);
    }
}
