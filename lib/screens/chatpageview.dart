import 'dart:async';
import 'dart:convert';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatPageView extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;
  final fcmToken;
  final senderName;
  const ChatPageView(
      {Key key,
      this.recipentname,
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
    });

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
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 3 / 4),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Stack(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0, left: 8.0, top: 8.0, bottom: 15.0),
                    child: Text(
                      jsonResponse[i]['message'],
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 10,
                    child: Text(
                      s,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          color: Colors.white),
                    ),
                  )
                ]),
              ),
            )));
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
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 3 / 4),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Stack(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0, left: 8.0, top: 8.0, bottom: 15.0),
                    child: Text(jsonResponse[i]['message'],
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white)),
                  ),
                  Positioned(
                    bottom: 1,
                    left: 10,
                    child: Text(
                      s,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6)),
                    ),
                  )
                ]),
              ),
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
      appBar: AppBar(
        title: Text(
          recipentname,
          style: TextStyle(
              fontFamily: 'Montserrat', fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(0, 73, 83, 1),
      ),
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
                  // SizedBox(
                  //   height: 50,
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
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
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
                              setState(() {
                                childList = childList;
                              });
                              var url = 'https://sellship.co/api/sendmessage/' +
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
