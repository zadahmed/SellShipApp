import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/pageNames.dart';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/forgotpassword.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/username.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.originPage});

  ///[originPage] use PageNames Class to reference names / found in navigation folder
  final String originPage;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:LoginEmail',
      screenClassOverride: 'AppLoginEmail',
    );
  }

  var loggedin;
  final facebookLogin = FacebookLogin();

  final storage = new FlutterSecureStorage();
  var firebasetoken;

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();

  TextEditingController EmailController = new TextEditingController();
  TextEditingController PasswordController = new TextEditingController();
  var userid;

  void Loginfunc() async {
    var url = 'https://api.sellship.co/api/login';

    Map<String, String> body = {
      'email': EmailController.text,
      'password': PasswordController.text,
    };

    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);

      if (jsondata['id'] != null) {
        await storage.write(key: 'userid', value: jsondata['id']);

        var userid = await storage.read(key: 'userid');
        var storeurl = 'https://api.sellship.co/api/userstores/' + userid;
        final storeresponse = await http.get(Uri.parse(storeurl));
        var storejsonbody = json.decode(storeresponse.body);
        print(storejsonbody);
        if (storejsonbody.isNotEmpty) {
          var storeid = storejsonbody[0]['_id']['\$oid'];
          await storage.write(key: 'storeid', value: storeid);
        }

        FirebaseAnalytics analytics = FirebaseAnalytics();
        await analytics.setUserId(userid);
        await analytics.logLogin();

        Navigator.of(context).pop();
        setState(() {
          userid = jsondata['id'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('seen', true);
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.rootScreen, (Route<dynamic> route) => false);
      } else if (jsondata['status']['message'].toString().trim() ==
          'User does not exist, please sign up') {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: false,
            builder: (_) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  content: Builder(
                    builder: (context) {
                      return Container(
                          height: 380,
                          child: Column(
                            children: [
                              Container(
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
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
                                'Oops!',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 30,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 115, 0, 1),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color(0xFF9DA3B4)
                                                .withOpacity(0.1),
                                            blurRadius: 65.0,
                                            offset: Offset(0.0, 15.0))
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Close",
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ));
                    },
                  ),
                ));
      } else if (jsondata['status']['message'].toString().trim() ==
          'Invalid password, try again') {
        showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: false,
            builder: (_) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  content: Builder(
                    builder: (context) {
                      return Container(
                          height: 380,
                          child: Column(
                            children: [
                              Container(
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
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
                                'Oops!',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 30,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 115, 0, 1),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color(0xFF9DA3B4)
                                                .withOpacity(0.1),
                                            blurRadius: 65.0,
                                            offset: Offset(0.0, 15.0))
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Close",
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ));
                    },
                  ),
                ));
      }
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (_) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Builder(
                  builder: (context) {
                    return Container(
                        height: 380,
                        child: Column(
                          children: [
                            Container(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
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
                              'Oops!',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              child: Container(
                                width: MediaQuery.of(context).size.width - 30,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 115, 0, 1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xFF9DA3B4)
                                              .withOpacity(0.1),
                                          blurRadius: 65.0,
                                          offset: Offset(0.0, 15.0))
                                    ]),
                                child: Center(
                                  child: Text(
                                    "Close",
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
                  },
                ),
              ));
    }
  }

  Widget OnBoarding(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                              height: 280,
                              width: MediaQuery.of(context).size.width,
                              child: SvgPicture.asset(
                                'assets/LoginBG.svg',
                                semanticsLabel: 'SellShip BG',
                                fit: BoxFit.cover,
                              ))),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.only(left: 35, top: 120),
                              child: Text(
                                'Welcome\nBack',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ))),
                    ],
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 36, top: 20, right: 36),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(131, 146, 165, 0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  onChanged: (text) {},
                                  controller: EmailController,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: "Email Address",
                                    hintStyle:
                                        TextStyle(fontFamily: 'Helvetica'),
                                    icon: Icon(
                                      Icons.email,
                                      color: Colors.blueGrey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 36, top: 20, right: 36),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(131, 146, 165, 0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  onChanged: (text) {},
                                  controller: PasswordController,
                                  obscureText: true,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle:
                                        TextStyle(fontFamily: 'Helvetica'),
                                    icon: Icon(
                                      Icons.lock,
                                      color: Colors.blueGrey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 36, top: 40, right: 36),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => new AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            content: Builder(
                                              builder: (context) {
                                                return Container(
                                                    height: 100,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Loading..',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                            height: 50,
                                                            width: 50,
                                                            child:
                                                                SpinKitDoubleBounce(
                                                              color: Colors
                                                                  .deepOrange,
                                                            )),
                                                      ],
                                                    ));
                                              },
                                            ),
                                          ));
                                  Loginfunc();
                                },
                                child: Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  width:
                                      MediaQuery.of(context).size.width - 120,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 115, 0, 1),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  )),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 40, bottom: 50, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword()));
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                  fontFamily: 'Helvetica'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpPage()));
                            },
                            child: Text(
                              "Create an Account",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Helvetica'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50, left: 20),
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          FeatherIcons.chevronLeft,
                          color: Colors.white,
                        )),
                  )),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnBoarding(context);
  }
}
