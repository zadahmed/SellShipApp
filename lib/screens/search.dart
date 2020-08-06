import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:typed_data';
import 'package:SellShip/screens/comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class Search extends StatefulWidget {
  final String text;
  Search({Key key, this.text}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Item> itemsgrid = [];

  var skip;
  var limit;
  var text;

  ScrollController _scrollController = ScrollController();

  LatLng position;
  String country;

  final storage = new FlutterSecureStorage();
  bool loading;

  bool gridtoggle;

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

  var currency;
  String brand;
  String minprice;
  String maxprice;
  String condition;
  String category;
  String subcategory;

  @override
  void initState() {
    super.initState();

    var q = widget.text.replaceAll('/', ' ');
    q = q.replaceAll('"', '');
    q = q.replaceAll('-', '');
    print(q);
    setState(() {
      skip = 0;
      limit = 20;
      text = q;
      searchcontroller.text = text;
      loading = true;
    });
    getfavourites();
    readstorage();

    _scrollController.addListener(() {
      var triggerFetchMoreSize = _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels == triggerFetchMoreSize) {
        if (_selectedFilter == 'Near me') {
          _getmorenearme();
        } else if (_selectedFilter == 'Recently Added') {
          _getmoreData();
        } else if (_selectedFilter == 'Below 100') {
          _getmorebelowhundred();
        } else if (_selectedFilter == 'Lowest Price') {
          _getmorelowestprice();
        } else if (_selectedFilter == 'Highest Price') {
          _getmorehighestprice();
        } else if (_selectedFilter == 'Brands') {
          getmorebrands(brand);
        } else if (_selectedFilter == 'Price') {
          getmorePrice(minprice, maxprice);
        } else if (_selectedFilter == 'Condition') {
          getmorecondition(condition);
        }
      }
    });
  }

  _getmoreData() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var jsondata in jsonbody) {
      var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsondata['_id']['\$oid'],
        name: jsondata['name'],
        date: dateuploaded,
        likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
        comments:
            jsondata['comments'] == null ? 0 : jsondata['comments'].length,
        image: jsondata['image'],
        price: jsondata['price'].toString(),
        category: jsondata['category'],
        sold: jsondata['sold'] == null ? false : jsondata['sold'],
      );
      itemsgrid.add(item);
    }
    if (itemsgrid == null) {
      print('Empty');
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var countr = await storage.read(key: 'country');
    if (countr.trim().toLowerCase() == 'united arab emirates') {
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
      onSearch();
      position = LatLng(double.parse(latitude), double.parse(longitude));
    });
  }

  TextEditingController searchcontroller = new TextEditingController();

  onSearch() async {
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var jsondata in jsonbody) {
      var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsondata['_id']['\$oid'],
        name: jsondata['name'],
        date: dateuploaded,
        likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
        comments:
            jsondata['comments'] == null ? 0 : jsondata['comments'].length,
        image: jsondata['image'],
        price: jsondata['price'].toString(),
        category: jsondata['category'],
        sold: jsondata['sold'] == null ? false : jsondata['sold'],
      );
      itemsgrid.add(item);
    }

    setState(() {
      itemsgrid = itemsgrid;
      loading = false;
    });
  }

  onSearche(String texte) async {
    itemsgrid.clear();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => Search(
          text: texte,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(child: SpinKitChasingDots(color: Colors.deepOrange)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: loading == false
                ? CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        snap: false,
                        floating: true,
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    controller: searchcontroller,
                                    onSubmitted: onSearche,
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
                        iconTheme: IconThemeData(color: Colors.black),
                        expandedHeight: 100.0,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          centerTitle: true,
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 65.0),
                                  child: filtersort(context)),
                            ],
                          ),
                        ),
                      ),
                      itemsgrid.isNotEmpty
                          ? (gridtoggle == true
                              ? SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.62,
                                    mainAxisSpacing: 1.0,
                                    crossAxisSpacing: 1.0,
                                    crossAxisCount: 2,
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
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        Details(
                                                            itemid:
                                                                itemsgrid[index]
                                                                    .itemid),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      var begin =
                                                          Offset(0.0, 1.0);
                                                      var end = Offset.zero;
                                                      var curve = Curves.ease;

                                                      var tween = Tween(
                                                              begin: begin,
                                                              end: end)
                                                          .chain(CurveTween(
                                                              curve: curve));

                                                      return SlideTransition(
                                                        position: animation
                                                            .drive(tween),
                                                        child: child,
                                                      );
                                                    },
                                                  ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 0.2,
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
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
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            fadeInDuration:
                                                                Duration(
                                                                    microseconds:
                                                                        10),
                                                            imageUrl:
                                                                itemsgrid[index]
                                                                    .image,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                SpinKitChasingDots(
                                                                    color: Colors
                                                                        .deepOrange),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                          ),
                                                        ),
                                                      ),
                                                      itemsgrid[index].sold ==
                                                              true
                                                          ? Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Container(
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
                                                                          'Helvetica',
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ))
                                                          : Container(),
                                                    ],
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              favourites != null
                                                                  ? favourites.contains(
                                                                          itemsgrid[index]
                                                                              .itemid)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            var userid =
                                                                                await storage.read(key: 'userid');

                                                                            if (userid !=
                                                                                null) {
                                                                              var url = 'https://api.sellship.co/api/favourite/' + userid;

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
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            FontAwesome.heart,
                                                                            color:
                                                                                Colors.deepPurple,
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            var userid =
                                                                                await storage.read(key: 'userid');

                                                                            if (userid !=
                                                                                null) {
                                                                              var url = 'https://api.sellship.co/api/favourite/' + userid;

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
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Feather.heart,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        )
                                                                  : Icon(
                                                                      Feather
                                                                          .heart,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                itemsgrid[index]
                                                                    .likes
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                  );
                                                                },
                                                                child: Icon(Feather
                                                                    .message_circle),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  itemsgrid[
                                                                          index]
                                                                      .comments
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Container(
                                                            height: 20,
                                                            child: Text(
                                                              itemsgrid[index]
                                                                  .name,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .deepOrange,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  child: Text(
                                                                    itemsgrid[
                                                                            index]
                                                                        .price
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
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
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    if (index != 0 && index % 8 == 0) {
                                      return Platform.isIOS == true
                                          ? Padding(
                                              padding: EdgeInsets.all(15),
                                              child: Container(
                                                height: 350,
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                                ),
                                                child: NativeAdmob(
                                                  adUnitID: _iosadUnitID,
                                                  controller: _controller,
                                                ),
                                              ))
                                          : Padding(
                                              padding: EdgeInsets.all(15),
                                              child: Container(
                                                height: 350,
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(
                                                    bottom: 20.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                                ),
                                                child: NativeAdmob(
                                                  adUnitID: _androidadUnitID,
                                                  controller: _controller,
                                                ),
                                              ));
                                    }
                                    return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                    sold: itemsgrid[index].sold,
                                                    itemid: itemsgrid[index]
                                                        .itemid)),
                                          );
                                        },
                                        onDoubleTap: () async {
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

                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                                var jsondata =
                                                    json.decode(response.body);

                                                favourites.clear();
                                                for (int i = 0;
                                                    i < jsondata.length;
                                                    i++) {
                                                  favourites.add(jsondata[i]
                                                      ['_id']['\$oid']);
                                                }
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes -
                                                          1;
                                                });
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

                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                                var jsondata =
                                                    json.decode(response.body);

                                                favourites.clear();
                                                for (int i = 0;
                                                    i < jsondata.length;
                                                    i++) {
                                                  favourites.add(jsondata[i]
                                                      ['_id']['\$oid']);
                                                }
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes +
                                                          1;
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
                                        child: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 0.2,
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 6.0,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: <Widget>[
                                                  new Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 400,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            fadeInDuration:
                                                                Duration(
                                                                    microseconds:
                                                                        10),
                                                            imageUrl:
                                                                itemsgrid[index]
                                                                    .image,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                SpinKitChasingDots(
                                                                    color: Colors
                                                                        .deepOrange),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                          ),
                                                        ),
                                                      ),
                                                      itemsgrid[index].sold ==
                                                              true
                                                          ? Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Container(
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
                                                                          'Helvetica',
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ))
                                                          : Container(),
                                                    ],
                                                  ),
                                                  SizedBox(height: 2.0),
                                                  new Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0,
                                                                  right: 10.0,
                                                                  bottom: 10.0,
                                                                  top: 5),
                                                          child: new Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    favourites !=
                                                                            null
                                                                        ? favourites.contains(itemsgrid[index].itemid)
                                                                            ? InkWell(
                                                                                onTap: () async {
                                                                                  var userid = await storage.read(key: 'userid');

                                                                                  if (userid != null) {
                                                                                    var url = 'https://api.sellship.co/api/favourite/' + userid;

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
                                                                                },
                                                                                child: Icon(
                                                                                  FontAwesome.heart,
                                                                                  color: Colors.deepPurple,
                                                                                ),
                                                                              )
                                                                            : InkWell(
                                                                                onTap: () async {
                                                                                  var userid = await storage.read(key: 'userid');

                                                                                  if (userid != null) {
                                                                                    var url = 'https://api.sellship.co/api/favourite/' + userid;

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
                                                                                },
                                                                                child: Icon(
                                                                                  Feather.heart,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              )
                                                                        : Icon(
                                                                            Feather.heart,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      itemsgrid[index]
                                                                              .likes
                                                                              .toString() +
                                                                          ' likes',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                        );
                                                                      },
                                                                      child: Icon(
                                                                          Feather
                                                                              .message_circle),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        itemsgrid[index].comments.toString() +
                                                                            ' comments',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        itemsgrid[index]
                                                                            .name,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
//                                                            overflow:
//                                                                TextOverflow
//                                                                    .ellipsis,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        currency +
                                                                            ' ' +
                                                                            itemsgrid[index].price.toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              17,
                                                                          color:
                                                                              Colors.deepOrange,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Icon(
                                                                          Icons
                                                                              .access_time,
                                                                          size:
                                                                              12,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          'Uploaded ${itemsgrid[index].date}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ]))),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            )));
                                  }, childCount: itemsgrid.length),
                                ))
                          : SliverToBoxAdapter(
                              child: Container(
                              height: MediaQuery.of(context).size.height,
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Column(
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                            'Oops! Looks like we can\'t find what you are looking for.\n Try another search!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
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
                            ))
                    ],
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
                          children: [0, 1, 2, 3, 4, 5, 6]
                              .map((_) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
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
                  )));
  }

  String _FilterLoad = "Recently Added";
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
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Recently Added";
                        _FilterLoad = "Recently Added";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      onSearch();
                    },
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
                                    fontFamily: 'Helvetica',
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
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Near Me";
                        _FilterLoad = "Near Me";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      fetchItems(skip, limit);
                    },
                    child: _selectedFilter == "Near Me"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 70,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
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
                            width: 70,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Below 100";
                        _FilterLoad = "Below 100";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      fetchbelowhundred(skip, limit);
                    },
                    child: _selectedFilter == "Below 100"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
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
                            width: 80,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
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
                                    fontFamily: 'Helvetica',
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
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          ),
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.2, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Feather.chevron_down),
                                SizedBox(
                                  height: 2,
                                ),
                                Center(
                                  child: Text(
                                    'Sort',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                ListTile(
                                  title: Text(
                                    'Price Low to High',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Sort';
                                      _FilterLoad = "Lowest Price";
                                      skip = 0;
                                      limit = 20;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    Navigator.of(context).pop();

                                    fetchLowestPrice(skip, limit);
                                  },
                                ),
                                ListTile(
                                  title: Text(
                                    'Price High to Low',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Sort';
                                      _FilterLoad = "Highest Price";
                                      skip = 0;
                                      limit = 20;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    Navigator.of(context).pop();

                                    fetchHighestPrice(skip, limit);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      loadbrands();
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
                                    fontFamily: 'Helvetica',
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
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                          height: 500,
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Feather.chevron_down),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Center(
                                    child: Text(
                                      'Conditions',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
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
                                              setState(() {
                                                _selectedCondition =
                                                    conditions[index];
                                              });

                                              setState(() {
                                                _selectedFilter = 'Condition';
                                                _FilterLoad = "Condition";
                                                condition = _selectedCondition;
                                                skip = 0;
                                                limit = 20;
                                                loading = true;
                                              });
                                              itemsgrid.clear();
                                              Navigator.of(context).pop();

                                              fetchCondition(
                                                  _selectedCondition);
                                            },
                                            child: ListTile(
                                              title: conditions[index] != null
                                                  ? Text(conditions[index])
                                                  : Text('sd'),
                                            ),
                                          );
                                        },
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                    child: _selectedFilter == "Condition"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
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
                            width: 80,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Feather.chevron_down),
                                SizedBox(
                                  height: 2,
                                ),
                                Center(
                                  child: Text(
                                    'Price',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ),
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
                                            width: 200,
                                            padding: EdgeInsets.only(),
                                            child: Center(
                                              child: TextField(
                                                cursorColor: Color(0xFF979797),
                                                controller: minpricecontroller,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Price " + currency,
                                                    alignLabelWithHint: true,
                                                    labelStyle: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                    focusColor: Colors.black,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
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
                                            width: 200,
                                            padding: EdgeInsets.only(),
                                            child: Center(
                                              child: TextField(
                                                cursorColor: Color(0xFF979797),
                                                controller: maxpricecontroller,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Price " + currency,
                                                    alignLabelWithHint: true,
                                                    labelStyle: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                    focusColor: Colors.black,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ))),
                                              ),
                                            )))),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _selectedFilter = 'Price';
                                        _FilterLoad = "Price";
                                        minprice = minpricecontroller.text;
                                        maxprice = maxpricecontroller.text;
                                        skip = 0;
                                        limit = 20;
                                        loading = true;
                                      });
                                      itemsgrid.clear();
                                      Navigator.of(context).pop();

                                      fetchPrice(minpricecontroller.text,
                                          maxpricecontroller.text);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                    ))
                              ],
                            ));
                      });
                    },
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
                                    fontFamily: 'Helvetica',
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
                                    fontFamily: 'Helvetica',
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

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  String getAppId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744~6783422976';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744~8862791402';
    }
    return null;
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  @override
  void dispose() {
    _scrollController.dispose();
    minpricecontroller.dispose();
    maxpricecontroller.dispose();
    super.dispose();
  }

  Future<List<Item>> fetchItems(int skip, int limit) async {
    country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        country = country;
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        country = country;
      });
    }

    var url = 'https://api.sellship.co/api/searchnearby/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    });
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();
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
          userid: jsonbody[i]['userid'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
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

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/searchbelowhundred/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchbrands(String brand) async {
    var url = 'https://api.sellship.co/api/searchbrand/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(url);
    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchCondition(String condition) async {
    var url = 'https://api.sellship.co/api/searchcondition/' +
        text.toString().toLowerCase().trim() +
        '/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchPrice(String minprice, String maxprice) async {
    var url = 'https://api.sellship.co/api/searchprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorecondition(String condition) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/searchcondition/' +
        text.toString().toLowerCase().trim() +
        '/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

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
    var url = 'https://api.sellship.co/api/searchprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

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

    var url = 'https://api.sellship.co/api/searchbrand/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/searchlowestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  loadbrands() async {
    brands.clear();
    var categoryurl = 'https://api.sellship.co/api/getallbrands';
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var categoryrespons = json.decode(categoryresponse.body);
      print(categoryrespons);
      for (int i = 0; i < categoryrespons.length; i++) {
        brands.add(categoryrespons[i]);
      }
      setState(() {
        brands = brands;
      });
    } else {
      print(categoryresponse.statusCode);
    }

    scaffoldState.currentState.showBottomSheet((context) {
      return Container(
        height: 500,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Feather.chevron_down),
              SizedBox(
                height: 2,
              ),
              Center(
                child: Text(
                  'Brand',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      color: Colors.deepOrange),
                ),
              ),
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
                      setState(() {
                        _selectedFilter = 'Brand';
                        _FilterLoad = "Brand";
                        brand = brands[index];
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();
                      Navigator.of(context).pop();

                      fetchbrands(brands[index]);
                    },
                    child: ListTile(
                      title: brands[index] != null
                          ? Text(brands[index])
                          : Text('sd'),
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      );
    });
  }

  List<String> brands = List<String>();
  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();

  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];
  String _selectedCondition;

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
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

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/searchlowestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
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

  _getmorebelowhundred() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
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
              ites.add(profilemap[i]['_id']['\$oid']);
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

  _getmorenearme() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        country = country;
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        country = country;
      });
    }

    var url = 'https://api.sellship.co/api/searchnearby/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    });
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();
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
          userid: jsonbody[i]['userid'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
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
}
