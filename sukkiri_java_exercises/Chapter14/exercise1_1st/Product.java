package Chapter14.exercise1_1st;

public class Product {
    //フィールド
    String productCode;
    int price;
    
    //メソッド
    //①のメソッド
    public String toString(){
        return "¥¥" + this.price + "(商品コード:" + this.productCode + ")";
        /*日本語環境で¥マークを正しく表示する方法
          return "\u00A5" + this.price + "(商品コード:" + this.productCode + ")";
        */
        
    }
    //②のメソッド
    public boolean equals(Object o){
        if (this == o) {
            return true;
        }
        if(o instanceof Product a){
            String pc1 = this.productCode.trim();
            String pc2 = a.productCode.trim();
            if (pc1.equals(pc2)) {
                return true;                
            }
        }
        return false;
    }

}
