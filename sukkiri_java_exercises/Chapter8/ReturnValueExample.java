package Chapter8;

/**
 * 戻り値を含むメソッドの基本的な書き方 - 具体例集
 */
public class ReturnValueExample {
    
    // ============================================
    // 【基本の基本】戻り値があるメソッドの構造
    // ============================================
    
    /*
     * 戻り値があるメソッドの書き方：
     * 
     * アクセス修飾子 戻り値の型 メソッド名(引数) {
     *     処理;
     *     return 戻り値;
     * }
     * 
     * 重要なポイント：
     * 1. voidではなく、intやStringなど具体的な型を指定
     * 2. 必ずreturn文で値を返す
     * 3. returnで返す値の型は、メソッドの戻り値の型と一致する必要がある
     */
    
    
    // ============================================
    // 例1: シンプルな数値計算メソッド（int型を返す）
    // ============================================
    
    /**
     * 2つの数の合計を計算して返す
     */
    public int calculateSum(int a, int b) {
        int result = a + b;  // 計算する
        return result;       // 計算結果を返す
    }
    
    /**
     * より簡潔な書き方（変数を使わず直接return）
     */
    public int calculateSumSimple(int a, int b) {
        return a + b;  // 計算結果を直接返す
    }
    
    
    // ============================================
    // 例2: 文字列を返すメソッド（String型を返す）
    // ============================================
    
    /**
     * 名前を受け取って、挨拶文を作成して返す
     */
    public String createGreeting(String name) {
        String greeting = "こんにちは、" + name + "さん！";
        return greeting;
    }
    
    /**
     * より簡潔な書き方
     */
    public String createGreetingSimple(String name) {
        return "こんにちは、" + name + "さん！";
    }
    
    
    // ============================================
    // 例3: 真偽値を返すメソッド（boolean型を返す）
    // ============================================
    
    /**
     * 数値が正の数かどうかを判定する
     */
    public boolean isPositive(int number) {
        if (number > 0) {
            return true;   // 正の数の場合、trueを返す
        } else {
            return false;  // 正の数でない場合、falseを返す
        }
    }
    
    /**
     * より簡潔な書き方（条件式の結果を直接返す）
     */
    public boolean isPositiveSimple(int number) {
        return number > 0;  // 条件式の結果（trueまたはfalse）を直接返す
    }
    
    
    // ============================================
    // 例4: 条件によって異なる値を返すメソッド
    // ============================================
    
    /**
     * 点数に応じて評価を返す（A, B, C）
     */
    public String getGrade(int score) {
        if (score >= 80) {
            return "A";      // 80点以上なら"A"を返す
        } else if (score >= 60) {
            return "B";      // 60点以上なら"B"を返す
        } else {
            return "C";      // それ以外なら"C"を返す
        }
    }
    
    /**
     * 数値の最大値を返す
     */
    public int getMax(int a, int b) {
        if (a > b) {
            return a;  // aの方が大きい場合、aを返す
        } else {
            return b;  // bの方が大きいか同じ場合、bを返す
        }
    }
    
    
    // ============================================
    // 例5: voidメソッドとの違い（比較用）
    // ============================================
    
    /**
     * voidメソッド：戻り値がない（何も返さない）
     * コンソールに出力するだけ
     */
    public void printMessage(String message) {
        System.out.println(message);
        // return文は不要（何も返さない）
        // もし書くなら return; のみ（値は返さない）
    }
    
    /**
     * 戻り値があるメソッド：必ず値を返す必要がある
     * エラーチェック：全ての経路でreturn文が必要
     */
    public int calculate(int value) {
        if (value < 0) {
            return 0;  // 負の数の場合は0を返す
        }
        // 正の数の場合は計算結果を返す
        return value * 2;  // このreturn文がないとコンパイルエラー
    }
    
    
    // ============================================
    // 例6: 実際の使い方の例（テスト用メインメソッド）
    // ============================================
    
    public static void main(String[] args) {
        ReturnValueExample example = new ReturnValueExample();
        
        // 【使い方1】戻り値を変数に保存して使用
        int sum = example.calculateSum(5, 3);
        System.out.println("合計: " + sum);  // 出力: 合計: 8
        
        // 【使い方2】戻り値を直接使用（変数に保存しない）
        System.out.println("挨拶: " + example.createGreeting("花子"));
        // 出力: 挨拶: こんにちは、花子さん！
        
        // 【使い方3】戻り値を条件分岐で使用
        if (example.isPositive(10)) {
            System.out.println("10は正の数です");
        }
        
        // 【使い方4】戻り値を別のメソッドの引数として使用
        int num1 = example.calculateSum(2, 3);  // 5
        int num2 = example.calculateSum(4, 6);  // 10
        int total = example.calculateSum(num1, num2);  // 15
        System.out.println("最終的な合計: " + total);
        
        // 【使い方5】戻り値を計算に使用
        int max = example.getMax(7, 12);
        System.out.println("最大値: " + max);  // 出力: 最大値: 12
        
        String grade = example.getGrade(85);
        System.out.println("評価: " + grade);  // 出力: 評価: A
    }
}
