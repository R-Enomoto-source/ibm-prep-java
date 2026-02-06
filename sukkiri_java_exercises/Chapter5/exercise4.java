package Chapter5;

public class exercise4 {
    public static void main(String[] args) {
        //三角形の面積のメソッド呼び出しと表示
        double bottom = 10.0;
        double height = 5.0;
        double triangleAreaCalculatingResult = calcTriangleArea(bottom,height);
        System.out.println("三角形の底辺の長さが" + bottom + "cm、高さが" + height + "cmの場合、面積は" 
                           + triangleAreaCalculatingResult + "平方cm");
        //円の面積のメソッド呼び出しと表示
        double circleRadius = 5.0;
        double circleAreaCalculatingResult = calcCircleArea(circleRadius);
        System.out.println("円の半径が" + circleRadius + "cmの場合、面積は" + circleAreaCalculatingResult
                           + "平方cm");
    }
    public static double calcTriangleArea (double bottom , double height) {
         //三角形の面積のメソッドの計算処理       
        double area2Minutes1Segmentation = 2;
        double calcAns = (bottom * height) / area2Minutes1Segmentation;
        return calcAns;
    }
    public static double calcCircleArea (double radius) {
        //円の面積のメソッドの計算処理
        double pi = 3.14;
        double calcAns = radius * radius * pi;
        return calcAns;
    }
}
