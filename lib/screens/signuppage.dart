import 'dart:convert';

import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/loginpage.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

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
    getNotifications();
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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeAnimation(
                      1,
                      Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: "SF",
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  FadeAnimation(
                      1.2,
                      Text(
                        "Create an account, It's free",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "SF",
                            color: Colors.grey[700]),
                      )),
                ],
              ),
              Column(
                children: <Widget>[
                  FadeAnimation(
                      1.2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'First Name',
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
                            controller: signupNameController,
                            decoration: InputDecoration(
                              hintText: "Enter your First Name",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  FadeAnimation(
                      1.2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Last Name',
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
                            controller: signupLastnameController,
                            decoration: InputDecoration(
                              hintText: "Enter your Last Name",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  FadeAnimation(
                      1.3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Phone Number',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "SF",
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          InternationalPhoneNumberInput.withCustomDecoration(
                            isEnabled: true,
                            onInputChanged: (PhoneNumber number) async {
                              var numberss = await PhoneNumber
                                  .getRegionInfoFromPhoneNumber(
                                      number.toString());
                              setState(() {
                                numberphone = numberss.toString();
                              });
                            },
                            focusNode: myFocusNodePhone,
                            autoValidate: true,
                            countries: ['GB', 'US', 'AE'],
                            textFieldController: signupphonecontroller,
                            inputDecoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "0501234567",
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  FadeAnimation(
                      1.2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email',
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
                            controller: signupEmailController,
                            decoration: InputDecoration(
                              hintText: "Enter your Email",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  FadeAnimation(
                      1.3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Password',
                            style: TextStyle(
                                fontFamily: "SF",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: signupPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter your Password",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400])),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                ],
              ),
              FadeAnimation(
                  1.5,
                  Container(
                    padding: EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        )),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
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
                                          height: 50,
                                          width: 50,
                                          child: SpinKitChasingDots(
                                            color: Colors.deepOrange,
                                          ));
                                    },
                                  ),
                                ));
                        Signup();
                      },
                      color: Colors.deepOrangeAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: "SF",
                            fontSize: 18),
                      ),
                    ),
                  )),
              FadeAnimation(
                  1.6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Already have an account?"),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text(
                          " Login",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: "SF",
                              fontSize: 14),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  final storage = new FlutterSecureStorage();
  var firebasetoken;
  var userid;

  getNotifications() async {
    var token = await FirebaseNotifications().getNotifications(context);
    setState(() {
      firebasetoken = token;
    });
    if (userid != null) {
      print(token + "\n Token was recieved from firebase");
      var url = 'https://api.sellship.co/api/checktokenfcm/' +
          userid +
          '/' +
          firebasetoken;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print(response.statusCode);
      }
    }
  }

  void Signup() async {
    if (signupNameController.text.isNotEmpty &&
        signupLastnameController.text.isNotEmpty &&
        signupEmailController.text.isNotEmpty &&
        signupPasswordController.text.isNotEmpty &&
        signupphonecontroller.text.isNotEmpty) {
      var url = 'https://api.sellship.co/api/signup';

      Map<String, String> body = {
        'first_name': signupNameController.text,
        'last_name': signupLastnameController.text,
        'email': signupEmailController.text,
        'phonenumber': signupphonecontroller.text,
        'password': signupPasswordController.text,
        'fcmtoken': firebasetoken,
      };

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print(jsondata);
        if (jsondata['id'] != null) {
          await storage.write(key: 'userid', value: jsondata['id']);
          Navigator.of(context, rootNavigator: true).pop('dialog');

          setState(() {
            userid = jsondata['id'];
          });
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RootScreen()));
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
                          fontSize: 22.0, fontWeight: FontWeight.w600),
                    ),
                    description: Text(
                      'Looks like you already have an account! Please login instead',
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
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
                  description: Text(
                    'Looks like something went wrong!',
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
    } else {
      showInSnackBar('Looks like you missed out something!');
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
        style: TextStyle(fontFamily: 'SF', fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    ));
  }
}
