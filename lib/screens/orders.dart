import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderseller.dart';
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
import 'package:timeago/timeago.dart' as timeago;

class OrdersScreen extends StatefulWidget {
  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  var userid;
  final storage = new FlutterSecureStorage();

  List<Item> sellingitem = List<Item>();

  List<Item> item = List<Item>();
  var currency;

  getorders() async {
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

    if (userid != null) {
      var url = 'https://api.sellship.co/api/getorders/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<Item> ites = List<Item>();
          List<Item> soldites = List<Item>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap['bought'].length; i++) {
              var q =
                  Map<String, dynamic>.from(profilemap['bought'][i]['date']);

              DateTime dateuploade =
                  DateTime.fromMillisecondsSinceEpoch(q['\$date']);
              var dateuploaded = timeago.format(dateuploade);

              Item ite = Item(
                itemid: profilemap['bought'][i]['itemid'],
                name: profilemap['bought'][i]['name'],
                image: profilemap['bought'][i]['itemimage'],
                price: profilemap['bought'][i]['itemprice'].toString(),
                userid: profilemap['bought'][i]['itemuserid'],
                description: profilemap['bought'][i]['messageid'],
                category: profilemap['bought'][i]['itemcategory'],
                username: profilemap['bought'][i]['itemusername'],
                subcategory: profilemap['bought'][i]['totalpayable'].toString(),
                date: dateuploaded,
              );
              ites.add(ite);
            }

            for (var i = 0; i < profilemap['sold'].length; i++) {
              var q = Map<String, dynamic>.from(profilemap['sold'][i]['date']);

              DateTime dateuploade =
                  DateTime.fromMillisecondsSinceEpoch(q['\$date']);
              var dateuploaded = timeago.format(dateuploade);

              Item iteso = Item(
                itemid: profilemap['sold'][i]['itemid'],
                name: profilemap['sold'][i]['name'],
                image: profilemap['sold'][i]['itemimage'],
                price: profilemap['sold'][i]['itemprice'].toString(),
                userid: profilemap['sold'][i]['itemuserid'],
                description: profilemap['sold'][i]['messageid'],
                category: profilemap['sold'][i]['itemcategory'],
                username: profilemap['sold'][i]['itemusername'],
                subcategory: profilemap['sold'][i]['totalpayable'].toString(),
                date: dateuploaded,
              );
              soldites.add(iteso);
            }

            Iterable inReverse = ites.reversed;
            List<Item> jsoninreverse = inReverse.toList();

            Iterable inReversesold = soldites.reversed;
            List<Item> jsoninreversesold = inReversesold.toList();
            setState(() {
              item = jsoninreverse;
              sellingitem = jsoninreversesold;
              loading = false;
            });
          } else {
            item = [];
            sellingitem = [];
          }
        } else {
          setState(() {
            loading = false;
            empty = true;
          });
        }

        print(sellingitem);
        print(item);
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
          fontFamily: 'Helvetica',
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
    });
    getorders();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final scaffoldState = GlobalKey<ScaffoldState>();
  TabController _tabController;

  ScrollController _scrollController = ScrollController();
  Widget orders(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Divider(),
        ),
        SliverAppBar(
          pinned: true,
          elevation: 1,
          backgroundColor: Colors.white,
          title: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            indicatorColor: Colors.deepPurple,
            labelStyle: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 14.0,
            ),
            tabs: [
              Tab(
                icon: Icon(
                  Icons.receipt,
                  color: Colors.deepPurple,
                ),
                text: 'Bought',
              ),
              Tab(
                icon: Icon(
                  Icons.monetization_on,
                  color: Colors.deepPurple,
                ),
                text: 'Sold',
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              loading == false
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
                                      child: ListView.builder(
                                        cacheExtent: double.parse(
                                            item.length.toString()),
                                        shrinkWrap: true,
                                        controller: _scrollController,
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
                                                                  itemid: item[
                                                                          index]
                                                                      .itemid)),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.2,
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
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
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl: item[
                                                                          index]
                                                                      .image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Column(
                                                                            children: <Widget>[
                                                                              Text(
                                                                                item[index].name,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Helvetica',
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.w800,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                'Bought for ' + currency + item[index].subcategory,
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.deepOrange),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                item[index].date,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Helvetica',
                                                                                  fontSize: 14,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                          )),
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => OrderBuyer(messageid: item[index].description, item: item[index])),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                30,
                                                                            width:
                                                                                100,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.deepPurpleAccent,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.deepPurpleAccent.shade200,
                                                                                  offset: Offset(0.0, 1.0), //(x,y)
                                                                                  blurRadius: 6.0,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                'View Order',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  )
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
                                        'View your bought items here!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                      'assets/onboard2.png',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2.0),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 8.0,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
              loading == false
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          sellingitem.isNotEmpty
                              ? Flexible(
                                  child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        cacheExtent: double.parse(
                                            sellingitem.length.toString()),
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        itemCount: sellingitem.length,
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
                                                                  itemid: sellingitem[
                                                                          index]
                                                                      .itemid)),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.2,
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
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
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      sellingitem[
                                                                              index]
                                                                          .image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Column(
                                                                            children: <Widget>[
                                                                              Text(
                                                                                sellingitem[index].name,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Helvetica',
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.w800,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                'Sold for ' + currency + sellingitem[index].subcategory,
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.deepOrange),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                sellingitem[index].date,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Helvetica',
                                                                                  fontSize: 14,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                          )),
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => OrderDetail(messageid: sellingitem[index].description, item: sellingitem[index])),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                30,
                                                                            width:
                                                                                100,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.deepPurpleAccent,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.deepPurpleAccent.shade200,
                                                                                  offset: Offset(0.0, 1.0), //(x,y)
                                                                                  blurRadius: 6.0,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                'View Order',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  )
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
                                        'View your sold items here!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                      'assets/onboard1.png',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2.0),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 8.0,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
            ],
          ),
        )
      ],
    );
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  Widget emptyorders(BuildContext context) {
    return empty == true
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text('View your order\'s here ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                    )),
              ),
              Expanded(
                  child: Image.asset(
                'assets/onboard1.png',
                fit: BoxFit.fitWidth,
              ))
            ],
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
                        fontFamily: 'Helvetica',
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
    return Scaffold(body: orders(context));
  }
}
