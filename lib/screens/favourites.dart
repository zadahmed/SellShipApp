import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  var userid;
  final storage = new FlutterSecureStorage();

  List<Item> item = List<Item>();
  var currency;
  getfavourites() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');
    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
    print(userid);
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<Item> ites = List<Item>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              Item ite = Item(
                  itemid: profilemap[i]['_id']['\$oid'],
                  name: profilemap[i]['name'],
                  image: profilemap[i]['image'],
                  likes: profilemap[i]['likes'] == null
                      ? 0
                      : profilemap[i]['likes'],
                  comments: profilemap[i]['comments'] == null
                      ? 0
                      : profilemap[i]['comments'].length,
                  price: profilemap[i]['price'].toString(),
                  sold: profilemap[i]['sold'] == null
                      ? false
                      : profilemap[i]['sold'],
                  category: profilemap[i]['category']);
              ites.add(ite);
            }

            Iterable inReverse = ites.reversed;
            List<Item> jsoninreverse = inReverse.toList();
            setState(() {
              item = jsoninreverse;
              loading = false;
            });
          } else {
            item = [];
          }
        } else {
          setState(() {
            loading = false;
            empty = true;
          });
        }
      } else {
        setState(() {
          empty = true;
          loading = false;
        });
      }
    } else {
      setState(() {
        empty = true;
        loading = false;
      });
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldState.currentState?.removeCurrentSnackBar();
    scaffoldState.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  var loading;
  var empty;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      empty = false;
    });
    getfavourites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final scaffoldState = GlobalKey<ScaffoldState>();

  ScrollController _scrollController = ScrollController();
  Widget favourites(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: loading == false
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    item.isNotEmpty
                        ? Flexible(
                            child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GridView.builder(
                                  cacheExtent:
                                      double.parse(item.length.toString()),
                                  shrinkWrap: true,
                                  controller: _scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.55),
                                  itemCount: item.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsets.all(10),
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Details(
                                                            itemid: item[index]
                                                                .itemid)),
                                              );
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
                                                              BorderRadius
                                                                  .circular(15),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                item[index]
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
                                                      item[index].sold == true
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
                                                                          'SF',
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
                                                            EdgeInsets.all(5),
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
                                                              children: <
                                                                  Widget>[
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    var userid =
                                                                        await storage.read(
                                                                            key:
                                                                                'userid');

                                                                    if (userid !=
                                                                        null) {
                                                                      var url =
                                                                          'https://api.sellship.co/api/favourite/' +
                                                                              userid;

                                                                      Map<String,
                                                                              String>
                                                                          body =
                                                                          {
                                                                        'itemid':
                                                                            item[index].itemid,
                                                                      };

                                                                      final response = await http.post(
                                                                          url,
                                                                          body:
                                                                              body);

                                                                      if (response
                                                                              .statusCode ==
                                                                          200) {
                                                                        var jsondata =
                                                                            json.decode(response.body);

                                                                        item.clear();
                                                                        for (int i =
                                                                                0;
                                                                            i < jsondata.length;
                                                                            i++) {
                                                                          Item ite = Item(
                                                                              itemid: jsondata[i]['_id']['\$oid'],
                                                                              name: jsondata[i]['name'],
                                                                              image: jsondata[i]['image'],
                                                                              likes: jsondata[i]['likes'] == null ? 0 : jsondata[i]['likes'],
                                                                              comments: jsondata[i]['comments'] == null ? 0 : jsondata[i]['comments'].length,
                                                                              price: jsondata[i]['price'].toString(),
                                                                              sold: jsondata[i]['sold'] == null ? false : jsondata[i]['sold'],
                                                                              category: jsondata[i]['category']);
                                                                          item.add(
                                                                              ite);
                                                                        }
                                                                        setState(
                                                                            () {
                                                                          item =
                                                                              item;
                                                                        });
                                                                      } else {
                                                                        print(response
                                                                            .statusCode);
                                                                      }
                                                                    } else {
                                                                      showInSnackBar(
                                                                          'Please Login to use Favourites');
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .deepPurple,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  item[index]
                                                                          .likes
                                                                          .toString() +
                                                                      ' likes',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF',
                                                                    fontSize:
                                                                        16,
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
                                                                          builder: (context) =>
                                                                              CommentsPage(itemid: item[index].itemid)),
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
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CommentsPage(itemid: item[index].itemid)),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    item[index]
                                                                        .comments
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'SF',
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
                                                                item[index]
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
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
                                                            SizedBox(
                                                                height: 5.0),
                                                            Container(
                                                              child: Text(
                                                                item[index]
                                                                    .category,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 5.0),
                                                            currency != null
                                                                ? Container(
                                                                    child: Text(
                                                                      currency +
                                                                          ' ' +
                                                                          item[index]
                                                                              .price
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'SF',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .deepOrange,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    child: Text(
                                                                      item[index]
                                                                          .price
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'SF',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .deepOrange,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      )),
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
                                  'View your favourites here!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/favourites.png',
                                fit: BoxFit.fitWidth,
                              ))
                            ],
                          )),
                  ],
                ),
              )
            : Container(
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

  Widget emptyfavourites(BuildContext context) {
    return loading == false
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text('View your favourite\'s here ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                      )),
                ),
                Expanded(
                    child: Image.asset(
                  'assets/favourites.png',
                  fit: BoxFit.fitWidth,
                ))
              ],
            ),
          )
        : Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 100,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return empty == false ? favourites(context) : emptyfavourites(context);
  }
}
