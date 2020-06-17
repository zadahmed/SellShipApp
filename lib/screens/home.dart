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
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/search.dart';

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
//  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 20;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        appBar: AppBar(
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
                  MaterialPageRoute(builder: (context) => NotifcationPage()),
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
        ),
        body: GestureDetector(onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        }, child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, top: 10, bottom: 10),
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
                                                alignment:
                                                    Alignment.bottomCenter,
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
                        nearmeitemsgrid.isNotEmpty
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, top: 10, bottom: 5),
                                      child: Text('Near me',
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
                                                  builder: (context) =>
                                                      NearMe()),
                                            );
                                          },
                                          child: Text('View All',
                                              style: TextStyle(
                                                  fontFamily: 'SF',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black)),
                                        )),
                                  ])
                            : Container(),
                        nearmeitemsgrid.isNotEmpty
                            ? SizedBox(
                                height: 5,
                              )
                            : Container(),
                        nearmeitemsgrid.isNotEmpty
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 230,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: nearmeitemsgrid.length,
                                    shrinkWrap: true,
                                    itemBuilder: (ctx, i) {
                                      return Row(
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => Details(
                                                              itemid:
                                                                  nearmeitemsgrid[
                                                                          i]
                                                                      .itemid)),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        new Stack(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 150,
                                                              width: 150,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      nearmeitemsgrid[
                                                                              i]
                                                                          .image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    height: 20,
                                                                    child: Text(
                                                                      nearmeitemsgrid[
                                                                              i]
                                                                          .name,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'SF',
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          3.0),
                                                                  Container(
                                                                    child: Text(
                                                                      currency +
                                                                          ' ' +
                                                                          nearmeitemsgrid[i]
                                                                              .price
                                                                              .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'SF',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                  ))),
                                        ],
                                      );
                                    }))
                            : Container(),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, top: 10, bottom: 5),
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RecentlyAdded()),
                                      );
                                    },
                                    child: Text('View All',
                                        style: TextStyle(
                                            fontFamily: 'SF',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black)),
                                  )),
                            ]),
                        itemsgrid.isNotEmpty
                            ? Flexible(
                                child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: StaggeredGridView.countBuilder(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                      itemCount: itemsgrid.length + 1,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        if (index != 0 && index % 8 == 0) {
                                          return Platform.isIOS == true
                                              ? Container(
                                                  height: 150,
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.only(
                                                      bottom: 20.0),
                                                  child: NativeAdmob(
                                                    adUnitID: _iosadUnitID,
                                                    controller: _controller,
                                                  ),
                                                )
                                              : Container(
                                                  height: 150,
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.only(
                                                      bottom: 20.0),
                                                  child: NativeAdmob(
                                                    adUnitID: _androidadUnitID,
                                                    controller: _controller,
                                                  ),
                                                );
                                        }

                                        if (index == itemsgrid.length) {
                                          return Center(
                                              child: Container(
                                            child: SpinKitThreeBounce(
                                              color: Colors.deepOrange,
                                              size: 20,
                                            ),
                                          ));
                                        }

                                        return Padding(
                                            padding: EdgeInsets.all(10),
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Details(
                                                                itemid: itemsgrid[
                                                                        index]
                                                                    .itemid)),
                                                  );
                                                },
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      new Stack(
                                                        children: <Widget>[
                                                          Container(
                                                            height: 180,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    itemsgrid[
                                                                            index]
                                                                        .image,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitChasingDots(
                                                                        color: Colors
                                                                            .deepOrange),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                          ),
                                                          itemsgrid[index]
                                                                      .sold ==
                                                                  true
                                                              ? Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      Container(
                                                                    height: 20,
                                                                    width: 50,
                                                                    color: Colors
                                                                        .amber,
                                                                    child: Text(
                                                                      'Sold',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'SF',
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ))
                                                              : Container(),
                                                        ],
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 20,
                                                                child: Text(
                                                                  itemsgrid[
                                                                          index]
                                                                      .name,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF',
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 3.0),
                                                              currency != null
                                                                  ? Container(
                                                                      child:
                                                                          Text(
                                                                        currency +
                                                                            ' ' +
                                                                            itemsgrid[index].price.toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'SF',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      child:
                                                                          Text(
                                                                        itemsgrid[index]
                                                                            .price
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'SF',
                                                                          fontSize:
                                                                              16,
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
                                      },
                                      staggeredTileBuilder: (int index) {
                                        if (index != 0 &&
                                            index == itemsgrid.length) {
                                          return StaggeredTile.count(2, 0.1);
                                        } else {
                                          return StaggeredTile.fit(1);
                                        }
                                      },
                                    )))
                            : Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                          'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'SF',
                                            fontSize: 16,
                                          )),
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                      'assets/little_theologians_4x.png',
                                      fit: BoxFit.fitWidth,
                                    ))
                                  ],
                                )),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ])));
        })));
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Loading'),
                SpinKitChasingDots(
                  color: Colors.deepOrange,
                )
              ],
            );
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

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List>(
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
            return Center(
              child: SpinKitChasingDots(
                color: Colors.deepOrange,
              ),
            );
          }
        });
  }
}
