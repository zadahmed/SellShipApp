import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Filtered extends StatefulWidget {
  final String filter;
  final String brand;
  final String condition;
  final String minprice;
  final String maxprice;

  Filtered(
      {Key key,
      this.filter,
      this.brand,
      this.condition,
      this.minprice,
      this.maxprice})
      : super(key: key);
  @override
  FilteredState createState() => FilteredState();
}

class FilteredState extends State<Filtered> {
  String country;
  String currency;

  final scaffoldState = GlobalKey<ScaffoldState>();

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
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
  }

  Future<List<Item>> fetchbrands(String brand) async {
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

  Future<List<Item>> fetchCondition(String condition) async {
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

  Future<List<Item>> fetchPrice(String minprice, String maxprice) async {
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

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
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
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
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
  }

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

    if (_selectedFilter == 'Recently Added') {
      fetchRecentlyAdded(skip, limit);
    } else if (_selectedFilter == 'Lowest Price') {
      fetchLowestPrice(skip, limit);
    } else if (_selectedFilter == 'Highest Price') {
      fetchHighestPrice(skip, limit);
    } else if (_selectedFilter == 'Brand') {
      fetchbrands(brand);
    } else if (_selectedFilter == 'Price') {
      fetchPrice(minprice, maxprice);
    } else if (_selectedFilter == 'Condition') {
      fetchCondition(condition);
    }
  }

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/homeitems/' + country;

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
      loading = false;
      itemsgrid = itemsgrid;
    });

    return itemsgrid;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedFilter = widget.filter;
      _FilterLoad = widget.filter;
      brand = widget.brand;
      minprice = widget.minprice;
      maxprice = widget.maxprice;
      condition = widget.condition;
      skip = 0;
      limit = 20;
      loading = true;
    });
    itemsgrid.clear();
    getfavourites();
    readstorage();
    _scrollController.addListener(_scrollListener);
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

  ScrollController _scrollController = ScrollController();

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

  var loading;

  String _FilterLoad;
  String _selectedFilter;

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  PersistentBottomSheetController _bottomsheetcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text(
          'Filter by ' + _selectedFilter,
          style: TextStyle(
              fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          Padding(
            child: InkWell(
              onTap: () {
                _bottomsheetcontroller =
                    scaffoldState.currentState.showBottomSheet((context) {
                  return Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.2, color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      height: 525,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                AppBar(
                                  title: Text('Filter',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(28, 45, 65, 1),
                                      )),
                                  elevation: 0.5,
                                  backgroundColor: Colors.white,
                                  excludeHeaderSemantics: true,
                                  automaticallyImplyLeading: false,
                                  actions: [
                                    Padding(
                                        padding: EdgeInsets.all(15),
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Done',
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 18,
                                                  color: Color.fromRGBO(
                                                      28, 45, 65, 1),
                                                ))))
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            height: 450,
                                            child: ListView(
                                              scrollDirection: Axis.vertical,
                                              children: [
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: InkWell(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              'Sort',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          28,
                                                                          45,
                                                                          65,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Divider()
                                                        ],
                                                      ),
                                                      onTap: () {
                                                        _bottomsheetcontroller
                                                            .setState(() {
                                                          _filter = 'Sort';
                                                        });
                                                      },
                                                    )),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: InkWell(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              'Brand',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          28,
                                                                          45,
                                                                          65,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Divider()
                                                        ],
                                                      ),
                                                      onTap: () async {
                                                        brands.clear();
                                                        var categoryurl =
                                                            'https://api.sellship.co/api/getallbrands';
                                                        final categoryresponse =
                                                            await http.get(
                                                                categoryurl);
                                                        if (categoryresponse
                                                                .statusCode ==
                                                            200) {
                                                          var categoryrespons =
                                                              json.decode(
                                                                  categoryresponse
                                                                      .body);

                                                          for (int i = 0;
                                                              i <
                                                                  categoryrespons
                                                                      .length;
                                                              i++) {
                                                            brands.add(
                                                                categoryrespons[
                                                                    i]);
                                                          }
                                                          _bottomsheetcontroller
                                                              .setState(() {
                                                            brands = brands;
                                                          });
                                                        } else {
                                                          print(categoryresponse
                                                              .statusCode);
                                                        }
                                                        _bottomsheetcontroller
                                                            .setState(() {
                                                          _filter = 'Brand';
                                                        });
                                                      },
                                                    )),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: InkWell(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              'Condition',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          28,
                                                                          45,
                                                                          65,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Divider()
                                                        ],
                                                      ),
                                                      onTap: () {
                                                        _bottomsheetcontroller
                                                            .setState(() {
                                                          _filter = 'Condition';
                                                        });
                                                      },
                                                    )),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: InkWell(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              'Price',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          28,
                                                                          45,
                                                                          65,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Divider()
                                                        ],
                                                      ),
                                                      onTap: () {
                                                        _bottomsheetcontroller
                                                            .setState(() {
                                                          _filter = 'Price';
                                                        });
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                          filters(context)
                                        ]))
                              ])));
                });
              },
              child:
                  SvgPicture.asset('assets/bottomnavbar/sound-module-fill.svg'),
            ),
            padding: EdgeInsets.only(right: 10),
          )
        ],
        backgroundColor: Colors.white,
      ),
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

  String _filter = 'Sort';

  Widget filters(BuildContext context) {
    if (_filter == 'Sort') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 2,
              ),
              ListTile(
                title: Text(
                  'Sort by Price Low to High',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Filtered(
                        filter: 'Lowest Price',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Sort by Price High to Low',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Filtered(
                        filter: 'Highest Price',
                      ),
                    ),
                  );
                },
              ),
            ],
          ));
    } else if (_filter == 'Condition') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                      height: 450,
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: conditions.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();

                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          Filtered(
                                    filter: 'Condition',
                                    condition: conditions[index],
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: conditions[index] != null
                                  ? Text(
                                      conditions[index],
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text('sd'),
                            ),
                          );
                        },
                      ))
                ],
              ),
            ),
          ));
    } else if (_filter == 'Price') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: ListTile(
                          title: Text(
                            'Minimum Price',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                              width: 100,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: minpricecontroller,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                      labelText: "Price " + currency,
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                      focusColor: Colors.black,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                                ),
                              )))),
                  SizedBox(
                    height: 2,
                  ),
                  Center(
                      child: ListTile(
                          title: Text(
                            'Maximum Price',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                              width: 100,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: maxpricecontroller,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                      labelText: "Price " + currency,
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                      focusColor: Colors.black,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                                ),
                              )))),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();

                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        Filtered(
                                  filter: 'Price',
                                  minprice: minpricecontroller.text,
                                  maxprice: maxpricecontroller.text,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.deepOrangeAccent),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Filter',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ),
                          ))),
                ],
              ))));
    } else if (_filter == 'Brand') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
//                  height: 600,
                    child: AlphabetListScrollView(
                  showPreview: true,
                  strList: brands,
                  indexedHeight: (i) {
                    return 40;
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Filtered(
                              filter: 'Brand',
                              brand: brands[index],
                            ),
                          ),
                        );

                        fetchbrands(brands[index]);
                      },
                      child: ListTile(
                        title: brands[index] != null
                            ? Text(
                                brands[index],
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                ),
                              )
                            : Text('No Brand'),
                      ),
                    );
                  },
                ))
              ],
            ),
          ));
    }
  }

  List<String> brands = List<String>();

  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();

  List<Item> itemsgrid = [];
  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];

  String brand;

  String condition;

  var skip;
  var limit;

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

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Widget home(BuildContext context) {
    return EasyRefresh.custom(
      topBouncing: false,
      footer: BallPulseFooter(
          color: Colors.deepPurpleAccent, enableInfiniteLoad: true),
      slivers: <Widget>[
        SliverStaggeredGrid(
          gridDelegate: SliverStaggeredGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            crossAxisCount: 2,
            staggeredTileCount: itemsgrid.length,
            staggeredTileBuilder: (index) => new StaggeredTile.fit(1),
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index != 0 && index % 8 == 0) {
                return Platform.isIOS == true
                    ? Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: 300,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2, color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: NativeAdmob(
                            adUnitID: _iosadUnitID,
                            controller: _controller,
                          ),
                        ))
                    : Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: 300,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2, color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
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
                              height: 220,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration(microseconds: 5),
                                  imageUrl: itemsgrid[index].image.isEmpty
                                      ? SpinKitChasingDots(
                                          color: Colors.deepOrange)
                                      : itemsgrid[index].image,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      SpinKitChasingDots(
                                          color: Colors.deepOrange),
                                  errorWidget: (context, url, error) =>
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
                                      color: Colors.black26.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
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
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    Numeral(itemsgrid[index]
                                                            .likes)
                                                        .value(),
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                              ),
                                            ),
                                            onTap: () async {
                                              if (favourites.contains(
                                                  itemsgrid[index].itemid)) {
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
                                                        itemsgrid[index].likes -
                                                            1;
                                                  });
                                                  final response = await http
                                                      .post(url, body: body);

                                                  if (response.statusCode ==
                                                      200) {
                                                  } else {
                                                    print(response.statusCode);
                                                  }
                                                } else {
                                                  showInSnackBar(
                                                      'Please Login to use Favourites');
                                                }
                                              } else {
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

                                                  favourites.add(
                                                      itemsgrid[index].itemid);
                                                  setState(() {
                                                    favourites = favourites;
                                                    itemsgrid[index].likes =
                                                        itemsgrid[index].likes +
                                                            1;
                                                  });
                                                  final response = await http
                                                      .post(url, body: body);

                                                  if (response.statusCode ==
                                                      200) {
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
                                                    Feather.message_circle,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    Numeral(itemsgrid[index]
                                                            .comments)
                                                        .value(),
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                                itemsgrid[index]
                                                                    .itemid)),
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
                            itemsgrid[index].sold == true
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.deepPurpleAccent
                                          .withOpacity(0.8),
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
                                    ? favourites
                                            .contains(itemsgrid[index].itemid)
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
                                                      itemsgrid[index].likes -
                                                          1;
                                                });
                                                final response = await http
                                                    .post(url, body: body);

                                                if (response.statusCode ==
                                                    200) {
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

                                                favourites.add(
                                                    itemsgrid[index].itemid);
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes +
                                                          1;
                                                });
                                                final response = await http
                                                    .post(url, body: body);

                                                if (response.statusCode ==
                                                    200) {
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
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          child: Text(
                            itemsgrid[index].name,
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color.fromRGBO(28, 45, 65, 1),
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
                                        itemsgrid[index].price.toString(),
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
                                    itemsgrid[index].price.toString(),
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
                    if (favourites.contains(itemsgrid[index].itemid)) {
                      var userid = await storage.read(key: 'userid');

                      if (userid != null) {
                        var url =
                            'https://api.sellship.co/api/favourite/' + userid;

                        Map<String, String> body = {
                          'itemid': itemsgrid[index].itemid,
                        };

                        final response = await http.post(url, body: body);

                        if (response.statusCode == 200) {
                          var jsondata = json.decode(response.body);

                          favourites.clear();
                          for (int i = 0; i < jsondata.length; i++) {
                            favourites.add(jsondata[i]['_id']['\$oid']);
                          }
                          setState(() {
                            favourites = favourites;
                            itemsgrid[index].likes = itemsgrid[index].likes - 1;
                          });
                        } else {
                          print(response.statusCode);
                        }
                      } else {
                        showInSnackBar('Please Login to use Favourites');
                      }
                    } else {
                      var userid = await storage.read(key: 'userid');

                      if (userid != null) {
                        var url =
                            'https://api.sellship.co/api/favourite/' + userid;

                        Map<String, String> body = {
                          'itemid': itemsgrid[index].itemid,
                        };

                        final response = await http.post(url, body: body);

                        if (response.statusCode == 200) {
                          var jsondata = json.decode(response.body);

                          favourites.clear();
                          for (int i = 0; i < jsondata.length; i++) {
                            favourites.add(jsondata[i]['_id']['\$oid']);
                          }
                          setState(() {
                            favourites = favourites;
                            itemsgrid[index].likes = itemsgrid[index].likes + 1;
                          });
                        } else {
                          print(response.statusCode);
                        }
                      } else {
                        showInSnackBar('Please Login to use Favourites');
                      }
                    }
                  },
                ),
              );
            },
            childCount: itemsgrid.length,
          ),
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

  String minprice;
  String maxprice;

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

    var url = 'https://api.sellship.co/api/homeitems/' + country;

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
