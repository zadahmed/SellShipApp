import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentlyAdded extends StatefulWidget {
  @override
  RecentlyAddedState createState() => RecentlyAddedState();
}

class RecentlyAddedState extends State<RecentlyAdded> {
  String country;
  String currency;

  final scaffoldState = GlobalKey<ScaffoldState>();

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
    fetchRecentlyAdded(skip, limit);
  }

  Widget loadingwidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                            width: MediaQuery.of(context).size.width / 2 - 30,
                            height: 150.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 30,
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

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    print(url);

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
        image: jsonbody[i]['image'],
        userid: jsonbody[i]['userid'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }

    setState(() {
      itemsgrid = itemsgrid;
      loading = false;
    });

    return itemsgrid;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedFilter = "Recently Added";
      _FilterLoad = "Recently Added";
      skip = 0;
      limit = 20;
      loading = true;
    });
    itemsgrid.clear();
    getfavourites();
    readstorage();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  _scrollListener() {
    _scrollController.position.isScrollingNotifier.addListener(() {
      if (_scrollController.position.pixels >= 1000) {
        setState(() {
          showfloatingbutton = true;
        });
      } else {
        setState(() {
          showfloatingbutton = false;
        });
      }
    });
  }

  var showfloatingbutton = false;

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
  final storage = new FlutterSecureStorage();

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

  var loading = true;

  String _FilterLoad = "Recently Added";
  String _selectedFilter = "Recently Added";

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading == false ? home(context) : loadingwidget(context),
      floatingActionButton: showfloatingbutton == true
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 100), curve: Curves.ease);
              },
            )
          : Container(),
    );
  }

  List<Item> itemsgrid = [];

  var skip;
  var limit;

  Widget home(BuildContext context) {
    EasyRefresh.custom(
      topBouncing: true,
      footer: MaterialFooter(
        enableInfiniteLoad: true,
        enableHapticFeedback: true,
      ),
      slivers: <Widget>[
        SliverStaggeredGrid.countBuilder(
          crossAxisCount: 2,
          itemCount: itemsgrid.length,
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          itemBuilder: (BuildContext context, index) {
            return new Padding(
              padding: EdgeInsets.all(7),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Details(
                              itemid: itemsgrid[index].itemid,
                              sold: itemsgrid[index].sold,
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
                            height: 215,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                height: 200,
                                width: 300,
                                fadeInDuration: Duration(microseconds: 5),
                                imageUrl: itemsgrid[index].image.isEmpty
                                    ? SpinKitDoubleBounce(
                                        color: Colors.deepOrange)
                                    : itemsgrid[index].image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    SpinKitDoubleBounce(
                                        color: Colors.deepOrange),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          itemsgrid[index].sold == true
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent
                                          .withOpacity(0.8),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
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
                              : favourites != null
                                  ? favourites.contains(itemsgrid[index].itemid)
                                      ? InkWell(
                                          enableFeedback: true,
                                          onTap: () async {
                                            var userid = await storage.read(
                                                key: 'userid');

                                            if (userid != null) {
                                              var url =
                                                  'https://api.sellship.co/api/favourite/' +
                                                      userid;

                                              Map<String, String> body = {
                                                'itemid':
                                                    itemsgrid[index].itemid,
                                              };

                                              favourites.remove(
                                                  itemsgrid[index].itemid);
                                              setState(() {
                                                favourites = favourites;
                                                itemsgrid[index].likes =
                                                    itemsgrid[index].likes - 1;
                                              });
                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                              } else {
                                                print(response.statusCode);
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Please Login to use Favourites');
                                            }
                                          },
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.deepPurple,
                                                    child: Icon(
                                                      FontAwesome.heart,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ))))
                                      : InkWell(
                                          enableFeedback: true,
                                          onTap: () async {
                                            var userid = await storage.read(
                                                key: 'userid');

                                            if (userid != null) {
                                              var url =
                                                  'https://api.sellship.co/api/favourite/' +
                                                      userid;

                                              Map<String, String> body = {
                                                'itemid':
                                                    itemsgrid[index].itemid,
                                              };

                                              favourites
                                                  .add(itemsgrid[index].itemid);
                                              setState(() {
                                                favourites = favourites;
                                                itemsgrid[index].likes =
                                                    itemsgrid[index].likes + 1;
                                              });
                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                              } else {
                                                print(response.statusCode);
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Please Login to use Favourites');
                                            }
                                          },
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Feather.heart,
                                                      color: Colors.blueGrey,
                                                      size: 16,
                                                    ),
                                                  ))))
                                  : Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Feather.heart,
                                              color: Colors.blueGrey,
                                              size: 16,
                                            ),
                                          ))),
                        ],
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ),
            );
          },
        )
      ],
      onLoad: () async {
        if (_FilterLoad == 'Recently Added') {
          _getmoreRecentData();
        } else if (_FilterLoad == 'Lowest Price') {
          _getmorelowestprice();
        } else if (_FilterLoad == 'Highest Price') {
          _getmorehighestprice();
        } else if (_FilterLoad == 'Brand') {
          getmorebrands(brand);
        } else if (_FilterLoad == 'Price') {
          getmorePrice(minprice, maxprice);
        } else if (_FilterLoad == 'Condition') {
          getmorecondition(condition);
        }
      },
    );
  }

  String brand;
  String minprice;
  String maxprice;
  String condition;

  Future<List<Item>> getmorecondition(String condition) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/condition/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorePrice(String minprice, String maxprice) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/price/' +
        country +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

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
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorebrands(String brand) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/brand/' +
        country +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

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
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/highestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

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
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/lowestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

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
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
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
          image: jsonbody[i]['image'],
          userid: jsonbody[i]['userid'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }

      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }
    } else {
      print(response.statusCode);
    }
  }
}
