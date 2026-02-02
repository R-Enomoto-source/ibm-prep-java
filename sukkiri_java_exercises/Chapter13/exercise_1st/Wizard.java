package Chapter13.exercise_1st;

public class Wizard {
    private int hp;
    private int mp;
    private String name;
    private Wand wand;

    public void heal(Hero h) {
        int basePoint = 10;                                  // 基本回復ポイント
        int recovPoint = (int)(basePoint * this.wand.getPower()); // 杖による増幅

        h.setHp(h.getHp() + recovPoint);                     // 勇者のHPを回復する
        System.out.println(h.getName() + "のHPを" + recovPoint + "回復した！");
    }
    //getter
    public String getName(){
        return this.name;
    }
    public int getHp(){
        return this.hp;
    }
    public int getMp(){
        return this.mp;
    }
    public Wand getWand(){
        return this.wand;
    }

    //setter
    public void setName(String name){
        this.name = name;
        final int LOWER_LIMIT_CHARACTERS = 3;
        if (name.length() > LOWER_LIMIT_CHARACTERS) {
            throw new IllegalArgumentException
            ("名前が短すぎます。処理を中断します。名前には、必ず3文字以上を入力してください");
        }
        
    }
    public void setHp(int hp){
        this.hp = hp;
        final int LOWER_LIMIT = 0;
        if (hp < LOWER_LIMIT) {
            this.hp = LOWER_LIMIT;
            throw new IllegalArgumentException
            ("HPに負の値を設定しないでください。HPは必ず0以上に設定してください");
        }        
    }
    public void setMp(int mp){
        this.mp = mp;        
    }
    public void setWand(Wand wand){
        this.wand = wand;
        if(wand == null){
            throw new IllegalArgumentException
            ("魔法使いが杖を装備していないです。処理を中断します。魔法使いには必ず杖を装備させてください。");
        }
    }
}
