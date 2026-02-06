package Chapter8;

/**
 * Clericクラスのprayメソッドの完全な実装例
 * 
 * エラー「This method must return a result of type int」を解決する方法
 */
public class ClericCompleteExample {
    
    String name;
    int hp = 50;
    final int MAX_HP = 50;
    int mp = 10;
    final int MAX_MP = 10;
    
    
    // ============================================
    // エラーの原因と解決方法
    // ============================================
    
    /*
     * 【エラーの原因】
     * public int pray(int a) {
     *     // return文がない → エラー！
     * }
     * 
     * 【解決方法】
     * 戻り値があるメソッド（int型を返す）は、必ずreturn文で値を返す必要があります。
     * メソッドの中身が空だと、Javaコンパイラは「値を返すはずなのに返していない」と判断してエラーを出します。
     */
    
    
    // ============================================
    // 段階的な実装例
    // ============================================
    
    /**
     * 【ステップ1】最小限の修正（エラー解消のみ）
     * これでエラーは解消されますが、まだ正しい動作はしません
     */
    @SuppressWarnings("unused")
    public int prayStep1(int second) {
        return 0;  // とりあえず0を返す（second はステップ2で使用）
    }
    
    
    /**
     * 【ステップ2】基本的な実装
     * 祈った秒数をそのまま返す（ランダム補正なし）
     */
    public int prayStep2(int second) {
        // 回復量 = 祈った秒数
        int recover = second;
        
        // MPを回復（最大MPを超えないように）
        int recoverActual = Math.min(recover, this.MAX_MP - this.mp);
        this.mp += recoverActual;
        
        // 実際に回復したMPの量を返す
        return recoverActual;
    }
    
    
    /**
     * 【ステップ3】完全な実装（練習問題の要件を満たす）
     * 祈った秒数 + ランダムで0~2ポイントの補正を加える
     */
    public int prayStep3(int second) {
        // 回復量を計算（祈った秒数 + ランダムで0~2ポイントの補正）
        int recover = second + new java.util.Random().nextInt(3); // 0~2のランダム値
        
        // 最大MPを超えないように調整
        int recoverActual = Math.min(recover, this.MAX_MP - this.mp);
        
        // MPを回復
        this.mp += recoverActual;
        
        // 実際に回復したMPの量を返す
        return recoverActual;
    }
    
    
    // ============================================
    // 完全な実装（推奨）
    // ============================================
    
    /**
     * 祈る行動を行い、MPを回復する
     * 
     * @param second 祈る秒数
     * @return 実際に回復したMPの量
     */
    public int pray(int second) {
        // 回復量 = 祈った秒数 + ランダムで0~2ポイントの補正
        int recover = second + new java.util.Random().nextInt(3);
        
        // 最大MPを超えないように調整
        int recoverActual = Math.min(recover, this.MAX_MP - this.mp);
        
        // MPを回復
        this.mp += recoverActual;
        
        // 実際に回復したMPの量を返す（重要！return文がないとエラー）
        return recoverActual;
    }
    
    
    // ============================================
    // 使い方の例
    // ============================================
    
    public static void main(String[] args) {
        ClericCompleteExample cleric = new ClericCompleteExample();
        cleric.mp = 5;  // MPが5の状態
        
        System.out.println("祈る前のMP: " + cleric.mp);
        
        // prayメソッドを呼び出し、戻り値を受け取る
        int recovered = cleric.pray(3);  // 3秒祈る
        
        System.out.println("回復したMP: " + recovered);
        System.out.println("祈った後のMP: " + cleric.mp);
    }
}
