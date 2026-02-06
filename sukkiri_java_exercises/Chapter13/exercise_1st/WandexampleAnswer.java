package Chapter13.exercise_1st;

/** 【解答例】Wand クラス（練習13-1〜13-4） */
public class WandexampleAnswer {
    private String name;    // 杖の名前
    private double power;   // 杖の魔力

    //getter
    public String getName() {
        return this.name;
    }
    public double getPower() {
        return this.power;
    }

    //setter
    /*
     * 【setName】元の誤り → 修正
     * ・誤り1: 条件が逆（name.length() > 3 だと4文字以上で例外になる。設問は「3文字以上」が正なので例外にすべきは3文字未満）
     * ・誤り2: null チェックなし（name が null のとき name.length() で NPE）
     * ・誤り3: 先に this.name = name を実行していた（不正な値でも一度代入される）
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
            throw new IllegalArgumentException("杖に設定されようとしている名前が異常です");
        }
        this.name = name;
    }
    /*
     * 【setPower】元の誤り → 修正
     * ・誤り: 先に this.power = power を代入してから範囲チェック（不正な値が一時的に代入される）
     * ・修正: 先に 0.5以上100以下 の範囲チェックを行い、通った場合だけ this.power = power
     *
     * 【元のコード（誤り）】
     *   public void setPower(double power){
     *       this.power = power;
     *       final double LOWER_LIMIT = 0.5;
     *       final double UPPER_LIMIT = 100;
     *       if (!(LOWER_LIMIT <= power && power <= UPPER_LIMIT)) {
     *           throw new IllegalArgumentException("パワーの値が異常です。...");
     *       }
     *   }
     */
    public void setPower(double power) {
        final double LOWER_LIMIT = 0.5;
        final double UPPER_LIMIT = 100.0;
        if (power < LOWER_LIMIT || power > UPPER_LIMIT) {
            throw new IllegalArgumentException("杖に設定されようとしている魔力が異常です");
        }
        this.power = power;
    }
}
