import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sellship/models/Items.dart';
import 'package:admob_flutter/admob_flutter.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:sellship/screens/details.dart';

class CategoryDetail extends StatefulWidget {
  final String category;

  CategoryDetail({Key key, this.category}) : super(key: key);

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  List<Item> itemsgrid = [];

  Future<List<Item>> fetchItems() async {
    var url = 'https://sellship.co/api/getcategoryitem/' + category;
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: base64Decode(jsondata['picture']['\$binary']),
          price: jsondata['price'],
          category: jsondata['category'],
        );
        itemsgrid.add(item);
      }
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  String category;
  @override
  void initState() {
    setState(() {
      category = widget.category;
    });
    print(category);
    super.initState();
  }

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
        body: SafeArea(
            child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<Item>>(
                future: fetchItems(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    return new GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: itemsgrid.length,
                      itemBuilder: (context, index) {
                        if (index != 0 && index % 6 == 0) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: AdmobBanner(
                              adUnitId: getBannerAdUnitId(),
                              adSize: AdmobBannerSize.LARGE_BANNER,
                              listener: (AdmobAdEvent event,
                                  Map<String, dynamic> args) {
                                handleEvent(event, args, 'Banner');
                              },
                            ),
                          );
                        }
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Details(item: itemsgrid[index])),
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              6.6,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            child: Image.memory(
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
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                )));
                      },
                    );
                  } else {
                    return Container(
                        height: 50, child: LinearProgressIndicator());
                  }
                },
              ),
            )
          ],
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
