import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

final String IP = "192.168.160.89";

int tenteMDP = 0;

final dio = Dio();
Directory appDocDir = Directory("");
CookieJar cookieJar = CookieJar();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isAuthenticated = false;

  String calculateSHA256(String input) {
    final bytes = utf8.encode("Seeel" + input + "Poooiivre");
    final res = sha256.convert(bytes);
    return res.toString();
  }

  @override
  void initState() {
    var cron = Cron();
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {});
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    // Check if the user is authenticated (e.g., by checking a token, session, etc.)
    appDocDir = await getApplicationDocumentsDirectory();
    String pth =
        Directory(appDocDir.path.toString() + "/.cookies/").path.toString();
    cookieJar =
        PersistCookieJar(ignoreExpires: false, storage: FileStorage(pth));
    dio.interceptors.add(CookieManager(cookieJar));

    List<Cookie> results =
        await cookieJar.loadForRequest(Uri.parse("http://" + IP + ":8080"));

    setState(() {
      _isAuthenticated = !results.isEmpty;
    });
  }

  Future<void> _login(String username, String password) async {
    // Call your server's login endpoint to get the authentication token
    // Adjust the request body based on your server's requirements
    password = calculateSHA256(password);
    Response response;
    try {
      response = await dio.post(
        "http://" + IP + ":8080/login",
        queryParameters: {'username': '$username', 'password': '$password'},
      );
    } catch (e) {
      tenteMDP = 1;
      setState(() {});
      throw Exception('Failed to login');
    }

    if (response.statusCode == 200) {
      //print(response.headers);
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

    final response = await dio.get(
      "http://" + IP + ":8080/logout",
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
    return _isAuthenticated
        ? MainPage(
            menu: _getDemande,
            logout: _logout,
            resp: Response(requestOptions: RequestOptions()),
          )
        : LoginPage(login: _login);
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 40.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

class _getDemande {}

class MainPage extends StatelessWidget {
  final Function logout;

  MainPage({required menu, required this.logout, required this.resp});

  final Response resp;

  Response rep = Response(requestOptions: RequestOptions());

  Future<bool> _getDBInfo() async {
    rep = await dio.get(
      "http://" + IP + ":8080/myInformations",
    );
    //print(rep.toString());
    return true;
  }

  Future<bool> _getDBEvent() async {
    rep = await dio.get(
      "http://" + IP + ":8080/myEvenements",
    );
    //print(rep.toString());
    return true;
  }

  Future<bool> _getDBAction() async {
    rep = await dio.get(
      "http://" + IP + ":8080/myActions",
    );
    //print(rep.toString());
    return true;
  }

  Future<bool> _getDBUsers() async {
    rep = await dio.get(
      "http://" + IP + ":8080/users",
    );
    //print(rep.toString());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 174, 198, 221),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconection',
            onPressed: () {
              logout();
            },
          ),
        ],
        centerTitle: true,
        title: const Text('MailDrop'),
      ),
      body: Container(
        color: Colors.white, // Page blanche
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                //directions_boat_filled_outlined
                child: IconButton(
                  iconSize: 72,
                  icon: const Icon(Icons.add_box_outlined),
                  tooltip: 'Créer une notification',
                  onPressed: () async {
                    if (await _getDBUsers()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreationMenu(resp: rep)));
                    }
                  }, /*
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreationMenu()));
                  },*/
                ),
              ),
            ]),
            const MySeparator(color: Colors.grey),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Mes Notifications",
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                if (await _getDBInfo()) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformationMenu(resp: rep)));
                }
              },
              child: const Text(
                "Informations",
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                if (await _getDBAction()) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformationMenu(resp: rep)));
                }
              },
              child: const Text(
                "Actions",
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                if (await _getDBEvent()) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformationMenu(resp: rep)));
                }
              },
              child: const Text(
                "Evènements",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
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
        backgroundColor: Color.fromARGB(255, 174, 198, 221),
        title: Text('Login Page'),
      ),
      body: Container(
        color: Color.fromARGB(255, 206, 214, 218),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tenteMDP == 1)
              Text(
                'Mot de passe ou identifiant inconnu',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                hintText: 'Enter your Password',
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
/*
class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;
  const StatefulWrapper({required this.onInit, required this.child});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
*/

class InformationMenu extends StatelessWidget {
  Response resp = Response(requestOptions: RequestOptions());
  InformationMenu({super.key, required this.resp});

  constructWidFromString(BuildContext context) {
    var allCont = <Widget>[];
    var val = json.decode(resp.toString());

    allCont.add(const SizedBox(height: 20));
    //print(val.length);
    for (int i = 1; i < val.length; i++) {
      allCont.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (val[i]['typeDemande'] == 'i')
                ? Color.fromARGB(255, 158, 8, 88)
                : (val[i]['typeDemande'] == 'e')
                    ? Color.fromARGB(255, 216, 196, 16)
                    : (val[i]['priorite'] == 1)
                        ? Colors.red
                        : const Color.fromARGB(255, 197, 197, 197),
          ),
          onPressed: () {
            (Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AfficheZoom(information: val[i]))));
          },
          child: Column(
            children: [
              Text(
                val[i]['titre'].toString(),
                style: const TextStyle(fontSize: 20),
              ),
              (val[i]['description'].toString().length < 51)
                  ? Text(val[i]['description'].toString(),
                      style: const TextStyle(fontSize: 10))
                  : Text(
                      val[i]['description'].toString().substring(0, 50) + "...",
                      style: const TextStyle(fontSize: 10))
            ],
          ),
        ),
      );
      allCont.add(const SizedBox(height: 20));
    }

    return allCont;
  }

  @override
  Widget build(BuildContext context) {
    //final todo = ModalRoute.of(context).!.settings.arguments as Response;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 174, 198, 221),
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: constructWidFromString(context),
      ),
    );
  }
}

class AfficheZoom extends StatelessWidget {
  var information;
  AfficheZoom({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    //final todo = ModalRoute.of(context).!.settings.arguments as Response;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 174, 198, 221),
        title: const Text('Notification'),
      ),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        const SizedBox(height: 20),
        Center(
            child: Text(
          information['titre'],
          style: TextStyle(fontSize: 26, color: Colors.red),
        )),
        Text(information['description'], style: TextStyle(fontSize: 15)),
        const SizedBox(height: 50),
        ElevatedButton(
          child: Text("Traiter"),
          onPressed: () {},
        )
      ]),
    );
  }
}

class CreationMenu extends StatefulWidget {
  var resp;
  CreationMenu({super.key, required this.resp});

  @override
  _CreationMenuState createState() => _CreationMenuState();
}

class _CreationMenuState extends State<CreationMenu> {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  static const List<String> list = <String>[
    'Information',
    'evenement',
    'action'
  ];
  String dropdownValue = list.first;

  Map<String, bool> jsonResponse = {};

/*
  Map<String, bool> values = {
    'foo': true,
    'bar': false,
  }; //List.filled(100, false, growable: true);*/

  @override
  void initState() {
    super.initState();
    // Fetch and decode the response when the widget is initialized

    setState(() {
      var tmp = json.decode(widget.resp.toString());
      for (int i = 0; i < tmp.length; i++) {
        jsonResponse[tmp[i]['username']] = false;
      }
    });
  }

  Future<void> _sendData(
      String titre, String desc, String type, String users) async {
    try {
      Response response = await dio.post(
        "http://" + IP + ":8080/createDemande",
        queryParameters: {
          'titre': '$titre',
          'description': '$desc',
          'type': type.toString().substring(0, 1),
          'users': users
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 174, 198, 221),
        title: const Text('Création de demande'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          TextField(
            controller: titreController,
            decoration: InputDecoration(
              hintText: 'Enter the title',
            ),
          ),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Enter the description',
            ),
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ), //widget.resp.toString()
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: jsonResponse.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key),
                value: jsonResponse[key],
                onChanged: (bool? value) {
                  setState(() {
                    jsonResponse[key] = value!;
                  });
                },
              );
            }).toList(),
          ),
          ElevatedButton(
            child: Text("Envoyer"),
            onPressed: () {
              List<String> selectedUsers = jsonResponse.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();
              _sendData(titreController.text, descriptionController.text,
                  dropdownValue, selectedUsers.toString());
              Navigator.pop(context);
              //print(json.encode(selectedUsers.toString()).toString());
            },
          )
        ],
      ),
    );
  }
}
