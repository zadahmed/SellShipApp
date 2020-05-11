import 'dart:async';
import 'dart:convert';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/details.dart';
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
  final String itemid;
  final fcmToken;
  final senderName;
  const ChatPageView(
      {Key key,
      this.recipentname,
      this.itemid,
      this.messageid,
      this.senderid,
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
  int limit;
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
    });
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
        price: jsonbody[0]['price'],
        category: jsonbody[0]['category'],
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
                                fontFamily: 'Montserrat',
                                fontSize: 14,
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
                            fontFamily: 'Montserrat',
                            fontSize: 10,
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
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Colors.black)),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        s,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 160),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 160,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    height: 70,
                    color: Colors.deepOrange,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            recipentname,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10, bottom: 5),
                          child: Align(
                            alignment: Alignment.centerRight,
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
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  }),
                            )),
                      ],
                    ),
                  ),
                  itemselling != null
                      ? Padding(
                          padding: EdgeInsets.all(10),
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
                                    color: Colors.white,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      itemselling.name,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
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
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      itemselling.price.toString() +
                                          ' ' +
                                          currency,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                          color: Colors.blue,
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
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    color: Colors.white)),
                                          ),
                                          Positioned(
                                            bottom: 1,
                                            right: 10,
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
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
                                        senderid +
                                        '/' +
                                        recipentid +
                                        '/' +
                                        messageid;
                                if (x.isNotEmpty) {
                                  final response = await http.post(url, body: {
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
                        ),
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
