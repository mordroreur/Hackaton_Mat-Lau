package fr.MatLau.app;


import static spark.Spark.*;
/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
		
		port(8080); // Spark will run on port 8080
		
        get("/hello", (req, res) -> "Hello World");
    }
}
