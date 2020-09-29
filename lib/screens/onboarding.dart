import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RootScreen()));
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

                print('Loggd in ');
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          height: 30,
          width: 125,
          child: Image.asset(
            'assets/logotransparent.png',
            fit: BoxFit.cover,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            color: Colors.white,
            elevation: 0,
            child: Text('Skip',
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange)),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('seen', true);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RootScreen()));
            },
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: ListView(
          children: <Widget>[
            FadeAnimation(
                1,
                Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Image(
                              image: AssetImage(
                                'assets/onboard1.png',
                              ),
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 4,
                              width: 300.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                              'Buying something? Find the best items near you in less than a minute!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.deepOrange)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Image(
                              image: AssetImage(
                                'assets/onboard2.png',
                              ),
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height / 4,
                              width: 300.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                              'Selling Something ? List your item on SellShip within seconds!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.deepOrange)),
                        ],
                      ),
                    ],
                  ),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: <Widget>[
                FadeAnimation(
                  1.5,
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('seen', true);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Login',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeAnimation(
                  1.5,
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('seen', true);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.deepPurpleAccent.withOpacity(0.4),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeAnimation(
                  1.5,
                  InkWell(
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Container(
                              height: 100,
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SpinKitChasingDots(
                                      color: Colors.deepOrangeAccent)),
                            );
                          });

                      _loginWithFB();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Sign in with Facebook',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Platform.isIOS
                    ? FadeAnimation(
                        1.5,
                        InkWell(
                          onTap: () async {
                            await FirebaseAuthOAuth().openSignInFlow(
                                "apple.com",
                                ["email", "fullName"],
                                {"locale": "en"}).then((user) async {
                              var url = 'https://api.sellship.co/api/signup';

                              print(user.email);
                              Map<String, String> body = {
                                'first_name': user.displayName != null
                                    ? user.displayName
                                    : 'First',
                                'last_name': 'Name',
                                'email': user.email,
                                'phonenumber': '000',
                                'password': user.uid,
                                'fcmtoken': '000',
                              };

                              final response = await http.post(url, body: body);

                              print('Done');
                              if (response.statusCode == 200) {
                                var jsondata = json.decode(response.body);
                                if (jsondata['id'] != null) {
                                  await storage.write(
                                      key: 'userid', value: jsondata['id']);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RootScreen()));
                                } else {
                                  var id = jsondata['status']['id'];
                                  await storage.write(key: 'userid', value: id);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RootScreen()));
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                      image: Image.asset(
                                        'assets/oops.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        'Oops!',
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'Looks like something went wrong!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                      onlyOkButton: true,
                                      entryAnimation:
                                      EntryAnimation.DEFAULT,
                                      onOkButtonPressed: () {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop('dialog');
                                      },
                                    ));
                              }
                              return user;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Sign in with Apple',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnBoarding(context);
  }
}
