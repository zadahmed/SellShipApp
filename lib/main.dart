import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SellShip/screens/additem.dart';

import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:SellShip/screens/onboarding.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//
//  _getToken() {
//    _firebaseMessaging.getToken().then((deviceToken) {
//      print(deviceToken);
//    });
//  }
//
//  _configureFirebaseListeners() {
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print('onMessage: $message');
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print('onLaunch: $message');
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print('onResume: $message');
//      },
//    );
//  }

  @override
  void initState() {
//    _getToken();
//    _configureFirebaseListeners();
    _getLocation();
    super.initState();
  }

  final storage = new FlutterSecureStorage();

  var latitude;
  var longitude;
  static LatLng position;

  var firsttime;

  _getLocation() async {
    Location _location = new Location();
    var location;

    try {
      location = await _location.getLocation();
      await storage.write(key: 'latitude', value: location.latitude.toString());
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());

        getcity();
      });
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
    }
  }

  var city;

  final Geolocator geolocator = Geolocator();
  void getcity() async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];
    var cit = place.administrativeArea;
    var country = place.country;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'country', value: country);
    setState(() {
      city = cit;
      print(city);
      //secure storage save it
    });
  }

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blue,
      home: new Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  final storage = new FlutterSecureStorage();

  var latitude;
  var longitude;
  static LatLng position;

  var firsttime;

  _getLocation() async {
    firsttime = await storage.read(key: 'firsttime');
    setState(() {
      firsttime = firsttime;
    });
    Location _location = new Location();
    var location;

    try {
      location = await _location.getLocation();
      await storage.write(key: 'latitude', value: location.latitude.toString());
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = p[0];
      var cit = place.administrativeArea;
      var country = place.country;
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'country', value: country);
      setState(() {
        city = cit;
        print(city);
        //secure storage save it
      });
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
    }
  }

//
  final Geolocator geolocator = Geolocator();
  static String city;

  void getcity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new RootScreen()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new OnboardingScreen()));
    }
  }

  @override
  void initState() {
    super.initState();

    new Timer(new Duration(milliseconds: 200), () {
      if (mounted) {
        _getLocation();
        getcity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return new Scaffold(
      body: new Center(
        child: new Container(
            color: Colors.deepOrange,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: Image.asset('assets/logo.png'),
                ),
                SizedBox(
                  height: 10,
                ),
                SpinKitChasingDots(color: Colors.white),
              ],
            )),
      ),
    );
  }
}
