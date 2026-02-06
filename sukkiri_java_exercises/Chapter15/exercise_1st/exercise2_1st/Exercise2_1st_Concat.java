package Chapter15.exercise_1st.exercise2_1st;

public class Exercise2_1st_Concat {
    //フィールド
    String folder;
    String file;
    //メソッド
    public String concatenateFolderAndFile(String folder , String file){
        //folderの編集
        //folderは末尾に\がついていなかったらつける。つけてから連結させる。
        if(!(folder.endsWith("\\"))){
            folder += "\\";
        }
        String sf = folder + file;
        return sf;
    }
}
