import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/blogs.dart';
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
        body: CustomScrollView(
          slivers: [
            electronicsitemsgrid.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                        padding:
                            EdgeInsets.only(left: 16, bottom: 10, right: 16),
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
                                'Top Picks in Electronics',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   CupertinoPageRoute(
                                //       builder: (context) => CategoryDynamic(
                                //             category: 'Electronics',
                                //           )),
                                // );
                              },
                              enableFeedback: true,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(5)),
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
                    height: 330,
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
                            width: MediaQuery.of(context).size.width / 2 - 20,
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
                                                  electronicsitemsgrid[index]
                                                      .itemid,
                                              image: electronicsitemsgrid[index]
                                                  .image,
                                              name: electronicsitemsgrid[index]
                                                  .name,
                                              sold: electronicsitemsgrid[index]
                                                  .sold,
                                              source: 'electronicsitemsgrid')),
                                    );
                                  },
                                  child: Stack(children: <Widget>[
                                    Container(
                                      height: 250,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Hero(
                                          tag:
                                              'electronicsitemsgrid${electronicsitemsgrid[index].itemid}',
                                          child: CachedNetworkImage(
                                            height: 200,
                                            width: 300,
                                            fadeInDuration:
                                                Duration(microseconds: 5),
                                            imageUrl: electronicsitemsgrid[
                                                        index]
                                                    .image
                                                    .isEmpty
                                                ? SpinKitDoubleBounce(
                                                    color: Colors.deepOrange)
                                                : electronicsitemsgrid[index]
                                                    .image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitDoubleBounce(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: favourites != null
                                          ? favourites.contains(
                                                  electronicsitemsgrid[index]
                                                      .itemid)
                                              ? InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
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
                                                        favourites = favourites;
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
                                                              Uri.parse(url),
                                                              body: json.encode(
                                                                  body));
                                                      if (response.statusCode ==
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
                                                      FontAwesomeIcons.heart,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ))
                                              : InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
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
                                                        favourites = favourites;
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
                                                              Uri.parse(url),
                                                              body: json.encode(
                                                                  body));

                                                      if (response.statusCode ==
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
                                                      backgroundColor: Colors
                                                          .blueGrey.shade50,
                                                      child: CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Icon(
                                                          FeatherIcons.heart,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 16,
                                                        ),
                                                      )))
                                          : CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  Colors.blueGrey.shade50,
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.white,
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
                                            electronicsitemsgrid[index].name,
                                            overflow: TextOverflow.ellipsis,
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
                                                        style: new TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                        text: ' -' +
                                                            (((double.parse(electronicsitemsgrid[index].price.toString()) -
                                                                            double.parse(electronicsitemsgrid[index]
                                                                                .saleprice
                                                                                .toString())) /
                                                                        double.parse(electronicsitemsgrid[index]
                                                                            .price
                                                                            .toString())) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            '%',
                                                        style: new TextStyle(
                                                          color: Colors.red,
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
                                                        style: new TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                        text:
                                                            electronicsitemsgrid[
                                                                    index]
                                                                .price
                                                                .toString(),
                                                        style: new TextStyle(
                                                            color: Colors.black,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        );
                      },
                    ),
                  ))
                : SliverToBoxAdapter(),
          ],
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
