import 'dart:io';

import 'package:flutter_icons/flutter_icons.dart';
import 'package:sellship/screens/additem.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sellship/global.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sellship/screens/categories.dart';
import 'package:sellship/screens/favourites.dart';
import 'package:sellship/screens/home.dart';
import 'package:sellship/screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize(getAppId());
  runApp(MyApp());
}

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-9959700192389744~6783422976';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-9959700192389744~8862791402';
  }
  return null;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// Create storage
  final storage = new FlutterSecureStorage();

  int _currentPage = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    CategoryScreen(),
    AddItem(),
    FavouritesScreen(),
    LoginPage(),
  ];

  var latitude;
  var longitude;
  static LatLng position;

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
    await storage.write(key: 'city', value: cit);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SellShip',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          backgroundColor: bgColor,
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.grey[500],
            currentIndex: _currentPage,
            onTap: (i) {
              setState(() {
                _currentPage = i;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesome.home,
                  color: Colors.amberAccent,
                ),
                title: Text(
                  "Home",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome5.list_alt,
                    color: Colors.amberAccent,
                  ),
                  title: Text(
                    "Categories",
                    style: TextStyle(color: Colors.amber),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome.plus_square_o,
                    size: 40,
                    color: Colors.amberAccent,
                  ),
                  title: Text(
                    "Add an Item",
                    style: TextStyle(color: Colors.amber),
                  )),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesome.heart,
                  color: Colors.amberAccent,
                ),
                title: Text(
                  "Favourites",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesome.user_circle_o,
                  color: Colors.amberAccent,
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: _pages[_currentPage],
          ),
        ));
  }
}
