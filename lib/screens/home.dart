import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sellship/models/Items.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sellship/screens/details.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> itemsgrid = [];

  List<Item> _search = [];

  var skip;
  var limit;

  var _scrollController;

  Future<List<Item>> fetchItems(int skip, int limit) async {
    if (city == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/getitems/' +
          city +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();

      final response = await http.post(url, body: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString()
      });

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
      });

      return itemsgrid;
    }
  }

  LatLng position;
  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 10;
    });
    readstorage();
    fetchItems(skip, limit);
  }

  _getLocation() async {
    Location _location = new Location();
    var location;

    try {
      location = await _location.getLocation();
      await storage.write(key: 'latitude', value: location.latitude.toString());
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());

        getcity();
      });
    } on Exception catch (e) {
      print(e);
      location = null;
    }
  }

  final Geolocator geolocator = Geolocator();

  void getcity() async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];
    var cit = place.administrativeArea;
    await storage.write(key: 'city', value: cit);
    setState(() {
      city = cit;
      fetchItems(skip, limit);
      //secure storage save it
    });
  }

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var cit = await storage.read(key: 'city');

    if (latitude == null || longitude == null) {
      _getLocation();
    } else {
      setState(() {
        position = LatLng(double.parse(latitude), double.parse(longitude));
        city = cit;
      });
    }
  }

  TextEditingController searchcontroller = new TextEditingController();

  onSearch(String text) async {
    _search.clear();
    if (text.isEmpty) {
      setState(() {
        return;
      });
    }

    itemsgrid.forEach((f) {
      if (f.name.contains(text) || f.category.contains(text)) {
        _search.add(f);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SafeArea(
                child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.search),
                      title: TextField(
                        controller: searchcontroller,
                        onChanged: onSearch,
                        decoration: InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          searchcontroller.clear();
                          onSearch('');
                        },
                        icon: Icon(Icons.cancel),
                      ),
                    ),
                  ),
                ),
                itemsgrid.isNotEmpty
                    ? Expanded(
                        child: FutureBuilder<List<Item>>(
                          future: fetchItems(skip, limit),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data != null) {
                              return LazyLoadScrollView(
                                  onEndOfPage: () {
                                    setState(() {
                                      skip = skip + 20;
                                    });
                                    fetchItems(skip, limit);
                                  },
                                  child: StaggeredGridView.countBuilder(
                                    controller: _scrollController,
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    //   crossAxisCount: 2,
                                    // ),
                                    itemCount: _search.isEmpty
                                        ? itemsgrid.length
                                        : _search.length,
                                    itemBuilder: (context, index) {
//                                    if (index == 7 ||
//                                        index == 14 ||
//                                        index == 21 ||
//                                        index == 29) {
//                                      return Container(
//                                        margin: EdgeInsets.only(bottom: 20.0),
//                                        child: AdmobBanner(
//                                          adUnitId: getBannerAdUnitId(),
//                                          adSize: AdmobBannerSize.LARGE_BANNER,
//                                        ),
//                                      );
//                                    }
                                      return _search.isEmpty
                                          ? InkWell(
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
                                              child: Padding(
                                                padding: EdgeInsets.all(1),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    elevation: 3.0,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              6.0,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                            ),
                                                            child:
                                                                Image.network(
                                                              itemsgrid[index]
                                                                  .image,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.0),
                                                        Expanded(
                                                          child: Text(
                                                            itemsgrid[index]
                                                                .name,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15.0),
                                                                child:
                                                                    Container(
                                                                  width: 100,
                                                                  child: Text(
                                                                    itemsgrid[
                                                                            index]
                                                                        .category,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          7.0),
                                                              child: Text(
                                                                itemsgrid[index]
                                                                        .price +
                                                                    ' AED',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Details(
                                                              itemid:
                                                                  _search[index]
                                                                      .itemid)),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(1),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    elevation: 3.0,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              6.8,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                            ),
                                                            child:
                                                                Image.network(
                                                              _search[index]
                                                                  .image,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.0),
                                                        Expanded(
                                                          child: Text(
                                                            _search[index].name,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15.0),
                                                                child:
                                                                    Container(
                                                                  width: 100,
                                                                  child: Text(
                                                                    _search[index]
                                                                        .category,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          7.0),
                                                              child: Text(
                                                                _search[index]
                                                                        .price +
                                                                    ' AED',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                    staggeredTileBuilder: (int index) {
                                      if (index == 7 ||
                                          index == 14 ||
                                          index == 21 ||
                                          index == 29) {
                                        return StaggeredTile.count(2, 1);
                                      } else {
                                        return StaggeredTile.count(1, 1);
                                      }
                                    },
                                  ));
                            } else {
                              return Container(
                                  height: 50, child: LinearProgressIndicator());
                            }
                          },
                        ),
                      )
                    : Expanded(
                        child: Column(
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Looks like you\'re the first here! \n Don\'t be shy add an Item!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(
                              child: Image.asset(
                            'assets/sss.jpg',
                            fit: BoxFit.cover,
                          ))
                        ],
                      )),
              ],
            ))));
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

  AdmobBannerSize bannerSize;

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        print('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        print('Admob $adType failed to load. :(');
        break;
      default:
    }
  }
}
