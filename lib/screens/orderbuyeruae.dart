import 'dart:convert';

import 'package:SellShip/models/Items.dart';

import 'package:SellShip/screens/ReviewSeller.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:app_review/app_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderBuyerUAE extends StatefulWidget {
  String messageid;
  Item item;

  OrderBuyerUAE({Key key, this.messageid, this.item}) : super(key: key);
  @override
  _OrderBuyerUAEState createState() => _OrderBuyerUAEState();
}

class _OrderBuyerUAEState extends State<OrderBuyerUAE> {
  Item item;
  String messageid;

  GlobalKey _toolTipKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      item = widget.item;
      messageid = widget.messageid;
    });
    getDetails();
  }

  var userid;

  var currency;
  int cancelled;

  final storage = new FlutterSecureStorage();

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
    if (jsonbody['shipping_details'] == null) {
      track = '';
    } else {
      track = jsonbody['shipping_details']['tracking_no'];
    }

    var wight;
    if (jsonbody['itemobject']['weight'] == null) {
      wight = 5;
    } else {
      wight = int.parse(jsonbody['itemobject']['weight']);
    }

    setState(() {
      itemprice = jsonbody['offer'];
      totalpaid = jsonbody['totalpayable'];
      date = s;
      cancelled = cancell;
      deliverystage = delstage;
      newitem = Item(weight: wight);
      itemfees = jsonbody['fees'];
      buyerid = jsonbody['senderid'];
      buyername = jsonbody['buyername'];
      loading = false;
    });
  }

  Item newitem;

  var deliveredtext;

  var itemprice;
  var totalpaid;
  var buyerid;
  var itemfees;
  var date;
  var buyername;
  bool loading;

  int deliverystage;
//
//  Widget shipfrom(BuildContext context) {
//    if (deliverystage == 0) {
//      return Container();
//    } else if (deliverystage == 1) {
//      return Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Container(
//              decoration: BoxDecoration(
//                color: Colors.white,
//                boxShadow: <BoxShadow>[
//                  BoxShadow(
//                      color: Colors.grey.withOpacity(0.2),
//                      offset: const Offset(0.0, 0.6),
//                      blurRadius: 5.0),
//                ],
//              ),
//              child: ListTile(
//                onTap: () async {
//                  var url =
//                      'http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=' +
//                          trackingnumber;
//
//                  if (await canLaunch(url)) {
//                    await launch(url);
//                  } else {
//                    throw 'Could not launch $url';
//                  }
//                },
//                leading: Text(
//                  'Tracking Number',
//                  style: TextStyle(
//                      fontFamily: 'Helvetica',
//                      fontSize: 16,
//                      fontWeight: FontWeight.w700),
//                ),
//                trailing: Text(
//                  trackingnumber,
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    fontWeight: FontWeight.w700,
//                    fontSize: 14,
//                    letterSpacing: 0.0,
//                    color: Colors.deepPurple,
//                  ),
//                ),
//              ),
//            ),
//          ]);
//    } else if (deliverystage == 2) {
//      return Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Container(
//              decoration: BoxDecoration(
//                color: Colors.white,
//                boxShadow: <BoxShadow>[
//                  BoxShadow(
//                      color: Colors.grey.withOpacity(0.2),
//                      offset: const Offset(0.0, 0.6),
//                      blurRadius: 5.0),
//                ],
//              ),
//              child: ListTile(
//                onTap: () async {
//                  var url =
//                      'http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=' +
//                          trackingnumber;
//
//                  if (await canLaunch(url)) {
//                    await launch(url);
//                  } else {
//                    throw 'Could not launch $url';
//                  }
//                },
//                leading: Text(
//                  'Tracking Number',
//                  style: TextStyle(
//                      fontFamily: 'Helvetica',
//                      fontSize: 16,
//                      fontWeight: FontWeight.w700),
//                ),
//                trailing: Text(
//                  trackingnumber,
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    fontWeight: FontWeight.w700,
//                    fontSize: 14,
//                    letterSpacing: 0.0,
//                    color: Colors.deepPurple,
//                  ),
//                ),
//              ),
//            ),
//          ]);
//    } else if (deliverystage == 3) {
//      return Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Container(
//              decoration: BoxDecoration(
//                color: Colors.white,
//                boxShadow: <BoxShadow>[
//                  BoxShadow(
//                      color: Colors.grey.withOpacity(0.2),
//                      offset: const Offset(0.0, 0.6),
//                      blurRadius: 5.0),
//                ],
//              ),
//              child: ListTile(
//                onTap: () async {
//                  var url =
//                      'http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=' +
//                          trackingnumber;
//
//                  if (await canLaunch(url)) {
//                    await launch(url);
//                  } else {
//                    throw 'Could not launch $url';
//                  }
//                },
//                leading: Text(
//                  'Tracking Number',
//                  style: TextStyle(
//                      fontFamily: 'Helvetica',
//                      fontSize: 16,
//                      fontWeight: FontWeight.w700),
//                ),
//                trailing: Text(
//                  trackingnumber,
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    fontWeight: FontWeight.w700,
//                    fontSize: 14,
//                    letterSpacing: 0.0,
//                    color: Colors.deepPurple,
//                  ),
//                ),
//              ),
//            ),
//          ]);
//    }
//  }

  Widget deliveryinformation(BuildContext context) {
    if (deliverystage == 0) {
      return Container(
        height: 160,
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
                      Feather.box,
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
                    'Preparing',
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
                    'Have a sip of that coffee and layback! Your item is being prepared by the seller, we will notify you when the item is ready',
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
    } else if (deliverystage == 1) {
      return Container(
        height: 160,
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
                      Icons.local_shipping,
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
                    'Meetup/Shipping',
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
                    'The seller is going to ship off your item or send a message to discuss delivery method.',
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
        height: 160,
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
                      Feather.mail,
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
                    'Keep a lookout for the postman or the seller! Your item is on the way! If the item was shipped by the seller deliveries normally take 3-5 business days once dropped off by the seller!',
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
        height: 160,
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
                      FontAwesome.magic,
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
                    'Hooray!',
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
                    'Congratulations on recieving your item! Make sure to confirm the item is as described and review your seller! This helps build the SellShip community!',
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
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: CircleAvatar(
                    radius: 19,
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
                Text('Waiting')
              ],
            ),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.check,
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
      );
    } else if (deliverystage == 1) {
      return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: CircleAvatar(
                    radius: 19,
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
                Text('Waiting')
              ],
            ),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.check,
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
      );
    } else if (deliverystage == 2) {
      return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: CircleAvatar(
                    radius: 19,
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
                Text('Waiting')
              ],
            ),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.check,
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
      );
    } else if (deliverystage == 3) {
      return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    child: Icon(
                      Icons.check,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Waiting')
              ],
            ),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: CircleAvatar(
                    radius: 19,
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
                Text('Review')
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Order Detail',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: loading == false
                ? Column(children: <Widget>[
                    SizedBox(height: 10),
                    deliverystagewidget(context),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Details(
                                          itemid: item.itemid,
                                        )),
                              );
                            },
                            child: Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width,
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
                                child: ListTile(
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
                                      borderRadius: BorderRadius.circular(10),
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
                                    currency + ' ' + item.price.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )))),
                    SizedBox(
                      height: 10,
                    ),
                    cancelled != null
                        ? Padding(
                            padding:
                                EdgeInsets.only(left: 10, bottom: 10, top: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Transaction has been cancelled',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        : deliveryinformation(context),
                    SizedBox(
                      height: 5,
                    ),
//                    shipfrom(context),
                    cancelled != null
                        ? Container()
                        : InkWell(
                            onTap: () async {
                              if (deliverystage == 2) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        CupertinoAlertDialog(
                                          title: new Text(
                                            "Confirm you have recieved the item",
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          content: new Text(
                                            "Please confirm if the item has been delivered!",
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              onPressed: () async {
                                                var url =
                                                    'https://api.sellship.co/api/delivered/uae/' +
                                                        messageid;

                                                final response =
                                                    await http.get(url);

                                                var jsonbody =
                                                    json.decode(response.body);

                                                setState(() {
                                                  deliverystage =
                                                      jsonbody['deliverystage'];
                                                  deliveredtext =
                                                      'Review Seller';
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "No",
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            )
                                          ],
                                        ));
                              } else if (deliverystage == 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReviewSeller(
                                            reviewuserid: item.userid,
                                            messageid: messageid,
                                          )),
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.deepPurpleAccent
                                            .withOpacity(0.4),
                                        offset: const Offset(1.1, 1.1),
                                        blurRadius: 10.0),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    deliveredtext,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                    Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Transaction Details',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 10, bottom: 10, top: 5, right: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  item.name,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                Text(
                                  itemprice.toString() + ' ' + currency,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Total',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                Text(
                                  totalpaid.toStringAsFixed(2) + ' ' + currency,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Transaction Status',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                cancelled != null
                                    ? Text(
                                        'Cancelled',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    : Text(
                                        'Paid',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                              ],
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Seller Information',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: InkWell(
                        child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
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
                          child: Center(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserItems(
                                          userid: item.userid,
                                          username: item.username)),
                                );
                              },
                              dense: true,
                              leading: Icon(FontAwesome.user_circle),
                              title: Text(
                                item.username,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    deliverystage == 0
                        ? InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) =>
                                      CupertinoAlertDialog(
                                        title: new Text(
                                          "Cancel this transaction",
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        content: new Text(
                                          "Are you sure you want to cancel this transaction?",
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            onPressed: () async {
                                              var url =
                                                  'https://api.sellship.co/api/cancelbuyer/' +
                                                      messageid;

                                              final response =
                                                  await http.get(url);

                                              if (response.statusCode == 200) {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          )
                                        ],
                                      ));
                            },
                            child: cancelled != null
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left: 10, bottom: 10, top: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Cancel this transaction',
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ))
                        : Container(),
                    SizedBox(
                      height: 5,
                    ),
                  ])
                : Center(child: CupertinoActivityIndicator())));
  }
}
