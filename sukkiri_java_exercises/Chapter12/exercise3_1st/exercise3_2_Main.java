package Chapter12.exercise3_1st;

public class exercise3_2_Main {
    public static void main(String[] args) {
        //インスタンス生成
        A a1 = new A ();
        B b1 = new B ();

        //配列への格納
        Y[] array = {a1,b1};

        //配列からの取り出し
        for(Y ins: array){
            //それぞれのインスタンスの呼び出し
            ins.b();
        }
    }
}