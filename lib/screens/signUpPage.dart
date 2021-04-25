import 'package:SellShip/Navigation/pageNames.dart';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/providers/userProvider.dart';
import 'package:SellShip/screens/OTPScreenSignUp.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({this.originPage});

  ///[originPage] use PageNames Class to reference names / found in navigation folder
  final String originPage;

  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodePhone = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();
  final FocusNode myFocusNodeLastName = FocusNode();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupLastnameController = new TextEditingController();
  TextEditingController signupphonecontroller = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    signupphonecontroller.dispose();
    super.dispose();
  }

  var numberphone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        key: _scaffoldKey,
        body: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Align(
                alignment: Alignment.topCenter,
                child: FadeAnimation(
                    1,
                    Stack(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: 250,
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
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ))),
                      ],
                    )),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.3,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              131, 146, 165, 0.1),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: TextField(
                                          onChanged: (text) {},
                                          controller: signupNameController,
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            hintText: "Full Name",
                                            hintStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            icon: Icon(
                                              Feather.user,
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
                                      left: 30, top: 20, right: 30),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: Container(
                                          height: 85,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                131, 146, 165, 0.1),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: InternationalPhoneNumberInput(
                                            isEnabled: true,
                                            onInputChanged:
                                                (PhoneNumber number) async {
                                              if (number != null) {
                                                setState(() {
                                                  numberphone =
                                                      number.toString();
                                                });
                                              }
                                            },
                                            focusNode: myFocusNodePhone,
                                            autoValidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            countries: ['AE'],
                                            textFieldController:
                                                signupphonecontroller,
                                            inputDecoration: InputDecoration(
                                                hintText: "501234567",
                                                hintStyle: TextStyle(
                                                    color: Colors.grey.shade300,
                                                    fontFamily: 'Helvetica')),
                                          ),
                                        ))
                                      ])),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 30, top: 20, right: 30),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              131, 146, 165, 0.1),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: TextField(
                                          onChanged: (text) {},
                                          controller: signupEmailController,
                                          cursorColor: Colors.black,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            hintText: "Email Address",
                                            hintStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            icon: Icon(
                                              Feather.mail,
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
                                      left: 30, top: 20, right: 30),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              131, 146, 165, 0.1),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: TextField(
                                          onChanged: (text) {},
                                          obscureText: true,
                                          controller: signupPasswordController,
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            hintText: "Password",
                                            hintStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18),
                                            icon: Icon(
                                              Feather.lock,
                                              color: Colors.blueGrey,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 36, top: 20, right: 36),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        useRootNavigator: false,
                                        barrierDismissible: false,
                                        builder: (_) => new AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              content: Builder(
                                                builder: (context) {
                                                  return Container(
                                                      height: 50,
                                                      width: 50,
                                                      child:
                                                          SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange,
                                                      ));
                                                },
                                              ),
                                            ));
                                    Signup();
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
                              ]),
                        ),
                        SizedBox(
                          height: 30,
                        ),
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
                                    "Already have an account?  ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                      fontFamily: 'Helvetica',
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Helvetica',
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  )),
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
            ])));
  }

  final storage = new FlutterSecureStorage();
  var firebasetoken;
  var userid;

  bool isValid = false;
  Future<Null> validate(StateSetter updateState) async {
    print("in validate : ${signupphonecontroller.text.length}");
    if (signupphonecontroller.text.length == 10) {
      updateState(() {
        isValid = true;
      });
    }
  }

  void Signup() async {
    if (signupNameController.text.isNotEmpty &&
        signupEmailController.text.isNotEmpty &&
        signupPasswordController.text.isNotEmpty &&
        signupphonecontroller.text.isNotEmpty) {
      final bool isValid = EmailValidator.validate(signupEmailController.text);
      if (isValid) {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreenSignUp(
                  phonenumber: numberphone,
                  userid: userid,
                  fullname: signupNameController.text,
                  email: signupEmailController.text,
                  password: signupPasswordController.text),
            ));
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
      showInSnackBar('Looks like you missed something!');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica', fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    ));
  }

  void showHttpResultDialog(String message) {
    showDialog(
        context: context,
        useRootNavigator: false,
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
                message,
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              onlyOkButton: true,
              entryAnimation: EntryAnimation.DEFAULT,
              onOkButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ));
  }
}

class _SignInTextField extends StatelessWidget {
  _SignInTextField(
      {@required this.titleText,
      @required this.hintText,
      @required this.controller,
      this.obscureText = false,
      this.fadeDelay});

  final String titleText;
  final bool obscureText;
  final String hintText;
  final double fadeDelay;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
        fadeDelay,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titleText,
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: "SF",
                  fontWeight: FontWeight.w400,
                  color: Colors.black87),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              obscureText: obscureText,
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}
