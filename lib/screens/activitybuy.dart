import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/orders.dart';
import 'package:SellShip/screens/chatpageviewseller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ActivityBuy extends StatefulWidget {
  ActivityBuy({Key key}) : super(key: key);

  @override
  _ActivityBuyState createState() => new _ActivityBuyState();
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

class _ActivityBuyState extends State<ActivityBuy>
    with AutomaticKeepAliveClientMixin {
  TabController _tabController;

  bool keepalive = true;

  @override
  bool get wantKeepAlive => keepalive;

  @override
  void initState() {
    super.initState();

    loadbuyingactivity();
  }

  var currency;
  bool loading;
  final storage = new FlutterSecureStorage();

  loadbuyingactivity() async {
    buyingItem.clear();
    var countr = await storage.read(key: 'country');

    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var itemurl = 'https://api.sellship.co/api/activity/buying/' + userid;
      final response = await http.get(Uri.parse(itemurl));
      if (response.statusCode == 200) {
        var itemrespons = json.decode(response.body);
        List itemmap = itemrespons;

        if (itemmap != null) {
          for (var i = 0; i < itemmap.length; i++) {
            print(itemmap[i]);
            print('ddd');
            var buyerid;

            buyerid = itemmap[i]['buyerid'];

            var buyername;
            if (itemmap[i].containsKey('buyername')) {
              buyername = itemmap[i]['buyername'];
            } else {
              buyername = 'Unknown';
            }

            var sellerid;

            sellerid = itemmap[i]['sellerid'];

            var date;
            if (itemmap[i]['offerdate'].containsKey('\$date')) {
              date = itemmap[i]['offerdate']['\$date'];
            } else {
              date = 0;
            }

            var sellername;
            if (itemmap[i].containsKey('sellername')) {
              sellername = itemmap[i]['sellername'];
            } else {
              sellername = 'Unknown';
            }

            List<Item> itemsorder = [];

            for (int l = 0; l < itemmap[i]['items'].length; l++) {
              var itemjson = itemmap[i]['items'][l];
              Item ite = Item(
                  name: itemmap[i]['items'][l]['name'],
                  selectedsize: itemmap[i]['items'][l]['selectedsize'],
                  quantity: itemmap[i]['items'][l]['quantity'],
                  itemid: itemmap[i]['items'][l]['itemid'],
                  weight: itemmap[i]['items'][l]['weight'],
                  freedelivery: itemmap[i]['items'][l]['freedelivery'],
                  price: itemmap[i]['items'][l]['price'].toString(),
                  saleprice: itemmap[i]['items'][l]['saleprice'] == null
                      ? null
                      : itemmap[i]['items'][l]['saleprice'],
                  image: itemmap[i]['items'][l]['image'],
                  userid: itemmap[i]['items'][l]['userid'],
                  username: itemmap[i]['items'][l]['username']);
              itemsorder.add(ite);
            }

            Orders order = Orders(
                orderdate: date.toString(),
                orderid: itemmap[i]['messageid'],
                // sellerid: sellerid,
                sellername: sellername,
                items: itemsorder,
                offerstage: itemmap[i]['offerstage'],
                orderamount: itemmap[i]['offer'],
                messageid: itemmap[i]['messageid']);

            buyingItem.add(order);
          }
        }
        if (mounted) {
          setState(() {
            currency = 'AED';
            keepalive = false;
            loading = false;
            buyingItem = new List.from(buyingItem.reversed);
          });
        }
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
    final response = await http.get(Uri.parse(itemurl));
    if (response.statusCode == 200) {
      var itemrespons = json.decode(response.body);
      List itemmap = itemrespons;

      List<Item> ites = List<Item>();

      if (itemmap != null) {
        for (var i = 0; i < itemmap.length; i++) {
          Item ite = Item(
              itemid: itemmap[i]['item']['_id']['\$oid'],
              name: itemmap[i]['item']['name'],
              image: itemmap[i]['item']['image'],
              weight: itemmap[i]['item']['weight'].toString(),
              price: itemmap[i]['offer'].toString(),
              messageid: itemmap[i]['messageid'].toString(),
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

  List<Orders> buyingItem = new List<Orders>();
  List<Item> sellingItem = new List<Item>();

  Widget offerstatus(BuildContext context, offerstage, offerprice) {
    if (offerstage == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 155,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: Color.fromRGBO(69, 80, 163, 1),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Pending Offer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                  fontSize: 14.0,
                  color: Colors.white),
            )),
          ),
        ],
      );
    } else if (offerstage == 2) {
      return Container(
          width: 155,
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(5)),
          child: Center(
              child: Text(
            'Pay',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                fontSize: 14.0,
                color: Colors.white),
          )));
    } else if (offerstage == 3) {
      return Container(
          width: 155,
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.deepOrange, borderRadius: BorderRadius.circular(5)),
          child: Center(
              child: Text(
            'Payment Completed',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                fontSize: 14.0,
                color: Colors.white),
          )));
    } else if (offerstage == 4) {
      return Container(
          width: 155,
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.deepOrange, borderRadius: BorderRadius.circular(5)),
          child: Center(
              child: Text(
            'Item Delivered',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                fontSize: 14.0,
                color: Colors.white),
          )));
    } else if (offerstage == 5) {
      return Container(
          width: 155,
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(5)),
          child: Center(
              child: Text(
            'Order Completed',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
                fontSize: 14.0,
                color: Colors.white),
          )));
    } else if (offerstage == -1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 155,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Offer Declined',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                  fontSize: 14.0,
                  color: Colors.white),
            )),
          ),
        ],
      );
    } else if (offerstage == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 155,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: Color.fromRGBO(69, 80, 163, 1),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Counter Offer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica',
                  fontSize: 14.0,
                  color: Colors.white),
            )),
          ),
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
                                        child: SpinKitDoubleBounce(
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

                            final response = await http.get(Uri.parse(itemurl));

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
                                      child: SpinKitDoubleBounce(
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

                          final response = await http.get(Uri.parse(itemurl));

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
        body: loading == false
            ? buyingItem.isNotEmpty
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
                        triggerDistance: 150.0,
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
                              return buyingItem.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: InkWell(

                                          // final result = await Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => ChatPageView(
                                          //           freedelivery:
                                          //               buyingItem[index]
                                          //                   .freedelivery,
                                          //           itemsold: buyingItem[index]
                                          //               .sold,
                                          //           storeid: buyingItem[index]
                                          //               .userid,
                                          //           storetype: buyingItem[index]
                                          //               .storetype,
                                          //           storename: buyingItem[index]
                                          //               .username,
                                          //           itemid: buyingItem[index]
                                          //               .itemid,
                                          //           recipentid: buyingItem[index]
                                          //               .sellerid,
                                          //           senderid: buyingItem[index]
                                          //               .buyerid,
                                          //           recipentname:
                                          //               buyingItem[index]
                                          //                   .sellername,
                                          //           itemprice: buyingItem[index]
                                          //               .price,
                                          //           messageid: buyingItem[index]
                                          //               .messageid,
                                          //           offer: buyingItem[index]
                                          //               .price,
                                          //           offerstage:
                                          //               buyingItem[index].offerstage,
                                          //           itemimage: buyingItem[index].image,
                                          //           itemname: buyingItem[index].name,
                                          //           item: buyingItem[index])),
                                          // );
                                          // if (result == null) {
                                          //   setState(() {
                                          //     loading = true;
                                          //   });
                                          //   return loadbuyingactivity();
                                          // }

                                          enableFeedback: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderBuyer(
                                                        items: buyingItem[index]
                                                            .items,
                                                        messageid:
                                                            buyingItem[index]
                                                                .messageid,
                                                      )),
                                            );
                                          },
                                          child: Container(
                                              height: 290,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 5),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    dense: true,
                                                    title: Text(
                                                      buyingItem[index]
                                                          .sellername
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    subtitle: Text(
                                                      'ORDER ' +
                                                          buyingItem[index]
                                                              .orderid
                                                              .toUpperCase(),
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 12,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                    trailing: InkWell(
                                                        onTap: () {
                                                          // Navigator.push(
                                                          //   context,
                                                          //   MaterialPageRoute(
                                                          //       builder:
                                                          //           (context) =>
                                                          //               Details(
                                                          //                 source:
                                                          //                     'activity',
                                                          //                 item:
                                                          //                     buyingItem[index],
                                                          //                 itemid:
                                                          //                     buyingItem[index].itemid,
                                                          //                 image:
                                                          //                     buyingItem[index].image,
                                                          //                 name:
                                                          //                     buyingItem[index].name,
                                                          //                 sold:
                                                          //                     buyingItem[index].sold,
                                                          //               )),
                                                          // );
                                                        },
                                                        child: Container(
                                                            width: 100,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  'AED ' +
                                                                      buyingItem[
                                                                              index]
                                                                          .orderamount,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ))),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      child: Divider()),
                                                  Container(
                                                      height: 135,
                                                      child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              buyingItem[index]
                                                                  .items
                                                                  .length,
                                                          itemBuilder:
                                                              (context, i) {
                                                            return InkWell(
                                                              onTap: () {},
                                                              child: Container(
                                                                height: 120,
                                                                width: 120,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Stack(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                70,
                                                                            width:
                                                                                70,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              child: CachedNetworkImage(
                                                                                height: 200,
                                                                                width: 300,
                                                                                fadeInDuration: Duration(microseconds: 5),
                                                                                imageUrl: buyingItem[index].items[i].image,
                                                                                fit: BoxFit.cover,
                                                                                placeholder: (context, url) => SpinKitDoubleBounce(color: Colors.deepOrange),
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                    SizedBox(
                                                                      height: 2,
                                                                    ),
                                                                    Text(
                                                                      buyingItem[
                                                                              index]
                                                                          .items[
                                                                              i]
                                                                          .name,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 2,
                                                                    ),
                                                                    buyingItem[index].items[i].saleprice !=
                                                                            null
                                                                        ? Text
                                                                            .rich(
                                                                            TextSpan(
                                                                              children: <TextSpan>[
                                                                                new TextSpan(
                                                                                  text: 'AED ' + buyingItem[index].items[i].saleprice.toString(),
                                                                                  style: new TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                new TextSpan(
                                                                                  text: '\nAED ' + buyingItem[index].items[i].price.toString(),
                                                                                  style: new TextStyle(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 10,
                                                                                    decoration: TextDecoration.lineThrough,
                                                                                  ),
                                                                                ),
                                                                                new TextSpan(
                                                                                  text: ' -' + (((double.parse(buyingItem[index].items[i].price.toString()) - double.parse(buyingItem[index].items[i].saleprice.toString())) / double.parse(buyingItem[index].items[i].price.toString())) * 100).toStringAsFixed(0) + '%',
                                                                                  style: new TextStyle(
                                                                                    color: Colors.red,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            'AED ' +
                                                                                buyingItem[index].items[i].price.toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 12,
                                                                            ),
                                                                          )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      child: Divider()),
                                                  ListTile(
                                                    dense: true,
                                                    title: offerstatus(
                                                      context,
                                                      buyingItem[index]
                                                          .offerstage,
                                                      buyingItem[index]
                                                          .orderamount,
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    trailing: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OrderBuyer(
                                                                          items:
                                                                              buyingItem[index].items,
                                                                          messageid:
                                                                              buyingItem[index].messageid,
                                                                        )),
                                                          );
                                                        },
                                                        child: Container(
                                                            width: 100,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  'View Details',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        14,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            65,
                                                                            105,
                                                                            225,
                                                                            1),
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  FeatherIcons
                                                                      .chevronRight,
                                                                  size: 16,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          65,
                                                                          105,
                                                                          225,
                                                                          1),
                                                                )
                                                              ],
                                                            ))),
                                                  ),
                                                ],
                                              ))))
                                  : Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ));
                            },
                            childCount: buyingItem.length,
                          ),
                        )
                      ])
                : EasyRefresh.custom(
                    onRefresh: () {
                      setState(() {
                        loading = true;
                      });
                      return loadbuyingactivity();
                    },
                    header: CustomHeader(
                        extent: 40.0,
                        enableHapticFeedback: true,
                        triggerDistance: 150.0,
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
                        SliverFillRemaining(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(left: 20, right: 20, top: 40),
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
                                  Text('Browse products and start ordering.',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'You can make purchases, track your orders and checkout your offers here. What are you waiting for?',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16.0,
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(25.0),
                                          ),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.4),
                                                offset: const Offset(1.1, 1.1),
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
                        )
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
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 150.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 150.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ));
  }
}
