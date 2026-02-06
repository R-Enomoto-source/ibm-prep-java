package Chapter14.exercise2_1st;

import java.util.Random;

public class chapter14_Cleric_1st {
    String name;
    int hp = 50;
    static final int MAX_HP = 50;
    int mp = 10;
    static final int MAX_MP = 10;

    public void selfAid() {
    System.out.println(this.name + "はセルフエイドを唱えた！");
    this.hp = chapter14_Cleric_1st.MAX_HP;
    this.mp -= 5;
    System.out.println("HPが最大まで回復した");
    }

    public int pray(int sec) {
    System.out.println(this.name + "は" + sec + "秒間天に祈った！");

    // 論理上の回復量を乱数を用いて決定する
    int recover = new Random().nextInt(3) + sec;

    // 実際の回復量を計算する
    int recoverActual = Math.min(chapter14_Cleric_1st.MAX_MP - this.mp, recover);

    this.mp += recoverActual;
    System.out.println("MPが" + recoverActual + "回復した");
    return recoverActual;
    }
}