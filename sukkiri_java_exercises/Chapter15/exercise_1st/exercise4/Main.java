package Chapter15.exercise_1st.exercise4;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class Main {
    public static void main(String[] args) {
        //定数
        final int AFTER_HUNDRED_DATE = 100;

        // 1. 現在の日時をDate型で取得する。
        Date dt = new Date();
        // 2. 取得した日時情報をCalendarにセットする。
        Calendar cl = Calendar.getInstance();
        cl.setTime(dt);
        // 3. Calendarから「日」の数値を取得する。
        int cld = cl.get(Calendar.DAY_OF_MONTH);
        // 4. 取得した値に100を足した値をCalendarの「日」にセットする。
        cld += AFTER_HUNDRED_DATE;
        cl.set(Calendar.DAY_OF_MONTH,cld);
        // 5. Calendarの日時情報をDate型に変換する。
        dt = cl.getTime();
        // 6. SimpleDateFormatを用いて、指定された形式でDateインスタンスの内容を表示する。
        SimpleDateFormat sdf = new SimpleDateFormat("西暦yyyy年mm月dd日");
        String dateAfterHundredDate = sdf.format(dt);
        System.out.println(dateAfterHundredDate);
        
    }
}
