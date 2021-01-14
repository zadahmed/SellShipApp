import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  bool keepalive = true;

  @override
  bool get wantKeepAlive => keepalive;

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
            loadbuyingactivity();
          });
        }
      }
      if (tab == 1) {
        if (mounted) {
          setState(() {
            loading = true;
            loadsellingactivity();
          });
        }
      }
    });
  }

  var currency;
  bool loading;
  final storage = new FlutterSecureStorage();

  loadbuyingactivity() async {
    buyingItem.clear();
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }

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
            keepalive = false;
            loading = false;
            buyingItem = ites;
          });
      }
    }
  }

  loadsellingactivity() async {
    sellingItem.clear();
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }
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

  Widget offerstatus(BuildContext context, offerstage, itemid, senderuserid,
      recieveruserid, offerprice) {
    if (offerstage == 0 && _tabController.index == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 140,
            height: 27,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: Color.fromRGBO(69, 80, 163, 1),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              'Pending Offer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
            )),
          ),
          SizedBox(
            height: 5,
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
          width: 140,
          height: 27,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: Color.fromRGBO(69, 80, 163, 1),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: Text(
            'Pay',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
          )));
    } else if (offerstage == -1 && _tabController.index == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 125,
            height: 35,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Offer Declined',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
            )),
          ),
          InkWell(
              onTap: () {
                showMe(
                    context, offerprice, recieveruserid, senderuserid, itemid);
              },
              child: Text(
                'Make an Offer',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14.0,
                    color: Colors.black),
              ))
        ],
      );
    } else if (offerstage == 0 && _tabController.index == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              height: 40,
              width: 124,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      var userid = await storage.read(key: 'userid');
                      var itemurl = 'https://api.sellship.co/api/acceptoffer/' +
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
                        loadsellingactivity();
                      } else {
                        print(response.statusCode);
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.lightGreen,
                      child: Icon(
                        Feather.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  InkWell(
                    onTap: () async {
                      var userid = await storage.read(key: 'userid');
                      var itemurl = 'https://api.sellship.co/api/canceloffer/' +
                          userid +
                          '/' +
                          itemid +
                          '/' +
                          senderuserid +
                          '/' +
                          recieveruserid;

                      final response = await http.get(itemurl);
                      if (response.statusCode == 200) {
                        print(response.body);
                        loadsellingactivity();
                      } else {
                        print(response.statusCode);
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.cancel,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  InkWell(
                    onTap: () async {
                      showMeCounter(context, offerprice, recieveruserid,
                          senderuserid, itemid);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Feather.repeat,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      );
    } else if (offerstage == -1 && _tabController.index == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 125,
            height: 35,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Offer Declined',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
            )),
          ),
        ],
      );
    } else if (offerstage == 2 && _tabController.index == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 140,
            height: 27,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: Color.fromRGBO(239, 190, 125, 1),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              'Payment Pending',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica', fontSize: 14.0, color: Colors.white),
            )),
          ),
        ],
      );
    } else if (offerstage == 2 && _tabController.index == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Checkout(itemid: itemid)),
                );
              },
              child: Container(
                  width: 140,
                  height: 27,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(119, 221, 119, 1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Text(
                    'Pay',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14.0,
                        color: Colors.white),
                  ))))
        ],
      );
    }
  }

  TextEditingController offercontroller = TextEditingController();

  String allowedoffer = '';
  bool disabled = true;

  void showMe(BuildContext context, offerprice, recieverid, senderid, itemid) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 20, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Make an Offer',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.deepOrangeAccent
                                          .withOpacity(0.2)),
                                  color:
                                      Colors.deepOrangeAccent.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text(
                                  'Current Price ' + currency + offerprice,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    allowedoffer.isNotEmpty
                        ? Padding(
                            padding:
                                EdgeInsets.only(left: 15, bottom: 5, top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                allowedoffer,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: Container(
                        height: 84,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2)),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: TextField(
                                    cursorColor: Color(0xFF979797),
                                    controller: offercontroller,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        var offer = double.parse(text);
                                        var minoffer =
                                            double.parse(offerprice) * 0.50;
                                        minoffer =
                                            double.parse(offerprice) - minoffer;

                                        if (offer < minoffer) {
                                          updateState(() {
                                            allowedoffer =
                                                'The offer is too low compared to the selling price';
                                            disabled = true;
                                          });
                                        } else {
                                          updateState(() {
                                            allowedoffer = '';
                                            disabled = false;
                                          });
                                        }
                                      } else {
                                        updateState(() {
                                          allowedoffer = '';
                                          disabled = true;
                                        });
                                      }
                                    },
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: '0',
//                                                alignLabelWithHint: true,
                                      hintStyle: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                      focusColor: Colors.black,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                  width: 100,
                                ),
                                Text(currency,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 22,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: InkWell(
                        onTap: () async {
                          if (disabled == false) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 100,
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SpinKitChasingDots(
                                            color: Colors.deepOrangeAccent)),
                                  );
                                });
                            var userid = await storage.read(key: 'userid');

                            var itemurl =
                                'https://api.sellship.co/api/createoffer/' +
                                    userid +
                                    '/' +
                                    recieverid +
                                    '/' +
                                    itemid +
                                    '/' +
                                    offercontroller.text.trim();

                            final response = await http.get(itemurl);

                            if (response.statusCode == 200) {
                              loadbuyingactivity();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: allowedoffer.isEmpty
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Center(
                              child: Text(
                                'Make Offer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Helvetica',
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              );
            }));
  }

  void showMeCounter(
      BuildContext context, offerprice, recieverid, senderid, itemid) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 20, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Make a Counteroffer',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.deepOrangeAccent
                                          .withOpacity(0.2)),
                                  color:
                                      Colors.deepOrangeAccent.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text(
                                  'Current Price ' + currency + offerprice,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: Container(
                        height: 84,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2)),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: TextField(
                                    cursorColor: Color(0xFF979797),
                                    controller: offercontroller,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: '0',
//                                                alignLabelWithHint: true,
                                      hintStyle: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                      focusColor: Colors.black,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                  width: 100,
                                ),
                                Text(currency,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 22,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: InkWell(
                        onTap: () async {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              useRootNavigator: false,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 100,
                                  child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SpinKitChasingDots(
                                          color: Colors.deepOrangeAccent)),
                                );
                              });

                          var itemurl =
                              'https://api.sellship.co/api/counteroffer/' +
                                  senderid +
                                  '/' +
                                  recieverid +
                                  '/' +
                                  itemid +
                                  '/' +
                                  offercontroller.text.trim();

                          final response = await http.get(itemurl);

                          if (response.statusCode == 200) {
                            loadsellingactivity();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: allowedoffer.isEmpty
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Center(
                              child: Text(
                                'Make Counteroffer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Helvetica',
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              );
            }));
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
                                fontWeight: FontWeight.bold,
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
                              isScrollable: false,
                              labelColor: Colors.black,
                              tabs: [
                                new Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: new Tab(
                                    text: 'Buy',
                                  ),
                                ),
                                new Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: new Tab(
                                    text: 'Sell',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ];
                },
                body: loading == false
                    ? TabBarView(controller: _tabController, children: [
                        buyingItem.isNotEmpty
                            ? EasyRefresh.custom(
                                onRefresh: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  return loadbuyingactivity();
                                },
                                header: CustomHeader(
                                    extent: 40.0,
                                    enableHapticFeedback: true,
                                    triggerDistance: 50.0,
                                    headerBuilder: (context,
                                        loadState,
                                        pulledExtent,
                                        loadTriggerPullDistance,
                                        loadIndicatorExtent,
                                        axisDirection,
                                        float,
                                        completeDuration,
                                        enableInfiniteLoad,
                                        success,
                                        noMore) {
                                      return SpinKitFadingCircle(
                                        color: Colors.deepOrange,
                                        size: 30.0,
                                      );
                                    }),
                                slivers: [
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: 5,
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Container(
                                                  height: 100,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              Details(
                                                                                itemid: buyingItem[index].itemid,
                                                                                sold: buyingItem[index].sold,
                                                                              )),
                                                                );
                                                              },
                                                              child: Container(
                                                                height: 80,
                                                                width: 80,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child: Image
                                                                      .network(
                                                                    buyingItem[
                                                                            index]
                                                                        .image,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  buyingItem[
                                                                          index]
                                                                      .name,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Text(
                                                                  '@' +
                                                                      buyingItem[
                                                                              index]
                                                                          .sellername,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  'Offer ' +
                                                                      currency +
                                                                      ' ' +
                                                                      buyingItem[
                                                                              index]
                                                                          .price,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .black),
                                                                )
                                                              ],
                                                            ),
                                                          ]),
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            offerstatus(
                                                              context,
                                                              buyingItem[index]
                                                                  .offerstage,
                                                              buyingItem[index]
                                                                  .itemid,
                                                              buyingItem[index]
                                                                  .buyerid,
                                                              buyingItem[index]
                                                                  .sellerid,
                                                              buyingItem[index]
                                                                  .price,
                                                            ),
                                                          ])
                                                    ],
                                                  )));
                                        },
                                        childCount: buyingItem.length,
                                      ),
                                    )
                                  ])
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '🛍',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('You have not made any offers yet ',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        textAlign: TextAlign.center),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'The buy section is for all your activities regarding items you are buying. You can make offers, track your orders and even make purchases. What are you waiting for?',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          color: Colors.black),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    InkWell(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Container(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.deepOrange
                                                      .withOpacity(0.4),
                                                  offset:
                                                      const Offset(1.1, 1.1),
                                                  blurRadius: 5.0),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Start SellShipping',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => RootScreen(
                                                    index: 0,
                                                  )),
                                        );
                                      },
                                    ),
                                  ],
                                )),
                        sellingItem.isNotEmpty
                            ? EasyRefresh.custom(
                                onRefresh: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  return loadsellingactivity();
                                },
                                header: CustomHeader(
                                    extent: 40.0,
                                    enableHapticFeedback: true,
                                    triggerDistance: 50.0,
                                    headerBuilder: (context,
                                        loadState,
                                        pulledExtent,
                                        loadTriggerPullDistance,
                                        loadIndicatorExtent,
                                        axisDirection,
                                        float,
                                        completeDuration,
                                        enableInfiniteLoad,
                                        success,
                                        noMore) {
                                      return SpinKitFadingCircle(
                                        color: Colors.deepOrange,
                                        size: 30.0,
                                      );
                                    }),
                                slivers: [
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: 5,
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Container(
                                                  height: 100,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              Details(
                                                                                itemid: sellingItem[index].itemid,
                                                                                sold: sellingItem[index].sold,
                                                                              )),
                                                                );
                                                              },
                                                              child: Container(
                                                                height: 80,
                                                                width: 80,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child: Image
                                                                      .network(
                                                                    sellingItem[
                                                                            index]
                                                                        .image,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  sellingItem[
                                                                          index]
                                                                      .name,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Text(
                                                                  '@' +
                                                                      sellingItem[
                                                                              index]
                                                                          .buyername,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  'Offer ' +
                                                                      currency +
                                                                      ' ' +
                                                                      sellingItem[
                                                                              index]
                                                                          .price,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .black),
                                                                )
                                                              ],
                                                            ),
                                                          ]),
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            offerstatus(
                                                              context,
                                                              sellingItem[index]
                                                                  .offerstage,
                                                              sellingItem[index]
                                                                  .itemid,
                                                              sellingItem[index]
                                                                  .buyerid,
                                                              sellingItem[index]
                                                                  .sellerid,
                                                              sellingItem[index]
                                                                  .price,
                                                            ),
                                                          ])
                                                    ],
                                                  )));
                                        },
                                        childCount: sellingItem.length,
                                      ),
                                    )
                                  ])
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '😞',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('You have no offers yet ',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        textAlign: TextAlign.center),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'The sell section is for all your activities regarding items you are selling. You can accept offers, send counter offers and even schedule pickups and track orders. What are you waiting for? Start listing your items',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          color: Colors.black),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    InkWell(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Container(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.deepOrange
                                                      .withOpacity(0.4),
                                                  offset:
                                                      const Offset(1.1, 1.1),
                                                  blurRadius: 5.0),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Start SellShipping',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => RootScreen(
                                                    index: 2,
                                                  )),
                                        );
                                      },
                                    ),
                                  ],
                                ))
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
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  30,
                                              height: 150.0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  30,
                                              height: 150.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ))));
  }
}
