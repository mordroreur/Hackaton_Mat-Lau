package fr.MatLau.app;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Login {

    private static Connection connect = _Connector.getInstance();

    // Creates a random 10 character alphanumeric String to serve as a login cookie
    private static String createCookie() {
        int leftLimit = 48; // numeral '0'
        int rightLimit = 122; // letter 'z'
        int targetStringLength = 10;
        SecureRandom random = new SecureRandom();

        String generatedString = random.ints(leftLimit, rightLimit + 1)
        .filter(i -> (i <= 57 || i >= 65) && (i <= 90 || i >= 97))
        .limit(targetStringLength)
        .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
        .toString();

        return generatedString;
    }

    public static String checkLogin(String username, String password) {
        try {
            PreparedStatement query = connect.prepareStatement("SELECT * FROM users WHERE username collate utf8mb4_bin = ? AND password = ?;");
            query.setString(1, username);
            query.setString(2, password);
            ResultSet resultSet = query.executeQuery();
            if(resultSet.next()) {
                String cookie = createCookie();
                PreparedStatement cookieUpdate = connect.prepareStatement("INSERT INTO cookies VALUES (?,?);");
                cookieUpdate.setString(1, username);
                cookieUpdate.setString(2, cookie);
                cookieUpdate.executeUpdate();
                return cookie;
            } else {
                return ""; // Echec de la connexion
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ""; // Erreur
    }

    public static void logout(String cookie) {
        try {
            PreparedStatement cookieUpdate = connect.prepareStatement("DELETE FROM cookies WHERE cookie collate utf8mb4_bin = ?");
            cookieUpdate.setString(1, cookie);
            cookieUpdate.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
