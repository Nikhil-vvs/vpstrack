import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter login UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //bool _isLoading = false;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String message = '';
  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      obscureText: false,
      style: style,
      controller: userNameController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: passwordController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    signIn(String username, String password) async {
      final url =
          'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/login';
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final msg = json.encode({"username": username, "password": password});
      var response = await http.post(url, headers: headers, body: msg);
      Map<String, dynamic> convertedDatatoJson = json.decode(response.body);
      return convertedDatatoJson;

      //if (response.statusCode == 200) {}
    }

    buses(String accesstoken) async {
      final url =
          'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/buses';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var response = await http.get(url, headers: headers);
      List convertedDatatoJson = json.decode(response.body);
      return convertedDatatoJson;
    }

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          setState(() {
            message = 'Please Wait...';
          });
          var rsp =
              await signIn(userNameController.text, passwordController.text);
          if (rsp.containsKey('access_token')) {
            setState(() {
              message = 'Login Successful';
            });
            String accesstoken = rsp['access_token'];
            String vendorName = rsp['vendorName'];
            var rsp1 = await buses(accesstoken);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashBoard(value: rsp1)));
          } else {
            setState(() {
              message = 'Invalid Credentials!';
            });
          }
          ;
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "assets/buspic.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 45.0),
                textField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 15.0,
                ),
                Text(message),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('New user?'),
                    FlatButton(
                      child: Text(
                        'Signup',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: () {},
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashBoard extends StatefulWidget {
  final List value;

  DashBoard({Key key, @required this.value}) : super(key: key);
  @override
  _DashBoardState createState() => new _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: List.generate(widget.value.length, (index) {
          return Text(
              "Route Id:" +
                  widget.value[index]['routeId'].toString() +
                  "\n" +
                  "VehicleNo:" +
                  widget.value[index]['vehicleNo'] +
                  "\n" +
                  "Status:" +
                  widget.value[index]['status'],
              style: TextStyle(fontSize: 30));
        }),
      )),
      appBar: new AppBar(
        title: new Text("Dash Board"),
      ),
    );
  }
}
