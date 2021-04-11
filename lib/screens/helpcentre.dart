import 'dart:io';
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
          initialUrl: 'https://help.sellship.co',
          initialHeaders: {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            "Access-Control-Allow-Methods": "*"
          },
          onWebViewCreated: (InAppWebViewController controller) {
            webView = controller;
          },
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                debuggingEnabled: true, useShouldOverrideUrlLoading: true),
          ),
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage.toJson());
            print(consoleMessage.message);
          },
          onLoadStart: (InAppWebViewController controller, String url) {
            if (url == "return_url") {
              Navigator.pop(context, 'Done');
            }
          },
          onLoadStop: (InAppWebViewController controller, String url) {},
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
          onReceivedServerTrustAuthRequest: (InAppWebViewController controller,
              ServerTrustChallenge challenge) async {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ));
  }
}
