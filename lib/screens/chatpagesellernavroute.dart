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
import 'package:dio/dio.dart';
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

class ChatPageOfferNav extends StatefulWidget {
  final String messageid;
  final String userid;

  const ChatPageOfferNav({
    Key key,
    this.userid,
    this.messageid,
  }) : super(key: key);

  @override
  _ChatPageOfferNavState createState() => _ChatPageOfferNavState();
}

class _ChatPageOfferNavState extends State<ChatPageOfferNav> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  var recipentname;
  var messageid;
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
      userid = widget.userid;
      messageid = widget.messageid;
    });

    getItem();
  }

  calculateearning() {
    var weight = int.parse(itemselling.weight);
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

    var fees = double.parse(itemprice.toString()) / 1.15;

    finalfees = fees - weightfees;

    var ourfee = (finalfees + weightfees) * 0.15;

    setState(() {
      ourfees = ourfee;
      deliveryfees = weightfees;
      finalfees = finalfees;
    });
  }

  var ourfees;
  var deliveryfees;
  var finalfees;

  Widget selleroptions(BuildContext context) {
    if (offerstage == 0) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 250 : 180,
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
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0))),
                                  backgroundColor: Colors.white,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter updateState) {
                                        return Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 5,
                                                          top: 20,
                                                          right: 15),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Offer Breakdown',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ])),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 5,
                                                          top: 10,
                                                          right: 15),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Offer Price',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                finalfees !=
                                                                        null
                                                                    ? currency +
                                                                        ' ' +
                                                                        itemprice
                                                                    : '',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ])),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 5,
                                                          right: 15),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Delivery Fees',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                finalfees !=
                                                                        null
                                                                    ? currency +
                                                                        ' ' +
                                                                        deliveryfees
                                                                            .toString()
                                                                    : '',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ])),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 35,
                                                          right: 15),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Service Fees',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                finalfees !=
                                                                        null
                                                                    ? currency +
                                                                        ' ' +
                                                                        ourfees
                                                                            .toStringAsFixed(2)
                                                                    : '',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ])),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 40,
                                                          top: 5,
                                                          right: 15),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'You Earn',
                                                              style: TextStyle(
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                finalfees !=
                                                                        null
                                                                    ? currency +
                                                                        ' ' +
                                                                        finalfees
                                                                            .toStringAsFixed(2)
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ])),
                                                ]));
                                      }));
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.deepOrange),
                                  color: Colors.deepOrange,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                height: 50,
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
                                      finalfees != null
                                          ? 'You Earn ' +
                                              currency +
                                              finalfees.toStringAsFixed(2)
                                          : '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )))))
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
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.2)),
                                    color: Colors.white),
                                height: 40,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
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
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.2)),
                                    color: Colors.white),
                                height: 40,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cancel),
                                    SizedBox(width: 5),
                                    Text(
                                      'Decline Offer',
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
                                borderRadius: BorderRadius.circular(5),
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
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
    if (offerstage == 2) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                            borderRadius: BorderRadius.circular(5),
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
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
    if (offerstage == 3) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.2)),
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
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
                                        itemid: itemselling.itemid,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                ),
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
    if (offerstage == 1) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                            borderRadius: BorderRadius.circular(5),
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
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
    if (offerstage == -1) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.2)),
                              color: Colors.red.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
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
                            )))),
                    itemselling.storetype == 'Secondhand Seller'
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, bottom: 10, top: 10),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: <Widget>[
                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Container(
                                  //     height: 30,
                                  //     width: 30,
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.deepOrangeAccent,
                                  //       borderRadius: BorderRadius.circular(30),
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.add,
                                  //       color: Colors.white,
                                  //       size: 20,
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: messagecontroller,
                                      scrollPadding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom +
                                              20),
                                      decoration: InputDecoration(
                                          hintText: "Send message...",
                                          hintStyle:
                                              TextStyle(color: Colors.black54),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  FloatingActionButton(
                                    onPressed: () async {
                                      final f = new DateFormat('hh:mm');
                                      DateTime date = new DateTime
                                              .fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                      var s = f.format(date);

                                      var msg = messagecontroller.text;

                                      childList.add(Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0,
                                              left: 8.0,
                                              top: 4.0,
                                              bottom: 4.0),
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                        minWidth: 50),
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Stack(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2.0,
                                                              left: 2.0,
                                                            ),
                                                            child: Text(
                                                              messagecontroller
                                                                  .text,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Text(
                                                      s,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              ))));

                                      messagecontroller.clear();
                                      Dio dio = new Dio();
                                      FormData formData = FormData.fromMap({
                                        'message': msg,
                                      });

                                      print(messagecontroller.text);
                                      var addurl =
                                          'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                      var response = await dio.post(addurl,
                                          data: formData);
                                      print(response.data);
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    backgroundColor: Colors.deepOrangeAccent,
                                    elevation: 0,
                                  ),
                                ],
                              ),
                            ))
                        : Container(),
                  ])));
    }
    if (offerstage == 4) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.2)),
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
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
                                    'Item Delivered',
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
                                        itemid: itemselling.itemid,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                ),
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
    if (offerstage == 5) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: itemselling.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.2)),
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              height: 40,
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.deepPurpleAccent, size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    'Order Completed',
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
                                        itemid: itemselling.itemid,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                ),
                itemselling.storetype == 'Secondhand Seller'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 10),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: <Widget>[
                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     height: 30,
                              //     width: 30,
                              //     decoration: BoxDecoration(
                              //       color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     child: Icon(
                              //       Icons.add,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messagecontroller,
                                  scrollPadding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20),
                                  decoration: InputDecoration(
                                      hintText: "Send message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  final f = new DateFormat('hh:mm');
                                  DateTime date =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                  var s = f.format(date);

                                  var msg = messagecontroller.text;

                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    minWidth: 50),
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Stack(children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 2.0,
                                                      left: 2.0,
                                                    ),
                                                    child: Text(
                                                      messagecontroller.text,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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

                                  messagecontroller.clear();
                                  Dio dio = new Dio();
                                  FormData formData = FormData.fromMap({
                                    'message': msg,
                                  });

                                  print(messagecontroller.text);
                                  var addurl =
                                      'https://api.sellship.co/api/sendmessage/${itemselling.sellerid}/${itemselling.buyerid}/${widget.messageid}';
                                  var response =
                                      await dio.post(addurl, data: formData);
                                  print(response.data);
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                elevation: 0,
                              ),
                            ],
                          ),
                        ))
                    : Container(),
              ],
            ),
          ));
    }
  }

  TextEditingController messagecontroller = TextEditingController();
  var profilepicture;

  var currency;
  final storage = new FlutterSecureStorage();
  Item itemselling;

  getItem() async {
    var itemurl =
        'https://api.sellship.co/api/selling/offer/' + userid + '/' + messageid;
    final response = await http.get(itemurl);
    if (response.statusCode == 200) {
      var itemmap = json.decode(response.body);

      if (itemmap != null) {
        var buyerid;
        if (itemmap['buyerid'].containsKey('\$oid')) {
          buyerid = itemmap['buyerid']['\$oid'];
        } else {
          buyerid = itemmap['buyerid'];
        }

        var buyername;
        if (itemmap.containsKey('buyername')) {
          buyername = itemmap['buyername'];
        } else {
          buyername = 'Unknown';
        }

        var sellerid;
        if (itemmap['sellerid'].containsKey('\$oid')) {
          sellerid = itemmap['sellerid']['\$oid'];
        } else {
          sellerid = itemmap['sellerid'];
        }

        var date;
        if (itemmap['offerdate'].containsKey('\$date')) {
          date = itemmap['offerdate']['\$date'];
        } else {
          date = 0;
        }

        var sellername;
        if (itemmap.containsKey('sellername')) {
          sellername = itemmap['sellername'];
        } else {
          buyername = 'Unknown';
        }

        Item ite = Item(
            itemid: itemmap['item']['_id']['\$oid'],
            name: itemmap['item']['name'],
            image: itemmap['item']['image'],
            weight: itemmap['item']['weight'].toString(),
            price: itemmap['offer'].toString(),
            messageid: itemmap['messageid'].toString(),
            offerstage: itemmap['offerstage'],
            storetype: itemmap['item']['storetype'],
            buyerid: buyerid,
            date: date.toString(),
            buyername: buyername,
            sellername: sellername,
            sellerid: sellerid,
            sold: itemmap['item']['sold']);
        setState(() {
          itemselling = ite;
        });
      }
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + itemselling.buyerid;
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
        loading = false;
        recipentname = itemselling.buyername;
        offerstage = itemselling.offerstage;
        itemprice = int.parse(itemselling.price);
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

      var d = double.parse(jsonResponse['offer'].toString()).round();

      itemprice = int.parse(d.toString());
      setState(() {
        offerstage = offerstage;
        itemprice = itemprice.toString();
      });
      calculateearning();
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
      if (jsonResponse[i]['sender'] == widget.userid) {
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
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
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

        print(jsonResponse[i]);

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
    var deliveryfees;
    var counterofferprice;
    var servicefees;

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
                                          itemprice.toString()
                                      : 'Current Price ' +
                                          currency +
                                          itemprice.toString(),
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
                      padding: EdgeInsets.only(left: 15, bottom: 5, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'You Earn',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: Container(
                        height: 85,
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
                                      var weight =
                                          int.parse(itemselling.weight);
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

                                      var fees = double.parse(
                                          offercontroller.text.toString());

                                      finalfees = fees + weightfees;

                                      var ourfee =
                                          (finalfees + weightfees) * 0.15;

                                      updateState(() {
                                        servicefees = ourfee;
                                        deliveryfees = weightfees;
                                        counterofferprice = finalfees + ourfee;
                                      });
                                    },
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
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
                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 15),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                          ),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Delivery Fees',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    deliveryfees != null
                                        ? currency +
                                            ' ' +
                                            deliveryfees.toString()
                                        : '0',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        color: Colors.black),
                                  )
                                ],
                              )),
                        )),
                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 15),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15)),
                          ),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Service Fees',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    servicefees != null
                                        ? currency +
                                            ' ' +
                                            servicefees.toString()
                                        : '0',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        color: Colors.black),
                                  )
                                ],
                              )),
                        )),
                    Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 5, right: 15),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15)),
                          ),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Counteroffer Price',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    counterofferprice != null
                                        ? currency +
                                            ' ' +
                                            counterofferprice.toString()
                                        : '0',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        color: Colors.black),
                                  )
                                ],
                              )),
                        )),
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
                              builder: (_) => Container(
                                  height: 50,
                                  width: 50,
                                  child: SpinKitDoubleBounce(
                                    color: Colors.deepOrange,
                                  )));

                          var itemurl =
                              'https://api.sellship.co/api/counteroffer/' +
                                  widget.messageid +
                                  '/' +
                                  itemselling.sellerid +
                                  '/' +
                                  itemselling.buyerid +
                                  '/' +
                                  itemselling.itemid +
                                  '/' +
                                  counterofferprice.toString();

                          final response = await http.get(itemurl);

                          if (response.statusCode == 200) {
                            setState(() {
                              offerstage = 0;
                              itemprice = counterofferprice.toString();
                            });
                            Navigator.pop(context);
                            Navigator.of(context, rootNavigator: true).pop();
                            getRemoteMessages();
                          } else {
                            print(response.statusCode);
                            Navigator.pop(context);
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
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
          itemselling.itemid +
          '/' +
          itemselling.sellerid +
          '/' +
          itemselling.buyerid;
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
          itemselling.itemid +
          '/' +
          itemselling.sellerid +
          '/' +
          itemselling.buyerid;
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
        bottomNavigationBar: loading == false
            ? SafeArea(child: selleroptions(context))
            : Container(
                height: 1,
                color: Colors.white,
              ),
        body: loading == false
            ? GestureDetector(
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
                              child: profilepicture != null &&
                                      profilepicture.isNotEmpty
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
                                                        color:
                                                            Colors.deepOrange),
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
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 5),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                      itemid:
                                                          itemselling.itemid,
                                                      name: itemselling.name,
                                                      sold: itemselling.sold,
                                                      source: 'chat',
                                                      image: itemselling.image,
                                                    )),
                                          );
                                        },
                                        child: Container(
                                            height: 70,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                itemselling.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              leading: Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    height: 200,
                                                    width: 300,
                                                    imageUrl: itemselling.image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              subtitle: Text(
                                                currency != null
                                                    ? currency +
                                                        ' ' +
                                                        itemprice.toString()
                                                    : itemprice.toString(),
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.deepOrange,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: new ExactAssetImage('assets/chatbg.png'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.grey, BlendMode.softLight))),
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
                                                        color:
                                                            Colors.deepOrange,
                                                        size: 30.0,
                                                      );
                                                    }),
                                                scrollController:
                                                    _scrollController,
                                                onRefresh: () async {
                                                  setState(() {
                                                    skip = skip + 10;
                                                  });
                                                },
                                                child: SingleChildScrollView(
                                                    controller:
                                                        _scrollController,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
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
                ))
            : Center(
                child: SpinKitDoubleBounce(
                color: Colors.deepOrange,
              )));
  }

  @override
  Widget build(BuildContext context) {
    return chatView(context);
  }

  bool loading = true;
}
