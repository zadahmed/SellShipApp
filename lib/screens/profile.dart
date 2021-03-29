import 'dart:io';
import 'dart:ui';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/onboardingbottom.dart';
import 'package:SellShip/screens/store/mystorepage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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
import 'package:SellShip/username.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
    super.build(context);
    return Scaffold(body: signedinprofile(context));
  }

  @override
  void dispose() {
    super.dispose();
  }

  var firebasetoken;

  TextEditingController EmailController = new TextEditingController();
  TextEditingController PasswordController = new TextEditingController();

  List<Stores> storeslist = List<Stores>();

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
          if (mounted)
            setState(() {
              notcount = notcoun;
              notbadge = false;
            });
          FlutterAppBadger.removeBadge();
        } else if (notcoun > 0) {
          if (mounted)
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

  checkuser() async {
    var userid = await storage.read(key: 'userid');

    if (userid == null) {
      showModalBottomSheet(
          context: context,
          useRootNavigator: false,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0)),
                      ),
                      child: OnboardingBottomScreen());
                });
          });
    }
  }

  @override
  void initState() {
    super.initState();

    checkuser();
    getStoreData();
    getnotification();
    if (mounted)
      setState(() {
        loading = true;
        notbadge = false;
      });
    _tabController = new TabController(length: 3, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    getProfileData();

    _tabController.addListener(() {
      var tab = _tabController.index;

      if (tab == 2) {
        refreshreviews();
        if (mounted)
          setState(() {
            reviewloading = true;
            refreshreviews();
          });
      }
      if (tab == 1) {
        if (mounted)
          setState(() {
            favouriteloading = true;
            getfavouritesuser();
          });
      }
    });
  }

  var profilepicture;
  var confirmedemail;

  bool confirmedfb;

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
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        profilepicture = response.data;
      });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  bool profileloading = true;

  // getfavourites() async {
  //   if (favourites != null) favourites.clear();
  //   var userid = await storage.read(key: 'userid');
  //   if (userid != null) {
  //     var url = 'https://api.sellship.co/api/favourites/' + userid;
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       if (response.body != 'Empty') {
  //         var respons = json.decode(response.body);
  //         var profilemap = respons;
  //         List<String> ites = List<String>();
  //
  //         if (profilemap != null) {
  //           for (var i = 0; i < profilemap.length; i++) {
  //             ites.add(profilemap[i]['_id']['\$oid']);
  //           }
  //
  //           Iterable inReverse = ites.reversed;
  //           List<String> jsoninreverse = inReverse.toList();
  //           if (mounted)
  //             setState(() {
  //               favourites = jsoninreverse;
  //             });
  //         } else {
  //           favourites = [];
  //         }
  //       }
  //     }
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         favourites = [];
  //       });
  //   }
  // }

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

    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        profilepicture = response.data;
      });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  var currency;
  TextEditingController searchcontroller = new TextEditingController();

  onSearch(String texte) async {
    if (texte.isEmpty) {
      if (mounted) setState(() {});
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
            var userid = await storage.read(key: 'userid');
            var storeurl = 'https://api.sellship.co/api/userstores/' + userid;
            final storeresponse = await http.get(storeurl);
            var storejsonbody = json.decode(storeresponse.body);

            if (storejsonbody.isNotEmpty) {
              var storeid = storejsonbody[0]['_id']['\$oid'];
              print(storeid);
              await storage.write(key: 'storeid', value: storeid);
            }

            Navigator.of(context).pop();

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => RootScreen()));
          } else {
            await storage.write(key: 'userid', value: jsondata['id']);
            var userid = await storage.read(key: 'userid');
            var storeurl = 'https://api.sellship.co/api/userstores/' + userid;
            final storeresponse = await http.get(storeurl);
            var storejsonbody = json.decode(storeresponse.body);

            if (storejsonbody.isNotEmpty) {
              var storeid = storejsonbody[0]['_id']['\$oid'];
              print(storeid);
              await storage.write(key: 'storeid', value: storeid);
            }

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

        if (mounted)
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
          title: Text(
            firstname != null ? firstname + ' ' + lastname : '',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        key: _scaffoldKey,
        body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                        delegate: new SliverChildListDelegate([
                      Stack(
                        children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  child: SvgPicture.asset(
                                    'assets/LoginBG.svg',
                                    semanticsLabel: 'SellShip BG',
                                    fit: BoxFit.cover,
                                  ))),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, top: 40, right: 20),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                              children: [
                                                Container(
                                                  height: 110,
                                                  width: 100,
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: GestureDetector(
                                                          child: Container(
                                                            height: 100,
                                                            width: 100,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade100,
                                                                    width: 5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                              child: profilepicture ==
                                                                          null ||
                                                                      profilepicture
                                                                          .isEmpty
                                                                  ? Image.asset(
                                                                      'assets/personplaceholder.png',
                                                                      fit: BoxFit
                                                                          .fitWidth,
                                                                    )
                                                                  : CachedNetworkImage(
                                                                      height:
                                                                          300,
                                                                      width:
                                                                          300,
                                                                      imageUrl:
                                                                          profilepicture,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          SpinKitDoubleBounce(
                                                                              color: Colors.deepOrange),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(Icons
                                                                              .error),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: InkWell(
                                                          onTap: () {
                                                            final action =
                                                                CupertinoActionSheet(
                                                              message: Text(
                                                                "Upload an Image",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                              ),
                                                              actions: <Widget>[
                                                                CupertinoActionSheetAction(
                                                                  child: Text(
                                                                      "Upload from Camera",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          fontWeight:
                                                                              FontWeight.normal)),
                                                                  isDefaultAction:
                                                                      true,
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        barrierDismissible:
                                                                            false,
                                                                        useRootNavigator:
                                                                            false,
                                                                        builder: (_) =>
                                                                            new AlertDialog(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                                              content: Builder(
                                                                                builder: (context) {
                                                                                  return Container(
                                                                                      height: 100,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Updating Profile Picture..',
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
                                                                    getImageCamera();
                                                                  },
                                                                ),
                                                                CupertinoActionSheetAction(
                                                                  child: Text(
                                                                      "Upload from Gallery",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          fontWeight:
                                                                              FontWeight.normal)),
                                                                  isDefaultAction:
                                                                      true,
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        barrierDismissible:
                                                                            false,
                                                                        useRootNavigator:
                                                                            false,
                                                                        builder: (_) =>
                                                                            new AlertDialog(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                                              content: Builder(
                                                                                builder: (context) {
                                                                                  return Container(
                                                                                      height: 100,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Updating Profile Picture..',
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
                                                                    getImageGallery();
                                                                  },
                                                                )
                                                              ],
                                                              cancelButton:
                                                                  CupertinoActionSheetAction(
                                                                child: Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                                isDestructiveAction:
                                                                    true,
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                              ),
                                                            );
                                                            showCupertinoModalPopup(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        action);
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor:
                                                                Color.fromRGBO(
                                                                    28,
                                                                    45,
                                                                    65,
                                                                    1),
                                                            child: Icon(
                                                              Feather.camera,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start),
                                          username != null
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20, top: 25),
                                                  child: Row(
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            '@' + username,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 24.0,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        businesstier != null
                                                            ? Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color:
                                                                      tiercolor,
                                                                ),
                                                                child: Icon(
                                                                  tiericon,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start),
                                                )
                                              : Column(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: 20,
                                                        ),
                                                        child: Column(
                                                            children: [
                                                              Text(
                                                                '@Username',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        22.0,
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start)),
                                                    InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Username(
                                                                  userid:
                                                                      userid,
                                                                ),
                                                              ));
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 2),
                                                          child: Container(
                                                              height: 40,
                                                              width: 130,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Center(
                                                                  child: Text(
                                                                'Set Username',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ))),
                                                        )),
                                                  ],
                                                )
                                        ]))),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ]))
                  ];
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        padding: EdgeInsets.only(left: 16),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(229, 233, 242, 1)
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20))),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: TabBar(
                                  controller: _tabController,
                                  labelStyle: tabTextStyle,
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Helvetica',
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: UnderlineTabIndicator(
                                      borderSide: BorderSide(
                                          width: 2.0,
                                          color: Colors.deepOrange)),
                                  isScrollable: true,
                                  labelColor: Colors.black,
                                  tabs: [
                                    new Tab(
                                      text: 'Stores',
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
                            ])),
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(229, 233, 242, 1)
                                  .withOpacity(0.5),
                            ),
                            child: Container(
                              padding: EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  profileloading == false
                                      ? storeitems(context)
                                      : Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 16.0),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300],
                                            highlightColor: Colors.grey[100],
                                            child: ListView(
                                              children: [0, 1, 2, 3, 4, 5, 6]
                                                  .map((_) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 8.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2 -
                                                                  30,
                                                              height: 150.0,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2 -
                                                                  30,
                                                              height: 150.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ),
//                                    getOrders(context),
                                  favouriteslist(context),
                                  reviewslist(context)
                                ],
                              ),
                            )))
                  ],
                ))));
  }

  bool favouriteloading = true;

  Widget favouriteslist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 36, bottom: 20, right: 36),
            child: Text(
              favouritelist.length.toString() + ' Favourites',
              style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          favouriteloading == false
              ? favouritelist.isNotEmpty
                  ? Flexible(
                      child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: EasyRefresh(
                              header: CustomHeader(
                                  extent: 40.0,
                                  enableHapticFeedback: true,
                                  triggerDistance: 50.0,
                                  headerBuilder: (context,
                                      loadState,
                                      pulledExtent,
                                      loadTriggerPullDistance,
                                      loadIndicatorExtent,
                                      axisDirection,
                                      float,
                                      completeDuration,
                                      enableInfiniteLoad,
                                      success,
                                      noMore) {
                                    return SpinKitFadingCircle(
                                      color: Colors.deepOrange,
                                      size: 30.0,
                                    );
                                  }),
                              onRefresh: () {
                                return getfavouritesuser();
                              },
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: 1.0,
                                        crossAxisSpacing: 1.0,
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.9),
                                itemBuilder:
                                    ((BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid: favouritelist[index]
                                                      .itemid,
                                                  sold:
                                                      favouritelist[index].sold,
                                                  image: favouritelist[index]
                                                      .image,
                                                  name:
                                                      favouritelist[index].name,
                                                  source: 'fav',
                                                )),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 195,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Hero(
                                                tag:
                                                    'fav${favouritelist[index].itemid}',
                                                child: CachedNetworkImage(
                                                  height: 200,
                                                  width: 300,
                                                  fadeInDuration:
                                                      Duration(microseconds: 5),
                                                  imageUrl: favouritelist[index]
                                                      .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitDoubleBounce(
                                                          color: Colors
                                                              .deepOrange),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: InkWell(
                                                      enableFeedback: true,
                                                      onTap: () async {
                                                        var userid =
                                                            await storage.read(
                                                                key: 'userid');

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

                                                          Item favitem = Item(
                                                              itemid:
                                                                  favouritelist[index]
                                                                      .itemid,
                                                              name: favouritelist[index]
                                                                  .name,
                                                              image:
                                                                  favouritelist[index]
                                                                      .image,
                                                              likes: favouritelist[index].likes == null
                                                                  ? 0
                                                                  : favouritelist[index]
                                                                      .likes,
                                                              comments: favouritelist[index].comments == null
                                                                  ? 0
                                                                  : favouritelist[index]
                                                                      .comments,
                                                              price:
                                                                  favouritelist[index]
                                                                      .price,
                                                              sold: favouritelist[index]
                                                                          .sold ==
                                                                      null
                                                                  ? false
                                                                  : favouritelist[index]
                                                                      .sold,
                                                              category:
                                                                  favouritelist[index]
                                                                      .category);

                                                          favouritelist
                                                              .remove(favitem);
                                                          if (mounted)
                                                            setState(() {
                                                              favouritelist =
                                                                  favouritelist;
                                                              favouritelist[
                                                                          index]
                                                                      .likes =
                                                                  favouritelist[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });

                                                          final response =
                                                              await http.post(
                                                                  url,
                                                                  body: json
                                                                      .encode(
                                                                          body));

                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                          } else {
                                                            print(response
                                                                .statusCode);
                                                          }
                                                        } else {
                                                          showInSnackBar(
                                                              'Please Login to use Favourites');
                                                        }
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor:
                                                            Colors.deepPurple,
                                                        child: Icon(
                                                          FontAwesome.heart,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      )))),
                                          favouritelist[index].sold == true
                                              ? Positioned(
                                                  top: 60,
                                                  child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                    width: 210,
                                                    child: Center(
                                                      child: Text(
                                                        'Sold',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                itemCount: favouritelist.length,
                              ))))
                  : Expanded(
                      child: Column(
                      children: <Widget>[
                        Container(
                            height: 250,
                            child: Image.asset(
                              'assets/favourites.png',
                              fit: BoxFit.fitHeight,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            'View your favourites here!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ))
              : Expanded(
                  child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
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
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          40,
                                      height: 150.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          40,
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
                ))
        ],
      ),
    );
  }

  getfavouritesuser() async {
    favouritelist.clear();
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    currency = 'AED';

    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<Item> ites = List<Item>();

          if (profilemap == 'Empty') {
            if (mounted)
              setState(() {
                favouritelist = [];
                favouriteloading = false;
              });
          } else {
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
              if (mounted)
                setState(() {
                  favouritelist = jsoninreverse;

                  favouriteloading = false;
                });
            } else {
              setState(() {
                favouritelist = [];

                favouriteloading = false;
              });
            }
          }
        } else {
          if (mounted)
            setState(() {
              favouritelist = [];
              favouriteloading = false;
            });
        }
      } else {
        if (mounted)
          setState(() {
            favouriteloading = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          favouriteloading = false;
        });
    }
  }

  List<Item> favouritelist = List<Item>();

  List<Item> orderslist = List<Item>();

  getorders() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      if (mounted)
        setState(() {
          currency = 'AED';
        });
    } else if (country.trim().toLowerCase() == 'united states') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (country.trim().toLowerCase() == 'canada') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      if (mounted)
        setState(() {
          currency = '\£';
        });
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/getorders/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<Item> ites = List<Item>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap['bought'].length; i++) {
              var q =
                  Map<String, dynamic>.from(profilemap['bought'][i]['date']);

              DateTime dateuploade =
                  DateTime.fromMillisecondsSinceEpoch(q['\$date']);
              var dateuploaded = timeago.format(dateuploade);

              Item ite = Item(
                  itemid: profilemap['bought'][i]['itemid'],
                  name: profilemap['bought'][i]['name'],
                  image: profilemap['bought'][i]['itemimage'],
                  price: profilemap['bought'][i]['itemprice'].toString(),
                  userid: profilemap['bought'][i]['itemuserid'],
                  description: profilemap['bought'][i]['messageid'],
                  category: profilemap['bought'][i]['itemcategory'],
                  username: profilemap['bought'][i]['itemusername'],
                  subcategory:
                      profilemap['bought'][i]['totalpayable'].toString(),
                  date: dateuploaded,
                  orderstatus: 'Bought');
              ites.add(ite);
            }

            for (var i = 0; i < profilemap['sold'].length; i++) {
              var q = Map<String, dynamic>.from(profilemap['sold'][i]['date']);

              DateTime dateuploade =
                  DateTime.fromMillisecondsSinceEpoch(q['\$date']);
              var dateuploaded = timeago.format(dateuploade);

              Item iteso = Item(
                  itemid: profilemap['sold'][i]['itemid'],
                  name: profilemap['sold'][i]['name'],
                  image: profilemap['sold'][i]['itemimage'],
                  price: profilemap['sold'][i]['itemprice'].toString(),
                  userid: profilemap['sold'][i]['itemuserid'],
                  description: profilemap['sold'][i]['messageid'],
                  category: profilemap['sold'][i]['itemcategory'],
                  username: profilemap['sold'][i]['itemusername'],
                  subcategory: profilemap['sold'][i]['totalpayable'].toString(),
                  date: dateuploaded,
                  orderstatus: 'Sold');
              ites.add(iteso);
            }

            Iterable inReverse = ites.reversed;
            List<Item> jsoninreverse = inReverse.toList();

            orderslist = jsoninreverse;
            if (mounted)
              setState(() {
                orderslist.sort((a, b) {
                  return a.compareTo(b);
                });
                orderloading = false;
              });
          } else {
            orderslist = [];
            orderloading = false;
          }
        } else {
          if (mounted)
            setState(() {
              loading = false;
            });
        }
      } else {
        if (mounted)
          setState(() {
            loading = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          loading = false;
        });
    }
  }

  Widget getOrders(BuildContext context) {
    return orderloading == false
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 36, top: 10, bottom: 10, right: 36),
                child: Text(
                  orderslist.length.toString() + ' Orders',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              orderslist.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: orderslist.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Container(
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, top: 5, bottom: 5, right: 16),
                                    child: ListTile(
                                      onTap: () async {
                                        if (orderslist[index].orderstatus ==
                                            'Sold') {
                                          var countr = await storage.read(
                                              key: 'country');

                                          if (countr.trim().toLowerCase() ==
                                              'united arab emirates') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderBuyerUAE(
                                                          messageid: item[index]
                                                              .description,
                                                          item: item[index])),
                                            );
                                          } else if (countr
                                                  .trim()
                                                  .toLowerCase() ==
                                              'united states') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderBuyer(
                                                          messageid: item[index]
                                                              .description,
                                                          itemid: item[index]
                                                              .itemid)),
                                            );
                                          }
                                        } else {
                                          var countr = await storage.read(
                                              key: 'country');

                                          if (countr.trim().toLowerCase() ==
                                              'united arab emirates') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderSellerUAE(
                                                          messageid: item[index]
                                                              .description,
                                                          item: item[index])),
                                            );
                                          } else if (countr
                                                  .trim()
                                                  .toLowerCase() ==
                                              'united states') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderSeller(
                                                          messageid:
                                                              item[index]
                                                                  .description,
                                                          itemid: item[index]
                                                              .itemid)),
                                            );
                                          }
                                        }
                                      },
                                      leading: Container(
                                        height: 140,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              height: 200,
                                              width: 300,
                                              imageUrl: orderslist[index].image,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      trailing: Container(
                                        height: 30,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            color:
                                                orderslist[index].orderstatus ==
                                                        'Sold'
                                                    ? Colors.deepOrangeAccent
                                                        .withOpacity(0.9)
                                                    : Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Center(
                                            child: Text(
                                          orderslist[index].orderstatus,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )),
                                      ),
                                      title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: 250,
                                              child: Text(
                                                orderslist[index].name,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ]),
                                      subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                currency +
                                                    ' ' +
                                                    orderslist[index].price,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                    color: Colors
                                                        .deepOrangeAccent
                                                        .withOpacity(1))),
                                            SizedBox(
                                              height: 2,
                                            ),
                                          ]),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 16.0),
                                    )));
                          }),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Text(
                            'View your Orders here ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height:
                                MediaQuery.of(context).size.height / 2 - 100,
                            child: Image.asset(
                              'assets/messages.png',
                              fit: BoxFit.fitWidth,
                            ))
                      ],
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
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                height: 150.0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
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
          );
  }

  void Loginfunc() async {
    var url = 'https://api.sellship.co/api/login';

    Map<String, String> body = {
      'email': EmailController.text,
      'password': PasswordController.text,
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
        if (mounted)
          setState(() {
            userid = jsondata['id'];
          });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('seen', true);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => RootScreen()));
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
      print(response.body);
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
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            useRootNavigator: false,
                                            builder: (_) => new AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
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
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
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
                                        await FirebaseAuthOAuth()
                                            .openSignInFlow("apple.com", [
                                          "email",
                                          "fullName"
                                        ], {
                                          "locale": "en"
                                        }).then((user) async {
                                          print(user);
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

                                              var userid = await storage.read(
                                                  key: 'userid');
                                              var storeurl =
                                                  'https://api.sellship.co/api/userstores/' +
                                                      userid;
                                              final storeresponse =
                                                  await http.get(storeurl);
                                              var storejsonbody = json
                                                  .decode(storeresponse.body);

                                              if (storejsonbody.isNotEmpty) {
                                                var storeid = storejsonbody[0]
                                                    ['_id']['\$oid'];

                                                await storage.write(
                                                    key: 'storeid',
                                                    value: storeid);
                                              }

                                              Navigator.of(context).pop();

                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          RootScreen()));
                                            } else {
                                              await storage.write(
                                                  key: 'userid',
                                                  value: jsondata['status']
                                                      ['id']);

                                              var userid = await storage.read(
                                                  key: 'userid');
                                              var storeurl =
                                                  'https://api.sellship.co/api/userstores/' +
                                                      userid;
                                              final storeresponse =
                                                  await http.get(storeurl);
                                              var storejsonbody = json
                                                  .decode(storeresponse.body);

                                              if (storejsonbody.isNotEmpty) {
                                                var storeid = storejsonbody[0]
                                                    ['_id']['\$oid'];
                                                print(storeid);
                                                await storage.write(
                                                    key: 'storeid',
                                                    value: storeid);
                                              }

                                              Navigator.of(context).pop();

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VerifyPhoneSignUp(
                                                      userid: jsondata['id'],
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
    reviews.clear();
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

        if (mounted)
          setState(() {
            reviewloading = false;
            reviews = jsoninreverse;
          });
      }
    } else {
      if (mounted)
        setState(() {
          reviewloading = false;
          reviews = [];
        });
    }
    return reviews;
  }

  List<Reviews> reviews = List<Reviews>();

  bool orderloading = true;
  bool reviewloading = true;

  Widget reviewslist(BuildContext context) {
    return reviewloading == false
        ? reviews.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 36, top: 20, bottom: 10, right: 36),
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
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: reviews[index]
                                                  .profilepicture
                                                  .isNotEmpty
                                              ? CachedNetworkImage(
                                                  height: 200,
                                                  width: 300,
                                                  imageUrl: reviews[index]
                                                      .profilepicture,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                reviews[index]
                                                    .rating
                                                    .toString(),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 250,
                      child: Image.asset(
                        'assets/messages.png',
                        fit: BoxFit.fitHeight,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'View your Reviews here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18.0,
                      ),
                    ),
                  ),
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
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                height: 150.0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
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
          );
  }

  Widget storeitems(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: storeslist.isNotEmpty
                  ? EasyRefresh(
                      header: CustomHeader(
                          extent: 40.0,
                          enableHapticFeedback: true,
                          triggerDistance: 50.0,
                          headerBuilder: (context,
                              loadState,
                              pulledExtent,
                              loadTriggerPullDistance,
                              loadIndicatorExtent,
                              axisDirection,
                              float,
                              completeDuration,
                              enableInfiniteLoad,
                              success,
                              noMore) {
                            return SpinKitFadingCircle(
                              color: Colors.deepOrange,
                              size: 30.0,
                            );
                          }),
                      onRefresh: () {
                        getProfileData();

                        return getStoreData();
                      },
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => StorePage(
                                              storename:
                                                  storeslist[index].storename,
                                              storeid:
                                                  storeslist[index].storeid)),
                                    );
                                  },
                                  child: storeslist[index].approved == true
                                      ? Container(
                                          height: 100,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {},
                                                      child: Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            child: storeslist[
                                                                        index]
                                                                    .storelogo
                                                                    .isNotEmpty
                                                                ? Hero(
                                                                    tag:
                                                                        'store${storeslist[index].storeid}',
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          storeslist[index]
                                                                              .storelogo,
                                                                      height:
                                                                          200,
                                                                      width:
                                                                          300,
                                                                      fadeInDuration:
                                                                          Duration(
                                                                              microseconds: 5),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          SpinKitDoubleBounce(
                                                                              color: Colors.deepOrange),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(Icons
                                                                              .error),
                                                                    ),
                                                                  )
                                                                : SpinKitFadingCircle(
                                                                    color: Colors
                                                                        .deepOrange,
                                                                  )),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height: 25,
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3 -
                                                              10,
                                                          child: Text(
                                                            storeslist[index]
                                                                .storename,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        Text(
                                                          storeslist[index]
                                                              .storecategory,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 14.0,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        // SizedBox(
                                                        //   height: 5,
                                                        // ),
                                                        // Row(
                                                        //   crossAxisAlignment:
                                                        //       CrossAxisAlignment
                                                        //           .center,
                                                        //   mainAxisAlignment:
                                                        //       MainAxisAlignment
                                                        //           .start,
                                                        //   children: [
                                                        //     Text(
                                                        //       storeslist[index]
                                                        //           .views,
                                                        //       style: TextStyle(
                                                        //           fontFamily:
                                                        //               'Helvetica',
                                                        //           fontSize:
                                                        //               14.0,
                                                        //           color: Colors
                                                        //               .grey),
                                                        //     ),
                                                        //     SizedBox(
                                                        //       width: 2,
                                                        //     ),
                                                        //     Icon(
                                                        //       Icons
                                                        //           .remove_red_eye_outlined,
                                                        //       color:
                                                        //           Colors.grey,
                                                        //       size: 16,
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                  ]),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Icon(
                                                      Feather.chevron_right,
                                                      color: Colors.grey,
                                                    )
                                                  ])
                                            ],
                                          ))
                                      : Stack(children: [
                                          Container(
                                              height: 100,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 5),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {},
                                                          child: Container(
                                                            height: 80,
                                                            width: 80,
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child: storeslist[
                                                                            index]
                                                                        .storelogo
                                                                        .isNotEmpty
                                                                    ? Hero(
                                                                        tag:
                                                                            'store${storeslist[index].storeid}',
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              storeslist[index].storelogo,
                                                                          height:
                                                                              200,
                                                                          width:
                                                                              300,
                                                                          fadeInDuration:
                                                                              Duration(microseconds: 5),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              SpinKitDoubleBounce(color: Colors.deepOrange),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(Icons.error),
                                                                        ),
                                                                      )
                                                                    : SpinKitFadingCircle(
                                                                        color: Colors
                                                                            .deepOrange,
                                                                      )),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 25,
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  10,
                                                              child: Text(
                                                                storeslist[
                                                                        index]
                                                                    .storename,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Text(
                                                              storeslist[index]
                                                                  .storecategory,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .lock_clock,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                Text(
                                                                  'Store Under Review',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .grey),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ]),
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .remove_red_eye_outlined,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            Text(storeslist[
                                                                    index]
                                                                .views)
                                                          ],
                                                        ),
                                                        Icon(
                                                          Feather.chevron_right,
                                                          color: Colors.grey,
                                                        )
                                                      ])
                                                ],
                                              )),
                                        ])));
                        },
                        itemCount: storeslist.length,
                      ))
                  : Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Image.asset(
                              'assets/little_theologians_4x.png',
                              fit: BoxFit.fitWidth,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                              'Looks like you dont have a store setup. Let\'s get you started with your first store',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 5.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Create a Store',
                                  textAlign: TextAlign.center,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RootScreen(
                                        index: 2,
                                      )),
                            );
                          },
                        ),
                      ],
                    ))),
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

  IconData tiericon;

  bool confirmedphone;

  var firstname;
  var lastname;
  var email;
  var phonenumber;

  List<Item> item = List<Item>();

  void getProfileData() async {
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;

        var usernam = profilemap['username'];
        if (usernam != null) {
        } else {
          usernam = null;
        }

        var tier;
        var colos;
        if (profilemap.containsKey('tier')) {
          tier = profilemap['tier'];
          await storage.write(key: 'tier', value: profilemap['tier']);
          if (tier == 'Enterprise') {
            colos = Colors.black;
            tiericon = FontAwesomeIcons.crown;
          } else if (tier == 'Grow') {
            colos = Colors.deepPurpleAccent;
            tiericon = FontAwesomeIcons.globe;
          } else {
            colos = Colors.deepOrangeAccent;
            tiericon = FontAwesomeIcons.igloo;
          }
        } else {
          tier = 'Start-Up';
          tiericon = FontAwesomeIcons.igloo;
          colos = Colors.deepOrangeAccent;
        }

        print(tier);

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

        if (profilemap != null) {
          setState(() {
            firstname = profilemap['first_name'];
            lastname = profilemap['last_name'];
            phonenumber = profilemap['phonenumber'];
            email = profilemap['email'];
            loading = false;
            businesstier = tier;
            tiercolor = colos;
            confirmedfb = confirmedf;
            confirmedemail = confirmedemai;
            confirmedphone = confirmedphon;
            profilepicture = profilepic;
            username = usernam;
          });

          await OneSignal.shared.setEmail(email: email);
        } else {
          if (mounted)
            setState(() {
              loading = false;
              userid = null;
            });
        }
      }
    } else {
      if (mounted)
        setState(() {
          userid = null;
          loading = false;
        });
    }
  }

  var username;
  var businesstier;
  var tiercolor;
  double reviewrating;

  getStoreData() async {
    var userid = await storage.read(key: 'userid');
    var storeurl = 'https://api.sellship.co/api/userstores/' + userid;

    final storeresponse = await http.get(storeurl);

    if (storeresponse.statusCode == 200) {
      var jsonbody = json.decode(storeresponse.body);
      List<Stores> ites = List<Stores>();
      for (int i = 0; i < jsonbody.length; i++) {
        var approved;
        if (jsonbody[i]['approved'] == null) {
          approved = false;
        } else {
          approved = jsonbody[i]['approved'];
        }

        var view;
        if (jsonbody[i]['views'] == null) {
          view = false;
        } else {
          view = jsonbody[i]['views'];
        }

        Stores store = Stores(
            approved: approved,
            views: view.toString(),
            storeid: jsonbody[i]['_id']['\$oid'],
            storecategory: jsonbody[i]['storecategory'],
            storelogo: jsonbody[i]['storelogo'],
            storename: jsonbody[i]['storename']);

        ites.add(store);
      }

      setState(() {
        storeslist = ites;
        profileloading = false;
      });
    } else {
      setState(() {
        storeslist = [];
        profileloading = false;
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
