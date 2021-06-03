import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SellShip/Navigation/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/username.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  VideoPlayerController _controller;

  var loggedin;
  final facebookLogin = FacebookLogin();

  final storage = new FlutterSecureStorage();

  _loginWithFB() async {
    if (await facebookLogin.isLoggedIn == true) {
      facebookLogin.logOut();
    }

    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken token = result.accessToken;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token'));

        final profile = await facebookLogin.getUserProfile();

        final imageUrl = await facebookLogin.getProfileImageUrl(width: 100);

        final email = await facebookLogin.getUserEmail();
        var url = 'https://api.sellship.co/api/signup';

        var uuo = Uuid();

        Map<String, String> body = {
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'email': email,
          'phonenumber': uuo.v4().toString(),
          'profilepicture': imageUrl,
          'password': 'password',
        };

        final response = await http.post(Uri.parse(url), body: body);

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);

          print(jsondata);

          if (jsondata.containsKey('status')) {
            if (jsondata['status']['message'] == 'User already exists') {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('seen', true);
              await storage.write(
                  key: 'userid', value: jsondata['status']['id']);

              var userid = await storage.read(key: 'userid');
              var storeurl = 'https://api.sellship.co/api/userstores/' + userid;
              final storeresponse = await http.get(Uri.parse(storeurl));
              var storejsonbody = json.decode(storeresponse.body);

              if (storejsonbody.isNotEmpty) {
                var storeid = storejsonbody[0]['_id']['\$oid'];
                print(storeid);
                await storage.write(key: 'storeid', value: storeid);
              } else {
                await storage.write(key: 'storeid', value: null);
              }

              FirebaseAnalytics analytics = FirebaseAnalytics();
              await analytics.setUserId(userid);
              await analytics.logLogin();
              await analytics.setUserProperty(
                  name: 'name', value: profile.firstName + profile.lastName);
              Navigator.of(context).pop();

              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.rootScreen, (Route<dynamic> route) => false);
            }
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('seen', true);
            await storage.write(key: 'userid', value: jsondata['id']);

            var userid = await storage.read(key: 'userid');
            var storeurl = 'https://api.sellship.co/api/userstores/' + userid;
            final storeresponse = await http.get(Uri.parse(storeurl));
            var storejsonbody = json.decode(storeresponse.body);

            if (storejsonbody.isNotEmpty) {
              var storeid = storejsonbody[0]['_id'];

              await storage.write(key: 'storeid', value: storeid);
            } else {
              await storage.write(key: 'storeid', value: null);
            }

            FirebaseAnalytics analytics = FirebaseAnalytics();
            await analytics.setUserId(userid);
            await analytics.logLogin();
            await analytics.setUserProperty(
                name: 'name', value: profile.firstName + profile.lastName);
            Navigator.of(context).pop();

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhoneSignUp(
                    userid: userid,
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
                                    width:
                                        MediaQuery.of(context).size.width - 30,
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
        }

        setState(() {
          loggedin = true;
        });
        break;

      case FacebookLoginStatus.cancel:
        setState(() => loggedin = false);
        Navigator.of(context).pop();
        break;
      case FacebookLoginStatus.error:
        setState(() => loggedin = false);
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/onboardingvideo.MOV')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:OnboardingScreen',
      screenClassOverride: 'AppOnboardingScreen',
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: VideoPlayer(_controller)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset('assets/logonew.png'),
                    ),
                  ),
                  Image.asset(
                    'assets/logo.png',
                    width: 250,
                  ),
                ],
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 20, right: 15),
                      child: GoogleAuthButton(
                        style: AuthButtonStyle(
                          width: 300.0,
                        ),
                        text: 'Continue with Google',
                        onPressed: () async {
                          GoogleSignIn _googleSignIn = GoogleSignIn(
                            scopes: [
                              'email',
                            ],
                          );
                          GoogleSignInAccount user =
                              await _googleSignIn.signIn();
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
                                            height: 100,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Loading..',
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: SpinKitDoubleBounce(
                                                      color: Colors.deepOrange,
                                                    )),
                                              ],
                                            ));
                                      },
                                    ),
                                  ));
                          var url = 'https://api.sellship.co/api/signup';

                          var name = user.displayName.split(" ");

                          var uui = Uuid();
                          var uuid = uui.v4();

                          Map<String, String> body = {
                            'first_name': name[0],
                            'last_name': name[1],
                            'email': user.email,
                            'phonenumber': uuid,
                            'profilepicture': user.photoUrl,
                            'password': 'password',
                          };

                          final response =
                              await http.post(Uri.parse(url), body: body);

                          if (response.statusCode == 200) {
                            var jsondata = json.decode(response.body);

                            print(jsondata);

                            if (jsondata.containsKey('status')) {
                              if (jsondata['status']['message'] ==
                                  'User already exists') {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool('seen', true);
                                await storage.write(
                                    key: 'userid',
                                    value: jsondata['status']['id']);

                                var userid = await storage.read(key: 'userid');
                                var storeurl =
                                    'https://api.sellship.co/api/userstores/' +
                                        userid;
                                final storeresponse =
                                    await http.get(Uri.parse(storeurl));
                                var storejsonbody =
                                    json.decode(storeresponse.body);

                                if (storejsonbody.isNotEmpty) {
                                  var storeid =
                                      storejsonbody[0]['_id']['\$oid'];
                                  print(storeid);
                                  await storage.write(
                                      key: 'storeid', value: storeid);
                                } else {
                                  await storage.write(
                                      key: 'storeid', value: null);
                                }

                                FirebaseAnalytics analytics =
                                    FirebaseAnalytics();
                                await analytics.setUserId(userid);
                                await analytics.logLogin();
                                await analytics.setUserProperty(
                                    name: 'name', value: name[0] + name[1]);

                                Navigator.of(context).pop();

                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    Routes.rootScreen,
                                    (Route<dynamic> route) => false);
                              }
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('seen', true);
                              await storage.write(
                                  key: 'userid', value: jsondata['id']);

                              var userid = await storage.read(key: 'userid');
                              var storeurl =
                                  'https://api.sellship.co/api/userstores/' +
                                      userid;
                              final storeresponse =
                                  await http.get(Uri.parse(storeurl));
                              var storejsonbody =
                                  json.decode(storeresponse.body);

                              if (storejsonbody.isNotEmpty) {
                                var storeid = storejsonbody[0]['_id'];

                                await storage.write(
                                    key: 'storeid', value: storeid);
                              } else {
                                await storage.write(
                                    key: 'storeid', value: null);
                              }

                              FirebaseAnalytics analytics = FirebaseAnalytics();
                              await analytics.setUserId(userid);
                              await analytics.logLogin();
                              await analytics.setUserProperty(
                                  name: 'name', value: name[0] + name[1]);

                              Navigator.of(context).pop();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifyPhoneSignUp(
                                      userid: userid,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              255, 115, 0, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color(
                                                                        0xFF9DA3B4)
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius:
                                                                    65.0,
                                                                offset: Offset(
                                                                    0.0, 15.0))
                                                          ]),
                                                      child: Center(
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
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
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 20, right: 15),
                      child: FacebookAuthButton(
                        style: AuthButtonStyle(
                          width: 300.0,
                        ),
                        onPressed: () {
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
                                            height: 100,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Loading..',
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: SpinKitDoubleBounce(
                                                      color: Colors.deepOrange,
                                                    )),
                                              ],
                                            ));
                                      },
                                    ),
                                  ));

                          _loginWithFB();
                        },
                        text: 'Continue with Facebook',
                      ),
                    ),
                    Platform.isIOS
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 15, bottom: 20, right: 15),
                            child: AppleAuthButton(
                              style: AuthButtonStyle(
                                width: 300.0,
                              ),
                              text: 'Continue with Apple',
                              onPressed: () async {
                                final result = await FirebaseAuthOAuth()
                                    .openSignInFlow(
                                        "apple.com",
                                        ["email", "fullName"],
                                        {"locale": "en"});

                                var user = result;

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
                                                        height: 15,
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
                                var url = 'https://api.sellship.co/api/signup';

                                Map<String, String> body = {
                                  'first_name': user.displayName != null
                                      ? user.displayName
                                      : 'First',
                                  'last_name': 'Name',
                                  'email': user.email,
                                  'phonenumber': user.uid,
                                  'password': user.uid,
                                };

                                final response =
                                    await http.post(Uri.parse(url), body: body);

                                if (response.statusCode == 200) {
                                  var jsondata = json.decode(response.body);

                                  print(jsondata);

                                  if (jsondata.containsKey('status')) {
                                    if (jsondata['status']['message'] ==
                                        'User already exists') {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool('seen', true);
                                      await storage.write(
                                          key: 'userid',
                                          value: jsondata['status']['id']);

                                      var userid =
                                          await storage.read(key: 'userid');
                                      var storeurl =
                                          'https://api.sellship.co/api/userstores/' +
                                              userid;
                                      final storeresponse =
                                          await http.get(Uri.parse(storeurl));
                                      print(storeresponse);
                                      var storejsonbody =
                                          json.decode(storeresponse.body);

                                      if (storejsonbody.isNotEmpty) {
                                        var storeid =
                                            storejsonbody[0]['_id']['\$oid'];
                                        print(storeid);
                                        await storage.write(
                                            key: 'storeid', value: storeid);
                                      }

                                      FirebaseAnalytics analytics =
                                          FirebaseAnalytics();
                                      await analytics.setUserId(userid);
                                      await analytics.logLogin();
                                      await analytics.setUserProperty(
                                          name: 'name',
                                          value: user.displayName);

                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              Routes.rootScreen,
                                              (Route<dynamic> route) => false);
                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (BuildContext
                                      //                 context) =>
                                      //             RootScreen()));
                                    }
                                  } else {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool('seen', true);
                                    await storage.write(
                                        key: 'userid', value: jsondata['id']);

                                    var userid =
                                        await storage.read(key: 'userid');
                                    var storeurl =
                                        'https://api.sellship.co/api/userstores/' +
                                            userid;
                                    final storeresponse =
                                        await http.get(Uri.parse(storeurl));
                                    var storejsonbody =
                                        json.decode(storeresponse.body);

                                    if (storejsonbody.isNotEmpty) {
                                      var storeid = storejsonbody[0]['_id'];

                                      await storage.write(
                                          key: 'storeid', value: storeid);
                                    }

                                    FirebaseAnalytics analytics =
                                        FirebaseAnalytics();
                                    await analytics.setUserId(userid);
                                    await analytics.logLogin();
                                    await analytics.setUserProperty(
                                        name: 'name', value: user.displayName);
                                    Navigator.of(context).pop();

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Username(
                                            userid: userid,
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
                                                                    .circular(
                                                                        15),
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
                                                                      offset: Offset(
                                                                          0.0,
                                                                          15.0))
                                                                ]),
                                                            child: Center(
                                                              child: Text(
                                                                "Close",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    ));
                                              },
                                            ),
                                          ));
                                }
                              },
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 20, right: 15),
                      child: EmailAuthButton(
                        style: AuthButtonStyle(
                          width: 300.0,
                        ),
                        text: 'Continue with Email',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
    Padding(
    padding: const EdgeInsets.only(
    left: 25, bottom: 40, right: 25),
    child: InkWell(
                        enableFeedback: true,
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      TermsandConditions()));
                        },
                        child: Text(
                          'By Signing up, you hereby agree to the Terms and Conditions and Privacy Policy of SellShip',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                        )))
                  ],
                ),
              )),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20, right: 30),
              child: Container(
                  child: InkWell(
                      enableFeedback: true,
                      onTap: () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RootScreen()));
                      },
                      child: Text(
                        'Just Exploring',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                      )))),
        )
      ],
    ));
  }
}
