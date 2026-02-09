package Chapter18;

import javax.swing.*;

public class GUITest {
    public static void main(String[] args) {
        JFrame frame = new JFrame("はじめてのGUI");
        JLabel label = new JLabel("Hello World!!");
        JButton button = new JButton("押してね");
        
        frame.add(label);
        frame.add(button);
        frame.setLayout(new java.awt.FlowLayout());
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(300, 100);
        frame.setVisible(true);
    }
}