package Chapter16.first.exercise3;

public class Hero {
    
    private String name;
    private int killedEnemyNum;

    public Hero(String name , int killedEnemyNum) {
         this.name = name;
         this.killedEnemyNum = killedEnemyNum; 
        }
    public String getName() { 
        return this.name; 
    }
    public int getKilleEnemyNum(){
        return this.killedEnemyNum;
    }
}

