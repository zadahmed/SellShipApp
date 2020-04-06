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
import 'package:permission_handler/permission_handler.dart' as Perm;

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with WidgetsBindingObserver {
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

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Perm.PermissionHandler()
          .checkPermissionStatus(Perm.PermissionGroup.locationWhenInUse)
          .then(_updateStatus);
    }
  }

  void _updateStatus(Perm.PermissionStatus status) {
    if (status != _status) {
      // check status has changed
      setState(() {
        _status = status; // update
      });
    } else {
      if (status != Perm.PermissionStatus.granted) {
        Perm.PermissionHandler().requestPermissions(
            [Perm.PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
      }
    }
  }

  Perm.PermissionStatus _status;

  void _askPermission() {
    Perm.PermissionHandler().requestPermissions(
        [Perm.PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
  }

  void _onStatusRequested(
      Map<Perm.PermissionGroup, Perm.PermissionStatus> statuses) {
    final status = statuses[Perm.PermissionGroup.locationWhenInUse];
    if (status != Perm.PermissionStatus.granted) {
      // On iOS if "deny" is pressed, open App Settings
      Perm.PermissionHandler().openAppSettings();
    } else {
      _updateStatus(status);
    }
  }

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
    WidgetsBinding.instance.addObserver(this);
    Perm.PermissionHandler() // Check location permission has been granted
        .checkPermissionStatus(Perm.PermissionGroup
            .locationWhenInUse) //check permission returns a Future
        .then(_updateStatus); // ha
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SellShip',
        home: Scaffold(
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
                ),
                title: Text(
                  "Home",
                ),
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome5.list_alt,
                  ),
                  title: Text(
                    "Categories",
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome.plus_square,
                    size: 40,
                    color: Colors.amber,
                  ),
                  title: Text(
                    "Add an Item",
                    style: TextStyle(color: Colors.white),
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
          body: SafeArea(
            child: _pages[_currentPage],
          ),
        ));
  }
}
