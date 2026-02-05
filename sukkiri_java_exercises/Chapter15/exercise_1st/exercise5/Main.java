package Chapter15.exercise_1st.exercise5;

import java.time.*;
import java.time.format.DateTimeFormatter;

public class Main {
    public static void main(String[] args) {
        LocalDate ld = LocalDate.now();
        LocalDate ldAfter100 = ld.plusDays(100);
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("西暦yyyy年mm月dd日");
        
        
    }
}
