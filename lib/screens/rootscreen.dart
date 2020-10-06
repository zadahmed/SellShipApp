import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/discover.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SellShip/screens/additem.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:flutter_svg/svg.dart';
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
    Discover(),
    AddItem(),
    Messages(),
    ProfilePage(),
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

  onselected() {
    if (_currentPage == 0) {
      setState(() {
        home = 'assets/bottomnavbar/Home.svg';
        discover = 'assets/bottomnavbar/Discover.svg';
        chat = 'assets/bottomnavbar/Chat.svg';
      });
    } else if (_currentPage == 1) {
      setState(() {
        home = 'assets/bottomnavbar/Homeselect.svg';
        discover = 'assets/bottomnavbar/Discoverselect.svg';
        chat = 'assets/bottomnavbar/Chat.svg';
      });
    } else if (_currentPage == 2) {
      setState(() {
        home = 'assets/bottomnavbar/Homeselect.svg';
        discover = 'assets/bottomnavbar/Discover.svg';
        chat = 'assets/bottomnavbar/Chat.svg';
      });
    } else if (_currentPage == 3) {
      setState(() {
        home = 'assets/bottomnavbar/Homeselect.svg';
        discover = 'assets/bottomnavbar/Discover.svg';
        chat = 'assets/bottomnavbar/Chatselect.svg';
      });
    } else if (_currentPage == 4) {
      setState(() {
        home = 'assets/bottomnavbar/Homeselect.svg';
        discover = 'assets/bottomnavbar/Discover.svg';
        chat = 'assets/bottomnavbar/Chat.svg';
      });
    }
  }

  var home = 'assets/bottomnavbar/Home.svg';
  var discover = 'assets/bottomnavbar/Discover.svg';
  var chat = 'assets/bottomnavbar/Chat.svg';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SellShip',
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromRGBO(28, 45, 65, 1),
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: false,
            selectedFontSize: 5,
            unselectedFontSize: 5,
            currentIndex: _currentPage,
            onTap: (i) {
              setState(() {
                _currentPage = i;
                onselected();
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    home,
                    height: 25,
                    width: 25,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    discover,
                    height: 25,
                    width: 25,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/bottomnavbar/plus.svg',
                    height: 40,
                    width: 40,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    chat,
                    height: 25,
                    width: 25,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: Text('',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black))),
              BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesome.user_circle,
                    size: 25,
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
        ));
  }
}
