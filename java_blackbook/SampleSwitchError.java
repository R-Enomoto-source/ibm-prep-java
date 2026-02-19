public class SampleSwitchError {
    public static void main(String[] args) {
        for (int i = 0; i < 4; i++) {
            print(i);
        }
    }

    private static void print(int i) {
        String str = switch (i) {
            case 1 -> "one";
            case 2 -> "two";
            case 3 -> "three";
        };
        System.out.println(str);
    }
}
