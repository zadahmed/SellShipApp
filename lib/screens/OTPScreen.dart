import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/otpinput.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String phonenumber;
  final String userid;
  OTPScreen({Key key, this.phonenumber, this.userid}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController _pinEditingController = TextEditingController();

  PinDecoration _pinDecoration =
      UnderlineDecoration(enteredColor: Colors.black, hintText: '000000');

  bool isCodeSent = false;
  String _verificationId;

  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
    print(widget.phonenumber);
    _onVerifyCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Feather.arrow_left)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Verify Phone Number',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          height: 400,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset(
                            'assets/165.png',
                            fit: BoxFit.cover,
                          ))
                    ])),
            Container(
              padding: EdgeInsets.only(left: 16.0, bottom: 10, top: 30),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          "Verification code sent to ${widget.phonenumber}",
                          style: TextStyle(
                              fontSize: 20.0,
//                            fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 30, top: 10, right: 30),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 70,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(131, 146, 165, 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: PinInputTextField(
                          pinLength: 6,
                          decoration: _pinDecoration,
                          controller: _pinEditingController,
                          autoFocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmit: (pin) {
                            if (pin.length == 6) {
                              _onFormSubmitted();
                            } else {
                              showInSnackBar("Invalid OTP");
                            }
                          },
                        ),
                      ),
                    ])),
            Padding(
              padding: EdgeInsets.only(left: 36, top: 30, right: 36),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _onFormSubmitted();
                      },
                      child: Container(
                        height: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: MediaQuery.of(context).size.width - 250,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 115, 0, 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                            child: Text(
                          'Verify Phone',
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
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      _onVerifyCode();
                    });
                  },
                  child: Text(
                    "Resent OTP",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
          fontFamily: 'Helvetica',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
        } else {
          showInSnackBar("Error validating OTP, try again");
        }
      }).catchError((error) {
        showInSnackBar(
          "Try again in sometime",
        );
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showInSnackBar(authException.message);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "${widget.phonenumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((UserCredential value) async {
      if (value.user != null) {
        print(value.user.phoneNumber);

        var url = 'https://api.sellship.co/verify/phone/' +
            userid +
            '/' +
            value.user.phoneNumber;

        final response = await http.get(url);
        if (response.statusCode == 200) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: Container(
                    width: 300.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Icon(
                            Feather.check,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Your phone number has been verified successfully.',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Helvetica",
                                fontWeight: FontWeight.w400,
                                color: Colors.black54),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        InkWell(
                          onTap: () async {
                            final storage = new FlutterSecureStorage();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('seen', true);
                            Navigator.of(context).pop();
                            await storage.write(
                                key: 'userid', value: widget.userid);
                            Navigator.pushNamedAndRemoveUntil(
                                context, Routes.rootScreen, (route) => false);
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                            ),
                            child: Text(
                              "Close",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "SF",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          showInSnackBar(
            "Error validating OTP, try again",
          );
        }
      } else {
        showInSnackBar(
          "Error validating OTP, try again",
        );
      }
    }).catchError((error) {
      showInSnackBar("Something went wrong. $error");
    });
  }
}
