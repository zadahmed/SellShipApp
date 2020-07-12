import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/nearme.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/recentlyadded.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/search.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> itemsgrid = [];

  List<Item> nearmeitemsgrid = [];
  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  ScrollController _scrollController = ScrollController();

  var currency;

  Future<List<Item>> fetchItems(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://api.sellship.co/api/getitems/' +
          locationcountry +
          '/' +
          0.toString() +
          '/' +
          15.toString();

      final response = await http.post(url, body: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString()
      });
      if (response.statusCode == 200) {
        var jsonbody = json.decode(response.body);
        nearmeitemsgrid.clear();
        for (var i = 0; i < jsonbody.length; i++) {
          Item item = Item(
            itemid: jsonbody[i]['_id']['\$oid'],
            name: jsonbody[i]['name'],
            image: jsonbody[i]['image'],
            price: jsonbody[i]['price'].toString(),
            category: jsonbody[i]['category'],
            sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
          );
          nearmeitemsgrid.add(item);
        }
      }

      if (nearmeitemsgrid != null) {
        setState(() {
          nearmeitemsgrid = nearmeitemsgrid;
        });
      } else {
        setState(() {
          nearmeitemsgrid = [];
        });
      }

      print(nearmeitemsgrid.length);
      return nearmeitemsgrid;
    }
  }

  refresh() async {
    setState(() {
      nearmeitemsgrid.clear();
      itemsgrid.clear();
      skip = 0;
      limit = 20;
    });

    fetchItems(skip, limit);
    fetchRecentlyAdded(skip, limit);
  }

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }
  }

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    print(itemsgrid);
    setState(() {
      itemsgrid = itemsgrid;
    });

    return itemsgrid;
  }

  LatLng position;
  bool loading;

//  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 20;
      loading = true;
      notifbadge = false;
      notbadge = false;
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));
    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize = _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels == triggerFetchMoreSize) {
          _getmoreRecentData();
        }
      });
    readstorage();
  }

  _getLocation() async {
    Location _location = new Location();
    var location;

    try {
      location = await _location.getLocation();
      await storage.write(key: 'latitude', value: location.latitude.toString());
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      var userid = await storage.read(key: 'userid');

      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());
        getcity();
      });

      var token = await FirebaseNotifications().getNotifications(context);
      if (userid != null) {
        print(token + "\n Token was recieved from firebase");
        var url =
            'https://api.sellship.co/api/checktokenfcm/' + userid + '/' + token;
        print(url);
        final response = await http.get(url);
        if (response.statusCode == 200) {
          print(response.body);
        } else {
          print(response.statusCode);
        }
      }

      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'locationcountry', value: countr);
      setState(() {
        city = cit;
        locationcountry = countr;
        print(city);
      });
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
      setState(() {
        nearmeitemsgrid = [];
      });
    }
  }

  String locationcountry;
  String country;

  String brand;
  String minprice;
  String maxprice;
  String condition;

  bool gridtoggle;

  final scaffoldState = GlobalKey<ScaffoldState>();

  final Geolocator geolocator = Geolocator();

  void getcity() async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];
    var cit = place.administrativeArea;
    var countryy = place.country;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'locationcountry', value: countryy);

    setState(() {
      city = cit;
      locationcountry = countryy;
    });
    fetchItems(skip, limit);
  }

  String city;
  var notcount;
  bool notbadge;

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/getnotification/' + userid;
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var notificationinfo = json.decode(response.body);
      var notif = notificationinfo['notification'];
      var notcoun = notificationinfo['notcount'];
      if (notif <= 0) {
        setState(() {
          notifcount = notif;
          notifbadge = false;
        });
        FlutterAppBadger.removeBadge();
      } else if (notif > 0) {
        setState(() {
          notifcount = notif;
          notifbadge = true;
        });
      }

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

      FlutterAppBadger.updateBadgeCount(notifcount + notcount);
    } else {
      print(response.statusCode);
    }
  }

  var notifcount;
  var notifbadge;

  void readstorage() async {
    getnotification();
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
    setState(() {
      country = countr;
    });
    fetchRecentlyAdded(skip, limit);

    _getLocation();
  }

  TextEditingController searchcontroller = new TextEditingController();

//  onSearch(String texte) async {
//    if (texte.isEmpty) {
//      setState(() {
//        skip = 0;
//        limit = 20;
//        fetchRecentlyAdded(skip, limit);
//      });
//    } else {
//      searchcontroller.clear();
//
//    }
//  }

  var crossaxiscount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SafeArea(
              child: EasyRefresh.custom(
            header: BezierCircleHeader(
                color: Colors.deepOrangeAccent,
                backgroundColor: Colors.deepPurple,
                enableHapticFeedback: true),
            footer: BallPulseFooter(
                color: Colors.deepPurpleAccent, enableInfiniteLoad: true),
            slivers: <Widget>[
              SliverAppBar(
                pinned: false,
                snap: false,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.white,
                leading: Badge(
                  showBadge: notbadge,
                  position: BadgePosition.topRight(top: 2, right: 3),
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
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                  ),
                ),
                title: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Feather.search,
                                size: 24,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                onTap: () {
                                  showSearch(
                                      context: context,
                                      delegate: UserSearchDelegate(country));
                                },
                                controller: searchcontroller,
//                          onSubmitted: onSearch,
                                decoration: InputDecoration(
                                    hintText: 'Search SellShip',
                                    hintStyle: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ))),
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
                            MaterialPageRoute(builder: (context) => Messages()),
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
                expandedHeight: 100.0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 60.0),
                          child: filtersort(context)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(5.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Text('Categories',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black)),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  right: 20, top: 10, bottom: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryScreen(
                                            selectedcategory: 0)),
                                  );
                                },
                                child: Text('View All',
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black)),
                              )),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 85,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: categories.length,
                            itemBuilder: (ctx, i) {
                              return Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryScreen(
                                                    selectedcategory: i)),
                                      );
                                    },
                                    child: Container(
                                        width: 100,
                                        height: 80,
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              width: 120,
                                              child: Image.asset(
                                                categories[i].image,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                "${categories[i].title}",
                                                style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 10, top: 10, bottom: 5),
                              child: Text('Recently Added',
                                  style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black)),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    right: 20, top: 10, bottom: 10),
                                child: InkWell(
                                    onTap: () {
                                      if (gridtoggle == true) {
                                        setState(() {
                                          gridtoggle = false;
                                        });
                                      } else {
                                        setState(() {
                                          gridtoggle = true;
                                        });
                                      }
                                    },
                                    child: gridtoggle == true
                                        ? Icon(
                                            Icons.grid_on,
                                            size: 18,
                                            color: Colors.deepOrange,
                                          )
                                        : Icon(Icons.list,
                                            size: 18,
                                            color: Colors.deepOrange))),
                          ]),
                    ],
                  ),
                ),
              ),
              itemsgrid.isNotEmpty
                  ? SliverGrid(
                      gridDelegate: gridtoggle == true
                          ? SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.7)
                          : SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1, childAspectRatio: 1),
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        if (index != 0 && index % 8 == 0) {
                          return Platform.isIOS == true
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.2, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _iosadUnitID,
                                      controller: _controller,
                                    ),
                                  ))
                              : Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.2, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _androidadUnitID,
                                      controller: _controller,
                                    ),
                                  ));
                        }
                        return new Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            Details(
                                                itemid:
                                                    itemsgrid[index].itemid),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = Offset(0.0, 1.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                      ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.2, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      new Stack(
                                        children: <Widget>[
                                          gridtoggle == true
                                              ? Container(
                                                  height: 180,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: CachedNetworkImage(
                                                      imageUrl: itemsgrid[index]
                                                          .image,
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
                                                )
                                              : Container(
                                                  height: 300,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: CachedNetworkImage(
                                                      imageUrl: itemsgrid[index]
                                                          .image,
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
                                          itemsgrid[index].sold == true
                                              ? Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    height: 20,
                                                    width: 50,
                                                    color: Colors.amber,
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'SF',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                              Container(
                                                height: 20,
                                                child: Text(
                                                  itemsgrid[index].name,
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: 3.0),
                                              currency != null
                                                  ? Container(
                                                      child: Text(
                                                        currency +
                                                            ' ' +
                                                            itemsgrid[index]
                                                                .price
                                                                .toString(),
                                                        style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 16,
                                                          color:
                                                              Colors.deepOrange,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      child: Text(
                                                        itemsgrid[index]
                                                            .price
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      }, childCount: itemsgrid.length),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                      height: MediaQuery.of(context).size.height,
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
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                30,
                                            height: 150.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                30,
                                            height: 150.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ))
            ],
            onRefresh: () async {
              refresh();
            },
            onLoad: () async {
              _getmoreRecentData();
            },
          )),
        ));
  }

  String _selectedFilter = "Recently Added";

  Widget filtersort(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Container(
          height: 30,
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                InkWell(
                    child: _selectedFilter == "Recently Added"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'New',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'New',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Near Me"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Below 100"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Sort"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Sort',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Sort',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          ),
                    onTap: () {
//              scaffoldState.currentState
//                  .showBottomSheet((context) {
//                return Container(
//                  height: MediaQuery.of(context).size.height,
//                  width: MediaQuery.of(context).size.width,
//                  child: Padding(
//                    padding: const EdgeInsets.all(1.0),
//                    child: Column(
//                      mainAxisAlignment:
//                      MainAxisAlignment.start,
//                      crossAxisAlignment:
//                      CrossAxisAlignment.start,
//                      children: [
//                        ListTile(
//                          title: Text(
//                            'Sort',
//                            style: TextStyle(
//                                fontFamily: 'SF',
//                                fontSize: 16,
//                                fontWeight: FontWeight.w800,
//                                color: Colors.black),
//                          ),
//                        ),
//                        InkWell(
//                          child: ListTile(
//                            title: Text(
//                              'New',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          onTap: () {
//                            setState(() {
//                              _selectedFilter =
//                              'Recently Added';
//                              skip = 0;
//                              limit = 20;
//                              loading = true;
//                            });
//                            itemsgrid.clear();
//                            Navigator.of(context).pop();
//
//                            fetchRecentlyAdded(skip, limit);
//                          },
//                        ),
//                        InkWell(
//                          child: ListTile(
//                            title: Text(
//                              'Near me',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          onTap: () {
//                            setState(() {
//                              _selectedFilter = 'Near me';
//                              skip = 0;
//                              limit = 20;
//                              loading = true;
//                            });
//                            itemsgrid.clear();
//                            Navigator.of(context).pop();
//
//                            fetchItems(skip, limit);
//                          },
//                        ),
//                        InkWell(
//                          child: ListTile(
//                            title: Text(
//                              'Below 100',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          onTap: () {
//                            setState(() {
//                              _selectedFilter = 'Below 100';
//                              skip = 0;
//                              limit = 20;
//                              loading = true;
//                            });
//                            itemsgrid.clear();
//                            Navigator.of(context).pop();
//
//                            fetchbelowhundred(skip, limit);
//                          },
//                        ),
//                        InkWell(
//                          child: ListTile(
//                            title: Text(
//                              'Price Low to High',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          onTap: () {
//                            setState(() {
//                              _selectedFilter = 'Lowest Price';
//                              skip = 0;
//                              limit = 20;
//                              loading = true;
//                            });
//                            itemsgrid.clear();
//                            Navigator.of(context).pop();
//
//                            fetchLowestPrice(skip, limit);
//                          },
//                        ),
//                        InkWell(
//                          child: ListTile(
//                            title: Text(
//                              'Price High to Low',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          onTap: () {
//                            setState(() {
//                              _selectedFilter = 'Highest Price';
//                              skip = 0;
//                              limit = 20;
//                              loading = true;
//                            });
//                            itemsgrid.clear();
//                            Navigator.of(context).pop();
//
//                            fetchHighestPrice(skip, limit);
//                          },
//                        ),
//                      ],
//                    ),
//                  ),
//                );
//              });
//            },
                    }),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
//              scaffoldState.currentState
//                  .showBottomSheet((context) {
//                return Container(
//                  height: MediaQuery.of(context).size.height,
//                  width: MediaQuery.of(context).size.width,
//                  child: Padding(
//                    padding: const EdgeInsets.all(1.0),
//                    child: SingleChildScrollView(
//                      child: Column(
//                        mainAxisAlignment:
//                        MainAxisAlignment.start,
//                        crossAxisAlignment:
//                        CrossAxisAlignment.start,
//                        children: [
//                          ListTile(
//                            title: Text(
//                              'Filter',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w800,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          ExpansionTile(
//                            title: Text(
//                              'Brand',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                            children: <Widget>[
//                              Container(
//                                  height: 500,
//                                  child: ListView.builder(
//                                    itemCount: brands.length,
//                                    itemBuilder:
//                                        (context, index) {
//                                      return InkWell(
//                                        onTap: () async {
//                                          setState(() {
//                                            _selectedFilter =
//                                            'Brands';
//                                            brand =
//                                            brands[index];
//                                            skip = 0;
//                                            limit = 20;
//                                            loading = true;
//                                          });
//                                          itemsgrid.clear();
//                                          Navigator.of(context)
//                                              .pop();
//
//                                          fetchbrands(
//                                              brands[index]);
//                                        },
//                                        child: ListTile(
//                                          title: brands[
//                                          index] !=
//                                              null
//                                              ? Text(
//                                              brands[index])
//                                              : Text('sd'),
//                                        ),
//                                      );
//                                    },
//                                  ))
//                            ],
//                          ),
//                          ExpansionTile(
//                            title: Text(
//                              'Condition',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                            children: <Widget>[
//                              Padding(
//                                padding: EdgeInsets.only(
//                                    left: 30, right: 30),
//                                child: Container(
//                                    width:
//                                    MediaQuery.of(context)
//                                        .size
//                                        .width,
//                                    child: Center(
//                                        child: Align(
//                                            alignment: Alignment
//                                                .center,
//                                            child:
//                                            DropdownButton<
//                                                String>(
//                                              value:
//                                              _selectedCondition,
//                                              hint: Text(
//                                                  'Please choose the condition of your Item'), // No
//                                              icon: Icon(Icons
//                                                  .keyboard_arrow_down),
//                                              iconSize: 20,
//                                              elevation: 1,
//                                              isExpanded: true,
//                                              style: TextStyle(
//                                                fontFamily:
//                                                'SF',
//                                                fontSize: 16,
//                                              ),
//                                              onChanged: (String
//                                              newValue) {
//                                                setState(() {
//                                                  _selectedCondition =
//                                                      newValue;
//                                                });
//
//                                                setState(() {
//                                                  _selectedFilter =
//                                                  'Condition';
//                                                  condition =
//                                                      _selectedCondition;
//                                                  skip = 0;
//                                                  limit = 20;
//                                                  loading =
//                                                  true;
//                                                });
//                                                itemsgrid
//                                                    .clear();
//                                                Navigator.of(
//                                                    context)
//                                                    .pop();
//
//                                                fetchCondition(
//                                                    _selectedCondition);
//                                              },
//                                              items: conditions.map<
//                                                  DropdownMenuItem<
//                                                      String>>((String
//                                              value) {
//                                                return DropdownMenuItem<
//                                                    String>(
//                                                  value: value,
//                                                  child: Text(
//                                                    value,
//                                                    textAlign:
//                                                    TextAlign
//                                                        .center,
//                                                    style: TextStyle(
//                                                        fontFamily:
//                                                        'SF',
//                                                        fontSize:
//                                                        16,
//                                                        color: Colors
//                                                            .black),
//                                                  ),
//                                                );
//                                              }).toList(),
//                                            )))),
//                              ),
//                            ],
//                          ),
//                          ExpansionTile(
//                            title: Text(
//                              'Price',
//                              style: TextStyle(
//                                  fontFamily: 'SF',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400,
//                                  color: Colors.black),
//                            ),
//                            children: <Widget>[
//                              Container(
//                                  height: 130,
//                                  decoration: BoxDecoration(
//                                    color: Colors.white,
//                                    boxShadow: [
//                                      BoxShadow(
//                                        color: Colors
//                                            .grey.shade300,
//                                        offset: Offset(
//                                            0.0, 1.0), //(x,y)
//                                        blurRadius: 6.0,
//                                      ),
//                                    ],
//                                  ),
//                                  child: Column(
//                                    mainAxisAlignment:
//                                    MainAxisAlignment
//                                        .spaceEvenly,
//                                    children: <Widget>[
//                                      Center(
//                                          child: ListTile(
//                                              title: Text(
//                                                'Minimum Price',
//                                                style:
//                                                TextStyle(
//                                                  fontFamily:
//                                                  'SF',
//                                                  fontSize: 16,
//                                                ),
//                                              ),
//                                              trailing:
//                                              Container(
//                                                  width:
//                                                  200,
//                                                  padding:
//                                                  EdgeInsets
//                                                      .only(),
//                                                  child:
//                                                  Center(
//                                                    child:
//                                                    TextField(
//                                                      cursorColor:
//                                                      Color(0xFF979797),
//                                                      controller:
//                                                      minpricecontroller,
//                                                      keyboardType:
//                                                      TextInputType.numberWithOptions(),
//                                                      decoration: InputDecoration(
//                                                          labelText: "Price " + currency,
//                                                          alignLabelWithHint: true,
//                                                          labelStyle: TextStyle(
//                                                            fontFamily: 'SF',
//                                                            fontSize: 16,
//                                                          ),
//                                                          focusColor: Colors.black,
//                                                          enabledBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          border: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          focusedErrorBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          disabledBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          errorBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          focusedBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              ))),
//                                                    ),
//                                                  )))),
//                                      Center(
//                                          child: ListTile(
//                                              title: Text(
//                                                'Maximum Price',
//                                                style:
//                                                TextStyle(
//                                                  fontFamily:
//                                                  'SF',
//                                                  fontSize: 16,
//                                                ),
//                                              ),
//                                              trailing:
//                                              Container(
//                                                  width:
//                                                  200,
//                                                  padding:
//                                                  EdgeInsets
//                                                      .only(),
//                                                  child:
//                                                  Center(
//                                                    child:
//                                                    TextField(
//                                                      cursorColor:
//                                                      Color(0xFF979797),
//                                                      controller:
//                                                      maxpricecontroller,
//                                                      keyboardType:
//                                                      TextInputType.numberWithOptions(),
//                                                      decoration: InputDecoration(
//                                                          labelText: "Price " + currency,
//                                                          alignLabelWithHint: true,
//                                                          labelStyle: TextStyle(
//                                                            fontFamily: 'SF',
//                                                            fontSize: 16,
//                                                          ),
//                                                          focusColor: Colors.black,
//                                                          enabledBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          border: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          focusedErrorBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          disabledBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          errorBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              )),
//                                                          focusedBorder: OutlineInputBorder(
//                                                              borderSide: BorderSide(
//                                                                color: Colors.grey.shade300,
//                                                              ))),
//                                                    ),
//                                                  ))))
//                                    ],
//                                  )),
//                              InkWell(
//                                  onTap: () async {
//                                    setState(() {
//                                      _selectedFilter = 'Price';
//                                      minprice =
//                                          minpricecontroller
//                                              .text;
//                                      maxprice =
//                                          maxpricecontroller
//                                              .text;
//                                      skip = 0;
//                                      limit = 20;
//                                      loading = true;
//                                    });
//                                    itemsgrid.clear();
//                                    Navigator.of(context).pop();
//
//                                    fetchPrice(
//                                        minpricecontroller.text,
//                                        maxpricecontroller
//                                            .text);
//                                  },
//                                  child: Container(
//                                    height: 50,
//                                    color: Colors.deepOrange,
//                                    width:
//                                    MediaQuery.of(context)
//                                        .size
//                                        .width,
//                                    child: Center(
//                                      child: Text(
//                                        'Filter',
//                                        style: TextStyle(
//                                            fontFamily: 'SF',
//                                            fontSize: 16,
//                                            fontWeight:
//                                            FontWeight.w400,
//                                            color:
//                                            Colors.white),
//                                      ),
//                                    ),
//                                  ))
//                            ],
//                          ),
////                                          ExpansionTile(
////                                            title: Text(
////                                              'Delivery',
////                                              style: TextStyle(
////                                                  fontFamily: 'SF',
////                                                  fontSize: 16,
////                                                  fontWeight: FontWeight.w400,
////                                                  color: Colors.black),
////                                            ),
////                                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                );
//              });
                    },
                    child: _selectedFilter == "Brand"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Brand',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Brand',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Condition"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Price"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Price',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Price',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
              ],
            ),
          ),
        ));
  }
}

class UserSearchDelegate extends SearchDelegate {
  final String country;

  UserSearchDelegate(this.country);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon((Icons.clear)),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List>(
        stream: getItemsSearch(query).asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data.length);
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.restore),
                  title: Text(snapshot.data[index]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Search(text: snapshot.data[index])),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        });
  }

  Future<List> getItemsSearch(String text) async {
    var url =
        'https://api.sellship.co/api/searchresults/' + country + '/' + text;

    final response = await http.get(url);

    List responseJson = json.decode(response.body.toString());
    return responseJson;
  }

  List<String> itemsresult = const [];

  bool gridtoggle;

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isNotEmpty
        ? FutureBuilder<List>(
            future: getItemsSearch(query),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.length);
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.restore),
                      title: Text(snapshot.data[index]),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Search(text: snapshot.data[index])),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            })
        : ListView(
            children: <Widget>[
              ListTile(
                title: Text('dss'),
              )
            ],
          );
  }
}
