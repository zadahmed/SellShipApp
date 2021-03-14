import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentWeb extends StatefulWidget {
  String url;
  String returnurl;
  String itemid;
  String messageid;
  String errorurl;

  PaymentWeb(
      {Key key,
      this.url,
      this.returnurl,
      this.itemid,
      this.messageid,
      this.errorurl})
      : super(key: key);

  @override
  PaymentWebState createState() => PaymentWebState();
}

class PaymentWebState extends State<PaymentWeb> {
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
            'Pay',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: InAppWebView(
          initialUrl: widget.url,
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
          onLoadStart: (InAppWebViewController controller, String url) {},
          onLoadStop: (InAppWebViewController controller, String url) async {
            if (url.substring(0, 20) == widget.returnurl.substring(0, 20)) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('cartitems');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderBuyer(
                          itemid: widget.itemid,
                          messageid: widget.messageid,
                        )),
              );
            } else if (url.substring(0, 20) ==
                widget.errorurl.substring(0, 20)) {
              print('error');
              print(url);
              Navigator.pop(context);
            }
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
          onReceivedServerTrustAuthRequest: (InAppWebViewController controller,
              ServerTrustChallenge challenge) async {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ));
  }
}
