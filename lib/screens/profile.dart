import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/balance.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

  Map userProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: userid != null ? signedinprofile(context) : profile(context));
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  List<IconData> iconssettings = [
    FontAwesomeIcons.store,
    FontAwesomeIcons.userAstronaut,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
    FontAwesomeIcons.store,
  ];

  var currency;

  final facebookLogin = FacebookLogin();

  Widget signedinprofile(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 25, top: 13),
            child: Text(
              'Hi, ' + firstname + '',
              style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 26.0,
                  color: Color.fromRGBO(28, 45, 65, 1),
                  fontWeight: FontWeight.bold),
            ),
          ),
          leadingWidth: MediaQuery.of(context).size.width - 150,
          backgroundColor: Colors.white,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 25),
              child: Icon(
                Feather.shopping_bag,
                color: Color.fromRGBO(28, 45, 65, 1),
                size: 24,
              ),

//              Badge(
//                showBadge: notbadge,
//                position: BadgePosition.topEnd(top: 2, end: -4),
//                animationType: BadgeAnimationType.slide,
//                badgeContent: Text(
//                  notcount.toString(),
//                  style: TextStyle(color: Colors.white),
//                ),
//                child: InkWell(
//                  onTap: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => NotifcationPage()),
//                    );
//                  },
//                  child: Icon(
//                    Feather.bell,
//                    color: Color.fromRGBO(28, 45, 65, 1),
//                    size: 24,
//                  ),
//                ),
//              ),
            ),
          ],
        ),
        key: _scaffoldKey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 244, 248, 1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: ListView(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            left: 25, bottom: 5, top: 30, right: 15),
                        child: Text(
                          'My Account',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(28, 45, 65, 1),
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 20, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'My Profile',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.user,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'My Store',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.home,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'My Orders',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.box,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Favourites',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.heart,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Earnings',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Icons.money,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 25, bottom: 5, top: 40, right: 15),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(28, 45, 65, 1),
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Language',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Icons.language,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Contact Us',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.help_circle,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.menu,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ListTile(
                              title: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Color.fromRGBO(28, 45, 65, 1),
                                ),
                              ),
                              leading: Icon(
                                Feather.alert_triangle,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                              trailing: Icon(
                                Feather.arrow_right,
                                size: 18,
                                color: Color.fromRGBO(28, 45, 65, 1),
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 20, bottom: 20, top: 10, right: 15),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 18.0,
                            color: Color.fromRGBO(28, 45, 65, 1),
                          ),
                        )),
                  ],
                ),
              )),
            ],
          ),
        ));
  }

  Widget profile(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.all(10),
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
        ));
  }

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

        if (profilemap != null) {
          if (mounted) {
            setState(() {
              firstname = profilemap['first_name'];
              lastname = profilemap['last_name'];
            });
          }
        } else {
          setState(() {
            userid = null;
          });
        }
      }
    }
  }
}
