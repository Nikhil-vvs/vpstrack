import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'Trip.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

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

    routes(String accesstoken) async {
      String url =
          'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/routes';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var response = await http.get(url, headers: headers);
      Map<String, dynamic> convertedDatatoJson = json.decode(response.body);
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
            final String accesstoken = rsp['access_token'];
            String vendorName = rsp['vendorName'];
            var rsp1 = await buses(accesstoken);
            //var rsp2 = await routes(accesstoken);
            //print(rsp2);
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
      appBar: new AppBar(
        title: new Text("Vehicle Tracking System"),
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
  final int index = 0;
  final List<Trip> tripsList = [];
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.value.length; i++) {
      tripsList.add(Trip(
          widget.value[i]['IMEI'],
          widget.value[i]['driverId'],
          widget.value[i]['fuelCapacity'],
          widget.value[i]['personCapacity'],
          widget.value[i]['routeId'],
          widget.value[i]['status'],
          widget.value[i]['vehicleNo']));
    }
    return Container(
      child: new ListView.builder(
          itemCount: tripsList.length,
          itemBuilder: (BuildContext context, int index) =>
              buildTripCard(context, index)),
    );
  }

  Widget buildTripCard(BuildContext context, int index) {
    final trip = tripsList[index];
    return new Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Row(children: <Widget>[
                  Text(
                    "Vehicle No: " + widget.value[index]['vehicleNo'],
                    style: new TextStyle(fontSize: 20.0),
                  ),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Row(children: <Widget>[
                  Text(
                    "Route Id: " + widget.value[index]['routeId'].toString(),
                    style: new TextStyle(fontSize: 15.0),
                  ),
                  Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Status: " + widget.value[index]['status'],
                      style: new TextStyle(fontSize: 15.0, color: Colors.green),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.directions_bus),
                      onPressed: () {
                        var routevalue = [
                          {'routeId': widget.value[index]['routeId']}
                        ];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DashBoard1(routevalue: routevalue)));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DashBoard1 extends StatefulWidget {
  final List routevalue;

  DashBoard1({Key key, @required this.routevalue}) : super(key: key);
  @override
  _DashBoard1State createState() => new _DashBoard1State();
}

class _DashBoard1State extends State<DashBoard1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Route No: " + widget.routevalue[0]['routeId'].toString(),
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          GridDashboard()
        ],
      ),
      appBar: new AppBar(title: new Text("Bus Details")),
    );
  }
}

class GridDashboard extends StatelessWidget {
  Items item1 =
      new Items(title: "Bus Stops", subtitle: "", img: "assets/busstops.PNG");

  Items item2 = new Items(
    title: "Vehicle Status",
    subtitle: "",
    img: "assets/buses.png",
  );
  Items item3 = new Items(
    title: "Locations",
    subtitle: "Live Tracking",
    img: "assets/map.png",
  );
  Items item6 = new Items(
    title: "Driver Details",
    subtitle: "",
    img: "assets/driver.png",
  );

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2, item3];
    myList.add(item6);
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return Container(
              decoration: BoxDecoration(
                  color: Color(color), borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    data.img,
                    width: 42,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    data.title,
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            );
          }).toList()),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String img;
  Items({this.title, this.subtitle, this.img});
}
