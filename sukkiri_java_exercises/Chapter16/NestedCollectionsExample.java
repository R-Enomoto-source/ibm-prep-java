import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 図16-18 ネストしたコレクションの実装例
 * Map のキーに都道府県名、値にその特産品の List を格納する構造
 */
public class NestedCollectionsExample {

    public static void main(String[] args) {
        // 1. Map の中に List をネストした構造を宣言
        // キー: 都道府県名 (String)、値: 特産品のリスト (List<String>)
        Map<String, List<String>> regionalProducts = new HashMap<>();

        // 2. 「東京都」の特産品リストを作成し、Map に追加
        List<String> tokyoProducts = new ArrayList<>();
        tokyoProducts.add("切子");
        tokyoProducts.add("佃煮");
        tokyoProducts.add("寿司");
        tokyoProducts.add("のり");
        regionalProducts.put("東京都", tokyoProducts);

        // 3. 「京都府」の特産品リストを作成し、Map に追加
        List<String> kyotoProducts = new ArrayList<>();
        kyotoProducts.add("織物");
        kyotoProducts.add("人形");
        kyotoProducts.add("漬け物");
        kyotoProducts.add("陶器");
        regionalProducts.put("京都府", kyotoProducts);

        // 4. 全地域の特産品を表示
        System.out.println("--- 全ての地域と特産品を表示 ---");
        for (Map.Entry<String, List<String>> entry : regionalProducts.entrySet()) {
            String prefecture = entry.getKey();
            List<String> products = entry.getValue();

            System.out.println(prefecture + "の特産品:");
            for (String product : products) {
                System.out.println("  - " + product);
            }
        }

        // 5. 特定の地域の特産品だけを取得して表示
        System.out.println("\n--- 特定の地域の特産品を取得 ---");
        String searchPrefecture = "東京都";
        if (regionalProducts.containsKey(searchPrefecture)) {
            List<String> products = regionalProducts.get(searchPrefecture);
            System.out.println(searchPrefecture + "の特産品:");
            for (String product : products) {
                System.out.println("  - " + product);
            }
        } else {
            System.out.println(searchPrefecture + "のデータはありません。");
        }

        searchPrefecture = "沖縄県";
        if (regionalProducts.containsKey(searchPrefecture)) {
            List<String> products = regionalProducts.get(searchPrefecture);
            System.out.println(searchPrefecture + "の特産品:");
            for (String product : products) {
                System.out.println("  - " + product);
            }
        } else {
            System.out.println(searchPrefecture + "のデータはありません。");
        }
    }
}
