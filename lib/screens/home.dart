import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
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
import 'package:sellship/screens/search.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  bool loading;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

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
        loading = false;
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
      loading = true;
    });

    readstorage();
    fetchItems(skip, limit);
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
      setState(() {
        loading = false;
        itemsgrid = null;
      });
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

  onSearch(String texte) async {
    if (texte.isEmpty) {
      setState(() {
        skip = 0;
        limit = 10;
        fetchItems(skip, limit);
      });
    } else {
      searchcontroller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search(text: texte)),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: loading == false
                ? SafeArea(
                    child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.search),
                            title: TextField(
                              controller: searchcontroller,
                              onSubmitted: onSearch,
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
                              child: StaggeredGridView.countBuilder(
                              controller: _scrollController,
                              crossAxisCount: 2,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              itemCount: itemsgrid.length + 1,
                              itemBuilder: (context, index) {
                                if (index == itemsgrid.length) {
                                  return _buildProgressIndicator();
                                }
                                if (index != 0 && index % 7 == 0) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: AdmobBanner(
                                      adUnitId: getBannerAdUnitId(),
                                      adSize: AdmobBannerSize.LARGE_BANNER,
                                    ),
                                  );
                                }
                                return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                itemid:
                                                    itemsgrid[index].itemid)),
                                      );
                                    },
                                    child: Card(
                                      child: new Column(
                                        children: <Widget>[
                                          new Stack(
                                            children: <Widget>[
                                              //new Center(child: new CircularProgressIndicator()),
                                              new Center(
                                                child: new Image.network(
                                                  itemsgrid[index].image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: new Column(
                                              children: <Widget>[
                                                Text(
                                                  itemsgrid[index].name,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 3.0),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      itemsgrid[index].category,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    Text(
                                                      itemsgrid[index].price +
                                                          ' AED',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                              staggeredTileBuilder: (int index) {
                                if (index != 0 && index % 7 == 0) {
                                  return StaggeredTile.count(2, 1);
                                } else if (index != 0 &&
                                    index == itemsgrid.length) {
                                  return StaggeredTile.count(2, 1);
                                } else {
                                  return StaggeredTile.fit(1);
                                }
                              },
                            ))
                          : Expanded(
                              child: Column(
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  ),
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
                : Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0)), //this right here
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Loading'),
                            SizedBox(
                              height: 10,
                            ),
                            CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  )));
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
