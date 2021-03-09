import 'dart:convert';

import 'package:SellShip/models/Items.dart';

import 'package:SellShip/screens/ReviewSeller.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:app_review/app_review.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderBuyer extends StatefulWidget {
  String messageid;
  String itemid;

  OrderBuyer({Key key, this.messageid, this.itemid}) : super(key: key);
  @override
  _OrderBuyerState createState() => _OrderBuyerState();
}

class _OrderBuyerState extends State<OrderBuyer> {
  String itemid;
  String messageid;

  var country;

  getuserDetails() async {
    var userurl = 'https://api.sellship.co/api/store/' + user;
    final userresponse = await http.get(userurl);

    print(userresponse.body);

    var userjsonbody = json.decode(userresponse.body);

    setState(() {
      profilepicture = userjsonbody['storelogo'];
    });
    var url = 'https://api.sellship.co/api/user/' + user;
    final response = await http.get(url);

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

    var url = 'https://api.sellship.co/api/getitem/' + widget.itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    item = Item(
        name: jsonbody[0]['name'],
        itemid: jsonbody[0]['_id']['\$oid'].toString(),
        price: jsonbody[0]['price'].toString(),
        description: jsonbody[0]['description'],
        category: jsonbody[0]['category'],
        condition: jsonbody[0]['condition'] == null
            ? 'Like New'
            : jsonbody[0]['condition'],
        image: jsonbody[0]['image'],
        image1: jsonbody[0]['image1'],
        image2: jsonbody[0]['image2'],
        image3: jsonbody[0]['image3'],
        image4: jsonbody[0]['image4'],
        image5: jsonbody[0]['image5'],
        sellerid: jsonbody[0]['selleruserid'],
        sellername: jsonbody[0]['sellerusername'],
        sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
        likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
        city: jsonbody[0]['city'],
        username: jsonbody[0]['username'],
        brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
        size: jsonbody[0]['size'] == null ? '' : jsonbody[0]['size'],
        useremail: jsonbody[0]['useremail'],
        usernumber: jsonbody[0]['usernumber'],
        userid: jsonbody[0]['userid'],
        latitude: jsonbody[0]['latitude'],
        comments: jsonbody[0]['comments'] == null
            ? 0
            : jsonbody[0]['comments'].length,
        longitude: jsonbody[0]['longitude'],
        subsubcategory: jsonbody[0]['subsubcategory'],
        subcategory: jsonbody[0]['subcategory']);

    setState(() {
      user = jsonbody[0]['userid'];
      item = item;
    });

    getuserDetails();
    return item;
  }

  var user;
  Item item;
  GlobalKey _toolTipKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      itemid = widget.itemid;
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

    var url = 'https://api.sellship.co/api/transactionhistory/' + messageid;

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    print(jsonbody);
    final f = new DateFormat('dd-MM-yyyy hh:mm');
    DateTime datet =
        new DateTime.fromMillisecondsSinceEpoch(jsonbody['date']['\$date']);
    var s = f.format(datet);

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

    setState(() {
      itemprice = jsonbody['totalpayable'];
      totalpaid = jsonbody['totalpayable'];
      date = s;
      cancelled = cancell;
      orderid = jsonbody['paymentid'];
      trackingnumber = track;
      deliverystage = delstage;
      buyerid = jsonbody['senderid'];
      buyername = jsonbody['buyername'];
      loading = false;
      addressline1 = jsonbody['deliveryaddress']['addressline1'];
      addressline2 = jsonbody['deliveryaddress']['addressline2'];
      area = jsonbody['deliveryaddress']['area'];
      city = jsonbody['deliveryaddress']['city'];
      country = jsonbody['deliveryaddress']['country'];
    });
  }

  Item newitem;

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
  var date;
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
                SizedBox(height: 10),
                Padding(
                  padding:
                      EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Order ID: ',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Container(
                                    child: Text(
                                  orderid,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(27, 44, 64, 1)),
                                )),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                  top: 20,
                                ),
                                child: Container(
                                    padding: EdgeInsets.all(20),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color:
                                            Color.fromRGBO(27, 44, 64, 0.03)),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Delivered to:',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.blueGrey),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              child: Text(
                                            addressline1 +
                                                ' ' +
                                                addressline2 +
                                                ' ' +
                                                area +
                                                ' ' +
                                                city +
                                                ' ' +
                                                country,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    27, 44, 64, 1)),
                                          )),
                                        ])))
                          ])),
                ),
                Padding(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Tracking ID: ',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                Container(
                                    child: Text(
                                  trackingnumber,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(27, 44, 64, 1)),
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            deliveryinformation(context),
                            SizedBox(
                              height: 20,
                            ),
                            deliverystagewidget(context),
                          ]),
                    )),
                Padding(
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
                              Text(
                                'Items: ',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.blueGrey),
                              ),
                              item != null
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                      itemid: widget.itemid,
                                                      name: item.name,
                                                      sold: item.sold,
                                                      source: 'order',
                                                      image: item.image,
                                                    )),
                                          );
                                        },
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          title: Text(
                                            item.name,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          leading: Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                height: 200,
                                                width: 300,
                                                imageUrl: item.image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          subtitle: Text(
                                            item.category,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            currency +
                                                ' ' +
                                                item.price.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                                  : SpinKitDoubleBounce(
                                      color: Colors.deepOrange,
                                    ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Delivery',
                                    style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text('Free',
                                      style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        color: Colors.green,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 0.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(currency + ' ' + totalpaid.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        letterSpacing: 0.0,
                                        color: Colors.black,
                                      )),
                                ],
                              )
                            ]))),

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
                                Text(
                                  'Seller: ',
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
                                                      storeid: item.userid,
                                                      storename: item.username,
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
                                          '@' + item.username,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
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
                                        Icons.chevron_right,
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
                //                               final response = await http.get(url);
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
