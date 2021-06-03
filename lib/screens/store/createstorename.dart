import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/onboardingbottom.dart';

import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/store/createstorebusinessdetail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CreateStoreName extends StatefulWidget {
  final String userid;

  CreateStoreName({
    Key key,
    this.userid,
  }) : super(key: key);

  @override
  _CreateStoreNameState createState() => new _CreateStoreNameState();
}

class _CreateStoreNameState extends State<CreateStoreName> {
  String userid;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  final storage = new FlutterSecureStorage();
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  checkuser() async {
    await analytics.setCurrentScreen(
      screenName: 'App:CreateStoreName',
      screenClassOverride: 'AppCreateStoreName',
    );
    var userid = await storage.read(key: 'userid');

    if (userid == null) {
      showModalBottomSheet(
          context: context,
          useRootNavigator: false,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 1,
                builder: (_, controller) {
                  return Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0)),
                      ),
                      child: OnboardingScreen());
                });
          });
    }
  }

  @override
  void initState() {
    super.initState();

    checkuser();
    setState(() {
      userid = widget.userid;
    });
  }

  bool disabled = true;

  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController storenamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            children: <Widget>[
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/storename.jpg',
                    fit: BoxFit.fitWidth,
                  )),
              Padding(
                padding:
                    EdgeInsets.only(left: 56.0, bottom: 10, top: 30, right: 36),
                child: Center(
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 100,
                    lineHeight: 10.0,
                    percent: 0.15,
                    progressColor: Color.fromRGBO(255, 115, 0, 1),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 56.0, bottom: 10, top: 20, right: 36),
                child: Center(
                  child: Text(
                    "What\'s your new store called?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 30.0,
                        color: Color.fromRGBO(28, 45, 65, 1),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Helvetica'),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                    top: 10,
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
                        child: TextField(
                          onChanged: (text) {},
                          controller: storenamecontroller,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Store Name",
                            hintStyle: TextStyle(fontFamily: 'Helvetica'),
                            icon: Icon(
                              FontAwesomeIcons.storeAlt,
                              color: Colors.blueGrey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(
                    top: 10,
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
                        child: TextField(
                          onChanged: (text) {},
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[^-\s]'))
                          ],
                          controller: usernamecontroller,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Store Username",
                            hintStyle: TextStyle(fontFamily: 'Helvetica'),
                            icon: Icon(
                              Icons.alternate_email,
                              color: Colors.blueGrey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (storenamecontroller.text.isEmpty) {
                            showInSnackBar('Please Enter A Store Name');
                          } else if (usernamecontroller.text.isEmpty) {
                            showInSnackBar(
                                'Please enter a username for your store');
                          } else {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20.0)), //this right here
                                      child: Container(
                                          height: 170,
                                          padding: EdgeInsets.all(15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Checking Store Username Availability..',
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SpinKitDoubleBounce(
                                                    color: Colors.deepOrange,
                                                  )),
                                            ],
                                          )));
                                });
                            var url =
                                'https://api.sellship.co/check/store/name/' +
                                    usernamecontroller.text.trim();

                            final response = await http.get(Uri.parse(url));

                            if (response.statusCode == 200) {
                              var jsondeco = json.decode(response.body);
                              if (jsondeco['Status'] == 'Success') {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreateStoreBusinessDetail(
                                        userid: widget.userid,
                                        username: usernamecontroller.text,
                                        storename: storenamecontroller.text,
                                      ),
                                    ));
                              } else {
                                Navigator.pop(context);

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    useRootNavigator: false,
                                    builder: (_) => new AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          content: Builder(
                                            builder: (context) {
                                              return Container(
                                                  height: 380,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 250,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.asset(
                                                            'assets/oops.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'Looks like that Store Username Exists',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      InkWell(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      115,
                                                                      0,
                                                                      1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Color(
                                                                            0xFF9DA3B4)
                                                                        .withOpacity(
                                                                            0.1),
                                                                    blurRadius:
                                                                        65.0,
                                                                    offset:
                                                                        Offset(
                                                                            0.0,
                                                                            15.0))
                                                              ]),
                                                          child: Center(
                                                            child: Text(
                                                              "Close",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                            },
                                          ),
                                        ));
                              }
                            }
                          }
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
            ],
          ),
        ));
  }
}
