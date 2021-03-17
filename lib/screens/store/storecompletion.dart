import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/paymentsubs.dart';
import 'package:SellShip/screens/store/createstorepage.dart';
import 'package:SellShip/screens/store/mystorepage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

class StoreCompletion extends StatefulWidget {
  final String storeid;
  StoreCompletion({
    this.storeid,
    Key key,
  }) : super(key: key);

  @override
  _StoreCompletionState createState() => new _StoreCompletionState();
}

class _StoreCompletionState extends State<StoreCompletion> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Congratulations',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
                child: Icon(
                  Feather.chevron_left,
                  color: Color.fromRGBO(28, 45, 65, 1),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RootScreen()),
                  );
                }),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width - 100,
                child: Image.asset(
                  'assets/celebration.png',
                  fit: BoxFit.fitHeight,
                )),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
                child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                                'Hooray! Great job on setting up your store on SellShip. We are excited to have you onboard. Now let\'s get Selling!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateStorePage(
                                              storeid: widget.storeid,
                                            )),
                                    ModalRoute.withName('/'));
                              },
                              enableFeedback: true,
                              child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.deepOrange
                                              .withOpacity(0.4),
                                          offset: const Offset(1.1, 1.1),
                                          blurRadius: 10.0),
                                    ],
                                  ),
                                  child: Center(
                                      child: Text('Go to my Store',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          )))))
                        ])))
          ],
        ));
  }
}
