import 'dart:async';
import 'dart:convert';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderdetail.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatPageView extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;
  final String offer;
  final String itemid;
  final int offerstage;
  final fcmToken;
  final senderName;
  const ChatPageView(
      {Key key,
      this.recipentname,
      this.itemid,
      this.messageid,
      this.offerstage,
      this.senderid,
      this.offer,
      this.recipentid,
      @required this.fcmToken,
      @required this.senderName})
      : super(key: key);

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
  var fcmToken;
  var itemid;
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
      fcmToken = widget.fcmToken;
      itemid = widget.itemid;
      offer = widget.offer;
      offerstage = widget.offerstage;
    });

    changeofferstate();
    getItem();
    _scrollController
      ..addListener(() {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0) {
            setState(() {
              skip = skip + 10;
            });
          }
        }
      });
  }

  var currency;
  final storage = new FlutterSecureStorage();
  Item itemselling;

  getItem() async {
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

    print(itemid);
    var url = 'https://sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      Item item = Item(
        itemid: jsonbody[0]['_id']['\$oid'],
        name: jsonbody[0]['name'],
        image: jsonbody[0]['image'],
        userid: jsonbody[0]['userid'],
        username: jsonbody[0]['username'],
        price: jsonbody[0]['price'].toString(),
        category: jsonbody[0]['category'],
        condition: jsonbody[0]['condition'],
        brand: jsonbody[0]['brand'],
      );
      setState(() {
        itemselling = item;
      });
    }
    print(itemselling.name);
  }

  Future<List> getRemoteMessages() async {
    var url = 'https://sellship.co/api/getmessages/' +
        messageid +
        '/' +
        skip.toString();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse;
    }
    return [];
  }

  changeofferstate() async {
    var url = 'https://sellship.co/api/getofferstage/' + messageid;
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      var offerstag = jsonbody['offerstage'];
      if (offerstag == 0) {
        if (mounted) {
          setState(() {
            offerstage = offerstag;
            offerstring = 'Edit';
            offeruserstring = 'Accept';
          });
        }
      } else if (offerstag == 1) {
        if (mounted) {
          setState(() {
            offerstage = offerstag;
            offerstring = 'Pay';
            offeruserstring = 'Cancel';
          });
        }
      } else if (offerstag == 2) {
        if (mounted) {
          setState(() {
            offerstage = offerstag;
            offerstring = 'View Order';
            offeruserstring = 'View Order';
          });
        }
      }
    }
  }

  List<Widget> mapJsonMessagesToListOfWidgetMessages(List jsonResponse) {
    childList = [];

    if (offerstage != null) {
      changeofferstate();
    }

    for (int i = 0; i < jsonResponse.length; i++) {
      if (jsonResponse[i]['sender'] == userid) {
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
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
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
                                fontFamily: 'SF',
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        s,
                        style: TextStyle(
                            fontFamily: 'SF',
                            fontSize: 12,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ))));
      } else if (jsonResponse[i]['reciever'] == recipentid) {
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
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0),
                          child: Text(jsonResponse[i]['message'],
                              style: TextStyle(
                                  fontFamily: 'SF',
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
                            fontFamily: 'SF',
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
    yield* Stream<int>.periodic(Duration(microseconds: 3), (i) => i)
        .asyncMap((i) => getRemoteMessages())
        .map((json) => mapJsonMessagesToListOfWidgetMessages(json));
  }

  TextEditingController offercontroller = TextEditingController();

  void showMe(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                    child: Text('Enter your address'),
//                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Make an Offer',
                        style: TextStyle(
                            fontFamily: 'SF',
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ListTile(
                        title: Container(
                            width: 200,
                            padding: EdgeInsets.only(),
                            child: Center(
                              child: TextField(
                                cursorColor: Color(0xFF979797),
                                controller: offercontroller,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                    labelText: "Offer Price",
                                    alignLabelWithHint: true,
                                    labelStyle: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                    focusColor: Colors.black,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ))),
                              ),
                            )),
                        trailing: InkWell(
                          onTap: () async {
                            var itemurl =
                                'https://sellship.co/api/createoffer/' +
                                    senderid +
                                    '/' +
                                    recipentid +
                                    '/' +
                                    itemid +
                                    '/' +
                                    offercontroller.text.trim();
                            final response = await http.get(itemurl);
                            var messageinfo = json.decode(response.body);

                            setState(() {
                              offer = messageinfo['offer'];
                            });
                            Navigator.of(context).pop();
                            print(offer);
                          },
                          child: Container(
                            width: 100,
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0),
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
                                      fontFamily: 'SF',
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(height: 10),
                ],
              ),
            ));
  }

  int offerstage;
  String offerstring;

  @override
  void dispose() {
    super.dispose();
  }

  acceptoffer() async {
    if (offerstage != null) {
      var url = 'https://sellship.co/api/acceptoffer/' +
          messageid +
          '/' +
          userid +
          '/' +
          recipentid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Success');
        setState(() {
          offerstage = 1;
        });
        print(offerstage);
      }
    }
  }

  canceloffer() async {
    if (offerstage != null) {
      var url = 'https://sellship.co/api/canceloffer/' +
          messageid +
          '/' +
          userid +
          '/' +
          recipentid;
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Success');
        setState(() {
          offerstage = 0;
        });
        print(offerstage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, offer == null ? 180 : 210),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: offer == null ? 180 : 220,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                    height: 90,
                    color: Colors.deepOrange,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              }),
                        ),
                        Text(
                          recipentname,
                          style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                              child: Icon(
                                Feather.user,
                                color: Colors.white,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserItems(
                                          userid: itemselling.userid,
                                          username: itemselling.username)),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  itemselling != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Details(itemid: itemselling.itemid)),
                                );
                              },
                              child: Container(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      itemselling.name,
                                      style: TextStyle(
                                          fontFamily: 'SF',
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
                                          imageUrl: itemselling.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      currency +
                                          ' ' +
                                          itemselling.price.toString(),
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))))
                      : Container(),
                  offer != null
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: 5, left: 10, right: 10, bottom: 10),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Details(itemid: itemselling.itemid)),
                                );
                              },
                              child: Container(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                130,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 5),
                                            child: currency != null
                                                ? Text(
                                                    'Offer Price ' +
                                                        currency +
                                                        ' ' +
                                                        offer.toString(),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 16,
                                                        color:
                                                            Colors.deepOrange,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                : Container()),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            if (offerstage == 0) {
                                              if (userid == recipentid) {
                                                acceptoffer();
                                              } else {
                                                showMe(context);
                                              }
                                            } else if (offerstage == 1) {
                                              if (userid == recipentid) {
                                                canceloffer();
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Checkout(
                                                              messageid:
                                                                  messageid,
                                                              offer: offer,
                                                              item:
                                                                  itemselling)),
                                                );
                                              }
                                            } else if (offerstage == 2) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetail(
                                                            messageid:
                                                                messageid,
                                                            item: itemselling)),
                                              );
                                            }
                                          },
                                          child: offerstring != null
                                              ? Container(
                                                  height: 30,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.deepOrangeAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .deepOrangeAccent
                                                            .shade200,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      userid == recipentid
                                                          ? offeruserstring
                                                          : offerstring,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              : Container())
                                    ],
                                  ))))
                      : Container()
                ],
              ))),
      body: SafeArea(
        child: Container(
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
                              return SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: snapshot.data,
                                  ));
                            } else if (snapshot.hasError) {
                              return SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Container());
                            } else {
                              return Container(
                                height: 100,
                                child: SpinKitChasingDots(
                                    color: Colors.deepOrange),
                              );
                            }
                          }),
                    ),
                  ),

                  Divider(height: 0, color: Colors.black26),

                  Container(
                    color: Colors.white,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        maxLines: 20,
                        controller: _text,
                        style: TextStyle(fontFamily: 'SF', fontSize: 16),
                        decoration: InputDecoration(
                            // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                child: CircleAvatar(
                                  child: Icon(
                                    Feather.send,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.deepOrange,
                                ),
                                onTap: () async {
                                  var x = _text.text;
                                  _text.clear();
                                  var date = DateTime.now();
                                  final f = new DateFormat('hh:mm');
                                  var s = f.format(date);
                                  childList.add(Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 4.0),
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  4),
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange,
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                          ),
                                          child: Stack(children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                  left: 8.0,
                                                  top: 8.0,
                                                  bottom: 15.0),
                                              child: Text(x,
                                                  style: TextStyle(
                                                      fontFamily: 'SF',
                                                      fontSize: 14,
                                                      color: Colors.white)),
                                            ),
                                            Positioned(
                                              bottom: 1,
                                              right: 10,
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 10,
                                                    color: Colors.white
                                                        .withOpacity(0.6)),
                                              ),
                                            )
                                          ]),
                                        ),
                                      )));

                                  var url =
                                      'https://sellship.co/api/sendmessage/' +
                                          userid +
                                          '/' +
                                          recipentid +
                                          '/' +
                                          messageid;
                                  if (x.isNotEmpty) {
                                    final response = await http.post(url,
                                        body: {
                                          'message': x,
                                          'time': DateTime.now().toString()
                                        });
                                    if (response.statusCode == 200) {
                                      print('ok');
                                    } else {
                                      print(response.statusCode);
                                      print(response.body);
                                    }

                                    Timer(Duration(microseconds: 1), () {
                                      _scrollController.jumpTo(_scrollController
                                          .position.maxScrollExtent);
                                    });
                                  }
                                },
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: "Enter your message",
                            hintStyle:
                                TextStyle(fontFamily: 'SF', fontSize: 16)),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
