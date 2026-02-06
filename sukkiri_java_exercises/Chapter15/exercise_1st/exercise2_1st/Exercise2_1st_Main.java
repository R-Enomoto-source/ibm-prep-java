package Chapter15.exercise_1st.exercise2_1st;

public class Exercise2_1st_Main {
    public static void main(String[] args) {
        Exercise2_1st_Concat concat = new Exercise2_1st_Concat();
        concat.folder = "c:\\javadev";
        concat.file = "readme.txt";

        String ff = concat.concatenateFolderAndFile(concat.folder,concat.file);
        System.out.println(ff);
    }
}
