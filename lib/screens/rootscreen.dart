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
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class RootScreen extends StatefulWidget {
  int index;
  RootScreen({Key key, this.index}) : super(key: key);
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final storage = new FlutterSecureStorage();

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      AddItem(),
      LoginPage(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);

    this.initDynamicLinks();
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Feather.home),
        activeColor: Colors.deepOrangeAccent,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        activeColor: Colors.deepOrangeAccent,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Feather.user),
        activeColor: Colors.deepOrangeAccent,
        inactiveColor: CupertinoColors.systemGrey,
      ),
    ];
  }

  PersistentTabController _controller;

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
        home: PersistentTabView(
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.white,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen when keyboard appears.
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 100),
            curve: Curves.bounceIn,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100),
          ),
          navBarStyle: NavBarStyle.style15, // Choose the
          // nav bar style with this property.
        ));
  }
}
