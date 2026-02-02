package Chapter13.exercise_1st;

/** 【解答例】Wizard クラス（練習13-1〜13-4） */
public class WizardexampleAnswer {
    private int hp;
    private int mp;
    private String name;
    private WandexampleAnswer wand;

    public void heal(Hero h) {
        int basePoint = 10;                                  // 基本回復ポイント
        int recovPoint = (int)(basePoint * this.getWand().getPower()); // 杖による増幅

        h.setHp(h.getHp() + recovPoint);                     // 勇者のHPを回復する
        System.out.println(h.getName() + "のHPを" + recovPoint + "回復した！");
    }
    //getter
    public String getName() {
        return this.name;
    }
    public int getHp() {
        return this.hp;
    }
    public int getMp() {
        return this.mp;
    }
    public WandexampleAnswer getWand() {
        return this.wand;
    }

    //setter
    /*
     * 【setName】元の誤り → 修正
     * ・誤り: Wand と同様（条件が逆 name.length() > 3、null 未チェック、先に代入していた）
     * ・修正: 先に if (name == null || name.length() < 3) で検証し、通った場合だけ this.name = name
     *
     * 【元のコード（誤り）】
     *   public void setName(String name){
     *       this.name = name;
     *       final int LOWER_LIMIT_CHARACTERS = 3;
     *       if (name.length() > LOWER_LIMIT_CHARACTERS) {
     *           throw new IllegalArgumentException("名前が短すぎます。...");
     *       }
     *   }
     */
    public void setName(String name) {
        if (name == null || name.length() < 3) {
            throw new IllegalArgumentException("魔法使いに設定されようとしている名前が異常です");
        }
        this.name = name;
    }
    /*
     * 【setHp】元の誤り → 修正
     * ・誤り: 設問は「負の値のときは自動的に0が設定される」のみなのに、0にしたうえで例外も投げていた
     * ・修正: 負のときは this.hp = 0 にするだけ。例外は投げない
     *
     * 【元のコード（誤り）】
     *   public void setHp(int hp){
     *       this.hp = hp;
     *       final int LOWER_LIMIT = 0;
     *       if (hp < LOWER_LIMIT) {
     *           this.hp = LOWER_LIMIT;
     *           throw new IllegalArgumentException("HPに負の値を設定しないでください。...");
     *       }
     *   }
     */
    public void setHp(int hp) {
        if (hp < 0) {
            this.hp = 0;
        } else {
            this.hp = hp;
        }
    }
    /*
     * 【setMp】元の誤り → 修正
     * ・誤り: MP が 0 以上であることの検証がなかった（負の値を設定できてしまっていた）
     * ・修正: mp < 0 のときに IllegalArgumentException を投げる処理を追加
     *
     * 【元のコード（誤り）】
     *   public void setMp(int mp){
     *       this.mp = mp;
     *   }
     */
    public void setMp(int mp) {
        if (mp < 0) {
            throw new IllegalArgumentException("設定されようとしているMPが異常です");
        }
        this.mp = mp;
    }
    /*
     * 【setWand】元の誤り → 修正
     * ・誤り: 先に this.wand = wand を実行してから if (wand == null) で例外（null を一度代入してから例外になっていた）
     * ・修正: 先に if (wand == null) で例外を投げ、問題なければ this.wand = wand
     *
     * 【元のコード（誤り）】
     *   public void setWand(Wand wand){
     *       this.wand = wand;
     *       if(wand == null){
     *           throw new IllegalArgumentException("魔法使いが杖を装備していないです。...");
     *       }
     *   }
     */
    public void setWand(WandexampleAnswer wand) {
        if (wand == null) {
            throw new IllegalArgumentException("設定されようとしている杖がnullです");
        }
        this.wand = wand;
    }
}
