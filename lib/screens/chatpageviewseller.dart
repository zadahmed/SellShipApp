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

class ChatPageViewSeller extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;
  final String offer;
  final String itemname;
  final String itemimage;
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
  }

  Widget selleroptions(BuildContext context) {
    if (offerstage == 0) {
      return Container(
        height: 120,
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
                          acceptoffer();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
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
                                )
                              ],
                            ))))),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                        onTap: () {
                          canceloffer();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
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
                                )
                              ],
                            ))))),
              ],
            ),
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
                        Icon(Icons.keyboard_return),
                        SizedBox(width: 5),
                        Text(
                          'Counter Offer',
                          textAlign: TextAlign.center,
                        )
                      ],
                    )))),
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
                        )
                      ],
                    )))),
          ],
        ),
      );
    }
    if (offerstage == -1) {
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
                        Icon(Icons.cancel),
                        SizedBox(width: 5),
                        Text(
                          'Offer Declined',
                          textAlign: TextAlign.center,
                        )
                      ],
                    )))),
          ],
        ),
      );
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
      List jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse;
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
    yield* Stream<int>.periodic(Duration(seconds: 1), (i) => i)
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
//                                var itemurl =
//                                    'https://api.sellship.co/api/createoffer/' +
//                                        senderid +
//                                        '/' +
//                                        recieverid +
//                                        '/' +
//                                        itemid +
//                                        '/' +
//                                        offercontroller.text.trim();

//                                final response = await http.get(itemurl);
//
//                                if (response.statusCode == 200) {
//                                  var messageinfo = json.decode(response.body);
//
//                                  (messageinfo['recievername']);
//                                  var offers = messageinfo['offer'];
//
//                                  Navigator.pop(context);
//                                  Navigator.of(context, rootNavigator: true)
//                                      .pop('dialog');
//                                  setState(() {
//                                    offer = offers;
//                                  });
//                                } else {
//                                  Navigator.pop(context);
//                                  Navigator.of(context, rootNavigator: true)
//                                      .pop('dialog');
//                                }
//                              } else {
//                                showDialog(
//                                    context: context,
//                                    builder: (_) => AssetGiffyDialog(
//                                          image: Image.asset(
//                                            'assets/oops.gif',
//                                            fit: BoxFit.cover,
//                                          ),
//                                          title: Text(
//                                            'Oops!',
//                                            textAlign: TextAlign.center,
//                                            style: TextStyle(
//                                                fontSize: 22.0,
//                                                fontWeight: FontWeight.w600),
//                                          ),
//                                          description: Text(
//                                            'You can\'t send an offer to yourself!',
//                                            textAlign: TextAlign.center,
//                                            style: TextStyle(),
//                                          ),
//                                          onlyOkButton: true,
//                                          entryAnimation:
//                                              EntryAnimation.DEFAULT,
//                                          onOkButtonPressed: () {
//                                            Navigator.pop(context);
//                                            Navigator.of(context,
//                                                    rootNavigator: true)
//                                                .pop('dialog');
//                                            Navigator.push(
//                                              context,
//                                              MaterialPageRoute(
//                                                  builder: (context) =>
//                                                      RootScreen(index: 0)),
//                                            );
//                                          },
//                                        ));
//                              }
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
          widget.messageid +
          '/' +
          widget.itemid +
          '/' +
          widget.senderid +
          '/' +
          widget.recipentid;
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
        print('Success');
        setState(() {
          offerstage = -1;
        });

        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                                            imageUrl: profilepicture,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitChasingDots(
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
                                                itemid: itemselling.itemid)),
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
                                          child: SpinKitChasingDots(
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
