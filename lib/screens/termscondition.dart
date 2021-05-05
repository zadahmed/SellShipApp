import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TermsandConditions extends StatefulWidget {
  TermsandConditions({
    Key key,
  }) : super(key: key);

  @override
  TermsandConditionsState createState() => TermsandConditionsState();
}

class TermsandConditionsState extends State<TermsandConditions> {
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
            'Terms and Conditions',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.parse('https://sellship.co/terms'),
          ),
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
