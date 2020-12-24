import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/createstore.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

class CreateStoreBusinessDetail extends StatefulWidget {
  final String userid;
  final String username;
  final String storename;

  CreateStoreBusinessDetail(
      {Key key, this.userid, this.username, this.storename})
      : super(key: key);

  @override
  _CreateStoreBusinessDetailState createState() =>
      new _CreateStoreBusinessDetailState();
}

class _CreateStoreBusinessDetailState extends State<CreateStoreBusinessDetail> {
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
  }

  bool disabled = true;
  var storetype;
  var storecategory;

  TextEditingController storenamecontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Feather.arrow_left)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Create My Store',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          FadeAnimation(
            1,
            Padding(
              padding:
                  EdgeInsets.only(left: 56.0, bottom: 10, top: 30, right: 36),
              child: Center(
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 100,
                  lineHeight: 10.0,
                  percent: 0.35,
                  progressColor: Color.fromRGBO(255, 115, 0, 1),
                ),
              ),
            ),
          ),
          FadeAnimation(
            1,
            Padding(
              padding:
                  EdgeInsets.only(left: 56.0, bottom: 10, top: 30, right: 36),
              child: Center(
                child: Text(
                  "Tell us more about your business",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Color.fromRGBO(28, 45, 65, 1),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica'),
                ),
              ),
            ),
          ),
          FadeAnimation(
            1,
            Padding(
                padding: EdgeInsets.only(
                  top: 30,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(131, 146, 165, 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: DropdownButton<String>(
                          value: storetype,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          hint: Text(
                            'Store Type',
                            style: TextStyle(
                                fontFamily: 'Helvetica', fontSize: 16),
                          ),
                          elevation: 16,
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              color: Colors.black,
                              fontSize: 16),
                          isExpanded: true,
//                        underline: Container(
//                            height: 2, color: Color.fromRGBO(255, 28, 89, 1)),
                          onChanged: (String newValue) {
                            setState(() {
                              storetype = newValue;
                            });
                          },
                          items: <String>[
                            'Retail',
                            'Home Business',
                            'Reseller',
                            'Secondhand Seller',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )),
                  ],
                )),
          ),
          storetype != null && storetype != 'Secondhand Seller'
              ? FadeAnimation(
                  1,
                  Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              height: 60,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: MediaQuery.of(context).size.width - 100,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(131, 146, 165, 0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: DropdownButton<String>(
                                value: storecategory,
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                hint: Text(
                                  'Category',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica', fontSize: 16),
                                ),
                                elevation: 16,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.black,
                                    fontSize: 16),
                                isExpanded: true,
//                        underline: Container(
//                            height: 2, color: Color.fromRGBO(255, 28, 89, 1)),
                                onChanged: (String newValue) {
                                  setState(() {
                                    storecategory = newValue;
                                  });
                                },
                                items: <String>[
                                  'Electronics',
                                  'Women',
                                  'Men',
                                  'Toys',
                                  'Beauty',
                                  'Home',
                                  'Kids',
                                  'Sport & Leisure',
                                  'Books',
                                  'Motors',
                                  'Vintage',
                                  'Luxury',
                                  'Garden',
                                  'Handmade'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )),
                        ],
                      )),
                )
              : Container(),
          FadeAnimation(
            1,
            Padding(
              padding: EdgeInsets.only(left: 36, top: 20, right: 36),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateStore(
                                userid: widget.userid,
                                username: widget.username,
                                storename: widget.storename,
                                storetype: storetype,
                                category: storecategory,
                              ),
                            ));
                      },
                      child: Container(
                        height: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 115, 0, 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                            child: Text(
                          'Next',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        )),
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
