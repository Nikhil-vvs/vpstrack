import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'Trip.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());
final List token = [];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      Map<String, String> headers = {'Authorization': 'Bearer $accesstoken'};
      var response = await http.get(url, headers: headers);
      List convertedDatatoJson = json.decode(response.body);

      return convertedDatatoJson;
    }

    routes(String accesstoken) async {
      String url =
          'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/routes';
      Map<String, String> headers = {'Authorization': 'Bearer $accesstoken'};
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
            token.add(accesstoken);
            var rsp1 = await buses(accesstoken);
            //nikhil
            var rsp2 = await routes(accesstoken);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashBoard(
                        value: rsp1, accesstoken: accesstoken, value1: rsp2)));
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
  final String accesstoken;
  final List value1;
  DashBoard({Key key, @required this.value, this.accesstoken, this.value1})
      : super(key: key);
  @override
  _DashBoardState createState() => new _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final int index = 0;
  final List<Trip> tripsList = [];
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.value.length; i++) {
      for (int j = 0; j < widget.value1.length; j++) {
        if (widget.value1[j]['routeId'] == widget.value[i]['routeId']) {
          widget.value[i]['routename'] = widget.value1[j]['routeName'];
          break;
        }
      }
      tripsList.add(Trip(
          widget.value[i]['IMEI'],
          widget.value[i]['driverId'],
          widget.value[i]['fuelCapacity'],
          widget.value[i]['personCapacity'],
          widget.value[i]['routeId'],
          widget.value[i]['status'],
          widget.value[i]['vehicleNo'],
          widget.value[i]['routename']));
    }
    var iconButton = IconButton(
        icon: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.clear();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => MyApp()));
        });
    return Scaffold(
      body: Container(
        child: new ListView.builder(
            itemCount: tripsList.length,
            itemBuilder: (BuildContext context, int index) =>
                buildTripCard(context, index)),
      ),
      appBar: new AppBar(
        title: new Text("Dash Board"),
        actions: <Widget>[iconButton],
      ),
    );
    return Scaffold(
      body: Container(
        child: new ListView.builder(
            itemCount: tripsList.length,
            itemBuilder: (BuildContext context, int index) =>
                buildTripCard(context, index)),
      ),
      appBar: new AppBar(
        title: new Text("Dash Board"),
      ),
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
                child: Row(children: <Widget>[
                  Text(
                    "Route Name: " +
                        widget.value[index]['routename'].toString(),
                    style: new TextStyle(fontSize: 13.0),
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
                        var routeName = [
                          {'routeName': widget.value[index]['routename']}
                        ];
                        if (token.length == 1) {
                          token.add(widget.value[index]['routeId']);
                        } else {
                          token[1] = widget.value[index]['routeId'];
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashBoard1(
                                    routevalue: routevalue,
                                    accesstoken: widget.accesstoken,
                                    routename: routeName)));
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
  final String accesstoken;
  final List routename;
  DashBoard1(
      {Key key, @required this.routevalue, this.accesstoken, this.routename})
      : super(key: key);
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
                    Text(
                      "Route Name: " +
                          widget.routename[0]['routeName'].toString(),
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
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
  driver(String accesstoken) async {
    final url =
        'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/drivers';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var response = await http.get(url, headers: headers);
    List convertedDatatoJson = json.decode(response.body);
    return convertedDatatoJson;
  }

  busstops(String accesstoken) async {
    final url =
        'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/busstops';
    Map<String, String> headers = {'Authorization': 'Bearer $accesstoken'};
    var response = await http.get(url, headers: headers);
    Map<String, dynamic> convertedDatatoJson = json.decode(response.body);
    return convertedDatatoJson;
  }

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
                  FlatButton(
                    onPressed: () async {
                      if (data.title == "Locations") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LiveTracking(title: "LiveTracking")));
                      }
                      ;
                      if (data.title == "Bus Stops") {
                        final List busstop = [];
                        var resp = await busstops(token[0]);
                        bool isKeyPresent =
                            resp.containsKey(token[1].toString());
                        if (isKeyPresent == true) {
                          for (var i = 0;
                              i < resp[token[1].toString()].length;
                              i++) {
                            busstop.add(
                                resp[token[1].toString()][i]['busStopName']);
                          }
                          ;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BusStop(busstop: busstop)));
                      }
                      ;
                      if (data.title == "Vehicle Status") {
                        var resp = await driver(token[0]);
                        for (int i = 0; i < resp.length; i++) {
                          if (token[1] == resp[i]['routeId']) {
                            final String status = resp[i]['status'];
                            final int fuelCapacity = resp[i]['fuelCapacity'];
                            final int personCapacity =
                                resp[i]['personCapacity'];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleStatus(
                                        status: status,
                                        fuelCapacity: fuelCapacity,
                                        personCapacity: personCapacity)));
                          }
                        }
                      }
                      ;
                      if (data.title == "Driver Details") {
                        var resp = await driver(token[0]);
                        for (int i = 0; i < resp.length; i++) {
                          if (token[1] == resp[i]['routeId']) {
                            final String driverName = resp[i]['driverName'];
                            final int driverId = resp[i]['driverId'];
                            final String phoneNo = resp[i]['phone'];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DriverDetails(
                                        driverName: driverName,
                                        driverId: driverId,
                                        phoneNo: phoneNo)));
                          }
                        }
                      }
                      ;
                    },
                    child: Image.asset(
                      data.img,
                      width: 42,
                    ),
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

class DriverDetails extends StatefulWidget {
  String driverName;
  int driverId;
  String phoneNo;
  DriverDetails(
      {Key key, @required this.driverName, this.driverId, this.phoneNo})
      : super(key: key);
  @override
  _DriverDetailsState createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/driver.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      "Driver ID: ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.driverId.toString(),
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "Driver Name: ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.driverName,
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "Phone No: ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.phoneNo,
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
        ],
      ),
      appBar: new AppBar(title: new Text("Driver Details")),
    );
  }
}

class BusStop extends StatefulWidget {
  final List busstop;
  BusStop({Key key, @required this.busstop}) : super(key: key);
  @override
  _BusStopState createState() => _BusStopState();
}

class _BusStopState extends State<BusStop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: new ListView.builder(
            itemCount: widget.busstop.length,
            itemBuilder: (BuildContext context, int index) =>
                buildBusstops(context, index)),
      ),
      appBar: new AppBar(
        title: new Text("Bus Stops"),
      ),
    );
  }

  Widget buildBusstops(BuildContext context, int index) {
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
                    (index + 1).toString() + ". " + widget.busstop[index],
                    style: new TextStyle(fontSize: 20.0),
                  ),
                  Spacer(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleStatus extends StatefulWidget {
  final String status;
  final int personCapacity;
  final int fuelCapacity;
  VehicleStatus(
      {Key key, @required this.status, this.personCapacity, this.fuelCapacity})
      : super(key: key);
  @override
  _VehicleStatusState createState() => _VehicleStatusState();
}

class _VehicleStatusState extends State<VehicleStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/buses.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      "Status : ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.status,
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "Fuel Capacity: ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.fuelCapacity.toString(),
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "Person Capacity: ",
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      widget.personCapacity.toString(),
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
        ],
      ),
      appBar: new AppBar(title: new Text("Vehicle Status")),
    );
  }
}

class LiveTracking extends StatefulWidget {
  LiveTracking({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LiveTrackingState createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  @override
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  Future<List> locationv(String accesstoken) async {
    final url =
        'http://ec2-13-233-193-38.ap-south-1.compute.amazonaws.com/tracking';
    Map<String, String> headers = {'Authorization': 'Bearer $accesstoken'};
    var response = await http.get(url, headers: headers);
    List convertedDatatoJson = json.decode(response.body);
    return convertedDatatoJson;
  }

  final CameraPosition initialLocation = CameraPosition(
    target: LatLng(17.390614, 78.3181),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData,
      String longitude, String latitude) {
    LatLng latlng = LatLng(double.parse(latitude), double.parse(longitude));
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      var resp = await locationv(token[0]);
      String latitude = "17.390614";
      String longitude = "78.3181";
      for (int i = 0; i < resp.length; i++) {
        if (token[1] == resp[i]['routeId']) {
          latitude = resp[i]['latitude'];
          longitude = resp[i]['longitude'];
        }
      }

      updateMarkerAndCircle(location, imageData, longitude, latitude);
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(double.parse(latitude), double.parse(longitude)),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData, longitude, latitude);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String img;
  Items({this.title, this.subtitle, this.img});
}
