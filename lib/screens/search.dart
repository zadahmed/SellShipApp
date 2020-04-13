import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
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
  String city;

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
        city +
        '/' +
        text +
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
    var cit = await storage.read(key: 'city');

    setState(() {
      position = LatLng(double.parse(latitude), double.parse(longitude));
      city = cit;
      onSearch();
    });
  }

  TextEditingController searchcontroller = new TextEditingController();

  onSearch() async {
    var url = 'https://sellship.co/api/searchitems/' +
        city +
        '/' +
        text.toString().toLowerCase() +
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
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (BuildContext context) => Search(
//                  text: texte,
//                )));
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            text,
            style: TextStyle(color: Colors.black),
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
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.search),
                            title: TextField(
                              controller: searchcontroller,
                              onSubmitted: onSearche,
                              decoration: InputDecoration(
                                  hintText: 'Search', border: InputBorder.none),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                searchcontroller.clear();
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
                                  return Platform.isIOS == true
                                      ? Container(
                                          height: 330,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          child: NativeAdmob(
                                            adUnitID: _iosadUnitID,
                                            controller: _controller,
                                          ),
                                        )
                                      : Container(
                                          height: 330,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          child: NativeAdmob(
                                            adUnitID: _androidadUnitID,
                                            controller: _controller,
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
                                                child: Image.network(
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
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 3.0),
                                                Container(
                                                  child: Text(
                                                    itemsgrid[index].category,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 3.0),
                                                Container(
                                                  child: Text(
                                                    itemsgrid[index].price +
                                                        ' AED',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
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

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();
}
