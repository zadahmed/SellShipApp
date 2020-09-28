import 'package:SellShip/Navigation/pageNames.dart';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
            if (widget.originPage == PageNames.loginPage) {
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
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
                  _SignInTextField(
                      fadeDelay: 1.2,
                      titleText: "First Name",
                      hintText: "Enter your first name",
                      controller: signupNameController),
                  _SignInTextField(
                    fadeDelay: 1.2,
                    titleText: "Last Name",
                    hintText: "Enter your last name",
                    controller: signupLastnameController,
                  ),
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
                          InternationalPhoneNumberInput(
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
                  _SignInTextField(
                    fadeDelay: 1.2,
                    titleText: "Email",
                    hintText: "Enter your email",
                    controller: signupEmailController,
                  ),
                  _SignInTextField(
                    fadeDelay: 1.3,
                    titleText: "Password",
                    hintText: "Enter your Password",
                    controller: signupPasswordController,
                    obscureText: true,
                  ),
                ],
              ),
              FadeAnimation(
                1.5,
                InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(5),
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
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => new AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
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
                ),
              ),
              FadeAnimation(
                  1.6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Already have an account?"),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
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
      Provider.of<UserProvider>(context, listen: false).signUpUser(
          firstName: signupNameController.text,
          lastName: signupLastnameController.text,
          email: signupEmailController.text,
          phoneNumber: signupphonecontroller.text,
          password: signupPasswordController.text,
          fcmtoken: firebasetoken,
          onSuccess: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Navigator.pushNamedAndRemoveUntil(
                //the predicate since it always returns false will remove
                // all screens under the stack and replace them with the one being pushed.
                context,
                Routes.rootScreen,
                (route) => false);
          },
          onUserAlreadyExist: () {
            showHttpResultDialog(
                "Looks like you already have an account! Please login instead");
          },
          onError: () {
            showHttpResultDialog('Looks like something went wrong!');
          });
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
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
