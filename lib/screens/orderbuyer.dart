import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/tracking.dart';

import 'package:SellShip/screens/ReviewSeller.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/tracking.dart';
import 'package:SellShip/screens/useritems.dart';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderBuyer extends StatefulWidget {
  String messageid;
  List<Item> items;

  OrderBuyer({Key key, this.messageid, this.items}) : super(key: key);
  @override
  _OrderBuyerState createState() => _OrderBuyerState();
}

class _OrderBuyerState extends State<OrderBuyer> {
  String itemid;
  String messageid;

  var country;

  getuserDetails() async {
    var userurl = 'https://api.sellship.co/api/store/' + user;
    final userresponse = await http.get(Uri.parse(userurl));

    print(userresponse.body);

    var userjsonbody = json.decode(userresponse.body);

    setState(() {
      profilepicture = userjsonbody['storelogo'];
    });
    var url = 'https://api.sellship.co/api/user/' + user;
    final response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);
  }

  var profilepicture;

  fetchItem() async {
    var countr = await storage.read(key: 'country');
    userid = await storage.read(key: 'userid');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
        country = countr;
      });
    }

    for (int i = 0; i < widget.items.length; i++) {
      Item ite = Item(
          name: widget.items[i].name,
          selectedsize: widget.items[i].selectedsize,
          quantity: widget.items[i].quantity,
          weight: widget.items[i].weight,
          freedelivery: widget.items[i].freedelivery,
          price: widget.items[i].price,
          saleprice: widget.items[i].saleprice == null
              ? null
              : widget.items[i].saleprice,
          image: widget.items[i].image,
          userid: widget.items[i].sellerid == null
              ? widget.items[i].userid
              : widget.items[i].sellerid,
          username: widget.items[i].sellername == null
              ? widget.items[i].username
              : widget.items[i].sellername);

      if (widget.items[i].saleprice != null) {
        subtotal = double.parse(widget.items[i].saleprice) + subtotal;
        discountprice = (double.parse(widget.items[i].price) -
                double.parse(widget.items[i].saleprice)) +
            discountprice;
      } else {
        subtotal = double.parse(widget.items[i].price) + subtotal;
      }
      orderprice = double.parse(widget.items[i].price) + orderprice;
      setState(() {
        user = widget.items[i].userid;
        item.add(ite);
      });
    }

    getuserDetails();
    return item;
  }

  double discountprice = 0.0;
  double subtotal = 0.0;
  double orderprice = 0.0;
  var user;
  List<Item> item = [];
  GlobalKey _toolTipKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      messageid = widget.messageid;
    });

    fetchItem();

    getDetails();
  }

  var userid;
  var trackingnumber;
  var currency;

  final storage = new FlutterSecureStorage();

  int cancelled;

  getDetails() async {
    userid = await storage.read(key: 'userid');

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

    print(messageid);

    var url = 'https://api.sellship.co/api/transactionhistory/' + messageid;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      final f = new DateFormat('dd, MMM yyyy,');
      DateTime datet =
          new DateTime.fromMillisecondsSinceEpoch(jsonbody['date']['\$date']);
      var s = f.add_jm().format(datet);
      print(s);

      var delstage;
      if (jsonbody['deliverystage'] == null) {
        delstage = 0;
      } else {
        delstage = jsonbody['deliverystage'];
      }

      var cancell;
      if (jsonbody['cancelled'] == null) {
        cancell = null;
      } else {
        cancell = jsonbody['cancelled'];
      }

      if (delstage == 0) {
        deliveredtext = 'Preparing Item..';
      } else if (delstage == 1) {
        deliveredtext = 'Shipping Item..';
      } else if (delstage == 2) {
        deliveredtext = 'Item has been delivered';
      } else if (delstage == 3) {
        deliveredtext = 'Review Seller';
      }

      var track;
      if (jsonbody['awbno'] == null) {
        track = '';
      } else {
        track = jsonbody['awbno'];
      }

      var deliver;
      if (jsonbody['delivered'] == null) {
        deliver = false;
      } else {
        deliver = jsonbody['delivered'];
      }

      var deliveryamoun;
      if (jsonbody['deliveryamount'] == null) {
        deliveryamoun = 'FREE';
      } else {
        deliveryamoun = jsonbody['deliveryamount'];
      }

      var comple;
      if (jsonbody['sellerreviewed'] == null) {
        comple = false;
      } else {
        comple = jsonbody['sellerreviewed'];
      }

      var sz;
      if (jsonbody['ordersize'] == 'nosize') {
        sz = '';
      } else {
        sz = jsonbody['ordersize'];
      }

      setState(() {
        itemprice = jsonbody['totalpayable'];
        totalpaid = jsonbody['totalpayable'];
        date = s;
        cancelled = cancell;
        orderid = messageid;
        trackingnumber = track;
        completed = comple;
        delivered = deliver;
        deliverystage = delstage;
        buyerid = jsonbody['senderid'];
        buyername = jsonbody['buyername'];
        size = sz;

        deliveryamount = deliveryamoun;
        quantity = jsonbody['orderquantity'];
        addressline1 = jsonbody['deliveryaddress']['addressline1'];
        addressline2 = jsonbody['deliveryaddress']['addressline2'];
        area = jsonbody['deliveryaddress']['area'];
        city = jsonbody['deliveryaddress']['city'];
        country = jsonbody['deliveryaddress']['country'];
        loading = false;
      });
    }
  }

  var quantity;
  var size;
  var date;
  var deliveryamount;
  var time = 0;

  Item newitem;
  var delivered;
  var completed;
  var deliveredtext;
  var orderid;
  var itemprice;
  var totalpaid;
  var addressline1;
  var addressline2;
  var area;
  var city;

  var buyerid;
  var itemfees;

  var buyername;
  bool loading;

  int deliverystage;

  double percentindicator = 0.20;

  Widget deliveryinformation(BuildContext context) {
    if (deliverystage == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Preparing',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Have a sip of that coffee and layback! Your item is being prepared by the seller, we will notify you when the item has been shipped',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (deliverystage == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Shipping',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'The seller is going to drop off your item, you can track the status of your item using the Tracking Number.',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (deliverystage == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Waiting for Delivery',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Keep a lookout for the postman! Your item is on the way! Deliveries normally take 3-5 business days once dropped off by the seller!',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (deliverystage == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Hooray!',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Congratulations on recieving your item! Make sure to confirm the item is as described and review your seller! This helps build the SellShip community!',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget deliverystagewidget(BuildContext context) {
    if (deliverystage == 0) {
      return Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.timer,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Waiting for Pickup',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueGrey,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Delivered',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueGrey,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Review',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 10,
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width / 1.4,
                                lineHeight: 8.0,
                                percent: 0.25,
                                progressColor: Colors.deepOrange,
                              ),
                            ),
                          )),
                    ])
              ]));
    } else if (deliverystage == 1) {
      return Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.timer,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Item Picked',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Waiting for Delivery',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueGrey,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Review',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 10,
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width / 1.4,
                                lineHeight: 8.0,
                                percent: 0.40,
                                progressColor: Colors.deepOrange,
                              ),
                            ),
                          )),
                    ])
              ]));
    } else if (deliverystage == 2) {
      return Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.timer,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Picked Up',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Delivered',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Review',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 10,
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width / 1.4,
                                lineHeight: 8.0,
                                percent: 0.80,
                                progressColor: Colors.deepOrange,
                              ),
                            ),
                          )),
                    ])
              ]));
    } else if (deliverystage == 3) {
      return Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.timer,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Picked Up',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Delivered',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            child: Icon(
                              Icons.local_shipping_rounded,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Reviewed',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            bottom: 5,
                            top: 10,
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width / 1.4,
                                lineHeight: 8.0,
                                percent: 1.00,
                                progressColor: Colors.deepOrange,
                              ),
                            ),
                          )),
                    ])
              ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RootScreen()),
              );
            },
            child: Icon(
              FeatherIcons.chevronLeft,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Order',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: loading == false
            ? ListView(children: <Widget>[
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 5,
                  ),
                  child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ], color: Colors.white),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            completed == false
                                ? delivered == true
                                    ? Text(
                                        'This order will automatically be marked complete once the Buyer\'s Protection period ends.',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 13,
                                            color: Colors.blueGrey),
                                      )
                                    : Container()
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Order -',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      color: Colors.blueGrey),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Container(
                                    child: Text(
                                  orderid.toString().toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(27, 44, 64, 1)),
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Order placed on ' + date.toString(),
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 14,
                                  color: Colors.blueGrey),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Divider(),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                  top: 10,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.shippingFast,
                                            size: 16,
                                            color: Colors.blueGrey,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Delivery Address',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          child: Text(
                                        addressline1 +
                                            '\n' +
                                            addressline2 +
                                            '\n' +
                                            area +
                                            '\n' +
                                            city +
                                            '\n' +
                                            country,
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            color:
                                                Color.fromRGBO(27, 44, 64, 1)),
                                      )),
                                    ]))
                          ])),
                ),
                trackingnumber.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 10, top: 5, right: 15),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Tracking ID: ',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.blueGrey),
                                    ),
                                    Container(
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TrackingDetails(
                                                        trackingnumber:
                                                            trackingnumber,
                                                      )),
                                            );
                                          },
                                          child: Text(
                                            trackingnumber,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange),
                                          )),
                                    ),
                                  ],
                                ),
                                completed == true
                                    ? delivered == true
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : Container()
                                    : Container(),
                                completed == false
                                    ? delivered == true
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReviewSeller(
                                                          messageid: messageid,
                                                          reviewuserid: widget
                                                              .items[0].userid,
                                                        )),
                                              );
                                            },
                                            enableFeedback: true,
                                            child: Container(
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: Colors.deepOrange,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      color: Colors.deepOrange
                                                          .withOpacity(0.4),
                                                      offset: const Offset(
                                                          1.1, 1.1),
                                                      blurRadius: 10.0),
                                                ],
                                              ),
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    'Review Seller',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ))
                                        : Container()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                            Icon(
                                              Icons.check,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'The Order has been Completed',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green),
                                            ),
                                          ]),
                                SizedBox(
                                  height: 5,
                                ),
                                completed == false
                                    ? delivered == true
                                        ? Text(
                                            'On tapping \'Review Seller\' you hereby confirm the order as complete and agree to the terms and conditions. On accepting the order as complete, Buyers Protection will no longer be applicable. ',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 13,
                                                color: Colors.blueGrey),
                                          )
                                        : Container()
                                    : Container()
                              ]),
                        ))
                    : Container(),
                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 5,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ], color: Colors.white),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: item.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Details(
                                                          itemid: item[index]
                                                              .itemid,
                                                          name:
                                                              item[index].name,
                                                          sold:
                                                              item[index].sold,
                                                          source: 'activity',
                                                          image:
                                                              item[index].image,
                                                        )),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: 80,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          child: item[index]
                                                                  .image
                                                                  .isNotEmpty
                                                              ? Hero(
                                                                  tag:
                                                                      'activity${item[index].itemid}',
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: item[
                                                                            index]
                                                                        .image,
                                                                    height: 200,
                                                                    width: 300,
                                                                    fadeInDuration:
                                                                        Duration(
                                                                            microseconds:
                                                                                5),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder: (context,
                                                                            url) =>
                                                                        SpinKitDoubleBounce(
                                                                            color:
                                                                                Colors.deepOrange),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                )
                                                              : SpinKitFadingCircle(
                                                                  color: Colors
                                                                      .deepOrange,
                                                                )),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  3 -
                                                              10,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height: 25,
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                10,
                                                            child: Text(
                                                              item[index].name,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Sold by @' +
                                                                item[index]
                                                                    .username,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          item[index].selectedsize !=
                                                                      'nosize' &&
                                                                  item[index]
                                                                          .selectedsize !=
                                                                      null
                                                              ? Text(
                                                                  'Size: ' +
                                                                      item[index]
                                                                          .selectedsize
                                                                          .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .grey),
                                                                )
                                                              : Container(),
                                                          item[index].quantity !=
                                                                  null
                                                              ? Text(
                                                                  'Quantity: ' +
                                                                      item[index]
                                                                          .quantity
                                                                          .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .grey),
                                                                )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  3 -
                                                              10,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          item[index].saleprice !=
                                                                  null
                                                              ? Text.rich(
                                                                  TextSpan(
                                                                    children: <
                                                                        TextSpan>[
                                                                      new TextSpan(
                                                                        text: 'AED ' +
                                                                            item[index].saleprice,
                                                                        style: new TextStyle(
                                                                            color: Colors
                                                                                .redAccent,
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      new TextSpan(
                                                                        text: '\nAED ' +
                                                                            item[index].price.toString(),
                                                                        style:
                                                                            new TextStyle(
                                                                          color:
                                                                              Colors.grey,
                                                                          fontSize:
                                                                              10,
                                                                          decoration:
                                                                              TextDecoration.lineThrough,
                                                                        ),
                                                                      ),
                                                                      new TextSpan(
                                                                        text: ' -' +
                                                                            (((double.parse(item[index].price.toString()) - double.parse(item[index].saleprice.toString())) / double.parse(item[index].price.toString())) * 100).toStringAsFixed(0) +
                                                                            '%',
                                                                        style:
                                                                            new TextStyle(
                                                                          color:
                                                                              Colors.red,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Text(
                                                                  currency +
                                                                      ' ' +
                                                                      item[index]
                                                                          .price,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                            )),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ));
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Divider(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  orderprice != 0.0
                                      ? currency +
                                          ' ' +
                                          orderprice.toStringAsFixed(2)
                                      : 'AED 0',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          discountprice != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Discount',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      subtotal != 0.0
                                          ? ' -' +
                                              discountprice.toStringAsFixed(2)
                                          : 'AED 0',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Divider(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  subtotal != 0.0
                                      ? currency +
                                          ' ' +
                                          subtotal.toStringAsFixed(2)
                                      : 'AED 0',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),

                // cancelled != null
                //     ? Padding(
                //         padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                //         child: Align(
                //           alignment: Alignment.centerLeft,
                //           child: Text(
                //             'Transaction has been cancelled',
                //             style: TextStyle(
                //                 fontFamily: 'Helvetica',
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w700),
                //           ),
                //         ),
                //       )
                //     : deliveryinformation(context),

                item != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                          top: 5,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ], color: Colors.white),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sold by: ',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StorePublic(
                                                      storeid: item[0].userid,
                                                      storename:
                                                          item[0].username,
                                                    )),
                                          );
                                        },
                                        dense: true,
                                        leading: profilepicture != null &&
                                                profilepicture.isNotEmpty
                                            ? Container(
                                                height: 50,
                                                width: 50,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    child: CachedNetworkImage(
                                                      height: 200,
                                                      width: 300,
                                                      imageUrl: profilepicture,
                                                      fit: BoxFit.cover,
                                                    )),
                                              )
                                            : CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: Image.asset(
                                                    'assets/personplaceholder.png',
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                )),
                                        title: Text(
                                          '@' + item[0].username,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Icon(
                                          FeatherIcons.chevronRight,
                                          color: Colors.black,
                                        ),
                                        contentPadding: EdgeInsets.zero),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ]),
                        ))
                    : SpinKitDoubleBounce(
                        color: Colors.deepOrange,
                      ),

                Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                      top: 5,
                    ),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ], color: Colors.white),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top: 0),
                                  child: InkWell(
                                    onTap: () async {
                                      await Intercom.initialize(
                                        'z4m2b833',
                                        androidApiKey:
                                            'android_sdk-78eb7d5e9dd5f4b508ddeec4b3c54d7491676661',
                                        iosApiKey:
                                            'ios_sdk-2744ef1f27a14461bfda4cb07e8fc44364a38005',
                                      );
                                      userid =
                                          await storage.read(key: 'userid');
                                      await Intercom.registerIdentifiedUser(
                                          userId: userid);

                                      Intercom.displayMessenger();
                                    },
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(
                                        'Need Support?',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      leading: Container(
                                        height: 70,
                                        width: 70,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                255, 115, 0, 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: SvgPicture.asset(
                                            'assets/support.svg',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Chat with us',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Icon(
                                        FeatherIcons.chevronRight,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                            ]))),
                SizedBox(
                  height: 5,
                ),
                //     deliverystage == 0
                //         ? InkWell(
                //             onTap: () {
                //               showDialog(
                //                   context: context,
                //                   barrierDismissible: false,
                //                   builder: (BuildContext context) =>
                //                       CupertinoAlertDialog(
                //                         title: new Text(
                //                           "Cancel this transaction",
                //                           style: TextStyle(
                //                               fontFamily: 'Helvetica',
                //                               fontSize: 16,
                //                               fontWeight: FontWeight.w700),
                //                         ),
                //                         content: new Text(
                //                           "Are you sure you want to cancel this transaction?",
                //                           style: TextStyle(
                //                               fontFamily: 'Helvetica',
                //                               fontSize: 16,
                //                               fontWeight: FontWeight.w400),
                //                         ),
                //                         actions: <Widget>[
                //                           CupertinoDialogAction(
                //                             isDefaultAction: true,
                //                             onPressed: () async {
                //                               var url =
                //                                   'https://api.sellship.co/api/cancelbuyer/' +
                //                                       messageid;
                //
                //                               final response = await http.get(Uri.parse(url));
                //
                //                               if (response.statusCode == 200) {
                //                                 Navigator.of(context).pop();
                //                                 Navigator.of(context).pop();
                //                               }
                //                             },
                //                             child: Text(
                //                               'Yes',
                //                               style: TextStyle(
                //                                   fontFamily: 'Helvetica',
                //                                   fontSize: 16,
                //                                   fontWeight: FontWeight.w700),
                //                             ),
                //                           ),
                //                           CupertinoDialogAction(
                //                             onPressed: () {
                //                               Navigator.of(context).pop();
                //                             },
                //                             child: Text(
                //                               "No",
                //                               style: TextStyle(
                //                                   fontFamily: 'Helvetica',
                //                                   fontSize: 16,
                //                                   fontWeight: FontWeight.w700),
                //                             ),
                //                           )
                //                         ],
                //                       ));
                //             },
                //             child: cancelled != null
                //                 ? Container()
                //                 : Padding(
                //                     padding: EdgeInsets.only(
                //                         left: 10, bottom: 10, top: 20),
                //                     child: Align(
                //                       alignment: Alignment.centerLeft,
                //                       child: Text(
                //                         'Cancel this transaction',
                //                         style: TextStyle(
                //                           fontFamily: 'Helvetica',
                //                           fontSize: 16,
                //                           color: Colors.red,
                //                         ),
                //                       ),
                //                     ),
                //                   ))
                //         : Container(),
                //     SizedBox(
                //       height: 5,
                //     ),
                //   ])
                // : Center(
                //     child: SpinKitDoubleBounce(
                //     color: Colors.deepOrange,
                //   )));
              ])
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                ),
              ));
  }
}
