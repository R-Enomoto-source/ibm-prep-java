package Chapter10.exercise3_1st;

public class Main {
    public static void main(String[] args) {
        Hero h = new Hero();
        PoisonMatango m = new PoisonMatango('A');
        
        m.attack(h);

        m.attack(h);

        m.attack(h);

        m.attack(h);

        m.attack(h);

        m.attack(h);

        System.out.println(h.name + "の残りのHPは"+ h.hp + "です");
    }
}
