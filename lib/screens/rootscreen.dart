import 'dart:io';

import 'package:SellShip/screens/messages.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:SellShip/screens/profile.dart';

class RootScreen extends StatefulWidget {
  int index;
  RootScreen({Key key, this.index}) : super(key: key);
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final storage = new FlutterSecureStorage();

  int _currentPage = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    LoginPage(),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.index != null) {
        _currentPage = widget.index;
      }
    });
    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SellShip',
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 5,
            unselectedFontSize: 5,
            currentIndex: _currentPage,
            onTap: (i) {
              setState(() {
                _currentPage = i;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Feather.home,
                    size: 26,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
              BottomNavigationBarItem(
                  icon: Icon(
                    Feather.user,
                    size: 26,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
            ],
          ),
          body: _pages[_currentPage],
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return AddItem();
                    },
                    isScrollControlled: true);
              }),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ));
  }
}
