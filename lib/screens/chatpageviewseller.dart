import 'dart:async';
import 'dart:convert';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/phoenix_header.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatPageViewSeller extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;
  final String offer;
  final String itemname;
  final String itemimage;
  final String weight;
  final String itemprice;
  final String itemid;
  final int offerstage;

  const ChatPageViewSeller({
    Key key,
    this.recipentname,
    this.itemname,
    this.itemimage,
    this.messageid,
    this.offerstage,
    this.weight,
    this.itemprice,
    this.itemid,
    this.senderid,
    this.offer,
    this.recipentid,
  }) : super(key: key);

  @override
  _ChatPageViewSellerState createState() => _ChatPageViewSellerState();
}

class _ChatPageViewSellerState extends State<ChatPageViewSeller> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  var recipentname;
  var messageid;
  var senderid;
  var recipentid;
  var itemname;
  var itemimage;
  int skip;
  var offer;
  int limit;
  String offeruserstring;
  String userid;
  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 10;
      recipentname = widget.recipentname;
      messageid = widget.messageid;
      senderid = widget.senderid;
      recipentid = widget.recipentid;
      itemimage = widget.itemimage;
      itemname = widget.itemname;
      offer = widget.offer;
      offerstage = widget.offerstage;
    });

    getItem();
    calculateearning();
  }

  calculateearning() {
    var weight = int.parse(widget.weight);
    var weightfees;
    if (weight <= 5) {
      weightfees = 20;
    } else if (weight <= 10) {
      weightfees = 30;
    } else if (weight <= 20) {
      weightfees = 50;
    } else if (weight <= 50) {
      weightfees = 110;
    }

    var fees = double.parse(offer.toString()) / 1.15;

    finalfees = fees - weightfees;

    setState(() {
      finalfees = finalfees;
    });
  }

  var finalfees;
  Widget selleroptions(BuildContext context) {
    if (offerstage == 0) {
      return Container(
        height: 170,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            currency != null
                ? Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange),
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on,
                                color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text(
                              'You Earn ' +
                                  currency +
                                  finalfees.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ))))
                : Container(),
            Row(
              children: [
                Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        onTap: () {
                          acceptoffer(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.2)),
                                color: Colors.white),
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 5),
                                Text(
                                  'Accept Offer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              useRootNavigator: false,
                              builder: (_) => Container(
                                  height: 50,
                                  width: 50,
                                  child: SpinKitDoubleBounce(
                                    color: Colors.deepOrange,
                                  )));
                          canceloffer();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.2)),
                                color: Colors.white),
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel),
                                SizedBox(width: 5),
                                Text(
                                  'Cancel Offer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))))),
              ],
            ),
            Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                    onTap: () {
                      showMe(context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.2)),
                            color: Colors.white),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_return),
                            SizedBox(width: 5),
                            Text(
                              'Counter Offer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ))))),
          ],
        ),
      );
    }
    if (offerstage == 2) {
      return Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timer),
                        SizedBox(width: 5),
                        Text(
                          'Pending Payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )))),
          ],
        ),
      );
    }
    if (offerstage == 3) {
      return Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    Colors.deepPurpleAccent.withOpacity(0.2)),
                            color: Colors.deepPurpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          height: 40,
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.delivery_dining,
                                  color: Colors.deepPurpleAccent, size: 16),
                              SizedBox(width: 5),
                              Text(
                                'Picking up Delivery',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )))),
                ),
                Expanded(
                  child: InkWell(
                      enableFeedback: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderSeller(
                                    itemid: widget.itemid,
                                    messageid: widget.messageid,
                                  )),
                        );
                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 5, right: 20, top: 10, bottom: 10),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.2)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              height: 40,
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.receipt,
                                      color: Colors.black, size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    'View Order',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ))))),
                ),
              ],
            )
          ],
        ),
      );
    }
    if (offerstage == 1) {
      return Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timer),
                        SizedBox(width: 5),
                        Text(
                          'Pending Payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )))),
          ],
        ),
      );
    }
    if (offerstage == -1) {
      return Padding(
          padding: EdgeInsets.all(10),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.2)),
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Offer Declined',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ))));
    }
  }

  var profilepicture;

  var currency;
  final storage = new FlutterSecureStorage();
  Item itemselling;

  getItem() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + recipentid;
      final response = await http.get(url);
      var respons = json.decode(response.body);
      Map<String, dynamic> profilemap = respons;
      var profilepic = profilemap['profilepicture'];
      if (profilepic != null) {
        setState(() {
          profilepicture = profilepic;
        });
      } else {
        setState(() {
          profilepicture = null;
        });
      }
    } else {
      setState(() {
        profilepicture = null;
      });
    }

    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        userid = userid;
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        userid = userid;
      });
    }
  }

  Future<List> getRemoteMessages() async {
    var url = 'https://api.sellship.co/api/getmessagesuser/' +
        messageid +
        '/' +
        userid +
        '/' +
        skip.toString();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      offerstage = int.parse(jsonResponse['offerstage']);

      setState(() {
        offerstage = offerstage;
      });
      List jsonChat = json.decode(jsonResponse['chats']);
      return jsonChat;
    } else {
      print(response.statusCode);
    }
    return [];
  }

  List<Widget> mapJsonMessagesToListOfWidgetMessages(List jsonResponse) {
    childList = [];

    for (int i = 0; i < jsonResponse.length; i++) {
      if (jsonResponse[i]['sender'] == senderid) {
        final f = new DateFormat('hh:mm');
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            jsonResponse[i]['date']['\$date']);
        var s = f.format(date);

        childList.add(Padding(
            padding: const EdgeInsets.only(
                right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
            child: Container(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 3 / 4,
                          minWidth: 50),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 2.0,
                            left: 2.0,
                          ),
                          child: Text(
                            jsonResponse[i]['message'],
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        s,
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ))));
      } else if (jsonResponse[i]['sender'] == 'SELLSHIP') {
        final f = new DateFormat('hh:mm');
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            jsonResponse[i]['date']['\$date']);
        var s = f.format(date);

        childList.add(Padding(
            padding: const EdgeInsets.only(
                right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
            child: Container(
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/logonew.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 3 / 4,
                                minWidth: 100),
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  style: BorderStyle.solid,
                                  color: Colors.grey.shade300,
                                )),
                            child: Stack(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 2.0, left: 2.0),
                                child: Text(jsonResponse[i]['message'],
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              s,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                    ]))));
      } else {
        final f = new DateFormat('hh:mm');
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            jsonResponse[i]['date']['\$date']);
        var s = f.format(date);

        childList.add(Padding(
            padding: const EdgeInsets.only(
                right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 3 / 4,
                          minWidth: 100),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            style: BorderStyle.solid,
                            color: Colors.grey.shade300,
                          )),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0),
                          child: Text(jsonResponse[i]['message'],
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.black)),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        s,
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  ]),
            )));
      }
    }

    return childList;
  }

  bool disabled = true;

  Stream<List<Widget>> getMessages() async* {
    yield* Stream<int>.periodic(Duration(microseconds: 3), (i) => i)
        .asyncMap((i) => getRemoteMessages())
        .map((json) => mapJsonMessagesToListOfWidgetMessages(json));
  }

  var itemprice;

  TextEditingController offercontroller = TextEditingController();

  void showMe(BuildContext context) {
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
                            left: 15, bottom: 5, top: 20, right: 15),
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
                                  itemprice == null
                                      ? 'Current Price ' +
                                          currency +
                                          widget.itemprice
                                      : 'Current Price ' + currency + itemprice,
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
                                Expanded(
                                  child: TextField(
                                    cursorColor: Color(0xFF979797),
                                    controller: offercontroller,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        var offer = double.parse(text);
                                        var minoffer =
                                            double.parse(widget.itemprice) *
                                                0.50;
                                        minoffer =
                                            double.parse(widget.itemprice) -
                                                minoffer;

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
                                builder: (_) => Container(
                                    height: 50,
                                    width: 50,
                                    child: SpinKitDoubleBounce(
                                      color: Colors.deepOrange,
                                    )));
                            var recieverid = widget.recipentid;
                            if (recieverid == userid) {
                              var itemurl =
                                  'https://api.sellship.co/api/counteroffer/' +
                                      widget.messageid +
                                      '/' +
                                      widget.senderid +
                                      '/' +
                                      widget.recipentid +
                                      '/' +
                                      widget.itemid +
                                      '/' +
                                      offercontroller.text.trim();

                              final response = await http.get(itemurl);

                              if (response.statusCode == 200) {
                                setState(() {
                                  offerstage = 0;
                                  itemprice = offercontroller.text.trim();
                                });
                                Navigator.pop(context);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              } else {
                                print(response.statusCode);
                                Navigator.pop(context);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (_) => AssetGiffyDialog(
                                        image: Image.asset(
                                          'assets/oops.gif',
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text(
                                          'Oops!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        description: Text(
                                          'You can\'t send an offer to yourself!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                        onlyOkButton: true,
                                        entryAnimation: EntryAnimation.DEFAULT,
                                        onOkButtonPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                      ));
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

  String allowedoffer = '';

  int offerstage;
  String offerstring;

  @override
  void dispose() {
    super.dispose();
  }

  acceptoffer(context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (_) => Container(
            height: 50,
            width: 50,
            child: SpinKitDoubleBounce(
              color: Colors.deepOrange,
            )));
    if (offerstage != null) {
      var url = 'https://api.sellship.co/api/acceptoffer/' +
          widget.messageid +
          '/' +
          widget.itemid +
          '/' +
          widget.senderid +
          '/' +
          widget.recipentid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          offerstage = 1;
        });
        print(offerstage);
      }
    }
  }

  canceloffer() async {
    if (offerstage != null) {
      var url = 'https://api.sellship.co/api/canceloffer/' +
          widget.messageid +
          '/' +
          widget.itemid +
          '/' +
          widget.senderid +
          '/' +
          widget.recipentid;
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.of(context, rootNavigator: true).pop();
        print('Success');
        setState(() {
          offerstage = -1;
        });
      }
    }
  }

  Widget chatView(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: SafeArea(child: selleroptions(context)),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  title: Text(
                    '@' + recipentname,
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                          child: profilepicture != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  radius: 17,
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                            height: 200,
                                            width: 300,
                                            imageUrl: profilepicture,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitDoubleBounce(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ))))
                              : Icon(
                                  Feather.user,
                                  color: Colors.deepOrange,
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserItems(
                                      userid: recipentid,
                                      username: recipentname)),
                            );
                          }),
                    ),
                  ],
                  expandedHeight: 140.0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 5),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid: widget.itemid,
                                                  name: widget.itemname,
                                                  sold: itemselling.sold,
                                                  source: 'chat',
                                                  image: widget.itemimage,
                                                )),
                                      );
                                    },
                                    child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            widget.itemname,
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
                                                imageUrl: widget.itemimage,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          subtitle: Text(
                                            currency != null
                                                ? currency +
                                                    ' ' +
                                                    widget.itemprice.toString()
                                                : widget.itemprice.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      fit: StackFit.loose,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: StreamBuilder(
                                    stream: getMessages(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return EasyRefresh(
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
                                            scrollController: _scrollController,
                                            onRefresh: () async {
                                              setState(() {
                                                skip = skip + 10;
                                              });
                                            },
                                            child: SingleChildScrollView(
                                                controller: _scrollController,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: snapshot.data,
                                                )));
                                      } else if (snapshot.hasError) {
                                        return SingleChildScrollView(
                                            controller: _scrollController,
                                            child: Container());
                                      } else {
                                        return Container(
                                          height: 100,
                                          child: SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                        );
                                      }
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return chatView(context);
  }
}
