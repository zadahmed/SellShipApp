import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 2;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepOrangeAccent : Colors.deepOrange,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    gettoken();
  }

  gettoken() async {
    var token = await FirebaseNotifications().getNotifications(context);
    setState(() {
      firebasetoken = token;
    });
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
      'fcmtoken': firebasetoken,
    };

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);

      if (jsondata['id'] != null) {
        await storage.write(key: 'userid', value: jsondata['id']);
        if (jsondata['businessid'] != null) {
          await storage.write(key: 'businessid', value: jsondata['businessid']);
        }
        print('Loggd in ');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        setState(() {
          userid = jsondata['id'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('seen', true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RootScreen()));
      } else if (jsondata['status']['message'].toString().trim() ==
          'User does not exist, please sign up') {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showDialog(
            context: context,
            builder: (_) => AssetGiffyDialog(
                  image: Image.asset(
                    'assets/oops.gif',
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    'Oops!',
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
                  description: Text(
                    'Looks like you don\'t have an account with us!',
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                  onlyOkButton: true,
                  entryAnimation: EntryAnimation.DEFAULT,
                  onOkButtonPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ));
      } else if (jsondata['status']['message'].toString().trim() ==
          'Invalid password, try again') {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showDialog(
            context: context,
            builder: (_) => AssetGiffyDialog(
                  image: Image.asset(
                    'assets/oops.gif',
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    'Oops!',
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
                  description: Text(
                    'Looks like thats the wrong password!',
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                  onlyOkButton: true,
                  entryAnimation: EntryAnimation.DEFAULT,
                  onOkButtonPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ));
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      showDialog(
          context: context,
          builder: (_) => AssetGiffyDialog(
                image: Image.asset(
                  'assets/oops.gif',
                  fit: BoxFit.cover,
                ),
                title: Text(
                  'Oops!',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                ),
                description: Text(
                  'Looks like something went wrong!\nPlease try again!',
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
                onlyOkButton: true,
                entryAnimation: EntryAnimation.DEFAULT,
                onOkButtonPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ));
    }
  }

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');

        final profile = json.decode(graphResponse.body);

        var url = 'https://api.sellship.co/api/signup';

        var name = profile['name'].split(" ");

        Map<String, String> body = {
          'first_name': name[0],
          'last_name': name[1],
          'email': profile['email'],
          'phonenumber': '00',
          'password': 'password',
          'fcmtoken': firebasetoken,
        };

        final response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          print(jsondata);
          if (jsondata['id'] != null) {
            await storage.write(key: 'userid', value: jsondata['id']);
            Navigator.of(context, rootNavigator: true).pop('dialog');

            var userid = await storage.read(key: 'userid');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhone(
                    userid: userid,
                  ),
                ));
          } else {
            var url = 'https://api.sellship.co/api/login';

            Map<String, String> body = {
              'email': profile['email'],
              'password': 'password',
              'fcmtoken': firebasetoken,
            };

            final response = await http.post(url, body: body);

            if (response.statusCode == 200) {
              var jsondata = json.decode(response.body);
              print(jsondata);
              if (jsondata['id'] != null) {
                await storage.write(key: 'userid', value: jsondata['id']);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('seen', true);

                Navigator.of(context, rootNavigator: true).pop('dialog');

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RootScreen()));
              }
            } else {
              print(response.statusCode);
            }
          }
        } else {
          print(response.statusCode);
        }

        setState(() {
          loggedin = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => loggedin = false);
        break;
      case FacebookLoginStatus.error:
        setState(() => loggedin = false);
        break;
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
                child: FadeAnimation(
                    1,
                    Stack(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: 350,
                                width: MediaQuery.of(context).size.width,
                                child: SvgPicture.asset(
                                  'assets/LoginBG.svg',
                                  semanticsLabel: 'SellShip BG',
                                  fit: BoxFit.cover,
                                ))),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                                padding: EdgeInsets.only(left: 20, top: 150),
                                child: Text(
                                  'Welcome\nBack',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ))),
                      ],
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 600,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  Loginfunc();
                                },
                                child: Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  width:
                                      MediaQuery.of(context).size.width - 250,
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
                              Platform.isIOS
                                  ? AppleAuthButton(
                                      onPressed: () async {
                                        await FirebaseAuthOAuth()
                                            .openSignInFlow("apple.com", [
                                          "email",
                                          "fullName"
                                        ], {
                                          "locale": "en"
                                        }).then((user) async {
                                          var url =
                                              'https://api.sellship.co/api/signup';

                                          print(user.email);
                                          Map<String, String> body = {
                                            'first_name':
                                                user.displayName != null
                                                    ? user.displayName
                                                    : 'First',
                                            'last_name': 'Name',
                                            'email': user.email,
                                            'phonenumber': '000',
                                            'password': user.uid,
                                            'fcmtoken': '000',
                                          };

                                          final response =
                                              await http.post(url, body: body);

                                          if (response.statusCode == 200) {
                                            var jsondata =
                                                json.decode(response.body);
                                            if (jsondata['id'] != null) {
                                              await storage.write(
                                                  key: 'userid',
                                                  value: jsondata['id']);

                                              var userid = await storage.read(
                                                  key: 'userid');
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VerifyPhone(
                                                      userid: userid,
                                                    ),
                                                  ));
                                            } else {
                                              var id = jsondata['status']['id'];
                                              await storage.write(
                                                  key: 'userid', value: id);
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setBool('seen', true);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RootScreen()));
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    AssetGiffyDialog(
                                                      image: Image.asset(
                                                        'assets/oops.gif',
                                                        fit: BoxFit.cover,
                                                      ),
                                                      title: Text(
                                                        'Oops!',
                                                        style: TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      description: Text(
                                                        'Looks like something went wrong!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(),
                                                      ),
                                                      onlyOkButton: true,
                                                      entryAnimation:
                                                          EntryAnimation
                                                              .DEFAULT,
                                                      onOkButtonPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');
                                                      },
                                                    ));
                                          }
                                          return user;
                                        });
                                      },
                                      style: AuthButtonStyle.icon,
                                    )
                                  : Container(),
                              FacebookAuthButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 100,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: SpinKitChasingDots(
                                                  color:
                                                      Colors.deepOrangeAccent)),
                                        );
                                      });

                                  _loginWithFB();
                                },
                                style: AuthButtonStyle.icon,
                              )
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
                      FadeAnimation(
                          1.5,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPassword()));
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      FadeAnimation(
                          1.5,
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
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: FadeAnimation(
                    1,
                    Padding(
                      padding: EdgeInsets.only(top: 50, left: 20),
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Feather.arrow_left,
                            color: Colors.white,
                          )),
                    )),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnBoarding(context);
  }
}
