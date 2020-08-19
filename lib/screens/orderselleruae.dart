import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/ReviewBuyer.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:app_review/app_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailUAE extends StatefulWidget {
  String messageid;
  Item item;

  OrderDetailUAE({Key key, this.messageid, this.item}) : super(key: key);
  @override
  _OrderDetailUAEState createState() => _OrderDetailUAEState();
}

class _OrderDetailUAEState extends State<OrderDetailUAE> {
  Item item;
  String messageid;
  var addressline1;
  var city;
  var state;
  var paymentby;
  var payment;

  var deliveryaddress;

  var zipcode;

  bool addressreturned = false;

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

  final storage = new FlutterSecureStorage();

//  Item newitem = new Item();
  var deliveredtext;
  getDetails() async {
    userid = await storage.read(key: 'userid');

    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
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

    if (delstage == 0) {
      deliveredtext = 'Item Prepared';
    } else if (delstage == 1) {
      deliveredtext = 'Item Shipped';
    } else if (delstage == 2) {
      deliveredtext = 'Waiting for Delivery';
    } else if (delstage == 3) {
      deliveredtext = 'Review Buyer';
    }

    setState(() {
      itemprice = jsonbody['offer'];
      totalpaid = jsonbody['totalpayable'];
      date = s;

      deliverystage = delstage;
//      newitem = Item(weight: int.parse(jsonbody['itemobject']['weight']));
      itemfees = jsonbody['fees'];
      buyerid = jsonbody['senderid'];
      buyername = jsonbody['buyername'];

      loading = false;
    });
  }

  var itemprice;
  var totalpaid;
  var buyerid;
  var itemfees;
  var date;

  var buyername;
  bool loading;

  int deliverystage;

//  Widget shipfrom(BuildContext context) {
//    if (deliverystage == 0) {
//      return Container(
//        decoration: BoxDecoration(
//          color: Colors.white,
//          boxShadow: <BoxShadow>[
//            BoxShadow(
//                color: Colors.grey.withOpacity(0.2),
//                offset: const Offset(0.0, 0.6),
//                blurRadius: 5.0),
//          ],
//        ),
//        child: ListTile(
//            onTap: () async {
//              final result = await Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => Address()),
//              );
//
//              if (result is String) {
//                setState(() {
//                  deliveryaddress = result;
//                  addressreturned = true;
//                });
//              } else {
//                setState(() {
//                  addressline1 = result['addrLine1'];
//                  city = result['city'];
//                  state = result['state'];
//                  zipcode = result['zip_code'];
//
//                  deliveryaddress = result['address'];
//                  addressreturned = true;
//                });
//              }
//            },
//            leading: Text(
//              'Ship from',
//              style: TextStyle(
//                  fontFamily: 'Helvetica',
//                  fontSize: 16,
//                  fontWeight: FontWeight.w700),
//            ),
//            title: addressreturned == false
//                ? Container()
//                : Text(
//                    deliveryaddress,
//                    textAlign: TextAlign.start,
//                    style: TextStyle(
//                        fontFamily: 'Helvetica',
//                        fontSize: 13,
//                        fontWeight: FontWeight.w500),
//                  ),
//            trailing: Icon(
//              Icons.arrow_forward_ios,
//              size: 10,
//            )),
//      );
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
//                  var url = 'https://www.ups.com/dropoff/?loc=en_us';
//
//                  if (await canLaunch(url)) {
//                    await launch(url);
//                  } else {
//                    throw 'Could not launch $url';
//                  }
//                },
//                leading: Text(
//                  'Shipping Carrier',
//                  style: TextStyle(
//                      fontFamily: 'Helvetica',
//                      fontSize: 16,
//                      fontWeight: FontWeight.w700),
//                ),
//                title: Icon(
//                  FontAwesome5Brands.ups,
//                  color: Colors.deepOrange,
//                  size: 35,
//                ),
//                trailing: Container(
//                  height: 48,
//                  width: 160,
//                  decoration: BoxDecoration(
//                    color: Colors.deepPurpleAccent,
//                    borderRadius: const BorderRadius.all(
//                      Radius.circular(10.0),
//                    ),
//                    boxShadow: <BoxShadow>[
//                      BoxShadow(
//                          color: Colors.deepPurpleAccent.withOpacity(0.4),
//                          offset: const Offset(1.1, 1.1),
//                          blurRadius: 10.0),
//                    ],
//                  ),
//                  child: Center(
//                    child: Text(
//                      'Find Nearby Drop Off',
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        fontWeight: FontWeight.w700,
//                        fontSize: 14,
//                        letterSpacing: 0.0,
//                        color: Colors.white,
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            )
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
//                  var url = 'https://www.ups.com/dropoff/?loc=en_us';
//
//                  if (await canLaunch(url)) {
//                    await launch(url);
//                  } else {
//                    throw 'Could not launch $url';
//                  }
//                },
//                leading: Text(
//                  'Shipping Carrier',
//                  style: TextStyle(
//                      fontFamily: 'Helvetica',
//                      fontSize: 16,
//                      fontWeight: FontWeight.w700),
//                ),
//                title: Icon(
//                  FontAwesome5Brands.ups,
//                  color: Colors.deepOrange,
//                  size: 35,
//                ),
//                trailing: Container(
//                  height: 48,
//                  width: 160,
//                  decoration: BoxDecoration(
//                    color: Colors.deepPurpleAccent,
//                    borderRadius: const BorderRadius.all(
//                      Radius.circular(10.0),
//                    ),
//                    boxShadow: <BoxShadow>[
//                      BoxShadow(
//                          color: Colors.deepPurpleAccent.withOpacity(0.4),
//                          offset: const Offset(1.1, 1.1),
//                          blurRadius: 10.0),
//                    ],
//                  ),
//                  child: Center(
//                    child: Text(
//                      'Find Nearby Drop Off',
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        fontWeight: FontWeight.w700,
//                        fontSize: 14,
//                        letterSpacing: 0.0,
//                        color: Colors.white,
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            )
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
                    'Prepare',
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
                    '1. Prepare your delivery by packaging your item in a safe and contained box or envelope.',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '2. Tap on \'Item Prepared\'.The notification will be send to the buyer that the item is ready for pickup or for shipment',
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
                    'Ship or Meetup',
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
                    '1. Upon completing preperation of your item, its time to deliver your item!',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '2. Chat with the buyer or discuss delivery methods and ship it to him, if the offer includes delivery cost.',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '3. Tap on \'Item Shipped\' once completed this process.',
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
                      Feather.clock,
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
                      Feather.clock,
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
                      Icons.label,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Prepare')
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
                Text('Ship/Meetup')
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
                Text('Delivered')
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
                      Icons.check,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Prepare')
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
                      Icons.local_shipping,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Ship/Meetup')
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
                Text('Delivered')
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
                      Icons.check,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Prepare')
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
                      Icons.check,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Ship/Meetup')
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
                      Icons.access_time,
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
                Text('Prepare')
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
                      Icons.check,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('Ship/Meetup')
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
                      Icons.check,
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
          iconTheme: IconThemeData(color: Colors.deepOrange),
          elevation: 0,
          title: Text(
            'Order Detail',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: loading == false
                ? Column(children: <Widget>[
                    SizedBox(height: 10),
                    deliverystagewidget(context),
                    Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Purchase Information',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
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
                                height: 90,
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
                                        imageUrl: item.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Purchased on ' + date.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 12,
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
//                    shipfrom(context),
                    SizedBox(
                      height: 10,
                    ),
                    deliveryinformation(context),
                    InkWell(
                        onTap: () async {
                          if (deliverystage == 0) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0)), //this right here
                                    child: Container(
                                      height: 100,
                                      child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: SpinKitChasingDots(
                                              color: Colors.deepOrange)),
                                    ),
                                  );
                                });

                            var url =
                                'https://api.sellship.co/api/shipitem/uae/' +
                                    messageid;

                            final response = await http.get(url);

                            var jsonbody = json.decode(response.body);

                            setState(() {
                              deliverystage = jsonbody['deliverystage'];

                              deliveredtext = 'Item Shipped';
                            });

                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          } else if (deliverystage == 1) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0)), //this right here
                                    child: Container(
                                      height: 100,
                                      child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: SpinKitChasingDots(
                                              color: Colors.deepOrange)),
                                    ),
                                  );
                                });
                            var url =
                                'https://api.sellship.co/api/shipped/uae/' +
                                    messageid;

                            final response = await http.get(url);

                            var jsonbody = json.decode(response.body);

                            setState(() {
                              deliverystage = jsonbody['deliverystage'];
                              deliveredtext = "Waiting for Delivery";
                            });
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          } else if (deliverystage == 3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewBuyer(
                                        reviewuserid: buyerid,
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
                          'Buyer Information',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
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
                                          userid: buyerid,
                                          username: buyername)),
                                );
                              },
                              dense: true,
                              leading: Icon(FontAwesome.user_circle),
                              title: Text(
                                buyername,
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
                  ])
                : Center(child: CupertinoActivityIndicator())));
  }
}
