import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SellShip/screens/additem.dart';

import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:SellShip/screens/onboarding.dart';
import 'package:SellShip/screens/rootscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

        getcity();
      });
    } on Exception catch (e) {
      print(e);
      location = null;
    }
  }

  final Geolocator geolocator = Geolocator();
  static String city;

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

  @override
  void initState() {
    _getLocation();

    super.initState();
  }

  FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SellShip',
      home: firsttime == null ? OnboardingScreen() : RootScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
