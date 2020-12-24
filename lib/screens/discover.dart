import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:badges/badges.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/subcategory.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Discover extends StatefulWidget {
  Discover({Key key}) : super(key: key);
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String country;
  String currency;

  void readstorage() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }
    setState(() {
      country = countr;
    });
    loaddiscover();
    loadelectronics();
    loadfashion();
    loadluxury();
    loadmen();
  }

  List<Item> trendingitems = [];
  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  void loaddiscover() async {
    var url = 'https://api.sellship.co/api/trending/' + country;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    print(response.statusCode);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      trendingitems.add(item);
    }
    if (trendingitems != null) {
      setState(() {
        trendingitems = trendingitems;
        loading = false;
      });
    } else {
      setState(() {
        trendingitems = [];
        loading = false;
      });
    }
  }

  List<Item> electronicsitems = [];

  void loadelectronics() async {
    var url = 'https://api.sellship.co/api/best/Electronics/' + country;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      electronicsitems.add(item);
    }
    if (electronicsitems != null) {
      setState(() {
        electronicsitems = electronicsitems;
        loading = false;
      });
    } else {
      setState(() {
        electronicsitems = [];
        loading = false;
      });
    }
  }

  List<Item> womenfashionitems = [];

  void loadfashion() async {
    var url = 'https://api.sellship.co/api/best/Women/' + country;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      womenfashionitems.add(item);
    }
    if (womenfashionitems != null) {
      setState(() {
        womenfashionitems = womenfashionitems;
        loading = false;
      });
    } else {
      setState(() {
        womenfashionitems = [];
        loading = false;
      });
    }
  }

  List<Item> menfashionitems = [];

  void loadmen() async {
    var url = 'https://api.sellship.co/api/best/Men/' + country;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      menfashionitems.add(item);
    }
    if (menfashionitems != null) {
      setState(() {
        menfashionitems = menfashionitems;
        loading = false;
      });
    } else {
      setState(() {
        menfashionitems = [];
        loading = false;
      });
    }
  }

  List<Item> luxuryitems = [];

  void loadluxury() async {
    var url = 'https://api.sellship.co/api/best/Luxury/' + country;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      luxuryitems.add(item);
    }
    if (luxuryitems != null) {
      setState(() {
        luxuryitems = luxuryitems;
        loading = false;
      });
    } else {
      setState(() {
        luxuryitems = [];
        loading = false;
      });
    }
  }

  var loading;
  bool notbadge;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      notbadge = false;
    });
    readstorage();
    getfavourites();
  }

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

        print(notifcount);

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

        FlutterAppBadger.updateBadgeCount(notifcount + notcount);
      } else {
        print(response.statusCode);
      }
    }
  }

  var notifcount;
  var notifbadge;

  TextEditingController searchcontroller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldState,
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0,
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
        body: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 10.0, left: 10, right: 10, bottom: 10),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: const Color(0x80e5e9f2),
                      ),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Icon(
                              Feather.search,
                              size: 24,
                              color: Color.fromRGBO(115, 115, 125, 1),
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
                              decoration: InputDecoration(
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
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5, bottom: 10),
                  child: Text('Discover',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 15, top: 10, bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CategoryScreen(selectedcategory: 0)),
                        );
                      },
                      child: Text('View All',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.deepOrange)),
                    )),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              padding: EdgeInsets.only(left: 10, right: 5),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
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
                                      CategoryScreen(selectedcategory: i)),
                            );
                          },
                          child: Container(
                              width: 80,
                              height: 70,
                              alignment: Alignment.center,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 30,
                                    width: 80,
                                    child: Image.asset(
                                      categories[i].image,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      "${categories[i].title}",
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              )),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5, bottom: 10),
                  child: Text('Trending Items',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            loading == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 260,
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: trendingitems.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: trendingitems[i].itemid,
                                            sold: trendingitems[i].sold,
                                          )),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
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
                                          height: 180,
                                          width: 200,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: trendingitems[i]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitChasingDots(
                                                      color: Colors.deepOrange)
                                                  : trendingitems[i].image,
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
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                height: 35,
                                                width: 145,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(trendingitems[
                                                                            i]
                                                                        .likes)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          if (favourites
                                                              .contains(
                                                                  trendingitems[
                                                                          i]
                                                                      .itemid)) {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    trendingitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.remove(
                                                                  trendingitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                trendingitems[i]
                                                                        .likes =
                                                                    trendingitems[i]
                                                                            .likes -
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          } else {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    trendingitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.add(
                                                                  trendingitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                trendingitems[i]
                                                                        .likes =
                                                                    trendingitems[i]
                                                                            .likes +
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          }
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 5),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: VerticalDivider(),
                                                    ),
                                                    Padding(
                                                      child: InkWell(
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Feather
                                                                    .message_circle,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(trendingitems[
                                                                            i]
                                                                        .comments)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
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
                                                                            trendingitems[i].itemid)),
                                                          );
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 10),
                                                    ),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                ),
                                              ),
                                            )),
                                        trendingitems[i].sold == true
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  child: Center(
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            : favourites != null
                                                ? favourites.contains(
                                                        trendingitems[i].itemid)
                                                    ? InkWell(
                                                        enableFeedback: true,
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
                                                                  trendingitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                trendingitems[i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              trendingitems[i]
                                                                      .likes =
                                                                  trendingitems[
                                                                              i]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                    : InkWell(
                                                        enableFeedback: true,
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
                                                                  trendingitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                trendingitems[i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              trendingitems[i]
                                                                      .likes =
                                                                  trendingitems[
                                                                              i]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Icon(
                                                                    Feather
                                                                        .heart,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Feather.heart,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 16,
                                                          ),
                                                        ))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      child: Container(
                                        height: 21,
                                        child: Text(
                                          trendingitems[i].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                Color.fromRGBO(28, 45, 65, 1),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    SizedBox(height: 4.0),
                                    currency != null
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                currency +
                                                    ' ' +
                                                    trendingitems[i]
                                                        .price
                                                        .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        : Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                trendingitems[i]
                                                    .price
                                                    .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              onDoubleTap: () async {
                                if (favourites
                                    .contains(trendingitems[i].itemid)) {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': trendingitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        trendingitems[i].likes =
                                            trendingitems[i].likes - 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                } else {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': trendingitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        trendingitems[i].likes =
                                            trendingitems[i].likes + 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [0, 1, 2, 3, 4, 5, 6]
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        height: 150.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
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
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
            Padding(
                padding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Platform.isIOS == true
                      ? Container(
                          height: 250,
                          padding: EdgeInsets.all(5),
                          child: NativeAdmob(
                            adUnitID: _iosadUnitID,
                            controller: _controller,
                          ),
                        )
                      : Container(
                          height: 250,
                          padding: EdgeInsets.all(5),
                          child: NativeAdmob(
                            adUnitID: _androidadUnitID,
                            controller: _controller,
                          ),
                        ),
                )),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5, bottom: 10),
                  child: Text('Best Styles in Men',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 5,
            ),
            loading == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: menfashionitems.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: menfashionitems[i].itemid,
                                            sold: menfashionitems[i].sold,
                                          )),
                                );
                              },
                              child: Container(
                                height: 180,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
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
                                          height: 150,
                                          width: 150,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: menfashionitems[i]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitChasingDots(
                                                      color: Colors.deepOrange)
                                                  : menfashionitems[i].image,
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
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                height: 35,
                                                width: 145,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(menfashionitems[
                                                                            i]
                                                                        .likes)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          if (favourites.contains(
                                                              menfashionitems[i]
                                                                  .itemid)) {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    menfashionitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.remove(
                                                                  menfashionitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                menfashionitems[
                                                                            i]
                                                                        .likes =
                                                                    menfashionitems[i]
                                                                            .likes -
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          } else {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    menfashionitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.add(
                                                                  menfashionitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                menfashionitems[
                                                                            i]
                                                                        .likes =
                                                                    menfashionitems[i]
                                                                            .likes +
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          }
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 5),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: VerticalDivider(),
                                                    ),
                                                    Padding(
                                                      child: InkWell(
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Feather
                                                                    .message_circle,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(menfashionitems[
                                                                            i]
                                                                        .comments)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
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
                                                                            menfashionitems[i].itemid)),
                                                          );
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 10),
                                                    ),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                ),
                                              ),
                                            )),
                                        menfashionitems[i].sold == true
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  child: Center(
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            : favourites != null
                                                ? favourites.contains(
                                                        menfashionitems[i]
                                                            .itemid)
                                                    ? InkWell(
                                                        enableFeedback: true,
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
                                                                  menfashionitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                menfashionitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              menfashionitems[i]
                                                                      .likes =
                                                                  menfashionitems[
                                                                              i]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                    : InkWell(
                                                        enableFeedback: true,
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
                                                                  menfashionitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                menfashionitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              menfashionitems[i]
                                                                      .likes =
                                                                  menfashionitems[
                                                                              i]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Icon(
                                                                    Feather
                                                                        .heart,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Feather.heart,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 16,
                                                          ),
                                                        ))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      child: Container(
                                        height: 21,
                                        child: Text(
                                          menfashionitems[i].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                Color.fromRGBO(28, 45, 65, 1),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    SizedBox(height: 4.0),
                                    currency != null
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                currency +
                                                    ' ' +
                                                    menfashionitems[i]
                                                        .price
                                                        .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        : Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                menfashionitems[i]
                                                    .price
                                                    .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              onDoubleTap: () async {
                                if (favourites
                                    .contains(menfashionitems[i].itemid)) {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': menfashionitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        menfashionitems[i].likes =
                                            menfashionitems[i].likes - 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                } else {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': menfashionitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        menfashionitems[i].likes =
                                            menfashionitems[i].likes + 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [0, 1, 2, 3, 4, 5, 6]
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        height: 150.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
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
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5, bottom: 10),
                  child: Text('Best Deals in Electronics',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 5,
            ),
            loading == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: electronicsitems.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: electronicsitems[i].itemid,
                                            sold: electronicsitems[i].sold,
                                          )),
                                );
                              },
                              child: Container(
                                height: 180,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
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
                                          height: 150,
                                          width: 150,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: electronicsitems[i]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitChasingDots(
                                                      color: Colors.deepOrange)
                                                  : electronicsitems[i].image,
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
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                height: 35,
                                                width: 145,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(electronicsitems[
                                                                            i]
                                                                        .likes)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          if (favourites.contains(
                                                              electronicsitems[
                                                                      i]
                                                                  .itemid)) {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    electronicsitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.remove(
                                                                  electronicsitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                electronicsitems[
                                                                            i]
                                                                        .likes =
                                                                    electronicsitems[i]
                                                                            .likes -
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          } else {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    electronicsitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.add(
                                                                  electronicsitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                electronicsitems[
                                                                            i]
                                                                        .likes =
                                                                    electronicsitems[i]
                                                                            .likes +
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          }
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 5),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: VerticalDivider(),
                                                    ),
                                                    Padding(
                                                      child: InkWell(
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Feather
                                                                    .message_circle,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(electronicsitems[
                                                                            i]
                                                                        .comments)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
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
                                                                            electronicsitems[i].itemid)),
                                                          );
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 10),
                                                    ),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                ),
                                              ),
                                            )),
                                        electronicsitems[i].sold == true
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  child: Center(
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            : favourites != null
                                                ? favourites.contains(
                                                        electronicsitems[i]
                                                            .itemid)
                                                    ? InkWell(
                                                        enableFeedback: true,
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
                                                                  electronicsitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                electronicsitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              electronicsitems[
                                                                          i]
                                                                      .likes =
                                                                  electronicsitems[
                                                                              i]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                    : InkWell(
                                                        enableFeedback: true,
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
                                                                  electronicsitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                electronicsitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              electronicsitems[
                                                                          i]
                                                                      .likes =
                                                                  electronicsitems[
                                                                              i]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Icon(
                                                                    Feather
                                                                        .heart,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Feather.heart,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 16,
                                                          ),
                                                        ))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      child: Container(
                                        height: 21,
                                        child: Text(
                                          electronicsitems[i].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                Color.fromRGBO(28, 45, 65, 1),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    SizedBox(height: 4.0),
                                    currency != null
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                currency +
                                                    ' ' +
                                                    electronicsitems[i]
                                                        .price
                                                        .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        : Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                electronicsitems[i]
                                                    .price
                                                    .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              onDoubleTap: () async {
                                if (favourites
                                    .contains(electronicsitems[i].itemid)) {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': electronicsitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        electronicsitems[i].likes =
                                            electronicsitems[i].likes - 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                } else {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': electronicsitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        electronicsitems[i].likes =
                                            electronicsitems[i].likes + 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [0, 1, 2, 3, 4, 5, 6]
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        height: 150.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
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
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
            Padding(
                padding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Platform.isIOS == true
                      ? Container(
                          height: 250,
                          padding: EdgeInsets.all(5),
                          child: NativeAdmob(
                            adUnitID: _iosadUnitID,
                            controller: _controller,
                          ),
                        )
                      : Container(
                          height: 250,
                          padding: EdgeInsets.all(5),
                          child: NativeAdmob(
                            adUnitID: _androidadUnitID,
                            controller: _controller,
                          ),
                        ),
                )),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 5, bottom: 10),
                  child: Text('Best Styles in Women',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 5,
            ),
            loading == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: womenfashionitems.length,
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: womenfashionitems[i].itemid,
                                            sold: womenfashionitems[i].sold,
                                          )),
                                );
                              },
                              child: Container(
                                height: 180,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
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
                                          height: 150,
                                          width: 150,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: womenfashionitems[i]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitChasingDots(
                                                      color: Colors.deepOrange)
                                                  : womenfashionitems[i].image,
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
                                        Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                height: 35,
                                                width: 145,
                                                decoration: BoxDecoration(
                                                  color: Colors.black26
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(womenfashionitems[
                                                                            i]
                                                                        .likes)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          if (favourites.contains(
                                                              womenfashionitems[
                                                                      i]
                                                                  .itemid)) {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    womenfashionitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.remove(
                                                                  womenfashionitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                womenfashionitems[
                                                                            i]
                                                                        .likes =
                                                                    womenfashionitems[i]
                                                                            .likes -
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          } else {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    womenfashionitems[
                                                                            i]
                                                                        .itemid,
                                                              };

                                                              favourites.add(
                                                                  womenfashionitems[
                                                                          i]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                womenfashionitems[
                                                                            i]
                                                                        .likes =
                                                                    womenfashionitems[i]
                                                                            .likes +
                                                                        1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body:
                                                                          body);

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
                                                          }
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 5),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: VerticalDivider(),
                                                    ),
                                                    Padding(
                                                      child: InkWell(
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Feather
                                                                    .message_circle,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Numeral(womenfashionitems[
                                                                            i]
                                                                        .comments)
                                                                    .value(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
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
                                                                            womenfashionitems[i].itemid)),
                                                          );
                                                        },
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 10),
                                                    ),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                ),
                                              ),
                                            )),
                                        womenfashionitems[i].sold == true
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  child: Center(
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            : favourites != null
                                                ? favourites.contains(
                                                        womenfashionitems[i]
                                                            .itemid)
                                                    ? InkWell(
                                                        enableFeedback: true,
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
                                                                  womenfashionitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                womenfashionitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              womenfashionitems[
                                                                          i]
                                                                      .likes =
                                                                  womenfashionitems[
                                                                              i]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                    : InkWell(
                                                        enableFeedback: true,
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
                                                                  womenfashionitems[
                                                                          i]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                womenfashionitems[
                                                                        i]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              womenfashionitems[
                                                                          i]
                                                                      .likes =
                                                                  womenfashionitems[
                                                                              i]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

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
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Icon(
                                                                    Feather
                                                                        .heart,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Feather.heart,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 16,
                                                          ),
                                                        ))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      child: Container(
                                        height: 21,
                                        child: Text(
                                          womenfashionitems[i].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                Color.fromRGBO(28, 45, 65, 1),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    SizedBox(height: 4.0),
                                    currency != null
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                currency +
                                                    ' ' +
                                                    womenfashionitems[i]
                                                        .price
                                                        .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        : Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Container(
                                              child: Text(
                                                womenfashionitems[i]
                                                    .price
                                                    .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              onDoubleTap: () async {
                                if (favourites
                                    .contains(womenfashionitems[i].itemid)) {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': womenfashionitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        womenfashionitems[i].likes =
                                            womenfashionitems[i].likes - 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                } else {
                                  var userid =
                                      await storage.read(key: 'userid');

                                  if (userid != null) {
                                    var url =
                                        'https://api.sellship.co/api/favourite/' +
                                            userid;

                                    Map<String, String> body = {
                                      'itemid': womenfashionitems[i].itemid,
                                    };

                                    final response =
                                        await http.post(url, body: body);

                                    if (response.statusCode == 200) {
                                      var jsondata = json.decode(response.body);

                                      favourites.clear();
                                      for (int i = 0;
                                          i < jsondata.length;
                                          i++) {
                                        favourites
                                            .add(jsondata[i]['_id']['\$oid']);
                                      }
                                      setState(() {
                                        favourites = favourites;
                                        womenfashionitems[i].likes =
                                            womenfashionitems[i].likes + 1;
                                      });
                                    } else {
                                      print(response.statusCode);
                                    }
                                  } else {
                                    showInSnackBar(
                                        'Please Login to use Favourites');
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [0, 1, 2, 3, 4, 5, 6]
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                30,
                                        height: 150.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
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
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ]))
        ]));
  }

  final scaffoldState = GlobalKey<ScaffoldState>();
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
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<String> ites = List<String>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              if (profilemap[i] != null) {
                ites.add(profilemap[i]['_id']['\$oid']);
              }
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
    print(favourites);
  }

  List<String> favourites;
}
