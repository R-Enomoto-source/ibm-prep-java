package Chapter9;

public class exercise1_1st_ThiefBrushup {
    //フィールド
    String name;
    int hp;
    int mp;
    //初期値（static にすると this() の引数で使える）
    private static final int MP_DEFAULT_VALUE = 5;
    private static final int HP_DEFAULT_VALUE = 40;
    //メソッド
    //①のコンストラクタ
    public exercise1_1st_ThiefBrushup(String name, int hp, int mp) {
        this.name = name;
        this.hp = hp;
        this.mp = mp;
    }
    //②のコンストラクタ
    public exercise1_1st_ThiefBrushup(String name, int hp) {
        this(name, hp, MP_DEFAULT_VALUE);
    }
    //③のコンストラクタ
    public exercise1_1st_ThiefBrushup(String name) {
        this(name, HP_DEFAULT_VALUE, MP_DEFAULT_VALUE);
    }
}
