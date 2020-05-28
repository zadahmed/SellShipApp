import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/balance.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/termscondition.dart';
import 'package:SellShip/support.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/editprofile.dart';
import 'package:image_picker/image_picker.dart';
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
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                child: Container(
                  height: 100,
                  child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SpinKitChasingDots(color: Colors.deepOrange)),
                ),
              );
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
          'fcmtoken': firebasetoken,
        };

        final response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          print(jsondata);
          if (jsondata['id'] != null) {
            await storage.write(key: 'userid', value: jsondata['id']);
            Navigator.of(context, rootNavigator: true).pop('dialog');
            print('signned up ');
            setState(() {
              userid = jsondata['id'];
              Navigator.pop(context);
              getProfileData();
            });
          } else {
            var url = 'https://sellship.co/api/login';

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
                setState(() {
                  userid = jsondata['id'];
                  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: profile(context));
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    signupphonecontroller.dispose();
    super.dispose();
  }

  var firebasetoken;
  getNotifications() async {
    var token = await FirebaseNotifications().getNotifications();
    setState(() {
      firebasetoken = token;
    });
    if (userid != null) {
      print(token + "\n Token was recieved from firebase");
      var url = 'https://sellship.co/api/checktokenfcm/' +
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

  @override
  void initState() {
    super.initState();
    getNotifications();
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
        style: TextStyle(fontFamily: 'SF', fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildSignIn(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Container(
                padding: EdgeInsets.only(top: 15.0),
                decoration: new BoxDecoration(
                  color: Colors.deepOrange,
                  border: Border.all(
                      width: 1, //
                      color: Colors.grey
                          .shade200 //                <--- border width here
                      ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              FontAwesome.close,
                              size: 30,
                              color: Colors.white,
                            ))
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    Container(
                      height: 60,
                      width: 200,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
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
                                      top: 20.0,
                                      bottom: 20.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodeEmailLogin,
                                    controller: loginEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.black,
                                        size: 22.0,
                                      ),
                                      hintText: "Email Address",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
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
                                      top: 20.0,
                                      bottom: 20.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodePasswordLogin,
                                    controller: loginPasswordController,
                                    obscureText: _obscureTextLogin,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        size: 22.0,
                                        color: Colors.black,
                                      ),
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                      ),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            gradient: new LinearGradient(
                                colors: [
                                  Colors.deepOrange,
                                  Colors.deepOrangeAccent
                                ],
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
                                  style: TextStyle(
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                20.0)), //this right here
                                        child: Container(
                                          height: 100,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: SpinKitChasingDots(
                                                  color: Colors.deepOrange)),
                                        ),
                                      );
                                    });
                                Login();
                              }),
                        ),
                      ],
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
                            child: InkWell(
                              onTap: () {},
                              child: Text(
                                "Or",
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
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
                        InkWell(
                          onTap: () {
                            _loginWithFB();
                          },
                          child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: new BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(25)),
                              width: 300,
                              height: 50,
                              child: Text(
                                'Login with Facebook',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                    color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: FlatButton(
                          onPressed: () {},
                          child: Text(
                            'By logging In \n you agree to the Terms and Conditions',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'SF',
                                fontSize: 12,
                                color: Colors.white),
                          )),
                    ),
                  ],
                ),
              )));
    });
  }

  var profilepicture;
  var loading;
  var followers;
  var itemssold;
  var following;
  var sold;
  var totalitems;

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    var url = 'https://sellship.co/api/imageupload/' + userid;
    Dio dio = new Dio();
    FormData formData;
    String fileName = image.path.split('/').last;
    formData = FormData.fromMap({
      'profilepicture':
          await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      print(response.data);
    }

    setState(() {
      profilepicture = response.data;
    });

    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    var url = 'https://sellship.co/api/imageupload/' + userid;
    Dio dio = new Dio();
    FormData formData;
    String fileName = image.path.split('/').last;
    formData = FormData.fromMap({
      'profilepicture':
          await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      print(response.data);
    }

    setState(() {
      profilepicture = response.data;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  var currency;
  TextEditingController searchcontroller = new TextEditingController();

  onSearch(String texte) async {
    if (texte.isEmpty) {
      setState(() {});
    } else {
      searchcontroller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search(text: texte)),
      );
    }
  }

  Widget profile(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 70),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 120,
                          child: Image.asset(
                            'assets/logotransparent.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    )),
              ),
            )),
        body: loading == false
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: 2,
                  ),
                  userid != null
                      ? GestureDetector(
                          onTap: () {
                            final action = CupertinoActionSheet(
                              message: Text(
                                "Upload an Image",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal),
                              ),
                              actions: <Widget>[
                                CupertinoActionSheetAction(
                                  child: Text("Upload from Camera",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.normal)),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    getImageCamera();
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: Text("Upload from Gallery",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.normal)),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    getImageGallery();
                                  },
                                )
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal)),
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            );
                            showCupertinoModalPopup(
                                context: context, builder: (context) => action);
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: profilepicture == null
                                  ? Image.asset(
                                      'assets/personplaceholder.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: profilepicture,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          SpinKitChasingDots(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    showBottomSheet(
                                        context: context,
                                        elevation: 1,
                                        builder: (context) =>
                                            _buildSignIn(context));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: Icon(
                                          Feather.user,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                            fontFamily: 'SF',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showBottomSheet(
                                        context: context,
                                        elevation: 1,
                                        builder: (context) =>
                                            _buildSignUp(context));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: Icon(
                                          Feather.user_plus,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Sign Up',
                                        style: TextStyle(
                                            fontFamily: 'SF',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  userid != null ? SizedBox(height: 25.0) : Container(),
                  firstname != null
                      ? Text(
                          firstname + ' ' + lastname,
                          style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  userid != null ? SizedBox(height: 4.0) : Container(),
                  userid != null
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: 10, left: 30, right: 30, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    followers == null
                                        ? '0'
                                        : followers.toString(),
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'FOLLOWERS',
                                    style: TextStyle(
                                        fontFamily: 'SF', color: Colors.grey),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    itemssold == null
                                        ? '0'
                                        : itemssold.toString(),
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'ITEMS SOLD',
                                    style: TextStyle(
                                        fontFamily: 'SF', color: Colors.grey),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    following == null
                                        ? '0'
                                        : following.toString(),
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'FOLLOWING',
                                    style: TextStyle(
                                        fontFamily: 'SF', color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Divider(),
                  Expanded(
                      child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: <Widget>[
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyItems()),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Feather.shopping_bag,
                                      color: Colors.deepOrange,
                                    ),
                                    trailing: Icon(
                                      Feather.arrow_right,
                                      size: 16,
                                      color: Colors.deepOrange,
                                    ),
                                    title: Text('My Items'),
                                  ),
                                ))
                            : Container(),
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Balance()),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.attach_money,
                                      color: Colors.deepOrange,
                                    ),
                                    trailing: Icon(
                                      Feather.arrow_right,
                                      size: 16,
                                      color: Colors.deepOrange,
                                    ),
                                    title: Text('Balance'),
                                  ),
                                ))
                            : Container(),
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    Feather.edit_3,
                                    color: Colors.deepOrange,
                                  ),
                                  trailing: Icon(
                                    Feather.arrow_right,
                                    size: 16,
                                    color: Colors.deepOrange,
                                  ),
                                  title: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProfile()),
                                    );
                                  },
                                ))
                            : Container(),
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    Feather.heart,
                                    color: Colors.deepOrange,
                                  ),
                                  trailing: Icon(
                                    Feather.arrow_right,
                                    size: 16,
                                    color: Colors.deepOrange,
                                  ),
                                  title: Text(
                                    'Favourites',
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FavouritesScreen()),
                                    );
                                  },
                                ))
                            : Container(),
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Support(email: email)),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.help_outline,
                                      color: Colors.deepOrange,
                                    ),
                                    trailing: Icon(
                                      Feather.arrow_right,
                                      size: 16,
                                      color: Colors.deepOrange,
                                    ),
                                    title: Text('Help & Support'),
                                  ),
                                ))
                            : Container(),
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: Icon(
                              Feather.file_text,
                              color: Colors.deepOrange,
                            ),
                            trailing: Icon(
                              Feather.arrow_right,
                              size: 16,
                              color: Colors.deepOrange,
                            ),
                            title: Text(
                              'Terms and Conditions',
                              style: TextStyle(
                                fontFamily: 'SF',
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TermsandConditions()),
                              );
                            },
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: Icon(
                              Feather.eye,
                              color: Colors.deepOrange,
                            ),
                            trailing: Icon(
                              Feather.arrow_right,
                              size: 16,
                              color: Colors.deepOrange,
                            ),
                            title: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontFamily: 'SF',
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PrivacyPolicy()),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        userid != null
                            ? Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    Feather.log_out,
                                    color: Colors.deepOrange,
                                  ),
                                  title: Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onTap: () {
                                    storage.delete(key: 'userid');
                                    setState(() {
                                      userid = null;
                                    });
                                  },
                                ))
                            : Container()
                      ],
                    ),
                  ))
                ],
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Container(
                padding: EdgeInsets.only(top: 15.0),
                decoration: new BoxDecoration(
                  color: Colors.deepOrange,
                  border: Border.all(
                      width: 1, //
                      color: Colors.grey
                          .shade200 //                <--- border width here
                      ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              FontAwesome.close,
                              size: 30,
                              color: Colors.white,
                            ))
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    Container(
                      height: 60,
                      width: 200,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
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
                            height: 430.0,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodeName,
                                    controller: signupNameController,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.user,
                                        color: Colors.black,
                                      ),
                                      hintText: "First Name",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
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
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodeLastName,
                                    controller: signupLastnameController,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesome5.user,
                                        color: Colors.black,
                                      ),
                                      hintText: "Last Name",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
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
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: InternationalPhoneNumberInput
                                      .withCustomDecoration(
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
                                        border: UnderlineInputBorder()),
                                  ),
                                ),
                                Container(
                                  width: 250.0,
                                  height: 1.0,
                                  color: Colors.grey[400],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodeEmail,
                                    controller: signupEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.black,
                                      ),
                                      hintText: "Email Address",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
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
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    focusNode: myFocusNodePassword,
                                    controller: signupPasswordController,
                                    obscureText: _obscureTextSignup,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.black,
                                      ),
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                      ),
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
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 25.0,
                                      right: 25.0),
                                  child: TextField(
                                    controller: signupConfirmPasswordController,
                                    obscureText: _obscureTextSignupConfirm,
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        FontAwesomeIcons.userLock,
                                        color: Colors.black,
                                      ),
                                      hintText: "Confirmation",
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                      ),
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
                          margin: EdgeInsets.only(top: 420.0),
                          decoration: new BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
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
                                  style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                if (signupEmailController.text.isNotEmpty &&
                                    signupphonecontroller.text.isNotEmpty !=
                                        null &&
                                    signupNameController.text.isNotEmpty !=
                                        null) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.0)), //this right here
                                          child: Container(
                                            height: 100,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: SpinKitChasingDots(
                                                    color: Colors.deepOrange)),
                                          ),
                                        );
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
                                              style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 22,
                                              ),
                                            ),
                                            description: Text(
                                              'Looks like you\'re missing something',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 16,
                                              ),
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
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        child: Text(
                      'By Signing Up \n you agree to the Terms and Conditions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'SF', fontSize: 12, color: Colors.white),
                    )),
                  ],
                ),
              )));
    });
  }

  final storage = new FlutterSecureStorage();

  var firstname;
  var lastname;
  var email;
  var phonenumber;
  String userid;

  List<Item> item = List<Item>();
  void getProfileData() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }

    if (userid != null) {
      await _firebaseMessaging.getToken().then((token) {
        setState(() {
          firebasetoken = token;
        });
      });
      var url = 'https://sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;

        var follower = profilemap['follower'];

        if (follower != null) {
          print(follower);
        } else {
          follower = [];
        }

        var followin = profilemap['following'];
        if (followin != null) {
          print(followin);
        } else {
          followin = [];
        }

        var sol = profilemap['sold'];
        if (sol != null) {
          print(sol);
        } else {
          sol = [];
        }

        var profilepic = profilemap['profilepicture'];
        if (profilepic != null) {
          print(profilepic);
        } else {
          profilepic = null;
        }

        if (profilemap != null) {
          if (mounted) {
            setState(() {
              firstname = profilemap['first_name'];
              lastname = profilemap['last_name'];
              phonenumber = profilemap['phonenumber'];
              email = profilemap['email'];
              loading = false;
              following = followin.length;
              followers = follower.length;
              itemssold = sol.length;
              profilepicture = profilepic;
            });
          }

          var itemurl = 'https://sellship.co/api/useritems/' + userid;
          print(itemurl);
          final itemresponse = await http.get(itemurl);
          if (itemresponse.statusCode == 200) {
            var itemrespons = json.decode(itemresponse.body);
            Map<String, dynamic> itemmap = itemrespons;
            print(itemmap);
            List<Item> ites = List<Item>();
            var productmap = itemmap['products'];

            if (productmap != null) {
              for (var i = 0; i < productmap.length; i++) {
                Item ite = Item(
                    itemid: productmap[i]['_id']['\$oid'],
                    name: productmap[i]['name'],
                    image: productmap[i]['image'],
                    price: productmap[i]['price'].toString(),
                    sold: productmap[i]['sold'] == null
                        ? false
                        : productmap[i]['sold'],
                    category: productmap[i]['category']);
                ites.add(ite);
              }
              setState(() {
                item = ites;
              });
            }
          } else {
            item = [];
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
      'fcmtoken': firebasetoken,
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
        Navigator.of(context, rootNavigator: true).pop('dialog');
        setState(() {
          userid = jsondata['id'];
          Navigator.pop(context);
          getProfileData();
        });
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

  void Signup() async {
    var url = 'https://sellship.co/api/signup';

    Map<String, String> body = {
      'first_name': signupNameController.text,
      'last_name': signupLastnameController.text,
      'email': signupEmailController.text,
      'phonenumber': numberphone,
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
        print('signned up ');
        setState(() {
          userid = jsondata['id'];
        });
        Navigator.pop(context);
        getProfileData();
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
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
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
                  'Looks like something went wrong!',
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
