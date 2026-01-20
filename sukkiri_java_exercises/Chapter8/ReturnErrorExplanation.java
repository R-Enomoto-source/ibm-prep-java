package Chapter8;

/**
 * エラー「This method must return a result of type int」の説明
 * 
 * このエラーは、戻り値があるメソッドでreturn文が欠けている場合に発生します。
 */
public class ReturnErrorExplanation {
    
    // ============================================
    // ❌ エラーが発生する例
    // ============================================
    
    /**
     * 【エラー例】戻り値の型を指定しているのに、return文がない
     * このメソッドはコンパイルエラーになります
     */
    /*
    public int getNumber() {
        // return文がない → エラー！
    }
    */
    
    
    // ============================================
    // ✅ 正しい書き方の例
    // ============================================
    
    /**
     * 【正しい例1】必ずreturn文で値を返す
     */
    public int getNumber() {
        return 10;  // return文で値を返す
    }
    
    /**
     * 【正しい例2】条件分岐がある場合も、全ての経路でreturnが必要
     */
    public int getNumberWithCondition(int value) {
        if (value > 0) {
            return value;  // この経路でreturn
        } else {
            return 0;      // この経路でもreturn（必須！）
        }
    }
    
    /**
     * 【正しい例3】変数に保存してからreturnしてもOK
     */
    public int calculate(int a, int b) {
        int result = a + b;  // 計算結果を変数に保存
        return result;       // 変数の値を返す
    }
    
    
    // ============================================
    // voidメソッドとの違い
    // ============================================
    
    /**
     * 【voidメソッド】戻り値がないので、return文は不要
     * これはエラーにならない
     */
    public void printMessage(String message) {
        System.out.println(message);
        // return文は不要（何も返さないから）
    }
    
    /**
     * 【戻り値があるメソッド】必ずreturn文が必要
     * return文がないとエラーになる
     */
    public int getValue() {
        // 何か処理...
        return 42;  // このreturn文がないとエラー！
    }
}
