import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/providers/userProvider.dart';
import 'package:SellShip/screens/otpinput.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/verification/verifyemailsignup.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreenSignUp extends StatefulWidget {
  final String phonenumber;
  final String userid;
  final String email;
  final String fullname;
  final String password;

  OTPScreenSignUp(
      {Key key,
      this.phonenumber,
      this.userid,
      this.fullname,
      this.email,
      this.password})
      : super(key: key);

  @override
  _OTPScreenSignUpState createState() => _OTPScreenSignUpState();
}

class _OTPScreenSignUpState extends State<OTPScreenSignUp> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController _pinEditingController = TextEditingController();

  PinDecoration _pinDecoration = UnderlineDecoration(
    enteredColor: Colors.deepOrange,
    color: Colors.transparent,
    hintText: '000000',
  );

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
        setState(() {
          authvalue = value;
        });
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

  var authvalue;
  void _onFormSubmitted() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 100,
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SpinKitChasingDots(color: Colors.deepOrange)),
            ),
          );
        });

    Provider.of<UserProvider>(context, listen: false).signUpUser(
        firstName: widget.fullname,
        lastName: '',
        email: widget.email,
        phoneNumber: widget.phonenumber,
        password: widget.password,
        onSuccess: () async {
          final storage = new FlutterSecureStorage();
          var userid = await storage.read(key: 'userid');

          var url = 'https://api.sellship.co/verify/phone/' +
              userid +
              '/' +
              widget.phonenumber;

          print('userid');
          print(widget.phonenumber);
          print(userid);
          final response = await http.get(url);
          if (response.statusCode == 200) {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyEmailSignUp(
                          userid: userid,
                          email: widget.email,
                        )));
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('seen', true);
          } else {
            Navigator.pop(context);
          }
        },
        onUserAlreadyExist: () {
          showHttpResultDialog(
              "Looks like you already have an account! Please login instead");
        },
        onError: () {
          showHttpResultDialog('Looks like something went wrong!');
        });
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
