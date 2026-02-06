package Chapter14.exercise1_1st;

public class CheckProduct {
    public static void main(String[] args) {
        Product p = new Product();
        p.productCode = "A001";
        p.price = 980;
        System.out.println(p);   // ① → ¥980(商品コード:A001)
    
        Product q = new Product();
        q.productCode = " A001 ";  // 前後にスペース
        q.price = 100;
        System.out.println(p.equals(q));  // ② → true（商品コードが同じとみなす）
    
        Product r = new Product();
        r.productCode = "B002";
        r.price = 980;
        System.out.println(p.equals(r));  // → false
    }
}
