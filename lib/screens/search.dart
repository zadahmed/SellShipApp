import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  LatLng position;
  String country;

  final storage = new FlutterSecureStorage();
  bool loading;

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 10;
      text = widget.text;
      searchcontroller.text = text;
      loading = true;
    });
    readstorage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getmoreData();
      }
    });
  }

  _getmoreData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
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
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
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

  var currency;
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
      position = LatLng(double.parse(latitude), double.parse(longitude));
      country = countr;
      onSearch();
    });
  }

  TextEditingController searchcontroller = new TextEditingController();

  onSearch() async {
    var url = 'https://sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
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
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Container(
                height: 45,
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: Offset(0.0, 1), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10),
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
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ))),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? SafeArea(
                  child: Column(
                  children: <Widget>[
                    itemsgrid.isNotEmpty
                        ? Flexible(
                            child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.80),
                                  itemCount: itemsgrid.length,
                                  itemBuilder: (context, index) {
                                    if (index != 0 && index % 8 == 0) {
                                      return Platform.isIOS == true
                                          ? Container(
                                              height: 330,
                                              padding: EdgeInsets.all(10),
                                              margin:
                                                  EdgeInsets.only(bottom: 20.0),
                                              child: NativeAdmob(
                                                adUnitID: _iosadUnitID,
                                                controller: _controller,
                                              ),
                                            )
                                          : Container(
                                              height: 330,
                                              padding: EdgeInsets.all(10),
                                              margin:
                                                  EdgeInsets.only(bottom: 20.0),
                                              child: NativeAdmob(
                                                adUnitID: _androidadUnitID,
                                                controller: _controller,
                                              ),
                                            );
                                    }

                                    return Padding(
                                        padding: EdgeInsets.all(4),
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Details(
                                                            itemid:
                                                                itemsgrid[index]
                                                                    .itemid)),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 6.0,
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              child: new Column(
                                                children: <Widget>[
                                                  new Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 150,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              itemsgrid[index]
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
                                                    ],
                                                  ),
                                                  new Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: new Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          height: 20,
                                                          child: Text(
                                                            itemsgrid[index]
                                                                .name,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        Container(
                                                          child: Text(
                                                            itemsgrid[index]
                                                                .category,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        currency != null
                                                            ? Container(
                                                                child: Text(
                                                                  itemsgrid[index]
                                                                          .price
                                                                          .toString() +
                                                                      ' ' +
                                                                      currency,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        16,
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
                                                                        'Montserrat',
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
                                                  )
                                                ],
                                              ),
                                            )));
                                  },
                                )))
                        : Expanded(
                            child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                    'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                    )),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/little_theologians_4x.jpg',
                                fit: BoxFit.cover,
                              ))
                            ],
                          )),
                  ],
                ))
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Column(
                      children: [0, 1, 2, 3, 4, 5, 6]
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                          ),
                                          Container(
                                            width: 40.0,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
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
}
