package fr.MatLau.app;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.jooq.RecordMapper;
import org.jooq.impl.DSL;
import org.jooq.tools.json.JSONArray;
import org.jooq.tools.json.JSONObject;
import org.json.JSONException;

public class DemandeDAO {
    private static Connection connect = _Connector.getInstance();

    private static JSONArray resultSetToJSON(ResultSet resultSet) {
        try {
            ResultSetMetaData md = resultSet.getMetaData();
            int numCols = md.getColumnCount();
            List<String> colNames = IntStream.range(0, numCols)
            .mapToObj(i -> {
                try {
                    return md.getColumnName(i + 1);
                } catch (SQLException e) {
                    e.printStackTrace();
                    return "?";
                }
            })
            .collect(Collectors.toList());

            JSONArray result = new JSONArray();
            while (resultSet.next()) {
                JSONObject row = new JSONObject();
                colNames.forEach(cn -> {
                    try {
                        row.put(cn, resultSet.getObject(cn));
                    } catch (JSONException | SQLException e) {
                        e.printStackTrace();
                    }
                });
                result.add(row);
            }
            return result;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String usernameFromCookie(String cookie) {
        String username="";
        try {
            PreparedStatement query = connect.prepareStatement("SELECT * FROM cookies WHERE cookie collate utf8mb4_bin = ?;");
            query.setString(1, cookie);
            ResultSet resultSet = query.executeQuery();
            if(resultSet.next()) username = resultSet.getString("username");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return username;
    }

    public static String getMyActions(String cookie) {
        try {
            String username = usernameFromCookie(cookie);
            //System.out.println(username);

            // Recuperation des actions que l'utilisateur traite
            PreparedStatement query = connect.prepareStatement("SELECT idDemande, titre, description, createur, dateCreation, acteur, priorite FROM Demandes NATURAL JOIN userDemande WHERE typeDemande = 'a' AND username COLLATE utf8mb4_bin = ? AND acteur COLLATE utf8mb4_bin = ?;");
            query.setString(1, username);
            query.setString(2, username);
            ResultSet resultSet = query.executeQuery();
            String part1 = resultSetToJSON(resultSet).toString();
            //System.out.println("partie 1 " + part1);

            // Recuperation des actions non traitees
            query = connect.prepareStatement("SELECT idDemande, titre, description, createur, dateCreation, acteur, priorite FROM Demandes NATURAL JOIN userDemande WHERE username COLLATE utf8mb4_bin = ? AND acteur IS NULL ORDER BY priorite, dateCreation DESC;");
            query.setString(1, username);
            resultSet = query.executeQuery();
            String part2 = resultSetToJSON(resultSet).toString();
            //System.out.println("partie 2 " + part2);

            // Recuperation des actions que quelqu'un d'autre traite
            query = connect.prepareStatement("SELECT idDemande, titre, description, createur, dateCreation, acteur, priorite FROM Demandes NATURAL JOIN userDemande WHERE username COLLATE utf8mb4_bin = ? AND acteur IS NOT NULL AND acteur COLLATE utf8mb4_bin != ?;");
            query.setString(1, username);
            query.setString(2, username);
            resultSet = query.executeQuery();
            String part3 = resultSetToJSON(resultSet).toString();
            //System.out.println("partie 3 " + part3);

            String fusedString = "[{\"username\":\"" + username + "\"}," + part1.substring(1, part1.length() - 1) + "," + part2.substring(1, part2.length() - 1) + "," + part3.substring(1);
            fusedString = fusedString.replace(",,", ",").replace(",]","]").replace(",]","]");
            //System.out.println(fusedString);
            return fusedString;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ""; // Erreur
    }

    public static String getMyEvenements(String cookie) {
        try {
            String username = usernameFromCookie(cookie);
            //System.out.println(username);

            // Recuperation des evenements
            PreparedStatement query = connect.prepareStatement("SELECT idDemande, titre, description, createur, dateCreation, participe FROM Demandes NATURAL JOIN userDemande WHERE typeDemande = \"e\" and username COLLATE utf8mb4_bin = ? ORDER BY CASE WHEN participe = TRUE THEN 1 WHEN participe IS NULL THEN 2 WHEN participe = FALSE THEN 3 ELSE 4 END;");
            query.setString(1, username);
            ResultSet resultSet = query.executeQuery();
            String json = resultSetToJSON(resultSet).toString();

            return json;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ""; // Erreur
    }

    public static String getMyInformations(String cookie) {
        try {
            String username = usernameFromCookie(cookie);
            //System.out.println(username);

            // Recuperation des informations
            PreparedStatement query = connect.prepareStatement("SELECT idDemande, titre, description, createur, dateCreation FROM Demandes NATURAL JOIN userDemande WHERE typeDemande = \"i\" and username COLLATE utf8mb4_bin = ?;");
            query.setString(1, username);
            ResultSet resultSet = query.executeQuery();
            String json = resultSetToJSON(resultSet).toString();

            return json;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ""; // Erreur
    }

    public static String getAllUsers() {
        try {
            // Recuperation des users
            PreparedStatement query = connect.prepareStatement("SELECT username FROM users;");
            ResultSet resultSet = query.executeQuery();
            String json = resultSetToJSON(resultSet).toString();

            return json;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ""; // Erreur
    }
}
