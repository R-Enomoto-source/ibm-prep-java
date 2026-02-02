package Chapter13.exercise_1st;

public class Hero {
    private String name;
    private int hp;
    
    //getter
    public String getName(){
        return this.name;
    }
    public int getHp(){
        return this.hp;
    }

    //setter
    public void setName(String name){
        this.name = name;        
    }
    public void setHp(int hp){
        this.hp = hp;        
    }
}
