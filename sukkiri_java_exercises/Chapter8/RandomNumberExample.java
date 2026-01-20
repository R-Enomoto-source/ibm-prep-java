package Chapter8;

/**
 * Javaで特定の範囲のランダムな数値を生成する方法の例
 */
public class RandomNumberExample {
    
    // ============================================
    // 基本的な方法：Randomクラスを使用
    // ============================================
    
    /**
     * 【方法1】0から指定した数値未満のランダムな整数を生成
     * 
     * RandomクラスのnextInt(上限)メソッドを使用
     * 
     * 例：nextInt(10) → 0以上10未満（0~9）のランダムな整数
     */
    public void example1() {
        java.util.Random random = new java.util.Random();
        
        int num1 = random.nextInt(10);  // 0~9のランダムな整数
        int num2 = random.nextInt(5);   // 0~4のランダムな整数
        int num3 = random.nextInt(3);   // 0~2のランダムな整数（0, 1, 2のいずれか）
        System.out.println("num1=" + num1 + ", num2=" + num2 + ", num3=" + num3);
    }
    
    
    /**
     * 【方法2】1から指定した数値までのランダムな整数を生成
     * 
     * nextInt(上限) + 1 を使用
     */
    public void example2() {
        java.util.Random random = new java.util.Random();
        
        int num1 = random.nextInt(10) + 1;  // 1~10のランダムな整数
        int num2 = random.nextInt(6) + 1;   // 1~6のランダムな整数（サイコロ）
        int num3 = random.nextInt(100) + 1; // 1~100のランダムな整数
        System.out.println("num1=" + num1 + ", num2=" + num2 + ", num3=" + num3);
    }
    
    
    /**
     * 【方法3】任意の範囲（min以上max以下）のランダムな整数を生成
     * 
     * nextInt(上限 - 下限 + 1) + 下限 の公式を使用
     * 
     * 例：5~10のランダムな整数
     *    nextInt(10 - 5 + 1) + 5
     *    = nextInt(6) + 5
     *    → 5, 6, 7, 8, 9, 10のいずれか
     */
    public void example3() {
        java.util.Random random = new java.util.Random();
        
        // 5~10のランダムな整数
        int num1 = random.nextInt(10 - 5 + 1) + 5;
        // または
        int num2 = random.nextInt(6) + 5;
        
        // 10~20のランダムな整数
        int num3 = random.nextInt(20 - 10 + 1) + 10;
        // または
        int num4 = random.nextInt(11) + 10;
        System.out.println("5~10: num1=" + num1 + ", num2=" + num2 + " / 10~20: num3=" + num3 + ", num4=" + num4);
    }
    
    
    // ============================================
    // よく使う具体例
    // ============================================
    
    /**
     * 【例1】0~2のランダムな整数（0, 1, 2のいずれか）
     * 
     * これは練習問題のprayメソッドで使う例です
     */
    public void exampleForPray() {
        java.util.Random random = new java.util.Random();
        
        int randomValue = random.nextInt(3);  // 0, 1, 2のいずれか
        System.out.println("randomValue=" + randomValue);
    }
    
    
    /**
     * 【例2】1~6のランダムな整数（サイコロ）
     */
    public void exampleDice() {
        java.util.Random random = new java.util.Random();
        
        int dice = random.nextInt(6) + 1;  // 1, 2, 3, 4, 5, 6のいずれか
        System.out.println("dice=" + dice);
    }
    
    
    /**
     * 【例3】毎回新しいRandomオブジェクトを作成する方法
     * 
     * メソッド内で毎回作成する場合（簡潔な書き方）
     */
    public void exampleSimple() {
        // new java.util.Random().nextInt(上限) で毎回作成
        int num1 = new java.util.Random().nextInt(10);  // 0~9
        int num2 = new java.util.Random().nextInt(3);   // 0~2
        System.out.println("num1=" + num1 + ", num2=" + num2);
    }
    
    
    // ============================================
    // 公式のまとめ
    // ============================================
    
    /*
     * 【公式まとめ】
     * 
     * 1. 0以上N未満のランダムな整数
     *    random.nextInt(N)
     *    例：nextInt(10) → 0~9
     * 
     * 2. 1以上N以下のランダムな整数
     *    random.nextInt(N) + 1
     *    例：nextInt(6) + 1 → 1~6
     * 
     * 3. min以上max以下のランダムな整数
     *    random.nextInt(max - min + 1) + min
     *    例：nextInt(10 - 5 + 1) + 5 → 5~10
     * 
     * 4. 毎回新しいRandomオブジェクトを作成
     *    new java.util.Random().nextInt(N)
     *    例：new java.util.Random().nextInt(3) → 0~2
     */
    
    
    // ============================================
    // 練習問題への応用例
    // ============================================
    
    /**
     * 【応用例】prayメソッドで使う場合
     * 
     * 祈った秒数 + ランダムで0~2ポイントの補正
     */
    public void exampleForPrayMethod() {
        int second = 3;  // 祈る秒数（例）
        
        // ランダムで0~2の補正値を生成
        int randomBonus = new java.util.Random().nextInt(3);  // 0, 1, 2のいずれか
        
        // 回復量 = 祈った秒数 + ランダム補正
        int recover = second + randomBonus;
        
        // 結果：second=3の場合、recoverは3, 4, 5のいずれかになる
        System.out.println("recover=" + recover);
    }
    
    
    // ============================================
    // 動作確認用のメインメソッド
    // ============================================
    
    public static void main(String[] args) {
        java.util.Random random = new java.util.Random();
        
        System.out.println("=== 0~2のランダムな整数を10回生成 ===");
        for (int i = 0; i < 10; i++) {
            int value = random.nextInt(3);  // 0~2
            System.out.println((i + 1) + "回目: " + value);
        }
        
        System.out.println("\n=== 1~6のランダムな整数（サイコロ）を5回 ===");
        for (int i = 0; i < 5; i++) {
            int dice = random.nextInt(6) + 1;  // 1~6
            System.out.println((i + 1) + "回目: " + dice);
        }
        
        System.out.println("\n=== 5~10のランダムな整数を5回 ===");
        for (int i = 0; i < 5; i++) {
            int value = random.nextInt(6) + 5;  // 5~10
            System.out.println((i + 1) + "回目: " + value);
        }
        
        System.out.println("\n=== 毎回新しいRandomオブジェクトを作成 ===");
        for (int i = 0; i < 5; i++) {
            int value = new java.util.Random().nextInt(3);  // 0~2
            System.out.println((i + 1) + "回目: " + value);
        }
    }
}
