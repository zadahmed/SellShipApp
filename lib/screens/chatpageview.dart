import 'dart:async';
import 'dart:convert';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/checkoutoffer.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:SellShip/screens/paymentweb.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/storepagepublic.dart';
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
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPageView extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;
  final String offer;
  final Item item;
  final String itemname;
  final String itemimage;
  final String itemprice;
  final String itemid;
  final int offerstage;
  final bool itemsold;
  final String storename;
  final String storeid;
  final bool freedelivery;
  final String storetype;

  const ChatPageView({
    Key key,
    this.recipentname,
    this.storename,
    this.storeid,
    this.freedelivery,
    this.itemname,
    this.itemimage,
    this.itemsold,
    this.storetype,
    this.messageid,
    this.offerstage,
    this.itemprice,
    this.senderid,
    this.item,
    this.itemid,
    this.offer,
    this.recipentid,
  }) : super(key: key);

  @override
  _ChatPageViewState createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  var recipentname;
  var messageid;
  var senderid;
  var recipentid;
  var itemname;
  var itemimage;
  var itemprice;
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
      itemprice = widget.itemprice;
      offerstage = widget.offerstage;
    });

    print(offerstage);
    getItem();
  }

  TextEditingController messagecontroller = TextEditingController();

  var profilepicture;

  var currency;
  final storage = new FlutterSecureStorage();
  Item itemselling;

  Widget buyeroptions(BuildContext context) {
    if (offerstage == 0) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.2)),
                          color: Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.timer,
                                color: Colors.deepPurple, size: 16),
                            SizedBox(width: 5),
                            Text(
                              'Pending Offer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )))),
                widget.storetype == 'Secondhand Seller'
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
                                      'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
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
              height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      useRootNavigator: false,
                                      barrierDismissible: false,
                                      builder: (_) => SpinKitDoubleBounce(
                                            color: Colors.deepOrange,
                                          ));

                                  acceptoffer();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                      useRootNavigator: false,
                                      barrierDismissible: false,
                                      builder: (_) => SpinKitDoubleBounce(
                                            color: Colors.deepOrange,
                                          ));
                                  canceloffer();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                    widget.storetype == 'Secondhand Seller'
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

                                      var addurl =
                                          'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
                                      var response = await dio.post(addurl,
                                          data: formData);
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
    if (offerstage == 2) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('cartitems');

                              String item = jsonEncode(widget.item);
                              prefs.setStringList('cartitems', [item]);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckoutOffer(
                                        ordertype: 'EXISTING',
                                        itemid: widget.itemid,
                                        freedelivery: widget.freedelivery,
                                        offer: itemprice.toString(),
                                        messageid: widget.messageid)),
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green),
                                height: 40,
                                width: MediaQuery.of(context).size.width - 20,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Proceed to Checkout',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ))))),
                    widget.storetype == 'Secondhand Seller'
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

                                      var addurl =
                                          'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
                                      var response = await dio.post(addurl,
                                          data: formData);
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
    if (offerstage == -1) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: widget.storetype == 'Secondhand Seller' ? 190 : 120,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.red.withOpacity(0.2)),
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
                        )))),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: InkWell(
                      onTap: () {
                        showMe(context);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white),
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.local_offer),
                              SizedBox(width: 5),
                              Text(
                                'Make a New Offer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )))),
                ),
                widget.storetype == 'Secondhand Seller'
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
                                      'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
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
            height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                    'Waiting for Delivery',
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
                                  builder: (context) => OrderBuyerPage(
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
                widget.storetype == 'Secondhand Seller'
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
                                      'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
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
    if (offerstage == 4) {
      return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                  builder: (context) => OrderBuyerPage(
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
                widget.storetype == 'Secondhand Seller'
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
                                      'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
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
            height: widget.storetype == 'Secondhand Seller' ? 130 : 60,
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
                                  builder: (context) => OrderBuyerPage(
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
                widget.storetype == 'Secondhand Seller'
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
                                      'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
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
                                          widget.itemprice.toString()
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
                                      // if (text.isNotEmpty) {
                                      //   var offer = double.parse(text);
                                      //   var minoffer =
                                      //       double.parse(itemprice) * 0.50;
                                      //   minoffer =
                                      //       double.parse(itemprice) - minoffer;
                                      //
                                      //   if (offer < minoffer) {
                                      //     updateState(() {
                                      //       allowedoffer =
                                      //           'The offer is too low compared to the selling price';
                                      //       disabled = true;
                                      //     });
                                      //     setState(() {
                                      //       disabled = true;
                                      //     });
                                      //   } else {
                                      //     updateState(() {
                                      //       allowedoffer = '';
                                      //       disabled = false;
                                      //     });
                                      //     setState(() {
                                      //       disabled = false;
                                      //     });
                                      //   }
                                      // } else {
                                      //   updateState(() {
                                      //     allowedoffer = '';
                                      //     disabled = true;
                                      //   });
                                      //   setState(() {
                                      //     disabled = true;
                                      //   });
                                      // }
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
                          var recieverid = widget.recipentid;

                          if (recieverid != userid) {
                            var itemurl =
                                'https://api.sellship.co/api/createoffer/' +
                                    widget.senderid +
                                    '/' +
                                    recieverid +
                                    '/' +
                                    widget.itemid +
                                    '/' +
                                    offercontroller.text.trim();

                            final response = await http.get(Uri.parse(itemurl));

                            if (response.statusCode == 200) {
                              setState(() {
                                offerstage = 0;
                                itemprice = offercontroller.text.trim();
                              });
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else {
                              print(response.statusCode);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } else {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (_) => new AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      content: Builder(
                                        builder: (context) {
                                          return Container(
                                              height: 380,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 250,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.asset(
                                                        'assets/oops.gif',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'You can\'t send an offer to yourself!',
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              255, 115, 0, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color(
                                                                        0xFF9DA3B4)
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius:
                                                                    65.0,
                                                                offset: Offset(
                                                                    0.0, 15.0))
                                                          ]),
                                                      child: Center(
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ));
                                        },
                                      ),
                                    ));
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

  getItem() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/store/' + widget.storeid;
      final response = await http.get(Uri.parse(url));
      var respons = json.decode(response.body);
      Map<String, dynamic> profilemap = respons;
      var profilepic = profilemap['storelogo'];
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

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      offerstage = int.parse(jsonResponse['offerstage']);
      var d = double.parse(jsonResponse['offer'].toString()).round();

      itemprice = int.parse(d.toString());

      setState(() {
        offerstage = offerstage;
        itemprice = itemprice;
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
                        color: Colors.grey.shade50,
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

  Stream<List<Widget>> getMessages() async* {
    yield* Stream<int>.periodic(Duration(seconds: 3), (i) => i)
        .asyncMap((i) => getRemoteMessages())
        .map((json) => mapJsonMessagesToListOfWidgetMessages(json));
  }

  TextEditingController offercontroller = TextEditingController();

  bool disabled = true;

  String allowedoffer = '';

  int offerstage;
  String offerstring;

  @override
  void dispose() {
    super.dispose();
  }

  acceptoffer() async {
    if (offerstage != null) {
      var url = 'https://api.sellship.co/api/counter/acceptoffer/' +
          widget.messageid +
          '/' +
          widget.itemid +
          '/' +
          widget.senderid +
          '/' +
          widget.recipentid;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        getRemoteMessages();
        setState(() {
          offerstage = 2;
        });

        Navigator.pop(context);
      }
    }
  }

  canceloffer() async {
    if (offerstage != null) {
      var url = 'https://api.sellship.co/api/counter/canceloffer/' +
          widget.messageid +
          '/' +
          widget.itemid +
          '/' +
          widget.senderid +
          '/' +
          widget.recipentid;
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          offerstage = -1;
        });
      }
    }
  }

  Widget chatView(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: SafeArea(child: buyeroptions(context)),
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
                    '@' + widget.storename,
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
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ))))
                              : Icon(
                                  FeatherIcons.user,
                                  color: Colors.deepOrange,
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StorePublic(
                                      storeid: widget.storeid,
                                      storename: widget.storename)),
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
                                                  sold: widget.itemsold,
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
                                              color: Colors.grey.shade200,
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
                                            overflow: TextOverflow.ellipsis,
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
                                                    itemprice.toString()
                                                : itemprice.toString(),
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
