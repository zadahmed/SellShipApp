import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SellShip/bubble_indication_painter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/edititem.dart';
import 'package:SellShip/screens/editprofile.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shimmer/shimmer.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodePhone = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();
  final FocusNode myFocusNodeLastName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupLastnameController = new TextEditingController();
  TextEditingController signupphonecontroller = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;
  var loggedin;

  final facebookLogin = FacebookLogin();
  Map userProfile;

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');

        setState(() {
          loading = true;
        });
        final profile = json.decode(graphResponse.body);

        var url = 'https://sellship.co/api/signup';

        var name = profile['name'].split(" ");

        Map<String, String> body = {
          'first_name': name[0],
          'last_name': name[1],
          'email': profile['email'],
          'phonenumber': '00',
          'password': 'password',
        };

        final response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          print(jsondata);
          if (jsondata['id'] != null) {
            await storage.write(key: 'userid', value: jsondata['id']);

            print('signned up ');
            setState(() {
              userid = jsondata['id'];
              getProfileData();
            });
          } else {
            var url = 'https://sellship.co/api/login';

            Map<String, String> body = {
              'email': profile['email'],
              'password': 'password',
            };

            final response = await http.post(url, body: body);

            if (response.statusCode == 200) {
              var jsondata = json.decode(response.body);
              print(jsondata);
              if (jsondata['id'] != null) {
                await storage.write(key: 'userid', value: jsondata['id']);

                print('Loggd in ');
                setState(() {
                  userid = jsondata['id'];
                  getProfileData();
                });
              } else if (jsondata['status']['message'].toString().trim() ==
                  'User does not exist, please sign up') {
              } else if (jsondata['status']['message'].toString().trim() ==
                  'Invalid password, try again') {}
            } else {
              print(response.statusCode);
            }
          }
        } else {
          print(response.statusCode);
        }

        setState(() {
          userProfile = profile;
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

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userid == null ? LoginSignup(context) : profile(context),
    );
  }

  Widget RootProfile(BuildContext context) {}

  Widget LoginSignup(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
//        appBar: AppBar(
//          automaticallyImplyLeading: true,
//          elevation: 0,
//          title: Container(
//            height: 100,
//            width: 200,
//            child: Image.asset(
//              'assets/logo.png',
//              fit: BoxFit.fitWidth,
//            ),
//          ),
//          backgroundColor: Colors.deepOrange,
//        ),
        body: loading == false
            ? new NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                },
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height >= 830.0
                        ? MediaQuery.of(context).size.height
                        : 830.0,
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [Colors.deepOrangeAccent, Colors.deepOrange],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 100,
                          width: 200,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: _buildMenuBar(context),
                        ),
                        Expanded(
                          flex: 2,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (i) {
                              if (i == 0) {
                                setState(() {
                                  right = Colors.white;
                                  left = Colors.black;
                                });
                              } else if (i == 1) {
                                setState(() {
                                  right = Colors.black;
                                  left = Colors.white;
                                });
                              }
                            },
                            children: <Widget>[
                              new ConstrainedBox(
                                constraints: const BoxConstraints.expand(),
                                child: _buildSignIn(context),
                              ),
                              new ConstrainedBox(
                                constraints: const BoxConstraints.expand(),
                                child: _buildSignUp(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Column(
                    children: [0, 1, 2, 3, 4, 5, 6]
                        .map((_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ));
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    getProfileData();

    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: GoogleFonts.lato(fontSize: 16, color: left),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: GoogleFonts.lato(fontSize: 16, color: right),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.lato(
                              fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "Email Address",
                            hintStyle: GoogleFonts.lato(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: GoogleFonts.lato(
                              fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: GoogleFonts.lato(
                                fontSize: 16, color: Colors.black),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 170.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.deepOrangeAccent,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: Colors.deepOrange,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [Colors.deepOrange, Colors.deepOrangeAccent],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.deepOrange,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "LOGIN",
                        style:
                            GoogleFonts.lato(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      Login();
                    }),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  'By logging In \n you agree to the Terms and Conditions',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "Or",
                    style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _loginWithFB();
                },
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: new Icon(
                    FontAwesomeIcons.facebookF,
                    color: Color(0xFF0084ff),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  var loading;

  Widget profile(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          title: Text(
            "Profile️",
            style: GoogleFonts.lato(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepOrange,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                storage.delete(key: 'userid');
                setState(() {
                  userid = null;
                });
              },
              icon: Icon(Feather.log_out),
            )
          ],
        ),
        body: loading == false
            ? Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Hi ' + firstname + '!',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          FlatButton(
                            color: Colors.deepOrange,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()),
                              );
                            },
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.lato(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Divider(),
                    Center(
                      child: Text(
                        'My Items',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Itemname.isNotEmpty
                        ? Expanded(
                            child: Scrollbar(
                                child: new ListView.builder(
                                    itemCount: Itemname.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int Index) {
                                      if (Index != 0 && Index % 4 == 0) {
                                        return Platform.isIOS == true
                                            ? Container(
                                                height: 200,
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                child: NativeAdmob(
                                                  adUnitID: _iosadUnitID,
                                                  controller: _controller,
                                                ),
                                              )
                                            : Container(
                                                height: 200,
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                child: NativeAdmob(
                                                  adUnitID: _androidadUnitID,
                                                  controller: _controller,
                                                ),
                                              );
                                      }
                                      return new InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Details(
                                                      itemid: Itemid[Index])),
                                            );
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 5.0),
                                              constraints:
                                                  BoxConstraints(minHeight: 90),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade200,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 6.0,
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(11.0),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  Itemname[Index],
                                                  style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                trailing: FlatButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditItem(
                                                                  itemid: Itemid[
                                                                      Index])),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Edit Item',
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                leading: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      Itemimage[Index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  Itemcategory[Index],
                                                  style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade800),
                                                ),
                                              )));
                                    })))
                        : Expanded(
                            child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Go ahead Add an Item \n and start selling!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/items.png',
                                fit: BoxFit.fitWidth,
                              ))
                            ],
                          )),
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Column(
                    children: [0, 1, 2, 3, 4, 5, 6]
                        .map((_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: 40.0,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ));
  }

  var numberphone;

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 540.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.lato(
                              fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hintText: "First Name",
                            hintStyle: GoogleFonts.lato(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeLastName,
                          controller: signupLastnameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.lato(
                              fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesome5.user,
                              color: Colors.black,
                            ),
                            hintText: "Last Name",
                            hintStyle: GoogleFonts.lato(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child:
                            InternationalPhoneNumberInput.withCustomDecoration(
                          isEnabled: true,
                          onInputChanged: (PhoneNumber number) async {
                            var numberss =
                                await PhoneNumber.getRegionInfoFromPhoneNumber(
                                    number.toString());
                            setState(() {
                              numberphone = numberss.toString();
                            });
                          },
                          focusNode: myFocusNodePhone,
                          autoValidate: true,
                          countries: ['GB', 'US', 'AE'],
                          textFieldController: signupphonecontroller,
                          inputDecoration:
                              InputDecoration(border: UnderlineInputBorder()),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.lato(
                              fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                            ),
                            hintText: "Email Address",
                            hintStyle: GoogleFonts.lato(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: GoogleFonts.lato(
                              fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: GoogleFonts.lato(
                                fontSize: 16, color: Colors.black),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextSignup
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: GoogleFonts.lato(fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.userLock,
                              color: Colors.black,
                            ),
                            hintText: "Confirmation",
                            hintStyle: GoogleFonts.lato(
                                fontSize: 16, color: Colors.black),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _obscureTextSignupConfirm
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 530.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.deepOrangeAccent,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: Colors.deepOrange,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                        Colors.deepOrange,
                        Colors.deepOrangeAccent,
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.deepOrangeAccent,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN UP",
                        style:
                            GoogleFonts.lato(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      if (signupEmailController.text.isNotEmpty &&
                          signupphonecontroller.text.isNotEmpty != null &&
                          signupNameController.text.isNotEmpty != null) {
                        setState(() {
                          loading = true;
                        });
                        Signup();
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
                                    style: GoogleFonts.lato(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  description: Text(
                                    'Looks like you\'re missing something',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  onlyOkButton: true,
                                  entryAnimation: EntryAnimation.DEFAULT,
                                  onOkButtonPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                ));
                      }
                    }),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
              child: Text(
            'By Signing Up \n you agree to the Terms and Conditions',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
          )),
        ],
      ),
    );
  }

  final storage = new FlutterSecureStorage();

  var firstname;
  var lastname;
  var email;
  var phonenumber;
  String userid;

  List<String> Itemid = List<String>();
  List<String> Itemname = List<String>();
  List<String> Itemimage = List<String>();
  List<String> Itemcategory = List<String>();
  List<String> Itemprice = List<String>();

  void getProfileData() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;
        print(profilemap);

        if (profilemap != null) {
          if (mounted) {
            setState(() {
              firstname = profilemap['first_name'];
              lastname = profilemap['last_name'];
              phonenumber = profilemap['phonenumber'];
              email = profilemap['email'];
              loading = false;
            });
          }

          var itemurl = 'https://sellship.co/api/useritems/' + userid;
          print(itemurl);
          final itemresponse = await http.get(itemurl);
          if (itemresponse.statusCode == 200) {
            var itemrespons = json.decode(itemresponse.body);
            Map<String, dynamic> itemmap = itemrespons;
            print(itemmap);

            var productmap = itemmap['products'];
            if (productmap != null) {
              for (var i = 0; i < productmap.length; i++) {
                Itemid.add(productmap[i]['_id']['\$oid']);
                Itemname.add(productmap[i]['name']);
                Itemimage.add(productmap[i]['image']);
                Itemprice.add(productmap[i]['price'].toString());
                Itemcategory.add(productmap[i]['category']);
              }
              setState(() {
                Itemid = Itemid;
                Itemname = Itemname;
                Itemimage = Itemimage;
                Itemprice = Itemprice;
                Itemcategory = Itemcategory;
              });
            }
          } else {
            print('No Items');
          }
        } else {
          setState(() {
            loading = false;
            userid = null;
          });
        }
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  void Login() async {
    var url = 'https://sellship.co/api/login';

    Map<String, String> body = {
      'email': loginEmailController.text,
      'password': loginPasswordController.text,
    };

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      print(jsondata);
      if (jsondata['id'] != null) {
        await storage.write(key: 'userid', value: jsondata['id']);
        if (jsondata['businessid'] != null) {
          await storage.write(key: 'businessid', value: jsondata['businessid']);
        }
        print('Loggd in ');
        setState(() {
          userid = jsondata['id'];
          getProfileData();
        });
      } else if (jsondata['status']['message'].toString().trim() ==
          'User does not exist, please sign up') {
      } else if (jsondata['status']['message'].toString().trim() ==
          'Invalid password, try again') {}
    } else {
      print(response.statusCode);
    }
  }

  void Signup() async {
    var url = 'https://sellship.co/api/signup';

    Map<String, String> body = {
      'first_name': signupNameController.text,
      'last_name': signupLastnameController.text,
      'email': signupEmailController.text,
      'phonenumber': numberphone,
      'password': signupPasswordController.text,
    };

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      print(jsondata);
      if (jsondata['id'] != null) {
        await storage.write(key: 'userid', value: jsondata['id']);

        print('signned up ');
        setState(() {
          userid = jsondata['id'];
          getProfileData();
        });
      } else {
        print('User Already Exists');
      }
    } else {
      print(response.statusCode);
    }
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}
