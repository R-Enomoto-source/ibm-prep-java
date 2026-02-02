package Chapter13.exercise_1st;

public class Wand {
    private String name;    // 杖の名前
    private double power;   // 杖の魔力

    //getter
    public String getName(){
        return this.name;
    }
    public double getPower(){
        return this.power;
    }
    
    //setter
    public void setName(String name){
        this.name = name;
        final int LOWER_LIMIT_CHARACTERS = 3;
        if (name.length() > LOWER_LIMIT_CHARACTERS) {
            throw new IllegalArgumentException
            ("名前が短すぎます。処理を中断します。名前には、必ず3文字以上を入力してください。");
        }
    }
    public void setPower(double power){
        this.power = power;
        final double LOWER_LIMIT = 0.5;
        final double UPPER_LIMIT = 100;
        if (!(LOWER_LIMIT <= power && power <= UPPER_LIMIT)) {
            throw new IllegalArgumentException
            ("パワーの値が異常です。処理を中断します。杖による増幅率は、0.5以上100以下の数値を入力してください");
        }
    }
}
