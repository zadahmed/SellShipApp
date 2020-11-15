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
import 'package:giffy_dialog/giffy_dialog.dart';

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
        userid = userid;
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        userid = userid;
      });
    }

    var url = 'https://api.sellship.co/api/getitem/' + itemid;
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
      List jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    return [];
  }

  changeofferstate() async {
    var url = 'https://api.sellship.co/api/getofferstage/' + messageid;
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
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Make an Offer',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
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
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ListTile(
                          title: Container(
                              width: 200,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: offercontroller,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {
                                      var offer = double.parse(text);
                                      var minoffer =
                                          double.parse(itemselling.price) *
                                              0.50;
                                      minoffer =
                                          double.parse(itemselling.price) -
                                              minoffer;

                                      if (offer < minoffer) {
                                        updateState(() {
                                          allowedoffer =
                                              'The offer is too low compared to the selling price';
                                        });
                                      } else {
                                        updateState(() {
                                          allowedoffer = '';
                                        });
                                      }
                                    } else {
                                      updateState(() {
                                        allowedoffer = '';
                                      });
                                    }
                                  },
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      labelText: "Offer Price",
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
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
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        content: Builder(
                                          builder: (context) {
                                            return Container(
                                                height: 50,
                                                width: 50,
                                                child: SpinKitChasingDots(
                                                  color: Colors.deepOrange,
                                                ));
                                          },
                                        ),
                                      ));
                              var recieverid = itemselling.userid;
                              if (recieverid != userid) {
                                var itemurl =
                                    'https://api.sellship.co/api/createoffer/' +
                                        senderid +
                                        '/' +
                                        recieverid +
                                        '/' +
                                        itemid +
                                        '/' +
                                        offercontroller.text.trim();

                                final response = await http.get(itemurl);

                                if (response.statusCode == 200) {
                                  var messageinfo = json.decode(response.body);

                                  (messageinfo['recievername']);
                                  var offers = messageinfo['offer'];

                                  Navigator.pop(context);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                  setState(() {
                                    offer = offers;
                                  });
                                } else {
                                  Navigator.pop(context);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                }
                              } else {
                                showDialog(
                                    context: context,
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
                                          entryAnimation:
                                              EntryAnimation.DEFAULT,
                                          onOkButtonPressed: () {
                                            Navigator.pop(context);
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 0)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: allowedoffer.isEmpty
                                      ? Colors.red
                                      : Colors.grey,
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
                                        fontFamily: 'Helvetica',
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 20),
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

  acceptoffer() async {
    if (offerstage != null) {
      var url = 'https://api.sellship.co/api/acceptoffer/' +
          messageid +
          '/' +
          senderid +
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
      var url = 'https://api.sellship.co/api/canceloffer/' +
          messageid +
          '/' +
          senderid +
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

  Widget chatView(BuildContext context) {
    return Scaffold(
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
                    recipentname,
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.deepOrange,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                          child: Icon(
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
                  expandedHeight: offer != null ? 170.0 : 160,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    centerTitle: true,
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        itemselling != null
                            ? Column(
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
                                                          itemselling.itemid)),
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
                                                    color: Colors.grey.shade200,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 6.0,
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  itemselling.name,
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
                                                        BorderRadius.circular(
                                                            10),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          itemselling.image,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  currency +
                                                      ' ' +
                                                      itemselling.price
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.deepOrange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )))),
                                ],
                              )
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
                                            builder: (context) => Details(
                                                itemid: itemselling.itemid)),
                                      );
                                    },
                                    child: Container(
                                        height: 30,
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  130,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
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
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      : Container()),
                                            ),
                                            InkWell(
                                                onTap: () async {
                                                  if (offerstage == 0) {
                                                    if (userid ==
                                                        itemselling.userid) {
                                                      acceptoffer();
                                                    } else {
                                                      showMe(context);
                                                    }
                                                  } else if (offerstage == 1) {
                                                    if (userid ==
                                                        itemselling.userid) {
                                                      canceloffer();
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Checkout(
                                                                    messageid:
                                                                        messageid,
                                                                    offer:
                                                                        offer,
                                                                    item:
                                                                        itemselling)),
                                                      );
                                                    }
                                                  } else if (offerstage == 2) {
                                                    if (userid ==
                                                        itemselling.userid) {
                                                      var countr = await storage
                                                          .read(key: 'country');

                                                      if (countr
                                                              .trim()
                                                              .toLowerCase() ==
                                                          'united arab emirates') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderDetailUAE(
                                                                      messageid:
                                                                          messageid,
                                                                      item:
                                                                          itemselling)),
                                                        );
                                                      } else if (countr
                                                              .trim()
                                                              .toLowerCase() ==
                                                          'united states') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderDetail(
                                                                      messageid:
                                                                          messageid,
                                                                      item:
                                                                          itemselling)),
                                                        );
                                                      } else {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderBuyerUAE(
                                                                    item:
                                                                        itemselling,
                                                                    messageid:
                                                                        messageid,
                                                                  )),
                                                        );
                                                      }
                                                    } else {
                                                      var countr = await storage
                                                          .read(key: 'country');

                                                      if (countr
                                                              .trim()
                                                              .toLowerCase() ==
                                                          'united arab emirates') {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderBuyerUAE(
                                                                    item:
                                                                        itemselling,
                                                                    messageid:
                                                                        messageid,
                                                                  )),
                                                        );
                                                      } else if (countr
                                                              .trim()
                                                              .toLowerCase() ==
                                                          'united states') {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      OrderBuyer(
                                                                        item:
                                                                            itemselling,
                                                                        messageid:
                                                                            messageid,
                                                                      )),
                                                        );
                                                      } else {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderBuyerUAE(
                                                                    item:
                                                                        itemselling,
                                                                    messageid:
                                                                        messageid,
                                                                  )),
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                                child: offerstring != null
                                                    ? Container(
                                                        height: 30,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .deepOrangeAccent
                                                                  .shade200,
                                                              offset: Offset(
                                                                  0.0,
                                                                  1.0), //(x,y)
                                                              blurRadius: 6.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                            child: itemselling !=
                                                                    null
                                                                ? Text(
                                                                    userid ==
                                                                            itemselling.userid
                                                                        ? offeruserstring
                                                                        : offerstring,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                : Container()),
                                                      )
                                                    : Container())
                                          ],
                                        ))))
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5),
                                child: InkWell(
                                    onTap: () {
                                      showMe(context);
                                    },
                                    child: Container(
                                      height: 25,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade200,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Make an Offer',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    )))
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
                                            header: BezierCircleHeader(
                                                color: Colors.deepPurple,
                                                backgroundColor: Colors
                                                    .deepPurpleAccent.shade200,
                                                enableHapticFeedback: true),
                                            scrollController: _scrollController,
                                            onRefresh: () async {
                                              setState(() {
                                                skip = skip + 10;
                                              });
                                            },
                                            child: SingleChildScrollView(
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
                                          child: SpinKitChasingDots(
                                              color: Colors.deepOrange),
                                        );
                                      }
                                    }),
                              ),
                            ),

                            Divider(height: 0, color: Colors.black26),

                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 0.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 25.0, left: 10, right: 10, top: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    padding: EdgeInsets.only(left: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            maxLines: null,
                                            expands: true,
                                            showCursor: true,
                                            controller: _text,
                                            textInputAction:
                                                TextInputAction.send,
                                            autocorrect: true,
                                            enableSuggestions: true,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16),
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
                                                      backgroundColor:
                                                          Colors.deepOrange,
                                                    ),
                                                    onTap: () async {
                                                      var x = _text.text;
                                                      _text.clear();
                                                      var date = DateTime.now();
                                                      final f = new DateFormat(
                                                          'hh:mm');
                                                      var s = f.format(date);

                                                      childList.add(Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0,
                                                                  left: 8.0,
                                                                  top: 4.0,
                                                                  bottom: 4.0),
                                                          child: Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    constraints: BoxConstraints(
                                                                        maxWidth: MediaQuery.of(context).size.width *
                                                                            3 /
                                                                            4,
                                                                        minWidth:
                                                                            100),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12.0),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius: BorderRadius.circular(15.0),
                                                                        border: Border.all(
                                                                          style:
                                                                              BorderStyle.solid,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300,
                                                                        )),
                                                                    child: Stack(
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 2.0, left: 2.0),
                                                                            child:
                                                                                Text(x, style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black)),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10),
                                                                    child: Text(
                                                                      s,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.6)),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          )));

                                                      var url =
                                                          'https://api.sellship.co/api/sendmessage/' +
                                                              senderid +
                                                              '/' +
                                                              recipentid +
                                                              '/' +
                                                              messageid;
                                                      if (x.isNotEmpty) {
                                                        final response =
                                                            await http.post(url,
                                                                body: {
                                                              'message': x,
                                                              'time': DateTime
                                                                      .now()
                                                                  .toString()
                                                            });
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          print('ok');
                                                        } else {
                                                          print(response
                                                              .statusCode);
                                                        }

                                                        Timer(
                                                            Duration(
                                                                microseconds:
                                                                    1), () {
                                                          _scrollController.jumpTo(
                                                              _scrollController
                                                                  .position
                                                                  .maxScrollExtent);
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                border: InputBorder.none,
                                                hintText: "Enter your message",
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16)),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            // ),
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
