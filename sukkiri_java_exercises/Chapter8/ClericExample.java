package Chapter8;

/**
 * Clericクラスを使った戻り値メソッドの実践例
 * 
 * この例では、練習問題で扱っているClericクラスの
 * prayメソッドを例に、戻り値があるメソッドの書き方を説明します。
 */
public class ClericExample {
    
    // Clericクラスの基本構造（練習問題と同じ）
    String name;
    int hp = 50;
    final int MAX_HP = 50;
    int mp = 10;
    final int MAX_MP = 10;
    
    
    // ============================================
    // 例1: voidメソッド（戻り値なし）との比較
    // ============================================
    
    /**
     * 【voidメソッド】戻り値がない
     * これは練習8-3で作成したselfAidメソッドと同じ
     * MPを消費してHPを回復するだけ（何も返さない）
     */
    public void selfAid() {
        this.mp -= 5;
        this.hp = this.MAX_HP;
        // return文は不要（何も返さないから）
    }
    
    
    // ============================================
    // 例2: 戻り値があるメソッドの基本形
    // ============================================
    
    /**
     * 【戻り値があるメソッド】int型を返す
     * 祈る行動を行い、MPを回復する
     * 
     * 戻り値があるメソッドのポイント：
     * 1. 戻り値の型（ここではint）を指定
     * 2. 必ずreturn文で値を返す
     * 3. 戻り値の型とreturnで返す値の型は一致している必要がある
     * 
     * @param second 祈る秒数（引数）
     * @return 実際に回復したMPの量（戻り値）
     */
    public int pray(int second) {
        // ステップ1: 回復量を計算
        // 祈った秒数 + ランダムで0~2ポイントの補正
        int recover = second + new java.util.Random().nextInt(3);
        
        // ステップ2: 最大MPを超えないように調整
        // 現在のMPと最大MPの差を計算
        int recoverActual = Math.min(recover, this.MAX_MP - this.mp);
        
        // ステップ3: MPを回復
        this.mp += recoverActual;
        
        // ステップ4: 実際に回復したMPの量を返す（重要！）
        return recoverActual;  // このreturn文が戻り値を返す
    }
    
    
    // ============================================
    // 例3: 戻り値があるメソッドの使い方
    // ============================================
    
    /**
     * prayメソッドの使い方の例
     */
    public static void main(String[] args) {
        ClericExample cleric = new ClericExample();
        cleric.name = "聖職者";
        cleric.mp = 5;  // MPが5の状態から開始
        
        System.out.println("=== 祈る前 ===");
        System.out.println("現在のMP: " + cleric.mp);
        System.out.println("最大MP: " + cleric.MAX_MP);
        
        // 【使い方】prayメソッドを呼び出し、戻り値を受け取る
        // 戻り値は「実際に回復したMPの量」
        int recoveredMp = cleric.pray(3);  // 3秒祈る
        
        System.out.println("\n=== 祈った後 ===");
        System.out.println("回復したMP: " + recoveredMp);  // 戻り値を使用
        System.out.println("現在のMP: " + cleric.mp);
        
        // 【ポイント】
        // - voidメソッド（selfAid）は何も返さない
        // - 戻り値があるメソッド（pray）は値を返すので、
        //   その値を受け取って使用できる
        
        System.out.println("\n=== もう一度祈る ===");
        int recoveredMp2 = cleric.pray(5);  // 5秒祈る
        System.out.println("今回回復したMP: " + recoveredMp2);
        System.out.println("現在のMP: " + cleric.mp);
        
        // 【戻り値の活用例】
        // 回復したMPの量を合計する
        int totalRecovered = recoveredMp + recoveredMp2;
        System.out.println("合計回復MP: " + totalRecovered);
    }
}
