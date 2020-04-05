import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sellship/models/Items.dart';
import 'package:admob_flutter/admob_flutter.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:sellship/screens/details.dart';

class CategoryDetail extends StatefulWidget {
  final String category;
  final String subcategory;

  CategoryDetail({Key key, this.category, this.subcategory}) : super(key: key);

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getmoreData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/categories/' +
        category +
        '/' +
        subcategory +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
          category: jsondata['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchItems() async {
    var url = 'https://sellship.co/api/categories/' +
        category +
        '/' +
        subcategory +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
          category: jsondata['category'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  String category;
  String subcategory;

  @override
  void initState() {
    setState(() {
      skip = 0;
      limit = 10;
      category = widget.category;
      subcategory = widget.subcategory;
    });

    fetchItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getmoreData();
      }
    });
    super.initState();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.amber,
          title: Text(
            category,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SafeArea(
                child: Column(
              children: <Widget>[
                itemsgrid.isNotEmpty
                    ? Expanded(
                        child: StaggeredGridView.countBuilder(
                        controller: _scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
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
                                        itemid: itemsgrid[index].itemid)),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(1),
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  elevation: 3.0,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                6.0,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          child: Image.network(
                                            itemsgrid[index].image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 2.0),
                                      Expanded(
                                        child: Text(
                                          itemsgrid[index].name,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 3.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15.0),
                                              child: Container(
                                                width: 100,
                                                child: Text(
                                                  itemsgrid[index].category,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 7.0),
                                            child: Text(
                                              itemsgrid[index].price + ' AED',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.left,
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
                          if (index != 0 && index % 7 == 0) {
                            return StaggeredTile.count(2, 1);
                          } else if (index != 0 && index == itemsgrid.length) {
                            return StaggeredTile.count(2, 1);
                          } else {
                            return StaggeredTile.count(1, 1);
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
