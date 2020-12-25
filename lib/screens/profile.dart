import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/edititem.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/featureitem.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/orders.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/reviews.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/settings.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/screens/termscondition.dart';
import 'package:SellShip/verification/verifyemail.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:numeral/numeral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
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

  final storage = new FlutterSecureStorage();

  ScrollController _scrollController = ScrollController();

  var userid;
  var loading;

  Map userProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: userid != null ? signedinprofile(context) : profile(context));
  }

  @override
  void dispose() {
    super.dispose();
  }

  var firebasetoken;

  TextEditingController EmailController = new TextEditingController();
  TextEditingController PasswordController = new TextEditingController();

  var notcount;

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/getnotification/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var notificationinfo = json.decode(response.body);
        var notif = notificationinfo['notification'];
        var notcoun = notificationinfo['notcount'];

        if (notcoun <= 0) {
          setState(() {
            notcount = notcoun;
            notbadge = false;
          });
          FlutterAppBadger.removeBadge();
        } else if (notcoun > 0) {
          setState(() {
            notcount = notcoun;
            notbadge = true;
          });
        }

        print(notcount);

        FlutterAppBadger.updateBadgeCount(notcount);
      } else {
        print(response.statusCode);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getnotification();
    setState(() {
      loading = true;
      notbadge = false;
    });
    _tabController = new TabController(length: 4, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    getProfileData();
    getItemData();
  }

  var profilepicture;
  var confirmedemail;

  bool confirmedfb;
  var followers;
  var itemssold;
  var following;
  var sold;
  var totalitems;

  var notbadge;
  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    var url = 'https://api.sellship.co/api/imageupload/' + userid;
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

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<String> ites = List<String>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              ites.add(profilemap[i]['_id']['\$oid']);
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            setState(() {
              favourites = jsoninreverse;
            });
          } else {
            favourites = [];
          }
        }
      }
    } else {
      setState(() {
        favourites = [];
      });
    }
  }

  List<String> favourites;

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    var url = 'https://api.sellship.co/api/imageupload/' + userid;
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

  final facebookLogin = FacebookLogin();

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');

        final profile = json.decode(graphResponse.body);

        var url = 'https://api.sellship.co/api/signup';

        print(profile);

        var name = profile['name'].split(" ");

        Map<String, String> body = {
          'first_name': name[0],
          'last_name': name[1],
          'email': profile['email'],
          'phonenumber': '00',
          'profilepicture': profile['picture']['data']['url'],
          'password': 'password',
        };

        final response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          print(jsondata);

          if (jsondata['status']['message'] == 'User already exists') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('seen', true);
            await storage.write(key: 'userid', value: jsondata['status']['id']);
            Navigator.of(context).pop();

            Navigator.pushNamedAndRemoveUntil(
                context, Routes.rootScreen, (route) => false);
          } else {
            Navigator.of(context).pop();

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhoneSignUp(
                    userid: jsondata['status']['id'],
                  ),
                ));
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
        Navigator.of(context).pop();
        break;
      case FacebookLoginStatus.error:
        setState(() => loggedin = false);
        Navigator.of(context).pop();
        break;
    }
  }

  var loggedin;

  TabController _tabController;

  Widget signedinprofile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
                child: Icon(
                  Feather.settings,
                  color: Color.fromRGBO(28, 45, 65, 1),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Settings(
                              email: email,
                              userid: userid,
                              confirmedemail: confirmedemail,
                              confirmedfb: confirmedfb,
                              confirmedphone: confirmedphone,
                            )),
                  );
                }),
          ),
          title: Container(
            height: 30,
            width: 120,
            child: Image.asset(
              'assets/logotransparent.png',
              fit: BoxFit.cover,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Badge(
                showBadge: notbadge,
                position: BadgePosition.topEnd(top: 2, end: -4),
                animationType: BadgeAnimationType.slide,
                badgeContent: Text(
                  notcount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotifcationPage()),
                    );
                  },
                  child: Icon(
                    Feather.bell,
                    color: Color.fromRGBO(28, 45, 65, 1),
                    size: 24,
                  ),
                ),
              ),
            ),
          ]),
      key: _scaffoldKey,
      body: loading == false
          ? DefaultTabController(
              length: 2,
              child: NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverList(
                          delegate: new SliverChildListDelegate([
                        Padding(
                            padding:
                                EdgeInsets.only(left: 30, top: 10, right: 30),
                            child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Row(children: <Widget>[
                                  Container(
                                    height: 110,
                                    width: 100,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade100,
                                                      width: 5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: profilepicture == null
                                                    ? Image.asset(
                                                        'assets/personplaceholder.png',
                                                        fit: BoxFit.fitWidth,
                                                      )
                                                    : CachedNetworkImage(
                                                        imageUrl:
                                                            profilepicture,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            SpinKitChasingDots(
                                                                color: Colors
                                                                    .deepOrange),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: InkWell(
                                            onTap: () {
                                              final action =
                                                  CupertinoActionSheet(
                                                message: Text(
                                                  "Upload an Image",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                actions: <Widget>[
                                                  CupertinoActionSheetAction(
                                                    child: Text(
                                                        "Upload from Camera",
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    isDefaultAction: true,
                                                    onPressed: () {
                                                      getImageCamera();
                                                    },
                                                  ),
                                                  CupertinoActionSheetAction(
                                                    child: Text(
                                                        "Upload from Gallery",
                                                        style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    isDefaultAction: true,
                                                    onPressed: () {
                                                      getImageGallery();
                                                    },
                                                  )
                                                ],
                                                cancelButton:
                                                    CupertinoActionSheetAction(
                                                  child: Text("Cancel",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  isDestructiveAction: true,
                                                  onPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  },
                                                ),
                                              );
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder: (context) => action);
                                            },
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  Color.fromRGBO(28, 45, 65, 1),
                                              child: Icon(
                                                Feather.camera,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  firstname != null
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 25),
                                          child: Column(
                                            children: [
                                              Text(
                                                firstname + ' ' + lastname,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 24.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                '@' +
                                                    firstname +
                                                    ' ' +
                                                    lastname,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16.0,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ))
                                      : Container(
                                          child: SpinKitChasingDots(
                                              color: Colors.deepOrangeAccent),
                                        ),
                                ]))),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: 140,
                            child: Stack(children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Container(
                                          color: Color.fromRGBO(
                                              131, 146, 165, 0.1),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(20),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      20))),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 30,
                                                        left: 20,
                                                        right: 20,
                                                        bottom: 5),
                                                    child: Container(
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    115,
                                                                    0,
                                                                    1),
                                                          )),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: <Widget>[
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                itemssold ==
                                                                        null
                                                                    ? '0'
                                                                    : itemssold
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                  height: 10.0),
                                                              Text(
                                                                'Sold',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: Colors
                                                                        .blueGrey),
                                                              )
                                                            ],
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                following ==
                                                                        null
                                                                    ? '0'
                                                                    : following
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                  height: 10.0),
                                                              Text(
                                                                'Likes',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: Colors
                                                                        .blueGrey),
                                                              )
                                                            ],
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                followers ==
                                                                        null
                                                                    ? '0'
                                                                    : followers
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                  height: 10.0),
                                                              Text(
                                                                'Followers',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: Colors
                                                                        .blueGrey),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ])))),
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 80,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 115, 0, 1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Feather.star,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          reviewrating != null
                                              ? reviewrating.toStringAsFixed(1)
                                              : '0.0',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )),
                            ]))
                      ]))
                    ];
                  },
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          color: Color.fromRGBO(131, 146, 165, 0.1),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: TabBar(
                                    controller: _tabController,
                                    labelStyle: tabTextStyle,
                                    onTap: (tab) {
                                      if (tab == 3) {
                                        refreshreviews();
                                      }
                                    },
                                    unselectedLabelStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Helvetica',
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicator: CircleTabIndicator(
                                        color: Colors.deepOrangeAccent,
                                        radius: 3),
                                    isScrollable: true,
                                    labelColor: Colors.black,
                                    tabs: [
                                      new Tab(
                                        text: 'Items',
                                      ),
                                      new Tab(
                                        text: 'Orders',
                                      ),
                                      new Tab(
                                        text: 'Favourites',
                                      ),
                                      new Tab(
                                        text: 'Reviews',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ])),
                      Expanded(
                        child: TabBarView(
                          children: [
                            item.isNotEmpty
                                ? storeitems(context)
                                : Container(
                                    child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: Text(
                                            'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                            )),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Expanded(
                                          child: Image.asset(
                                        'assets/little_theologians_4x.png',
                                        fit: BoxFit.fitWidth,
                                      ))
                                    ],
                                  )),
                            OrdersScreen(),
                            FavouritesScreen(),
                            reviewslist(context)
                          ],
                          controller: _tabController,
                        ),
                      )
                    ],
                  )))
          : Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: ListView(
                  children: [0, 1, 2, 3, 4, 5, 6]
                      .map((_) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }

  Widget favouriteslist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          favouritelist.isNotEmpty
              ? Flexible(
                  child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          crossAxisCount: 2,
                        ),
                        itemBuilder: ((BuildContext context, int index) {
                          return Padding(
                              padding: EdgeInsets.all(10),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Details(
                                              itemid:
                                                  favouritelist[index].itemid)),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.2, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        new Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 180,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: CachedNetworkImage(
                                                  imageUrl: favouritelist[index]
                                                      .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitChasingDots(
                                                          color: Colors
                                                              .deepOrange),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            favouritelist[index].sold == true
                                                ? Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height: 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      color: Colors
                                                          .deepPurpleAccent
                                                          .withOpacity(0.8),
                                                      child: Center(
                                                        child: Text(
                                                          'Sold',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ))
                                                : Container(),
                                          ],
                                        ),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: () async {
                                                          var userid =
                                                              await storage.read(
                                                                  key:
                                                                      'userid');

                                                          if (userid != null) {
                                                            var url =
                                                                'https://api.sellship.co/api/favourite/' +
                                                                    userid;

                                                            Map<String, String>
                                                                body = {
                                                              'itemid':
                                                                  favouritelist[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              var jsondata =
                                                                  json.decode(
                                                                      response
                                                                          .body);

                                                              favouritelist
                                                                  .clear();
                                                              for (int i = 0;
                                                                  i <
                                                                      jsondata
                                                                          .length;
                                                                  i++) {
                                                                Item ite = Item(
                                                                    itemid: jsondata[i]['_id'][
                                                                        '\$oid'],
                                                                    name: jsondata[i][
                                                                        'name'],
                                                                    image: jsondata[i][
                                                                        'image'],
                                                                    likes: jsondata[i]['likes'] == null
                                                                        ? 0
                                                                        : jsondata[i][
                                                                            'likes'],
                                                                    comments: jsondata[i]['comments'] == null
                                                                        ? 0
                                                                        : jsondata[i]['comments']
                                                                            .length,
                                                                    price: jsondata[i]
                                                                            ['price']
                                                                        .toString(),
                                                                    sold: jsondata[i]['sold'] == null ? false : jsondata[i]['sold'],
                                                                    category: jsondata[i]['category']);
                                                                favouritelist
                                                                    .add(ite);
                                                              }
                                                              setState(() {
                                                                item = item;
                                                              });
                                                            } else {
                                                              print(response
                                                                  .statusCode);
                                                            }
                                                          } else {
                                                            showInSnackBar(
                                                                'Please Login to use Favourites');
                                                          }
                                                        },
                                                        child: Icon(
                                                          FontAwesome.heart,
                                                          color:
                                                              Colors.deepPurple,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        favouritelist[index]
                                                                .likes
                                                                .toString() +
                                                            ' likes',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    CommentsPage(
                                                                        itemid:
                                                                            favouritelist[index].itemid)),
                                                          );
                                                        },
                                                        child: Icon(Feather
                                                            .message_circle),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    CommentsPage(
                                                                        itemid:
                                                                            favouritelist[index].itemid)),
                                                          );
                                                        },
                                                        child: Text(
                                                          favouritelist[index]
                                                              .comments
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    child: Text(
                                                      favouritelist[index].name,
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Container(
                                                    child: Text(
                                                      favouritelist[index]
                                                          .category,
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  currency != null
                                                      ? Container(
                                                          child: Text(
                                                            currency +
                                                                ' ' +
                                                                favouritelist[
                                                                        index]
                                                                    .price
                                                                    .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          child: Text(
                                                            favouritelist[index]
                                                                .price
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  )));
                        }),
                        itemCount: favourites.length,
                      )))
              : Expanded(
                  child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'View your favourites here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                        child: Image.asset(
                      'assets/favourites.png',
                      fit: BoxFit.fitWidth,
                    ))
                  ],
                )),
        ],
      ),
    );
  }

  getfavouritesuser() async {
    favouritelist.clear();
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<Item> ites = List<Item>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              if (profilemap[i] != null) {
                Item ite = Item(
                    itemid: profilemap[i]['_id']['\$oid'],
                    name: profilemap[i]['name'],
                    image: profilemap[i]['image'],
                    likes: profilemap[i]['likes'] == null
                        ? 0
                        : profilemap[i]['likes'],
                    comments: profilemap[i]['comments'] == null
                        ? 0
                        : profilemap[i]['comments'].length,
                    price: profilemap[i]['price'].toString(),
                    sold: profilemap[i]['sold'] == null
                        ? false
                        : profilemap[i]['sold'],
                    category: profilemap[i]['category']);
                ites.add(ite);
              }
            }

            Iterable inReverse = ites.reversed;
            List<Item> jsoninreverse = inReverse.toList();
            setState(() {
              favouritelist = jsoninreverse;
              loading = false;
            });
          } else {
            favouritelist = [];
          }
        } else {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  List<Item> favouritelist = List<Item>();

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
        Navigator.of(context).pop();
        setState(() {
          userid = jsondata['id'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('seen', true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RootScreen()));
      } else if (jsondata['status']['message'].toString().trim() ==
          'User does not exist, please sign up') {
        Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
                  },
                ));
      } else if (jsondata['status']['message'].toString().trim() ==
          'Invalid password, try again') {
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
      }
    } else {
      Navigator.of(context).pop();
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
                  'Looks like something went wrong!\nPlease try again!',
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
                onlyOkButton: true,
                entryAnimation: EntryAnimation.DEFAULT,
                onOkButtonPressed: () {
                  Navigator.of(context).pop();
                },
              ));
    }
  }

  Widget profile(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
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
                  height: MediaQuery.of(context).size.height / 2 + 50,
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
                                  obscureText: true,
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
                                                    height: 50,
                                                    width: 50,
                                                    child: SpinKitChasingDots(
                                                      color: Colors.deepOrange,
                                                    ));
                                              },
                                            ),
                                          ));
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
                                            if (jsondata['status']['message'] ==
                                                'User already exists') {
                                              await storage.write(
                                                  key: 'userid',
                                                  value: jsondata['status']
                                                      ['id']);
                                              Navigator.of(context).pop();

                                              Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.rootScreen,
                                                  (route) => false);
                                            } else {
                                              Navigator.of(context).pop();

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VerifyPhoneSignUp(
                                                      userid: jsondata['status']
                                                          ['id'],
                                                    ),
                                                  ));
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                useRootNavigator: false,
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
                                                        Navigator.of(context)
                                                            .pop();
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
                                      useRootNavigator: false,
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
            ],
          )),
    );
  }

  refreshreviews() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl = 'https://api.sellship.co/api/getreviews/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        print(jsonResponse);

        for (int i = 0; i < jsonResponse.length; i++) {
          var q = Map<String, dynamic>.from(jsonResponse[i]['date']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
          var dateuploaded = timeago.format(dateuploade);

          Reviews withd = Reviews(
            message: jsonResponse[i]['review'],
            date: dateuploaded,
            rating: jsonResponse[i]['rating'],
            username: jsonResponse[i]['reviewedusername'],
            profilepicture: jsonResponse[i]['reviewedprofilepic'],
          );
          reviews.add(withd);
        }

        Iterable inReverse = reviews.reversed;
        List<Reviews> jsoninreverse = inReverse.toList();

        setState(() {
          reviews = jsoninreverse;
        });
      }
    } else {
      setState(() {
        reviews = [];
      });
    }
    return reviews;
  }

  List<Reviews> reviews = List<Reviews>();

  Widget reviewslist(BuildContext context) {
    return reviews.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 36, top: 20, bottom: 10, right: 36),
                child: Text(
                  reviews.length.toString() + ' Reviews',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new Container(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, top: 5, bottom: 5, right: 16),
                              child: ListTile(
                                dense: true,
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: reviews[index]
                                              .profilepicture
                                              .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  reviews[index].profilepicture,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/personplaceholder.png',
                                              fit: BoxFit.fitWidth,
                                            )),
                                ),
                                trailing: Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      reviews[index].date,
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 10,
                                      ),
                                    )),
                                title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 250,
                                        child: Text(
                                          reviews[index].username,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          SmoothStarRating(
                                              allowHalfRating: true,
                                              starCount: 5,
                                              isReadOnly: true,
                                              rating: reviews[index].rating,
                                              size: 16.0,
                                              color: Color.fromRGBO(
                                                  255, 115, 0, 1),
                                              borderColor: Colors.blueGrey,
                                              spacing: 0.0),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            reviews[index].rating.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          )
                                        ],
                                      )
                                    ]),
                                subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(reviews[index].message,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 14,
                                              color: Colors.black
                                                  .withOpacity(0.6))),
                                      SizedBox(
                                        height: 2,
                                      ),
                                    ]),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 16.0),
                              )));
                    }),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  'View your Reviews here ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                  child: Image.asset(
                'assets/messages.png',
                fit: BoxFit.fitWidth,
              ))
            ],
          );
  }

  Widget storeitems(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.7),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Details(
                          itemid: item[index].itemid,
                          sold: item[index].sold,
                        )),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.2, color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      Container(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(microseconds: 5),
                            imageUrl: item[index].image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                SpinKitChasingDots(color: Colors.deepOrange),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              height: 35,
                              width: 145,
                              decoration: BoxDecoration(
                                color: Colors.black26.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    child: InkWell(
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Feather.heart,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              Numeral(item[index].likes)
                                                  .value(),
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        ),
                                      ),
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 10, right: 5),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: VerticalDivider(),
                                  ),
                                  Padding(
                                    child: InkWell(
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Feather.message_circle,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              Numeral(item[index].comments)
                                                  .value(),
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        ),
                                      ),
                                      enableFeedback: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentsPage(
                                                      itemid:
                                                          item[index].itemid)),
                                        );
                                      },
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 5, right: 10),
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                          )),
                      item[index].sold == true
                          ? Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepPurpleAccent.withOpacity(0.8),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    'Sold',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ))
                          : Container(),
                      Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditItem(
                                                itemid: item[index].itemid,
                                              )),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Feather.edit_2,
                                      color: Colors.blueGrey,
                                      size: 16,
                                    ),
                                  )))),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    child: Text(
                      item[index].name,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10),
                  ),
                  Padding(
                    child: Text(
                      item[index].category,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10),
                  ),
                  SizedBox(height: 4.0),
                  currency != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                              child: Row(
                            children: <Widget>[
                              Text(
                                currency + ' ' + item[index].price.toString(),
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                  child: Row(children: <Widget>[
                                Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.blueGrey,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  item[index].views.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ])),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          )))
                      : Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Container(
                            child: Text(
                              item[index].price.toString(),
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, top: 5, right: 10, bottom: 10),
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              if (item[index].sold == true) {
                                var url =
                                    'https://api.sellship.co/api/unsold/' +
                                        item[index].itemid +
                                        '/' +
                                        userid;

                                final response = await http.get(url);
                                if (response.statusCode == 200) {
                                  print(response.body);
                                }
                                getProfileData();
                                showInSnackBar('Item is now live!');
                              } else {
                                var url = 'https://api.sellship.co/api/sold/' +
                                    item[index].itemid +
                                    '/' +
                                    userid;
                                print(url);
                                final response = await http.get(url);
                                if (response.statusCode == 200) {
                                  print(response.body);
                                }
                                getProfileData();
                                showInSnackBar('Item has been marked sold!');
                              }
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width / 2 - 25,
                              decoration: BoxDecoration(
                                color: item[index].sold == true
                                    ? Colors.deepPurpleAccent
                                    : Colors.deepOrange,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Text(
                                  item[index].sold == false
                                      ? 'Mark Sold'
                                      : 'Mark Live',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
        );
      },
      itemCount: item.length,
    );
  }

  final int _numPages = 2;
  final PageController _pageControllerlogin = PageController(initialPage: 0);
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

  var numberphone;

  bool confirmedphone;

  var firstname;
  var lastname;
  var email;
  var phonenumber;

  List<Item> item = List<Item>();

  void getProfileData() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;
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

        var followin = profilemap['likes'];
        if (followin != null) {
          print(followin);
        } else {
          followin = 0;
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

        var confirmedemai = profilemap['confirmedemail'];
        if (confirmedemai != null) {
          print(confirmedemai);
        } else {
          confirmedemai = false;
        }

        var confirmedphon = profilemap['confirmedphone'];
        if (confirmedphon != null) {
          print(confirmedphon);
        } else {
          confirmedphon = false;
        }

        var confirmedf = profilemap['confirmedfb'];
        if (confirmedf != null) {
          print(confirmedf);
        } else {
          confirmedf = false;
        }

        var rating;
        if (profilemap['reviewrating'] == null) {
          rating = 0.0;
        } else {
          rating = profilemap['reviewrating'];
        }

        if (profilemap != null) {
          if (mounted) {
            setState(() {
              reviewrating = rating;
              firstname = profilemap['first_name'];
              lastname = profilemap['last_name'];
              phonenumber = profilemap['phonenumber'];
              email = profilemap['email'];
              loading = false;
              following = followin;
              followers = follower.length;
              itemssold = sol.length;
              confirmedfb = confirmedf;
              confirmedemail = confirmedemai;
              confirmedphone = confirmedphon;
              profilepicture = profilepic;
            });
          }

          await OneSignal.shared.setEmail(email: email);

          var itemurl = 'https://api.sellship.co/api/useritems/' + userid;
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
                    views: productmap[i]['views'] == null
                        ? 0
                        : productmap[i]['views'],
                    price: productmap[i]['price'].toString(),
                    likes: productmap[i]['likes'] == null
                        ? 0
                        : productmap[i]['likes'],
                    comments: productmap[i]['comments'] == null
                        ? 0
                        : productmap[i]['comments'].length,
                    sold: productmap[i]['sold'] == null
                        ? false
                        : productmap[i]['sold'],
                    category: productmap[i]['category']);
                ites.add(ite);
              }

              Iterable inReverse = ites.reversed;
              List<Item> jsoninreverse = inReverse.toList();

              setState(() {
                item = jsoninreverse;
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

  double reviewrating;

  void getItemData() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;

        var follower = profilemap['follower'];

        if (follower != null) {
        } else {
          follower = [];
        }

        var followin = profilemap['likes'];
        if (followin != null) {
        } else {
          followin = 0;
        }

        var sol = profilemap['sold'];
        if (sol != null) {
        } else {
          sol = [];
        }

        var profilepic = profilemap['profilepicture'];
        if (profilepic != null) {
        } else {
          profilepic = null;
        }

        if (profilemap != null) {
          var itemurl = 'https://api.sellship.co/api/useritems/' + userid;

          final itemresponse = await http.get(itemurl);
          if (itemresponse.statusCode == 200) {
            var itemrespons = json.decode(itemresponse.body);
            Map<String, dynamic> itemmap = itemrespons;

            List<Item> ites = List<Item>();
            var productmap = itemmap['products'];

            if (productmap != null) {
              for (var i = 0; i < productmap.length; i++) {
                Item ite = Item(
                    itemid: productmap[i]['_id']['\$oid'],
                    name: productmap[i]['name'],
                    image: productmap[i]['image'],
                    price: productmap[i]['price'].toString(),
                    views: productmap[i]['views'] == null
                        ? 0
                        : productmap[i]['views'],
                    likes: productmap[i]['likes'] == null
                        ? 0
                        : productmap[i]['likes'],
                    comments: productmap[i]['comments'] == null
                        ? 0
                        : productmap[i]['comments'].length,
                    sold: productmap[i]['sold'] == null
                        ? false
                        : productmap[i]['sold'],
                    category: productmap[i]['category']);
                ites.add(ite);
              }
              setState(() {
                item = ites;
                loading = false;
              });
            } else {
              setState(() {
                item = [];
                loading = false;
              });
            }
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
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

const tabTextStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'Helvetica',
    fontWeight: FontWeight.bold);

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height);

    var firstEndPoint = Offset(size.width * .5, size.height - 30.0);
    var firstControlpoint = Offset(size.width * 0.25, size.height - 50.0);
    path.quadraticBezierTo(firstControlpoint.dx, firstControlpoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 80.0);
    var secondControlPoint = Offset(size.width * .75, size.height - 10);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
