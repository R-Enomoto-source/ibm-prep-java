package Chapter16.first.exercise2;

import java.util.List;
import java.util.ArrayList;

public class NameDisplay {
    public static void main(String[] args) {
        Hero hero1 = new Hero("斎藤");
        Hero hero2 = new Hero("鈴木");

        List<String> heroNames = new ArrayList<String>();
        heroNames.add(hero1.getName());
        heroNames.add(hero2.getName());
        
        for(String dispay : heroNames){
            System.out.println(dispay);
        }
    }
}
