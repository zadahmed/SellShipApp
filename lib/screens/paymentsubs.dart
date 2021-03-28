import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/store/storecompletion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paymentsubs extends StatefulWidget {
  String url;
  String returnurl;
  String businesstier;
  String storeid;
  String orderid;

  Paymentsubs({
    Key key,
    this.url,
    this.storeid,
    this.orderid,
    this.businesstier,
    this.returnurl,
  }) : super(key: key);

  @override
  PaymentsubsState createState() => PaymentsubsState();
}

class PaymentsubsState extends State<Paymentsubs> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  final storage = new FlutterSecureStorage();

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
              await storage.write(key: 'tier', value: widget.businesstier);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StoreCompletion(
                        storeid: widget.storeid, orderid: widget.orderid)),
              );
            } else if (url.substring(0, 20) ==
                'https://api.sellship.co/api/payment/failed/') {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  useRootNavigator: false,
                  builder: (_) => new AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        content: Builder(
                          builder: (context) {
                            return Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Oops. Looks like the payment did not go through. Please try again.',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      child: Container(
                                        height: 60,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(255, 115, 0, 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                            child: Text(
                                          'Close',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        )),
                                      ),
                                      onTap: () {
                                        Navigator.pop(
                                          context,
                                        );
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                    ),
                                  ],
                                ));
                          },
                        ),
                      ));
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
