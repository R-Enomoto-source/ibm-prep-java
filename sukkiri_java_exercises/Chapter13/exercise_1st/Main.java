package Chapter13.exercise_1st;

public class Main {
    public static void main(String[] args) {
        Hero h = new Hero();
        h.setName("ジロウ");
        h.setHp(100);

        Wizard w = new Wizard();
        Wand wd = new Wand();
        w.setName("タカシ");
        w.setHp(50); 
        w.setMp(10);
        w.setWand(wd);
        wd.setName("樫の杖");
        wd.setPower(10);
        w.heal(h);
        
    }
    
}
