import 'dart:io';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/balance.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/edititem.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/loginpage.dart';
import 'package:SellShip/screens/loginprofile.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/settings.dart';
import 'package:SellShip/screens/signuppage.dart';
import 'package:SellShip/screens/signupprofiel.dart';
import 'package:SellShip/screens/termscondition.dart';
import 'package:SellShip/support.dart';
import 'package:SellShip/verification/verifyemail.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
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

  final storage = new FlutterSecureStorage();

  ScrollController _scrollController = ScrollController();

  var userid;
  var loading;

  Map userProfile;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
  getNotifications() async {
    var token = await FirebaseNotifications().getNotifications(context);
    setState(() {
      firebasetoken = token;
    });
    if (userid != null) {

      var url = 'https://api.sellship.co/api/checktokenfcm/' +
          userid +
          '/' +
          firebasetoken;

      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print(response.statusCode);
      }
    }
  }

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/getnotification/' + userid;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var notificationinfo = json.decode(response.body);
      var notif = notificationinfo['notification'];

      if (notif <= 0) {
        setState(() {
          notifcount = notif;
          notifbadge = false;
        });
      } else if (notif > 0) {
        setState(() {
          notifcount = notif;
          notifbadge = true;
        });
      }
    } else {
      print(response.statusCode);
    }
  }

  var notifcount;
  var notifbadge;

  bool verified;

  @override
  void initState() {
    super.initState();
    getNotifications();
    getnotification();
    setState(() {
      loading = true;
      notifbadge = false;
      verified = false;
    });
    _tabController = new TabController(length: 3, vsync: this);
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

  var followers;
  var itemssold;
  var following;
  var sold;
  var totalitems;

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

  TabController _tabController;

  Widget signedinprofile(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: loading == false
          ? CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        child: Icon(
                          Feather.settings,
                          color: Colors.deepOrange,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Settings(
                                      email: email,
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
                        showBadge: notifbadge,
                        position: BadgePosition.topRight(top: 2),
                        animationType: BadgeAnimationType.slide,
                        badgeContent: Text(
                          notifcount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Messages()),
                            );
                          },
                          child: Icon(
                            Feather.message_square,
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                    child: Container(
                        color: Colors.white,
                        width: double.infinity,
//                  height: MediaQuery.of(context).size.height,
                        child: Column(children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
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
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: profilepicture == null
                                        ? Image.asset(
                                            'assets/personplaceholder.png',
                                            fit: BoxFit.fitWidth,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: profilepicture,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitChasingDots(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 30, right: 30, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          followers == null
                                              ? '0'
                                              : followers.toString(),
                                          style: TextStyle(
                                              fontFamily: 'SF',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'SF',
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          itemssold == null
                                              ? '0'
                                              : itemssold.toString(),
                                          style: TextStyle(
                                              fontFamily: 'SF',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          'Items Sold',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'SF',
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          following == null
                                              ? '0'
                                              : following.toString(),
                                          style: TextStyle(
                                              fontFamily: 'SF',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'SF',
                                              color: Colors.black),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  firstname + ' ' + lastname,
                                  style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Verify your information to sell faster',
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.0),
                          SizedBox(height: 4.0),
                          verified == false
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 30, right: 30, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VerifyEmail(
                                                      email: email,
                                                      userid: userid,
                                                    )),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            confirmedemail == true
                                                ? Badge(
                                                    showBadge: true,
                                                    badgeColor:
                                                        Colors.deepOrangeAccent,
                                                    position: BadgePosition
                                                        .topRight(),
                                                    animationType:
                                                        BadgeAnimationType
                                                            .slide,
                                                    badgeContent: Icon(
                                                      Feather.check_circle,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 0.2,
                                                              color:
                                                                  Colors.grey),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: CircleAvatar(
                                                          child: Icon(
                                                            Feather.mail,
                                                            color: Colors
                                                                .deepOrange,
                                                          ),
                                                          backgroundColor:
                                                              Colors.white,
                                                        )))
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.2,
                                                          color: Colors.grey),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: CircleAvatar(
                                                      child: Icon(
                                                        Feather.mail,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                            SizedBox(height: 10.0),
                                            confirmedemail == false
                                                ? Text(
                                                    'Verify Email',
                                                    style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 14),
                                                  )
                                                : Text(
                                                    'Email Verified',
                                                    style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 14),
                                                  )
                                          ],
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
                                                    VerifyPhone(
                                                      userid: userid,
                                                    )),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            confirmedphone == true
                                                ? Badge(
                                                    showBadge: true,
                                                    badgeColor:
                                                        Colors.deepOrangeAccent,
                                                    position: BadgePosition
                                                        .topRight(),
                                                    animationType:
                                                        BadgeAnimationType
                                                            .slide,
                                                    badgeContent: Icon(
                                                      Feather.check_circle,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 0.2,
                                                              color:
                                                                  Colors.grey),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: CircleAvatar(
                                                          child: Icon(
                                                            Feather.phone,
                                                            color: Colors
                                                                .deepOrange,
                                                          ),
                                                          backgroundColor:
                                                              Colors.white,
                                                        )))
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.2,
                                                          color: Colors.grey),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: CircleAvatar(
                                                      child: Icon(
                                                        Feather.phone,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                            SizedBox(height: 10.0),
                                            confirmedphone == false
                                                ? Text(
                                                    'Verify Phone',
                                                    style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 14),
                                                  )
                                                : Text(
                                                    'Phone Verified',
                                                    style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 14),
                                                  )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          CircleAvatar(
                                            child: Icon(
                                              Feather.facebook,
                                              color: Colors.white,
                                            ),
                                            backgroundColor: Colors.blue,
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            'Connect Facebook',
                                            style: TextStyle(
                                                fontFamily: 'SF', fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(child: Text('Verified')),
                        ]))),
                SliverAppBar(
                  backgroundColor: Colors.white,
                  pinned: true,
                  title: TabBar(
                    labelColor: Colors.black,
                    labelStyle: TextStyle(
                      fontFamily: 'SF',
                      fontSize: 14.0,
                    ),
                    indicatorColor: Colors.deepOrange,
                    controller: _tabController,
                    tabs: [
                      new Tab(
                        icon: const Icon(
                          Feather.clipboard,
                          size: 23,
                          color: Colors.deepOrange,
                        ),
                        text: 'My Items',
                      ),
                      new Tab(
                        icon: const Icon(
                          Feather.shopping_bag,
                          size: 23,
                          color: Colors.deepOrange,
                        ),
                        text: 'My Orders',
                      ),
                      new Tab(
                        icon: const Icon(
                          Feather.heart,
                          size: 23,
                          color: Colors.deepOrange,
                        ),
                        text: 'Favourites',
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      item.isNotEmpty
                          ? myitems(context)
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
                                        fontFamily: 'SF',
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
                      Container(
                          child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text('View your orders here!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 16,
                                )),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Image.asset(
                            'assets/onboard1.png',
                            fit: BoxFit.fitWidth,
                          ))
                        ],
                      )),
                      FavouritesScreen()
                    ],
                    controller: _tabController,
                  ),
                )
              ],
            )
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

  Widget profile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                Feather.settings,
                color: Colors.deepOrange,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
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
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeAnimation(
                1,
                Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageControllerlogin,
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
                              height: MediaQuery.of(context).size.height / 4,
                              width: 300.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                              'Buying something? Find the best items near you in less than a minute!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                              height: MediaQuery.of(context).size.height / 4,
                              width: 300.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                              'Selling Something ? List your item on SellShip within seconds!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
            Column(
              children: <Widget>[
                FadeAnimation(
                    1.5,
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginProfile()));
                      },
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    )),
                SizedBox(
                  height: 15,
                ),
                FadeAnimation(
                    1.6,
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpProfilePage()));
                        },
                        color: Colors.deepOrangeAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget myitems(BuildContext context) {
    return CustomScrollView(
        shrinkWrap: true,
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: SizedBox(
            height: 5,
          )),
          SliverToBoxAdapter(
            child: Container(
              child: Center(child: Text('${item.length} Items')),
            ),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.60),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Details(itemid: item[index].itemid)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2, color: Colors.grey),
                            borderRadius: BorderRadius.circular(15),
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
                                    height: 150,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: item[index].image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            SpinKitChasingDots(
                                                color: Colors.deepOrange),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  item[index].sold == true
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 20,
                                            width: 50,
                                            color: Colors.amber,
                                            child: Text(
                                              'Sold',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'SF',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                      : Container(),
                                ],
                              ),
                              new Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            favourites != null
                                                ? favourites.contains(
                                                        item[index].itemid)
                                                    ? InkWell(
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
                                                                  item[index]
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

                                                              favourites
                                                                  .clear();
                                                              for (int i = 0;
                                                                  i <
                                                                      jsondata
                                                                          .length;
                                                                  i++) {
                                                                favourites.add(
                                                                    jsondata[i][
                                                                            '_id']
                                                                        [
                                                                        '\$oid']);
                                                              }
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
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
                                                      )
                                                    : InkWell(
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
                                                                  item[index]
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

                                                              favourites
                                                                  .clear();
                                                              for (int i = 0;
                                                                  i <
                                                                      jsondata
                                                                          .length;
                                                                  i++) {
                                                                favourites.add(
                                                                    jsondata[i][
                                                                            '_id']
                                                                        [
                                                                        '\$oid']);
                                                              }
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
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
                                                          Feather.heart,
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                : Icon(
                                                    Feather.heart,
                                                    color: Colors.black,
                                                  ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              item[index].likes.toString(),
                                              style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
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
                                                                  item[index]
                                                                      .itemid)),
                                                );
                                              },
                                              child:
                                                  Icon(Feather.message_circle),
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
                                                                  item[index]
                                                                      .itemid)),
                                                );
                                              },
                                              child: Text(
                                                item[index].comments.toString(),
                                                style: TextStyle(
                                                  fontFamily: 'SF',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Container(
                                          height: 20,
                                          child: Text(
                                            item[index].name,
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Container(
                                          child: Text(
                                            item[index].category,
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        currency != null
                                            ? Container(
                                                child: Text(
                                                  currency +
                                                      ' ' +
                                                      item[index]
                                                          .price
                                                          .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                child: Text(
                                                  item[index].price.toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditItem(
                                                              itemid:
                                                                  item[index]
                                                                      .itemid,
                                                            )),
                                                  );
                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4 -
                                                      20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepOrange,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  if (item[index].sold ==
                                                      true) {
                                                    var url =
                                                        'https://api.sellship.co/api/unsold/' +
                                                            item[index].itemid +
                                                            '/' +
                                                            userid;


                                                    final response =
                                                        await http.get(url);
                                                    if (response.statusCode ==
                                                        200) {
                                                      print(response.body);
                                                    }
                                                    getProfileData();
                                                    showInSnackBar(
                                                        'Item is now live!');
                                                  } else {
                                                    var url =
                                                        'https://api.sellship.co/api/sold/' +
                                                            item[index].itemid +
                                                            '/' +
                                                            userid;
                                                    print(url);
                                                    final response =
                                                        await http.get(url);
                                                    if (response.statusCode ==
                                                        200) {
                                                      print(response.body);
                                                    }
                                                    getProfileData();
                                                  }
                                                  showInSnackBar(
                                                      'Item has been marked sold!');
                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4 -
                                                      20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      item[index].sold == false
                                                          ? 'Mark Sold'
                                                          : 'Mark Live',
                                                      style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        )));
              },
              childCount: item.length,
            ),
          )
        ]);
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
      var url = 'https://api.sellship.co/api/user/' + userid;
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
              confirmedemail = confirmedemai;
              confirmedphone = confirmedphon;
              profilepicture = profilepic;
            });
          }

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

  void getItemData() async {
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

        var followin = profilemap['following'];
        if (followin != null) {

        } else {
          followin = [];
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
