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
import 'package:shimmer/shimmer.dart';

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
        loading = false;
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
      loading = true;
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

  bool loading;

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

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.amber,
          title: Text(
            subcategory,
            style: TextStyle(color: Colors.white),
          ),
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
                                              itemid: itemsgrid[index].itemid)),
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
                                                  Container(
                                                    width: 80,
                                                    child: Text(
                                                      itemsgrid[index].category,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
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
                                  'Looks like you\'re the first here! \n Don\'t be shy add an Item!',
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
