import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Activity extends StatefulWidget {
  Activity({Key key}) : super(key: key);

  @override
  _ActivityState createState() => new _ActivityState();
}

class Offer {
  final String itempicture;
  final String itemname;
  final String sellingusername;
  final String sellinguserid;
  final String buyinguserid;
  final String buyingusername;
  final String offer;
  final int offerstage;

  Offer(
      {this.itemname,
      this.itempicture,
      this.sellinguserid,
      this.sellingusername,
      this.buyinguserid,
      this.buyingusername,
      this.offer,
      this.offerstage});
}

class _ActivityState extends State<Activity>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);

    loadbuyingactivity();
    _tabController.addListener(() {
      var tab = _tabController.index;
      if (tab == 0) {
        if (mounted) {
          setState(() {
            loading = true;
          });
        }
        loadbuyingactivity();
      }
      if (tab == 1) {
        if (mounted) {
          setState(() {
            loading = true;
          });
        }
        loadsellingactivity();
      }
    });
  }

  bool loading = true;
  final storage = new FlutterSecureStorage();

  loadbuyingactivity() async {
    var userid = await storage.read(key: 'userid');
    var itemurl = 'https://api.sellship.co/api/activity/buying/' + userid;
    final response = await http.get(itemurl);
    if (response.statusCode == 200) {
      var itemrespons = json.decode(response.body);
      List itemmap = itemrespons;

      List<Item> ites = List<Item>();

      if (itemmap != null) {
        print(itemmap);
        for (var i = 0; i < itemmap.length; i++) {
          Item ite = Item(
              itemid: itemmap[i]['item']['_id']['\$oid'],
              name: itemmap[i]['item']['name'],
              image: itemmap[i]['item']['image'],
              price: itemmap[i]['offer'].toString(),
              offerstage: itemmap[i]['offerstage'],
              buyerid: itemmap[i]['buyerid']['\$oid'].toString(),
              buyername: itemmap[i]['buyername'],
              sellername: itemmap[i]['sellername'],
              sellerid: itemmap[i]['sellerid']['\$oid'].toString(),
              sold: itemmap[i]['item']['sold']);
          ites.add(ite);
        }
        if (mounted)
          setState(() {
            loading = false;
            buyingItem = ites;
          });
      }
    }
  }

  loadsellingactivity() async {
    var userid = await storage.read(key: 'userid');
    var itemurl = 'https://api.sellship.co/api/activity/selling/' + userid;
    final response = await http.get(itemurl);
    if (response.statusCode == 200) {
      var itemrespons = json.decode(response.body);
      List itemmap = itemrespons;

      List<Item> ites = List<Item>();

      if (itemmap != null) {
        print(itemmap);
        for (var i = 0; i < itemmap.length; i++) {
          Item ite = Item(
              itemid: itemmap[i]['item']['_id']['\$oid'],
              name: itemmap[i]['item']['name'],
              image: itemmap[i]['item']['image'],
              price: itemmap[i]['offer'].toString(),
              offerstage: itemmap[i]['offerstage'],
              buyerid: itemmap[i]['buyerid']['\$oid'].toString(),
              buyername: itemmap[i]['buyername'],
              sellername: itemmap[i]['sellername'],
              sellerid: itemmap[i]['sellerid']['\$oid'].toString(),
              sold: itemmap[i]['item']['sold']);
          ites.add(ite);
        }
        if (mounted)
          setState(() {
            sellingItem = ites;
            loading = false;
          });
      }
    }
  }

  List<Item> buyingItem = new List<Item>();
  List<Item> sellingItem = new List<Item>();

  Widget offerstatus(
      BuildContext context, offerstage, itemid, senderuserid, recieveruserid) {
    if (offerstage == 0 && _tabController.index == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 125,
            height: 35,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.deepOrangeAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Pending Offer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
            )),
          ),
          InkWell(
              onTap: () async {
                var userid = await storage.read(key: 'userid');
                var itemurl =
                    'https://api.sellship.co/api/canceloffer/pending/' +
                        userid +
                        '/' +
                        itemid +
                        '/' +
                        senderuserid +
                        '/' +
                        recieveruserid;
                print(itemurl);
                final response = await http.get(itemurl);
                if (response.statusCode == 200) {
                  loadbuyingactivity();
                } else {
                  print(response.statusCode);
                }
              },
              child: Text(
                'Cancel Offer',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 12.0,
                    color: Colors.grey),
              ))
        ],
      );
    } else if (offerstage == 1 && _tabController.index == 0) {
      return Container(
          width: 80,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Text(
                'Pay',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14.0,
                    color: Colors.white),
              )
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Activity',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        snap: true,
                        floating: true,
                        title: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.circular(20))),
                          child: Center(
                            child: TabBar(
                              controller: _tabController,
                              labelStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Helvetica',
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Helvetica',
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                      width: 2.0, color: Colors.deepOrange)),
                              isScrollable: true,
                              labelColor: Colors.black,
                              tabs: [
                                new Tab(
                                  text: 'Buy',
                                ),
                                new Tab(
                                  text: 'Sell',
                                ),
                              ],
                            ),
                          ),
                        )),
                  ];
                },
                body: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(229, 233, 242, 1).withOpacity(0.5),
                    ),
                    child: Container(
                        padding: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: loading == false
                            ? TabBarView(controller: _tabController, children: [
                                EasyRefresh.custom(slivers: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: ListTile(
                                                  trailing: offerstatus(
                                                      context,
                                                      buyingItem[index]
                                                          .offerstage,
                                                      buyingItem[index].itemid,
                                                      buyingItem[index].buyerid,
                                                      buyingItem[index]
                                                          .sellerid),
                                                  leading: InkWell(
                                                    child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        child: Image.network(
                                                          buyingItem[index]
                                                              .image,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Details(
                                                                      itemid: buyingItem[
                                                                              index]
                                                                          .itemid,
                                                                      sold: buyingItem[
                                                                              index]
                                                                          .sold,
                                                                    )),
                                                      );
                                                    },
                                                  ),
                                                  title: Text(
                                                    buyingItem[index].name,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                  subtitle: Text(
                                                    '@' +
                                                        buyingItem[index]
                                                            .sellername,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.grey),
                                                  ),
                                                )));
                                      },
                                      childCount: buyingItem.length,
                                    ),
                                  )
                                ]),
                                EasyRefresh.custom(slivers: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Details(
                                                                itemid:
                                                                    sellingItem[
                                                                            index]
                                                                        .itemid,
                                                                sold: sellingItem[
                                                                        index]
                                                                    .sold,
                                                              )),
                                                    );
                                                  },
                                                  leading: Container(
                                                    height: 60,
                                                    width: 60,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: Image.network(
                                                        sellingItem[index]
                                                            .image,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    sellingItem[index].name,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                  subtitle: Text(
                                                    sellingItem[index]
                                                        .sellername,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                )));
                                      },
                                      childCount: sellingItem.length,
                                    ),
                                  )
                                ]),
                              ])
                            : Container(
                                height: MediaQuery.of(context).size.height,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300],
                                    highlightColor: Colors.grey[100],
                                    child: ListView(
                                      children: [0, 1, 2, 3, 4, 5, 6]
                                          .map((_) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2 -
                                                              30,
                                                      height: 150.0,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8.0),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2 -
                                                              30,
                                                      height: 150.0,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ))))));
  }
}
