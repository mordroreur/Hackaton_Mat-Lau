import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

final String IP = "192.168.246.89";

int tenteMDP = 0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationWrapper(),
    );
  }

}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {

  bool _isAuthenticated = false;

  final dio = Dio();
  Directory appDocDir = Directory("");
  CookieJar cookieJar = CookieJar();
  

  String calculateSHA256(String input) {
    final bytes = utf8.encode("Seeel" + input + "Poooiivre");
    final res = sha256.convert(bytes);
    return res.toString();
  }

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    // Check if the user is authenticated (e.g., by checking a token, session, etc.)
    appDocDir =  await getApplicationDocumentsDirectory();
    String pth = Directory(appDocDir.path.toString() + "/.cookies/").path.toString();
    print("Le sting : ");
    print(pth);
    print("fini");
    cookieJar = PersistCookieJar(ignoreExpires: false, storage: FileStorage(pth));
    dio.interceptors.add(CookieManager(cookieJar)); 

    List<Cookie> results = await cookieJar.loadForRequest(Uri.parse("http://192.168.246.89:8080"));

    //print(results.isEmpty);
    

    setState(() {
      _isAuthenticated = !results.isEmpty;
    });
  }

  Future<void> _login(String username, String password) async {
    // Call your server's login endpoint to get the authentication token
    // Adjust the request body based on your server's requirements
    password = calculateSHA256(password);
    
    final response = await dio.post(
      "http://192.168.246.89:8080/login",
      queryParameters: {'username' : '$username', 'password' : '$password' },
    );


    if (response.statusCode == 200) {

      print(response.headers);
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      tenteMDP = 1;
      setState(() {});
      throw Exception('Failed to login');
    }
  }

  Future<void> _logout() async {
    // Call your server's logout endpoint TODO
    //await http.post(Uri.parse('your_api_endpoint/logout_endpoint'));

    final response = await dio.get("http://192.168.246.89:8080/logout",
      //Uri.http("192.168.246.89:8080", "/users"),
      //headers: {},
      /*headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },*/
      //body: // Update with actual password input
      
    );

    //await _storage.delete(key: 'auth_token');
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated ? MainPage(logout: _logout) : LoginPage(login: _login);
  }
}

class MainPage extends StatelessWidget {
  final Function logout;

  MainPage({required this.logout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Container(
        color: Colors.white, // Page blanche
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              logout();
            },
            child: Text('Déconnexion'),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Function login;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({required this.login});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Container(
        color: Colors.blueGrey,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tenteMDP == 1)
              Text(
                'Mot de passe ou identifiant inconnu',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
              ),
              autocorrect: false,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Enter your Pasword',
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text;
                String password = passwordController.text;
                login(username, password);
              },
              child: Text('Login'),
              ),
          ],
        ),
      ),
    );
  }
}
