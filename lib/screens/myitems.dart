import 'dart:convert';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/edititem.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class MyItems extends StatefulWidget {
  MyItems({Key key}) : super(key: key);

  @override
  _MyItemsState createState() => new _MyItemsState();
}

class _MyItemsState extends State<MyItems> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final storage = new FlutterSecureStorage();

  ScrollController _scrollController = ScrollController();

  var userid;
  var loading;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });

    getProfileData();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica', fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 3),
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          title: Text(
            'MY ITEMS',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
          backgroundColor: Colors.deepOrange,
        ),
        body: loading == false
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      '${item.length} Items',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  item.isNotEmpty
                      ? Flexible(
                          child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: StaggeredGridView.builder(
                                gridDelegate:
                                    SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 1.0,
                                  crossAxisSpacing: 1.0,
                                  crossAxisCount: 2,
                                  staggeredTileCount: item.length,
                                  staggeredTileBuilder: (index) =>
                                      new StaggeredTile.fit(1),
                                ),
                                itemBuilder:
                                    ((BuildContext context, int index) {
                                  return Padding(
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Details(
                                                      itemid:
                                                          item[index].itemid)),
                                            );
                                          },
                                          child: Hero(
                                              tag: item[index].itemid,
                                              child: Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    new Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          height: 150,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
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
                                                              errorWidget: (context,
                                                                      url,
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
                                                                child:
                                                                    Container(
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
                                                                            FontWeight.bold),
                                                                  ),
                                                                ))
                                                            : Container(),
                                                      ],
                                                    ),
                                                    new Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: new Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 20,
                                                                child: Text(
                                                                  item[index]
                                                                      .name,
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
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        14,
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
                                                                      child:
                                                                          Text(
                                                                        currency +
                                                                            ' ' +
                                                                            item[index].price.toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      child:
                                                                          Text(
                                                                        item[index]
                                                                            .price
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: <
                                                                      Widget>[
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => EditItem(
                                                                                    itemid: item[index].itemid,
                                                                                  )),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            30,
                                                                        width: MediaQuery.of(context).size.width /
                                                                                4 -
                                                                            20,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.deepOrange,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.shade300,
                                                                              offset: Offset(0.0, 1.0), //(x,y)
                                                                              blurRadius: 6.0,
                                                                            ),
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(15.0),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Edit',
                                                                            style: TextStyle(
                                                                                fontFamily: 'Helvetica',
                                                                                fontSize: 14,
                                                                                color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        if (item[index].sold ==
                                                                            true) {
                                                                          var url = 'https://api.sellship.co/api/unsold/' +
                                                                              item[index].itemid +
                                                                              '/' +
                                                                              userid;
                                                                          print(
                                                                              url);
                                                                          final response =
                                                                              await http.get(url);
                                                                          if (response.statusCode ==
                                                                              200) {
                                                                            print(response.body);
                                                                          }
                                                                          getProfileData();
                                                                          showInSnackBar(
                                                                              'Item is now live!');
                                                                        } else {
                                                                          var url = 'https://api.sellship.co/api/sold/' +
                                                                              item[index].itemid +
                                                                              '/' +
                                                                              userid;
                                                                          print(
                                                                              url);
                                                                          final response =
                                                                              await http.get(url);
                                                                          if (response.statusCode ==
                                                                              200) {
                                                                            print(response.body);
                                                                          }
                                                                          getProfileData();
                                                                        }
                                                                        showInSnackBar(
                                                                            'Item has been marked sold!');
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            30,
                                                                        width: MediaQuery.of(context).size.width /
                                                                                4 -
                                                                            20,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.amber,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.shade300,
                                                                              offset: Offset(0.0, 1.0), //(x,y)
                                                                              blurRadius: 6.0,
                                                                            ),
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(15.0),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            item[index].sold == false
                                                                                ? 'Mark Sold'
                                                                                : 'Mark Live',
                                                                            style: TextStyle(
                                                                                fontFamily: 'Helvetica',
                                                                                fontSize: 14,
                                                                                color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ))));
                                }),
                              )))
                      : Expanded(
                          child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                  'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                  )),
                            ),
                            Expanded(
                                child: Image.asset(
                              'assets/little_theologians_4x.png',
                              fit: BoxFit.cover,
                            ))
                          ],
                        )),
                ],
              )
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
              ));
  }

  List<Item> item = List<Item>();

  var currency;

  void getProfileData() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');

    if (country.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;

        var follower = profilemap['follower'];

        if (follower != null) {
          print(follower);
        } else {
          follower = [];
        }

        var followin = profilemap['following'];
        if (followin != null) {
          print(followin);
        } else {
          followin = [];
        }

        var sol = profilemap['sold'];
        if (sol != null) {
          print(sol);
        } else {
          sol = [];
        }

        var profilepic = profilemap['profilepicture'];
        if (profilepic != null) {
          print(profilepic);
        } else {
          profilepic = null;
        }

        if (profilemap != null) {
          var itemurl = 'https://api.sellship.co/api/useritems/' + userid;
          print(itemurl);
          final itemresponse = await http.get(itemurl);
          if (itemresponse.statusCode == 200) {
            var itemrespons = json.decode(itemresponse.body);
            Map<String, dynamic> itemmap = itemrespons;
            print(itemmap);
            List<Item> ites = List<Item>();
            var productmap = itemmap['products'];

            if (productmap != null) {
              for (var i = 0; i < productmap.length; i++) {
                Item ite = Item(
                    itemid: productmap[i]['_id']['\$oid'],
                    name: productmap[i]['name'],
                    image: productmap[i]['image'],
                    price: productmap[i]['price'].toString(),
                    sold: productmap[i]['sold'] == null
                        ? false
                        : productmap[i]['sold'],
                    category: productmap[i]['category']);
                ites.add(ite);
              }
              setState(() {
                item = ites;
                loading = false;
              });
            } else {
              setState(() {
                item = [];
                loading = false;
              });
            }
          }
        } else {
          setState(() {
            loading = false;
            userid = null;
          });
        }
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }
}
