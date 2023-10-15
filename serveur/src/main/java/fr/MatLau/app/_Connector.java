package fr.MatLau.app;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class _Connector {
    static String url = "jdbc:mysql://localhost:3306/MatLauDB";
    static String user = "Matlau_App";
    static String password = "Matlau_App";

    private static Connection connect;

    public static Connection getInstance(){
        if(connect == null){
            try {
                connect = DriverManager.getConnection(url, user, password);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return connect;
    }
}
