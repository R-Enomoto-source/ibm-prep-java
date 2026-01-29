package Chapter10.exercise3_1st;

public class PoisonMatango extends Matango{
    //static定数や変数
    private static int poisonAttackTimesValue = 5;
    private static final int pointConsumeInToxicAttack = 1;
    private static int poisonDamage;
    //フィールド
    public PoisonMatango(char suffix){
        super(suffix);
    }
    //メソッド
    public void attack(Hero h){
        super.attack(h);
        poisonDamage = h.hp / 5;
        if(poisonAttackTimesValue > 0){
            System.out.println("さらに毒の胞子をばらまいた!");
            h.hp -= poisonDamage;
            System.out.println(h.name + "に" + poisonDamage + "ポイントのダメージ!");
            poisonAttackTimesValue -= pointConsumeInToxicAttack;
        }else{
            System.out.println("毒の胞子がなくて、ばらまけない!");
        }
    }
}
