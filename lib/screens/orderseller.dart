import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/models/tracking.dart';
import 'package:SellShip/screens/ReviewBuyer.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/storepage.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/tracking.dart';
import 'package:SellShip/screens/useritems.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class OrderSeller extends StatefulWidget {
  List<Item> items;
  String messageid;

  OrderSeller({Key key, this.messageid, this.items}) : super(key: key);
  @override
  _OrderSellerState createState() => _OrderSellerState();
}

class _OrderSellerState extends State<OrderSeller> {
  String messageid;
  var addressline1;
  var city;
  var state;
  var paymentby;
  var payment;
  String itemid;
  var deliveryaddress;

  var zipcode;

  bool addressreturned = false;

  getuserDetails() async {
    var url = 'https://api.sellship.co/api/user/' + buyerid;
    final response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);

    var users;
    if (jsonbody['username'] == null) {
      users = jsonbody['first_name'];
    } else {
      users = jsonbody['username'];
    }
    setState(() {
      profilepicture = jsonbody['profilepicture'];
      username = users;
    });
  }

  var country;
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
        item.add(ite);
      });
    }

    setState(() {
      item = item;
      fees = fees;
    });

    getuserDetails();
    getstore(item[0].userid);

    return item;
  }

  double discountprice = 0.0;
  double subtotal = 0.0;
  double orderprice = 0.0;
  List<Item> item = [];
  var fees;
  var storeid;

  var username;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      messageid = widget.messageid;
    });

    print(messageid);

    getDetails();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:SellerOrderPage',
      screenClassOverride: 'AppSellerOrderPage',
    );
  }

  var userid;
  var currency;

  final storage = new FlutterSecureStorage();
  int cancelled;
  Item newitem = new Item();
  var deliveredtext;

  var qty;
  var size;

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

    if (messageid != null) {
      var url = 'https://api.sellship.co/api/transactionhistory/' + messageid;

      final response = await http.get(Uri.parse(url));

      var qt;
      var sz;
      var jsonbody = json.decode(response.body);

      if (jsonbody.containsKey('orderquantity')) {
        qt = jsonbody['orderquantity'];
      } else {
        qt = '1';
      }

      if (jsonbody.containsKey('ordersize')) {
        if (jsonbody['ordersize'] != 'nosize') {
          sz = (jsonbody['ordersize']);
        } else {
          sz = '';
        }
      } else {
        sz = '';
      }
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
        deliveredtext = 'Create Label';
      } else if (delstage == 1) {
        deliveredtext = 'Item Shipped';
      } else if (delstage == 2) {
        deliveredtext = 'Waiting for Delivery';
      } else if (delstage == 3) {
        deliveredtext = 'Review Buyer';
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

      var comple;
      if (jsonbody['buyerreviewed'] == null) {
        comple = false;
      } else {
        comple = jsonbody['buyerreviewed'];
      }

      setState(() {
        itemprice = jsonbody['totalpayable'];
        totalpaid = jsonbody['totalpayable'];
        date = s;
        cancelled = cancell;
        completed = comple;
        fees = jsonbody['userearnings'];
        size = sz;
        qty = qt;
        delivered = deliver;
        orderid = jsonbody['messageid'];
        trackingnumber = track;
        deliverystage = delstage;
        buyerid = jsonbody['senderid'];
        buyername = jsonbody['buyername'];
        addressline1 = jsonbody['deliveryaddress']['addressline1'];
        addressline2 = jsonbody['deliveryaddress']['addressline2'];
        area = jsonbody['deliveryaddress']['area'];
        city = jsonbody['deliveryaddress']['city'];
        country = jsonbody['deliveryaddress']['country'];
      });

      fetchItem();
    } else {}
  }

  var delivered;
  var completed;
  getstore(storeid) async {
    var url = 'https://api.sellship.co/api/store/' + storeid;
    final response = await http.get(Uri.parse(url));
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      print(jsonbody);

      Stores store = Stores(
          storeid: jsonbody['_id']['\$oid'],
          storelogo: jsonbody['storelogo'],
          storebio: jsonbody['address'],
          storename: jsonbody['storename']);

      setState(() {
        mystore = store;
        loading = false;
      });
    }
  }

  Stores mystore;
  var orderid;
  var addressline2;
  var area;

  var itemprice;
  var totalpaid;
  var buyerid;
  var itemfees;
  var date;
  var trackingnumber;
  var buyername;
  bool loading;

  int deliverystage;

  Widget deliveryinformation(BuildContext context) {
    if (deliverystage == 0) {
      return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Row(
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
                    'Prepare and Print',
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
                    'Please prepare your delivery by packaging your item in a safe and contained box or envelope. The delivery pickup team will be in touch with you shortly, to arrange a pickup.',
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
        ),
      );
    } else if (deliverystage == 1) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Icon(
                      FeatherIcons.box,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ]),
            Container(
              padding: const EdgeInsets.all(15.0),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Ship the Item',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '1. Upon completing preperation of your item, tap on \'Find Nearby Drop Off\' to find your nearest drop off point',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '2. Drop off your item in the nearest drop off point.',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '3. Tap on \'Item Shipped\' once completed to notify the buyer the item has shipped successfully',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (deliverystage == 2) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Icon(
                      FeatherIcons.clock,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ]),
            Container(
              padding: const EdgeInsets.all(15.0),
              width: MediaQuery.of(context).size.width * 0.85,
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
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Kick back and relax! your item is on the way to the buyer, once the buyer confirms delivery you may review the buyer and recieve your money!',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (deliverystage == 3) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Icon(
                      FeatherIcons.clock,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ]),
            Container(
              padding: const EdgeInsets.all(15.0),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Review Buyer',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Your item has been delivered! Make sure to review your experience with the buyer! This helps build the SellShip community!',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget deliverystagewidget(BuildContext context) {
    if (deliverystage == 0) {
      return Container(
          height: 110,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: Icon(Icons.label_rounded),
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
                          Icons.local_shipping_sharp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('In Transit')
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
                          Icons.check_box,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Delivered')
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
                          Icons.star,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Review')
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: Icon(Icons.label_rounded),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Picked-up',
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
                          Icons.local_shipping_sharp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'In Transit',
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
                          Icons.check_box,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Delivered')
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
                          Icons.star,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Review')
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width / 1.4,
                            lineHeight: 8.0,
                            percent: 0.55,
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
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: Icon(Icons.label_rounded),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Picked-up',
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
                          Icons.local_shipping_sharp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'In Transit',
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
                          Icons.check_box,
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
                          Icons.star,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Review')
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width / 1.4,
                            lineHeight: 8.0,
                            percent: 0.75,
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
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: Icon(Icons.label_rounded),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Picked-up',
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
                          Icons.local_shipping_sharp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'In Transit',
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
                          Icons.check_box,
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
                          Icons.star,
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
                          fontWeight: FontWeight.bold),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width / 1.4,
                            lineHeight: 8.0,
                            percent: 0.85,
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
                                            'Pickup Address',
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
                                        mystore.storebio,
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
                                completed == false
                                    ? delivered == false
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 20),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                      onTap: () async {
                                                        var url =
                                                            'https://api.sellship.co/api/sendlabel/$messageid';
                                                        print(url);
                                                        final response =
                                                            await http.get(
                                                                Uri.parse(url));
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            useRootNavigator:
                                                                false,
                                                            builder: (_) =>
                                                                new AlertDialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10.0))),
                                                                  content:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      return Container(
                                                                          height:
                                                                              170,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              CircleAvatar(
                                                                                backgroundColor: Colors.deepOrangeAccent,
                                                                                child: Icon(
                                                                                  Icons.receipt,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Text(
                                                                                'Please check your email, to find the delivery pickup label.',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Helvetica',
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              TextButton(
                                                                                child: Text(
                                                                                  'Close',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(fontSize: 16.0, color: Colors.red, fontWeight: FontWeight.w800),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ));
                                                                    },
                                                                  ),
                                                                ));
                                                      },
                                                      enableFeedback: true,
                                                      child: Container(
                                                        height: 52,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.deepOrange,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                5.0),
                                                          ),
                                                        ),
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.print,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              'Print Label',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                      )),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    'Packing Instructions',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    """1. Pack the items you're shipping with care.\n\n2.Print your shipping label and attach it to the package. Cover any existing shipping labels.\n\n3.Give the package to the carrier identified on the label. Ensure the label can be seen by the carrier, as it helps track the shippment throughout the delivery process.""",
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                ]))
                                        : Container()
                                    : Container(),
                                completed == true
                                    ? delivered == true
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : Container()
                                    : Container(),
                                completed == false
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
                                                        ReviewBuyer(
                                                          messageid: messageid,
                                                          reviewuserid: buyerid,
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
                                                    'Review Buyer',
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
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  subtotal != 0.0
                                      ? currency +
                                          ' ' +
                                          subtotal.toStringAsFixed(2)
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
                                  'You Earn',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  subtotal != 0.0
                                      ? currency + ' ' + fees.toStringAsFixed(2)
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
                              'Ordered by: ',
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
                                            builder: (context) => UserItems(
                                                  userid: buyerid,
                                                  username: username,
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
                                                    BorderRadius.circular(25),
                                                child: CachedNetworkImage(
                                                  height: 200,
                                                  width: 300,
                                                  imageUrl: profilepicture,
                                                  fit: BoxFit.cover,
                                                )),
                                          )
                                        : CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.deepOrange,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Image.asset(
                                                'assets/personplaceholder.png',
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )),
                                    title: Text(
                                      username != null ? '@' + username : '',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(
                                      FeatherIcons.chevronRight,
                                      color: Colors.blueGrey,
                                      size: 16,
                                    ),
                                    contentPadding: EdgeInsets.zero),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ]),
                    )),

                Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
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
                // deliverystage == 0
                //     ? InkWell(
                //         onTap: () {
                //           showDialog(
                //               context: context,
                //               barrierDismissible: false,
                //               builder: (BuildContext context) =>
                //                   CupertinoAlertDialog(
                //                     title: new Text(
                //                       "Cancel this transaction",
                //                       style: TextStyle(
                //                           fontFamily: 'Helvetica',
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.w700),
                //                     ),
                //                     content: new Text(
                //                       "Are you sure you want to cancel this transaction?",
                //                       style: TextStyle(
                //                           fontFamily: 'Helvetica',
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.w400),
                //                     ),
                //                     actions: <Widget>[
                //                       CupertinoDialogAction(
                //                         isDefaultAction: true,
                //                         onPressed: () async {
                //                           var url =
                //                               'https://api.sellship.co/api/cancelbuyer/' +
                //                                   messageid;
                //
                //                           final response =
                //                               await http.get(Uri.parse(url));
                //
                //                           if (response.statusCode == 200) {
                //                             Navigator.of(context).pop();
                //                             Navigator.of(context).pop();
                //                           }
                //                         },
                //                         child: Text(
                //                           'Yes',
                //                           style: TextStyle(
                //                               fontFamily: 'Helvetica',
                //                               fontSize: 16,
                //                               fontWeight: FontWeight.w700),
                //                         ),
                //                       ),
                //                       CupertinoDialogAction(
                //                         onPressed: () {
                //                           Navigator.of(context).pop();
                //                         },
                //                         child: Text(
                //                           "No",
                //                           style: TextStyle(
                //                               fontFamily: 'Helvetica',
                //                               fontSize: 16,
                //                               fontWeight: FontWeight.w700),
                //                         ),
                //                       )
                //                     ],
                //                   ));
                //         },
                //         child: cancelled != null
                //             ? Container()
                //             : Padding(
                //                 padding: EdgeInsets.only(
                //                     left: 10, bottom: 10, top: 20),
                //                 child: Align(
                //                   alignment: Alignment.centerLeft,
                //                   child: Text(
                //                     'Cancel this transaction',
                //                     style: TextStyle(
                //                       fontFamily: 'Helvetica',
                //                       fontSize: 16,
                //                       color: Colors.red,
                //                     ),
                //                   ),
                //                 ),
                //               ))
                //     : Container(),
                SizedBox(
                  height: 5,
                ),
              ])
            : Center(
                child: SpinKitDoubleBounce(
                color: Colors.deepOrange,
              )));
  }
}
