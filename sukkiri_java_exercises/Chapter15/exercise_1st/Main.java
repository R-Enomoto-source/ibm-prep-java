package Chapter15.exercise_1st;

import java.util.Calendar;
import java.util.Date;

public class Main {
    public static void main(String[] args) {
        // 1. 現在の日時をDate型で取得する。
        Date dt = new Date();
        // 2. 取得した日時情報をCalendarにセットする。
        Calendar cl = Calendar.getInstance();
        cl.setTime(dt);
        // 3. Calendarから「日」の数値を取得する。
        int cl.get(Calendar.DAY_OF_MONTH);
        // 4. 取得した値に100を足した値をCalendarの「日」にセットする。

        // 5. Calendarの日時情報をDate型に変換する。
        // 6. SimpleDateFormatを用いて、指定された形式でDateインスタンスの内容を表示する。

        
    }
}
