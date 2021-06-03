import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class NoAvailable extends StatefulWidget {
  NoAvailable({Key key}) : super(key: key);
  @override
  _NoAvailableState createState() => _NoAvailableState();
}

class _NoAvailableState extends State<NoAvailable> {
  @override
  void initState() {
    super.initState();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:NotAvailableInCountry',
      screenClassOverride: 'AppNotAvailableInCountry',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          'Oops!',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/error404.png',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'Looks like we are not in your region yet.',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
