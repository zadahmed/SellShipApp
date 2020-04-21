import 'dart:io';

import 'package:SellShip/screens/messages.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SellShip/screens/additem.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/home.dart';
import 'package:SellShip/screens/login.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
// Create storage
  final storage = new FlutterSecureStorage();

  int _currentPage = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    Messages(),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SellShip',
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromRGBO(239, 100, 97, 1),
            unselectedItemColor: Colors.grey[400],
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
                ),
                title: Text(
                  "Home",
                ),
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Feather.message_square,
                  ),
                  title: Text(
                    "Messages",
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome.plus_square,
                    color: Color.fromRGBO(239, 100, 97, 1),
                    size: 40,
                  ),
                  title: Text(
                    "Sell",
                  )),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesome.heart,
                ),
                title: Text(
                  "Favourites",
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesome.user_circle_o,
                ),
                title: Text(
                  "Profile",
                ),
              ),
            ],
          ),
          body: _pages[_currentPage],
        ));
  }
}
