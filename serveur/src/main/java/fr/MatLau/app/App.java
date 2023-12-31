package fr.MatLau.app;

import static spark.Spark.*;

public class App 
{
    public static void main( String[] args )
    {
        port(8080);
        
        post("/login", (req, res) -> {
            //System.out.println(req.body());
            String username = req.queryParams("username");
            String password = req.queryParams("password");
            //System.out.println(username);
            //System.out.println(password);
            
            String cookie = Login.checkLogin(username, password);
            if(!cookie.equals("")) {
                res.cookie("session_cookie", cookie, 518400);
                res.status(200);
                return "Login Success";
            } else {
                res.status(401);
                return "Login Failed";
            }
        });
	
        get("/logout", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            res.removeCookie("session_cookie");
            Login.logout(cookie);
            return "Logged Out";
	    });

        get("/users", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            }
            return DemandeDAO.getAllUsers();
        });

        get("/myActions", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            }
            return DemandeDAO.getMyActions(username);
        });

        get("/myInformations", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            }
            return DemandeDAO.getMyInformations(username);
        });

        get("/myEvenements", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            }
            return DemandeDAO.getMyEvenements(username);
        });

        post("/createDemande", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            } else {
                String titre = req.queryParams("titre");
                String description = req.queryParams("description");
                String typeDemande = req.queryParams("type").toLowerCase();
                String usersList = req.queryParams("users");
                DemandeDAO.createDemande(username, titre, description, typeDemande, usersList);
                return "Notification créée";
            }
        });

        get("/recent", (req, res) -> {
            String cookie = req.cookie("session_cookie");
            String username = DemandeDAO.usernameFromCookie(cookie);
            if(username.equals("")) {
                res.status(401);
                return "Authentication Error";
            }
            return DemandeDAO.getRecentDemandes(username);
        });
    }
}
