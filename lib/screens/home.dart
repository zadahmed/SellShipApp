import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/user.dart';
import 'package:SellShip/screens/categorydynamic.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/filter.dart';
import 'package:SellShip/screens/home/below100.dart';
import 'package:SellShip/screens/home/discover.dart';
import 'package:SellShip/screens/home/foryou.dart';
import 'package:SellShip/screens/home/nearme.dart';
import 'package:SellShip/screens/home/toppicks.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/subcategory.dart';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart' as Location;

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class Subcategory {
  final String name;
  final String image;

  Subcategory({this.name, this.image});
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  bool keepalive = true;

  @override
  bool get wantKeepAlive => keepalive;

  ScrollController _scrollController = ScrollController();

  var currency;

  LatLng position;
  bool loading;

  final storage = new FlutterSecureStorage();

  TabController _tabController;

  @override
  void initState() {
    super.initState();

    getnotification();
    if (mounted) {
      setState(() {
        currency = 'AED';
        notifbadge = false;
        notbadge = false;
      });
    }
    getfavourites();
  }

  String locationcountry;
  String country;

  String brand;
  String minprice;
  String maxprice;
  String condition;

  bool gridtoggle = true;

  final scaffoldState = GlobalKey<ScaffoldState>();

  String city;
  var notcount;

  PersistentBottomSheetController bottomsheetcontroller;

  bool checkoutbadge = false;
  int checkoutcount;
  bool notbadge;

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List cartitems = prefs.getStringList('cartitems');
      if (cartitems != null) {
        if (cartitems.length > 0) {
          if (mounted) {
            setState(() {
              checkoutbadge = true;
              checkoutcount = cartitems.length;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              checkoutbadge = false;
              checkoutcount = 0;
            });
          }
        }
      }
      var url = 'https://api.sellship.co/api/getnotification/' + userid;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        var notificationinfo = json.decode(response.body);

        var notcoun = notificationinfo['notcount'];

        if (notcoun <= 0) {
          if (mounted) {
            setState(() {
              notcount = 0;
              notbadge = false;
            });
          }
          FlutterAppBadger.removeBadge();
        } else if (notcoun > 0) {
          if (mounted) {
            setState(() {
              notcount = notcoun;
              notbadge = true;
            });
          }
        }

        FlutterAppBadger.updateBadgeCount(notcount);
      } else {
        print(response.statusCode);
      }
    }
  }

  Color followcolor = Colors.deepOrange;

  var follow = false;

  var notifcount;
  var notifbadge;

  void readstorage() async {
    getnotification();
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      if (mounted)
        setState(() {
          currency = 'AED';
        });
    } else if (countr.trim().toLowerCase() == 'united states') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (countr.trim().toLowerCase() == 'canada') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      if (mounted)
        setState(() {
          currency = '\£';
        });
    }
    if (mounted)
      setState(() {
        country = countr;
      });
  }

  TextEditingController searchcontroller = new TextEditingController();

  var crossaxiscount = 2;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Container(
              margin: EdgeInsets.only(top: 10.0, right: 10, bottom: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Color.fromRGBO(249, 249, 249, 1),
                ),
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: Icon(
                        FeatherIcons.search,
                        size: 24,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => RootScreen(
                                index: 1,
                              ),
                              transitionsBuilder: (c, anim, a2, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration: Duration(milliseconds: 50),
                            ),
                          );
                        },
                        controller: searchcontroller,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => searchcontroller.clear(),
                              icon: Icon(
                                Icons.clear,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                            ),
                            hintText: 'Search SellShip',
                            hintStyle: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                )),
              ),
            ),
            leading: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotifcationPage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Badge(
                  showBadge: notbadge,
                  position: BadgePosition.topEnd(top: 5, end: 5),
                  animationType: BadgeAnimationType.slide,
                  badgeColor: Colors.deepOrange,
                  badgeContent: Text(
                    notcount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Icon(
                    FeatherIcons.bell,
                    color: Color.fromRGBO(28, 45, 65, 1),
                    size: 24,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Checkout()),
                    );
                  },
                  child: Badge(
                    showBadge: checkoutbadge,
                    position: BadgePosition.topEnd(top: 5, end: 5),
                    animationType: BadgeAnimationType.slide,
                    badgeColor: Colors.deepOrange,
                    badgeContent: Text(
                      checkoutcount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Icon(
                        FeatherIcons.shoppingBag,
                        size: 24,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      ),
                    ),
                  ))
            ]),
        body: Discover()

        // DefaultTabController(
        //     length: 2,
        //     child: NestedScrollView(
        //         headerSliverBuilder: (context, _) {
        //           return [];
        //         },
        //         body: Discover()))

        // Container(
        //     decoration: BoxDecoration(
        //       color: Color.fromRGBO(229, 233, 242, 1).withOpacity(0.5),
        //     ),
        //     child: Container(
        //         padding: EdgeInsets.only(top: 15),
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(20),
        //             topRight: Radius.circular(20),
        //           ),
        //         ),
        //         child: TabBarView(
        //             controller: _tabController,
        //             children: [Discover(), ForYou()])))

        );
  }

  List<String> favourites;

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldState.currentState?.removeCurrentSnackBar();
    scaffoldState.currentState.showSnackBar(new SnackBar(
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

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        if (respons != 'Empty') {
          print(respons);
          List<String> ites = List<String>();

          if (respons != null) {
            for (var i = 0; i < respons.length; i++) {
              if (respons[i] != null) {
                ites.add(respons[i]['_id']['\$oid']);
              }
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            if (mounted) {
              setState(() {
                favourites = jsoninreverse;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                favourites = [];
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              favourites = [];
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            favourites = [];
          });
        }
      }
      print(favourites);
    }
  }
}
