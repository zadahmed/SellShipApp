import 'dart:async';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/starterscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:SellShip/screens/onboarding.dart';
import 'package:SellShip/screens/rootscreen.dart';
//import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
//  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));
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
  void navigatetoscreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new RootScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new StarterPage()));
    }
  }

  Future handleDynamicLinks() async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');

      var id = deepLink.queryParameters['id'];

      if (id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(itemid: id)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    new Timer(new Duration(milliseconds: 10), () {
      if (mounted) {
        handleDynamicLinks();
        navigatetoscreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return new Scaffold(
      backgroundColor: Colors.deepOrange,
    );
  }
}
