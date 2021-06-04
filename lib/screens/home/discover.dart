import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/category.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/models/user.dart';
import 'package:SellShip/screens/blogPage.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/filter.dart';
import 'package:SellShip/screens/home/below100.dart';
import 'package:SellShip/screens/home/foryou.dart';
import 'package:SellShip/screens/home/nearme.dart';
import 'package:SellShip/screens/home/recentlyadded.dart';
import 'package:SellShip/screens/home/toppicks.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notavaialablecountry.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/storepage.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/subcategory.dart';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart' as Location;

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Discover extends StatefulWidget {
  Discover({Key key}) : super(key: key);
  @override
  _DiscoverState createState() => _DiscoverState();
}

class Subcategory {
  final String name;
  final String image;

  Subcategory({this.name, this.image});
}

class _DiscoverState extends State<Discover>
    with AutomaticKeepAliveClientMixin {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  bool alive = false;

  @override
  bool get wantKeepAlive => alive;

  ScrollController _scrollController = ScrollController();

  var currency;

  List<Item> electronicsitemsgrid = [];
  List<Item> homeitemsgrid = [];
  List<Item> beautyitemsgrid = [];
  List<Item> menitemsgrid = [];
  List<Item> womenitemsgrid = [];
  List<Item> handmadeitemsgrid = [];
  List<Item> booksitemsgrid = [];
  List<Item> luxuryitemsgrid = [];
  List<Item> gardenitemsgrid = [];
  List<Item> kidsitemsgrid = [];
  List<Item> toysitemsgrid = [];

  Future<List<Item>> gethome() async {
    var url = 'https://api.sellship.co/api/custom/home';
    final response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);

    print(jsonbody);

    var electronics = jsonbody['electronics'];
    var home = jsonbody['home'];
    var beauty = jsonbody['beauty'];
    var men = jsonbody['men'];
    var women = jsonbody['women'];
    var handmade = jsonbody['handmade'];
    var books = jsonbody['books'];
    var luxury = jsonbody['luxury'];
    var garden = jsonbody['garden'];
    var kids = jsonbody['kids'];
    var toys = jsonbody['toys'];

    for (var i = 0; i < garden.length; i++) {
      var q = Map<String, dynamic>.from(garden[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: garden[i]['_id']['\$oid'],
        date: dateuploaded,
        name: garden[i]['name'],
        condition: garden[i]['condition'] == null
            ? 'Like New'
            : garden[i]['condition'],
        username: garden[i]['username'],
        likes: garden[i]['likes'] == null ? 0 : garden[i]['likes'],
        comments:
            garden[i]['comments'] == null ? 0 : garden[i]['comments'].length,
        image: garden[i]['image'],
        price: garden[i]['price'].toString(),
        saleprice: garden[i].containsKey('saleprice')
            ? garden[i]['saleprice'].toString()
            : null,
        category: garden[i]['category'],
        sold: garden[i]['sold'] == null ? false : garden[i]['sold'],
      );
      gardenitemsgrid.add(item);
    }

    for (var i = 0; i < kids.length; i++) {
      var q = Map<String, dynamic>.from(kids[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: kids[i]['_id']['\$oid'],
        date: dateuploaded,
        name: kids[i]['name'],
        condition:
            kids[i]['condition'] == null ? 'Like New' : kids[i]['condition'],
        username: kids[i]['username'],
        likes: kids[i]['likes'] == null ? 0 : kids[i]['likes'],
        comments: kids[i]['comments'] == null ? 0 : kids[i]['comments'].length,
        image: kids[i]['image'],
        price: kids[i]['price'].toString(),
        saleprice: kids[i].containsKey('saleprice')
            ? kids[i]['saleprice'].toString()
            : null,
        category: kids[i]['category'],
        sold: kids[i]['sold'] == null ? false : kids[i]['sold'],
      );
      kidsitemsgrid.add(item);
    }

    for (var i = 0; i < toys.length; i++) {
      var q = Map<String, dynamic>.from(toys[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: toys[i]['_id']['\$oid'],
        date: dateuploaded,
        name: toys[i]['name'],
        condition:
            toys[i]['condition'] == null ? 'Like New' : toys[i]['condition'],
        username: toys[i]['username'],
        likes: toys[i]['likes'] == null ? 0 : toys[i]['likes'],
        comments: toys[i]['comments'] == null ? 0 : toys[i]['comments'].length,
        image: toys[i]['image'],
        price: toys[i]['price'].toString(),
        saleprice: toys[i].containsKey('saleprice')
            ? toys[i]['saleprice'].toString()
            : null,
        category: toys[i]['category'],
        sold: toys[i]['sold'] == null ? false : toys[i]['sold'],
      );
      toysitemsgrid.add(item);
    }

    for (var i = 0; i < luxury.length; i++) {
      var q = Map<String, dynamic>.from(luxury[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: luxury[i]['_id']['\$oid'],
        date: dateuploaded,
        name: luxury[i]['name'],
        condition: luxury[i]['condition'] == null
            ? 'Like New'
            : luxury[i]['condition'],
        username: luxury[i]['username'],
        likes: luxury[i]['likes'] == null ? 0 : luxury[i]['likes'],
        comments:
            luxury[i]['comments'] == null ? 0 : luxury[i]['comments'].length,
        image: luxury[i]['image'],
        price: luxury[i]['price'].toString(),
        saleprice: luxury[i].containsKey('saleprice')
            ? luxury[i]['saleprice'].toString()
            : null,
        category: luxury[i]['category'],
        sold: luxury[i]['sold'] == null ? false : luxury[i]['sold'],
      );
      luxuryitemsgrid.add(item);
    }

    for (var i = 0; i < books.length; i++) {
      var q = Map<String, dynamic>.from(books[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: books[i]['_id']['\$oid'],
        date: dateuploaded,
        name: books[i]['name'],
        condition:
            books[i]['condition'] == null ? 'Like New' : books[i]['condition'],
        username: books[i]['username'],
        likes: books[i]['likes'] == null ? 0 : books[i]['likes'],
        comments:
            books[i]['comments'] == null ? 0 : books[i]['comments'].length,
        image: books[i]['image'],
        price: books[i]['price'].toString(),
        saleprice: books[i].containsKey('saleprice')
            ? books[i]['saleprice'].toString()
            : null,
        category: books[i]['category'],
        sold: books[i]['sold'] == null ? false : books[i]['sold'],
      );
      booksitemsgrid.add(item);
    }

    for (var i = 0; i < electronics.length; i++) {
      var q = Map<String, dynamic>.from(electronics[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: electronics[i]['_id']['\$oid'],
        date: dateuploaded,
        name: electronics[i]['name'],
        condition: electronics[i]['condition'] == null
            ? 'Like New'
            : electronics[i]['condition'],
        username: electronics[i]['username'],
        likes: electronics[i]['likes'] == null ? 0 : electronics[i]['likes'],
        comments: electronics[i]['comments'] == null
            ? 0
            : electronics[i]['comments'].length,
        image: electronics[i]['image'],
        price: electronics[i]['price'].toString(),
        saleprice: electronics[i].containsKey('saleprice')
            ? electronics[i]['saleprice'].toString()
            : null,
        category: electronics[i]['category'],
        sold: electronics[i]['sold'] == null ? false : electronics[i]['sold'],
      );
      electronicsitemsgrid.add(item);
    }

    for (var i = 0; i < beauty.length; i++) {
      var q = Map<String, dynamic>.from(beauty[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: beauty[i]['_id']['\$oid'],
        date: dateuploaded,
        name: beauty[i]['name'],
        condition: beauty[i]['condition'] == null
            ? 'Like New'
            : beauty[i]['condition'],
        username: beauty[i]['username'],
        likes: beauty[i]['likes'] == null ? 0 : beauty[i]['likes'],
        comments:
            beauty[i]['comments'] == null ? 0 : beauty[i]['comments'].length,
        image: beauty[i]['image'],
        price: beauty[i]['price'].toString(),
        saleprice: beauty[i].containsKey('saleprice')
            ? beauty[i]['saleprice'].toString()
            : null,
        category: beauty[i]['category'],
        sold: beauty[i]['sold'] == null ? false : beauty[i]['sold'],
      );
      beautyitemsgrid.add(item);
    }

    for (var i = 0; i < home.length; i++) {
      var q = Map<String, dynamic>.from(home[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: home[i]['_id']['\$oid'],
        date: dateuploaded,
        name: home[i]['name'],
        condition:
            home[i]['condition'] == null ? 'Like New' : home[i]['condition'],
        username: home[i]['username'],
        likes: home[i]['likes'] == null ? 0 : home[i]['likes'],
        comments: home[i]['comments'] == null ? 0 : home[i]['comments'].length,
        image: home[i]['image'],
        price: home[i]['price'].toString(),
        saleprice: home[i].containsKey('saleprice')
            ? home[i]['saleprice'].toString()
            : null,
        category: home[i]['category'],
        sold: home[i]['sold'] == null ? false : home[i]['sold'],
      );
      homeitemsgrid.add(item);
    }

    for (var i = 0; i < men.length; i++) {
      var q = Map<String, dynamic>.from(men[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: men[i]['_id']['\$oid'],
        date: dateuploaded,
        name: men[i]['name'],
        condition:
            men[i]['condition'] == null ? 'Like New' : men[i]['condition'],
        username: men[i]['username'],
        likes: men[i]['likes'] == null ? 0 : men[i]['likes'],
        comments: men[i]['comments'] == null ? 0 : men[i]['comments'].length,
        image: men[i]['image'],
        price: men[i]['price'].toString(),
        saleprice: men[i].containsKey('saleprice')
            ? men[i]['saleprice'].toString()
            : null,
        category: men[i]['category'],
        sold: men[i]['sold'] == null ? false : men[i]['sold'],
      );
      menitemsgrid.add(item);
    }

    for (var i = 0; i < handmade.length; i++) {
      var q = Map<String, dynamic>.from(handmade[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: handmade[i]['_id']['\$oid'],
        date: dateuploaded,
        name: handmade[i]['name'],
        condition: handmade[i]['condition'] == null
            ? 'Like New'
            : handmade[i]['condition'],
        username: handmade[i]['username'],
        likes: handmade[i]['likes'] == null ? 0 : handmade[i]['likes'],
        comments: handmade[i]['comments'] == null
            ? 0
            : handmade[i]['comments'].length,
        image: handmade[i]['image'],
        price: handmade[i]['price'].toString(),
        saleprice: handmade[i].containsKey('saleprice')
            ? handmade[i]['saleprice'].toString()
            : null,
        category: handmade[i]['category'],
        sold: handmade[i]['sold'] == null ? false : handmade[i]['sold'],
      );
      handmadeitemsgrid.add(item);
    }

    for (var i = 0; i < women.length; i++) {
      var q = Map<String, dynamic>.from(women[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: women[i]['_id']['\$oid'],
        date: dateuploaded,
        name: women[i]['name'],
        condition:
            women[i]['condition'] == null ? 'Like New' : women[i]['condition'],
        username: women[i]['username'],
        likes: women[i]['likes'] == null ? 0 : women[i]['likes'],
        comments:
            women[i]['comments'] == null ? 0 : women[i]['comments'].length,
        image: women[i]['image'],
        price: women[i]['price'].toString(),
        saleprice: women[i].containsKey('saleprice')
            ? women[i]['saleprice'].toString()
            : null,
        category: women[i]['category'],
        sold: women[i]['sold'] == null ? false : women[i]['sold'],
      );
      womenitemsgrid.add(item);
    }

    if (mounted) {
      setState(() {
        electronicsitemsgrid = electronicsitemsgrid;
        homeitemsgrid = homeitemsgrid;
        beautyitemsgrid = beautyitemsgrid;
        menitemsgrid = menitemsgrid;
        womenitemsgrid = womenitemsgrid;
        handmadeitemsgrid = handmadeitemsgrid;
        booksitemsgrid = booksitemsgrid;
        luxuryitemsgrid = luxuryitemsgrid;
        gardenitemsgrid = gardenitemsgrid;
        kidsitemsgrid = kidsitemsgrid;
        toysitemsgrid = toysitemsgrid;
        loading = false;
      });
    }
  }

  LatLng position;
  bool loading;

  final storage = new FlutterSecureStorage();

  TabController _tabController;
  @override
  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        skip = 0;
        limit = 50;
        loading = true;
      });
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));

    gethome();
    getCategories();
  }

  List<Category> categoryList = new List<Category>();

  List<String> hashtagList = [];

  getCategories() async {
    var url = 'https://api.sellship.co/api/categories/view';

    final response = await http.get(Uri.parse(url));
    var jsonbody = json.decode(response.body);

    for (int i = 0; i < jsonbody.length; i++) {
      if (jsonbody[i]['name'] != 'Other') {
        Category cat = new Category(
            categoryname: jsonbody[i]['name'],
            categoryimage: jsonbody[i]['categoryimage'],
            subcategories: jsonbody[i]['subcategories']);

        categoryList.add(cat);
      }
    }

    setState(() {
      categoryList = categoryList;
    });
  }

  String locationcountry;
  String country;

  String brand;
  String minprice;
  String maxprice;
  String condition;

  bool gridtoggle = true;

  final scaffoldState = GlobalKey<ScaffoldState>();

  Color followcolor = Colors.deepOrange;

  var follow = false;

  var notifcount;
  var notifbadge;

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

  void readstorage() async {
    getfavourites();
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

  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();
  TextEditingController searchcontroller = new TextEditingController();

  var crossaxiscount = 2;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        body: loading == false
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: CarouselSlider(
                          options: CarouselOptions(
                            height: 120.0,
                            aspectRatio: 16 / 9,
                            viewportFraction: 1,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                          ),
                          items: [
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {},
                              enableFeedback: true,
                              child: Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/homebanners/IMG_2980.PNG',
                                      fit: BoxFit.contain,
                                      fadeInDuration: Duration(microseconds: 5),
                                      placeholder: (context, url) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  )),
                            );
                          },
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {},
                              enableFeedback: true,
                              child: Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/homebanners/IMG_2984.PNG',
                                      fit: BoxFit.contain,
                                      fadeInDuration: Duration(microseconds: 5),
                                      placeholder: (context, url) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  )),
                            );
                          },
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {},
                              enableFeedback: true,
                              child: Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/homebanners/IMG_2986.PNG',
                                      fit: BoxFit.contain,
                                      fadeInDuration: Duration(microseconds: 5),
                                      placeholder: (context, url) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  )),
                            );
                          },
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {},
                              enableFeedback: true,
                              child: Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/homebanners/IMG_2996.PNG',
                                      fit: BoxFit.contain,
                                      fadeInDuration: Duration(microseconds: 5),
                                      placeholder: (context, url) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  )),
                            );
                          },
                        ),
                      ])),
                  SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 16, bottom: 10, right: 16, top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              enableFeedback: true,
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   CupertinoPageRoute(
                                //       builder: (context) => CategoryDynamic(
                                //             category: 'Electronics',
                                //           )),
                                // );
                              },
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              itemCount: categoryList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      categoryList[index]
                                                          .banner,
                                                  category: categoryList[index]
                                                      .categoryname,
                                                  subcategory:
                                                      categoryList[index]
                                                          .subcategories,
                                                )),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: categoryList[index]
                                                      .categoryimage !=
                                                  null
                                              ? ClipRRect(
                                                  child: Hero(
                                                      tag: 'cat' +
                                                          categoryList[index]
                                                              .categoryimage,
                                                      child: CachedNetworkImage(
                                                        height: 120,
                                                        width: 120,
                                                        imageUrl:
                                                            categoryList[index]
                                                                .categoryimage,
                                                        fit: BoxFit.fitHeight,
                                                      )))
                                              : Container(),
                                        ),
                                        Container(
                                          height: 30,
                                          width: 120,
                                          padding: EdgeInsets.all(5),
                                          child: Center(
                                            child: Text(
                                              categoryList[index]
                                                  .categoryname
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ));
                              }))),
                  handmadeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2789.PNG',
                                            category: 'Handmade',
                                            subcategory:
                                                categoryList[4].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2789.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  handmadeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Handmade',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2789.PNG',
                                                  category: 'Handmade',
                                                  subcategory: categoryList[4]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  handmadeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: handmadeitemsgrid.length > 20
                                ? 20
                                : handmadeitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        handmadeitemsgrid[index]
                                                            .itemid,
                                                    image:
                                                        handmadeitemsgrid[index]
                                                            .image,
                                                    name:
                                                        handmadeitemsgrid[index]
                                                            .name,
                                                    sold:
                                                        handmadeitemsgrid[index]
                                                            .sold,
                                                    source:
                                                        'handmadeitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: handmadeitemsgrid[
                                                            index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : handmadeitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        handmadeitemsgrid[index]
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
                                                                  handmadeitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                handmadeitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              handmadeitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  handmadeitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  handmadeitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                handmadeitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              handmadeitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  handmadeitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  handmadeitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                handmadeitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  handmadeitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  handmadeitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(handmadeitemsgrid[index].price.toString()) - double.parse(handmadeitemsgrid[index].saleprice.toString())) / double.parse(handmadeitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: handmadeitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  beautyitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2795.PNG',
                                            category: 'Beauty',
                                            subcategory:
                                                categoryList[2].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2795.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  beautyitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Beauty',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2795.PNG',
                                                  category: 'Beauty',
                                                  subcategory: categoryList[2]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  beautyitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: beautyitemsgrid.length > 20
                                ? 20
                                : beautyitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        beautyitemsgrid[index]
                                                            .itemid,
                                                    image:
                                                        beautyitemsgrid[index]
                                                            .image,
                                                    name: beautyitemsgrid[index]
                                                        .name,
                                                    sold: beautyitemsgrid[index]
                                                        .sold,
                                                    source: 'beautyitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: beautyitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : beautyitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        beautyitemsgrid[index]
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
                                                                  beautyitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                beautyitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              beautyitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  beautyitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  beautyitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                beautyitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              beautyitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  beautyitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  beautyitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                beautyitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  beautyitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  beautyitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(beautyitemsgrid[index].price.toString()) - double.parse(beautyitemsgrid[index].saleprice.toString())) / double.parse(beautyitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: beautyitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  electronicsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2782.PNG',
                                            category: 'Electronics',
                                            subcategory:
                                                categoryList[0].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2782.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  electronicsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Electronics',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2782.PNG',
                                                  category: 'Electronics',
                                                  subcategory: categoryList[0]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  electronicsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: electronicsitemsgrid.length > 20
                                ? 20
                                : electronicsitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        electronicsitemsgrid[
                                                                index]
                                                            .itemid,
                                                    image: electronicsitemsgrid[
                                                            index]
                                                        .image,
                                                    name: electronicsitemsgrid[
                                                            index]
                                                        .name,
                                                    sold: electronicsitemsgrid[
                                                            index]
                                                        .sold,
                                                    source:
                                                        'electronicsitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl:
                                                    electronicsitemsgrid[index]
                                                            .image
                                                            .isEmpty
                                                        ? SpinKitDoubleBounce(
                                                            color: Colors
                                                                .deepOrange)
                                                        : electronicsitemsgrid[
                                                                index]
                                                            .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        electronicsitemsgrid[
                                                                index]
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
                                                                  electronicsitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                electronicsitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              electronicsitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  electronicsitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  electronicsitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                electronicsitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              electronicsitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  electronicsitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  electronicsitemsgrid[index]
                                                      .name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                electronicsitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  electronicsitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  electronicsitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(electronicsitemsgrid[index].price.toString()) - double.parse(electronicsitemsgrid[index].saleprice.toString())) / double.parse(electronicsitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: electronicsitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  womenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2787.PNG',
                                            category: 'Women',
                                            subcategory:
                                                categoryList[7].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2787.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  womenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Women',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2787.PNG',
                                                  category: 'Women',
                                                  subcategory: categoryList[7]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  womenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: womenitemsgrid.length > 20
                                ? 20
                                : womenitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        womenitemsgrid[index]
                                                            .itemid,
                                                    image: womenitemsgrid[index]
                                                        .image,
                                                    name: womenitemsgrid[index]
                                                        .name,
                                                    sold: womenitemsgrid[index]
                                                        .sold,
                                                    source: 'womenitemgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: womenitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : womenitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        womenitemsgrid[index]
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
                                                                  womenitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                womenitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              womenitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  womenitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  womenitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                womenitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              womenitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  womenitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  womenitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                womenitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  womenitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  womenitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(womenitemsgrid[index].price.toString()) - double.parse(womenitemsgrid[index].saleprice.toString())) / double.parse(womenitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: womenitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  homeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2793.PNG',
                                            category: 'Home',
                                            subcategory:
                                                categoryList[5].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2793.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  homeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Home',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2793.PNG',
                                                  category: 'Home',
                                                  subcategory: categoryList[5]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  homeitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: homeitemsgrid.length > 20
                                ? 20
                                : homeitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid: homeitemsgrid[index]
                                                        .itemid,
                                                    image: homeitemsgrid[index]
                                                        .image,
                                                    name: homeitemsgrid[index]
                                                        .name,
                                                    sold: homeitemsgrid[index]
                                                        .sold,
                                                    source: 'homeitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: homeitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : homeitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        homeitemsgrid[index]
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
                                                                  homeitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                homeitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              homeitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  homeitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  homeitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                homeitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              homeitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  homeitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  homeitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                homeitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  homeitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  homeitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(homeitemsgrid[index].price.toString()) - double.parse(homeitemsgrid[index].saleprice.toString())) / double.parse(homeitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: homeitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  booksitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2783.PNG',
                                            category: 'Books',
                                            subcategory:
                                                categoryList[3].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2783.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  booksitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Books',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2783.PNG',
                                                  category: 'Books',
                                                  subcategory: categoryList[3]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  booksitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: booksitemsgrid.length > 20
                                ? 20
                                : booksitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        booksitemsgrid[index]
                                                            .itemid,
                                                    image: booksitemsgrid[index]
                                                        .image,
                                                    name: booksitemsgrid[index]
                                                        .name,
                                                    sold: booksitemsgrid[index]
                                                        .sold,
                                                    source: 'booksitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: booksitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : booksitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        booksitemsgrid[index]
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
                                                                  booksitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                booksitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              booksitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  booksitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  booksitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                booksitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              booksitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  booksitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  booksitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                booksitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  booksitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  booksitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(booksitemsgrid[index].price.toString()) - double.parse(booksitemsgrid[index].saleprice.toString())) / double.parse(booksitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: booksitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  luxuryitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2790.PNG',
                                            category: 'Luxury',
                                            subcategory:
                                                categoryList[11].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2790.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  luxuryitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Luxury',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2790.PNG',
                                                  category: 'Luxury',
                                                  subcategory: categoryList[11]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  luxuryitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: luxuryitemsgrid.length > 20
                                ? 20
                                : luxuryitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        luxuryitemsgrid[index]
                                                            .itemid,
                                                    image:
                                                        luxuryitemsgrid[index]
                                                            .image,
                                                    name: luxuryitemsgrid[index]
                                                        .name,
                                                    sold: luxuryitemsgrid[index]
                                                        .sold,
                                                    source: 'booksitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: luxuryitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : luxuryitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        luxuryitemsgrid[index]
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
                                                                  luxuryitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                luxuryitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              luxuryitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  luxuryitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  luxuryitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                luxuryitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              luxuryitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  luxuryitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  luxuryitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                luxuryitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  luxuryitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  luxuryitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(luxuryitemsgrid[index].price.toString()) - double.parse(luxuryitemsgrid[index].saleprice.toString())) / double.parse(luxuryitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: luxuryitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  kidsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2794.PNG',
                                            category: 'Kids',
                                            subcategory:
                                                categoryList[12].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2794.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  kidsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Kids',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2794.PNG',
                                                  category: 'Kids',
                                                  subcategory: categoryList[12]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  kidsitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: kidsitemsgrid.length > 20
                                ? 20
                                : kidsitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid: kidsitemsgrid[index]
                                                        .itemid,
                                                    image: kidsitemsgrid[index]
                                                        .image,
                                                    name: kidsitemsgrid[index]
                                                        .name,
                                                    sold: kidsitemsgrid[index]
                                                        .sold,
                                                    source: 'kidsitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: kidsitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : kidsitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        kidsitemsgrid[index]
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
                                                                  kidsitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                kidsitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              kidsitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  kidsitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  kidsitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                kidsitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              kidsitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  kidsitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  kidsitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                kidsitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  kidsitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  kidsitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(kidsitemsgrid[index].price.toString()) - double.parse(kidsitemsgrid[index].saleprice.toString())) / double.parse(kidsitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: kidsitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  toysitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2791.PNG',
                                            category: 'Toys',
                                            subcategory:
                                                categoryList[9].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2791.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  toysitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Toys',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2791.PNG',
                                                  category: 'Toys',
                                                  subcategory: categoryList[12]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  toysitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: toysitemsgrid.length > 20
                                ? 20
                                : toysitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 2,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid: toysitemsgrid[index]
                                                        .itemid,
                                                    image: toysitemsgrid[index]
                                                        .image,
                                                    name: toysitemsgrid[index]
                                                        .name,
                                                    sold: toysitemsgrid[index]
                                                        .sold,
                                                    source: 'toysitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: toysitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : toysitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        toysitemsgrid[index]
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
                                                                  toysitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                toysitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              toysitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  toysitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  toysitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                toysitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              toysitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  toysitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  toysitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                toysitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  toysitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  toysitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(toysitemsgrid[index].price.toString()) - double.parse(toysitemsgrid[index].saleprice.toString())) / double.parse(toysitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: toysitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                  gardenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetail(
                                            categoryimage:
                                                'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2788.PNG',
                                            category: 'Garden',
                                            subcategory:
                                                categoryList[6].subcategories,
                                          )),
                                );
                              },
                              child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                    'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2788.PNG',
                                    fit: BoxFit.contain),
                              )))
                      : SliverToBoxAdapter(),
                  gardenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16, top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    enableFeedback: true,
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //       builder: (context) => CategoryDynamic(
                                      //             category: 'Electronics',
                                      //           )),
                                      // );
                                    },
                                    child: Text(
                                      'Top Picks in Garden',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetail(
                                                  categoryimage:
                                                      'https://sellshipcdn.ams3.cdn.digitaloceanspaces.com/banners/IMG_2788.PNG',
                                                  category: 'Garden',
                                                  subcategory: categoryList[6]
                                                      .subcategories,
                                                )),
                                      );
                                    },
                                    enableFeedback: true,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.deepOrange),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text('See All',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.deepOrange,
                                            fontSize: 14.0,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      : SliverToBoxAdapter(),
                  gardenitemsgrid.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: gardenitemsgrid.length > 20
                                ? 20
                                : gardenitemsgrid.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return new Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  height: 90,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Details(
                                                    itemid:
                                                        gardenitemsgrid[index]
                                                            .itemid,
                                                    image:
                                                        gardenitemsgrid[index]
                                                            .image,
                                                    name: gardenitemsgrid[index]
                                                        .name,
                                                    sold: gardenitemsgrid[index]
                                                        .sold,
                                                    source: 'gardenitemsgrid')),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: gardenitemsgrid[index]
                                                        .image
                                                        .isEmpty
                                                    ? SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange)
                                                    : gardenitemsgrid[index]
                                                        .image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: favourites != null
                                                ? favourites.contains(
                                                        gardenitemsgrid[index]
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
                                                                  gardenitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                gardenitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              gardenitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  gardenitemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                          radius: 16,
                                                          backgroundColor:
                                                              Colors.deepOrange,
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .heart,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ))
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
                                                                  gardenitemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                gardenitemsgrid[
                                                                        index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              gardenitemsgrid[
                                                                          index]
                                                                      .likes =
                                                                  gardenitemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(
                                                                        url),
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
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.blueGrey
                                                                    .shade50,
                                                            child: CircleAvatar(
                                                              radius: 15,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                FeatherIcons
                                                                    .heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            )))
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.blueGrey.shade50,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        FeatherIcons.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  gardenitemsgrid[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                gardenitemsgrid[index]
                                                            .saleprice !=
                                                        null
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ' +
                                                                  gardenitemsgrid[
                                                                          index]
                                                                      .saleprice,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            new TextSpan(
                                                              text: '\nAED ' +
                                                                  gardenitemsgrid[
                                                                          index]
                                                                      .price
                                                                      .toString(),
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: ' -' +
                                                                  (((double.parse(gardenitemsgrid[index].price.toString()) - double.parse(gardenitemsgrid[index].saleprice.toString())) / double.parse(gardenitemsgrid[index].price.toString())) *
                                                                          100)
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%',
                                                              style:
                                                                  new TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Text.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: 'AED ',
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: gardenitemsgrid[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                              ],
                                            )),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                      : SliverToBoxAdapter(),
                ],
              )
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                ),
              ));
  }

  String view = 'home';

  List<Stores> followingusers = List<Stores>();

  followuser(user) async {
    Stores foluser = user;
    var userid = await storage.read(key: 'userid');
    if (followingusers.contains(user)) {
      setState(() {
        followingusers.remove(foluser);
      });
      var followurl = 'https://api.sellship.co/api/follow/' +
          userid +
          '/' +
          foluser.storeid;

      final followresponse = await http.get(Uri.parse(followurl));
      if (followresponse.statusCode == 200) {
        print('UnFollowed');
      }
    } else {
      setState(() {
        followingusers.add(foluser);
      });
      var followurl = 'https://api.sellship.co/api/follow/' +
          userid +
          '/' +
          foluser.storeid;

      final followresponse = await http.get(Uri.parse(followurl));
      if (followresponse.statusCode == 200) {
        print('Followed');
      }
    }
    setState(() {
      followingusers = followingusers;
    });
  }

  List<Item> foryoulist = List<Item>();
  List<Item> foryouscroll = List<Item>();

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  TextEditingController searchcontrollerr = TextEditingController();
}
