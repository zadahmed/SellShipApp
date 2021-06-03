import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HelpCentre extends StatefulWidget {
  HelpCentre({
    Key key,
  }) : super(key: key);

  @override
  HelpCentreState createState() => HelpCentreState();
}

class HelpCentreState extends State<HelpCentre> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:HelpCentre',
      screenClassOverride: 'AppHelpCentre',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Help Centre',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.parse(
            'https://help.sellship.co',
          )),
          onWebViewCreated: (InAppWebViewController controller) {
            webView = controller;
          },
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage.toJson());
            print(consoleMessage.message);
          },
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
        ));
  }
}
