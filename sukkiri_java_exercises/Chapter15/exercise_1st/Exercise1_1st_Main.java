package Chapter15.exercise_1st;

public class Exercise1_1st_Main {
    public static void main(String[] args) {
        //定数（メソッド内では static / private は使えない。final のみ可）
        final int ST_NUM = 1;
        final int EN_NUM = 100;

        //繰り返し処理 
        StringBuilder s = new StringBuilder();
        for(int i = ST_NUM; i <= EN_NUM; i++){
            s.append(i + ",");
        }
        String ss = s.toString();
        @SuppressWarnings("unused")
        String[] a = ss.split("[,]");
    }
}
