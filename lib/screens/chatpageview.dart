import 'dart:async';
import 'dart:convert';

import 'package:SellShip/recievedmessagewidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/sendedmessagewidget.dart';

class ChatPageView extends StatefulWidget {
  final String recipentname;
  final String messageid;
  final String senderid;
  final String recipentid;

  const ChatPageView(
      {Key key,
      this.recipentname,
      this.messageid,
      this.senderid,
      this.recipentid})
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

  @override
  void initState() {
    super.initState();
    setState(() {
      recipentname = widget.recipentname;
      messageid = widget.messageid;
      senderid = widget.senderid;
      recipentid = widget.recipentid;
    });
    getMessages();
  }

  void getMessages() async {
    var url = 'https://sellship.co/api/getmessages/' + messageid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var chats = json.decode(response.body);

      for (int i = 0; i < chats.length; i++) {
        print(chats[i]);
        if (chats[i]['sender'] == senderid) {
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
                  child: Text(
                    chats[i]['message'],
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                  ),
                ),
              )));
        } else {
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
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Text(
                    chats[i]['message'],
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                  ),
                ),
              )));
        }
        setState(() {
          childList = childList;
        });
      }
    } else {
      print(response.statusCode);
    }
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
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.amberAccent,
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    // height: 500,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
//                        image: DecorationImage(
//                            image: AssetImage(
//                                "assets/images/chat-background-1.jpg"),
//                            fit: BoxFit.cover,
//                            colorFilter: ColorFilter.linearToSrgbGamma()),
                          ),
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          // reverse: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: childList,
                          )),
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
                              var url = 'https://sellship.co/api/sendmessage/' +
                                  senderid +
                                  '/' +
                                  recipentid +
                                  '/' +
                                  messageid;
                              final response = await http.post(url, body: {
                                'message': _text.text,
                                'time': DateTime.now().toString()
                              });
                              if (response.statusCode == 200) {
                                print(response.body);
                              } else {
                                print(response.statusCode);
                              }
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
                                      child: Text(
                                        _text.text,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )));
                              _text.clear();

                              setState(() {
                                childList = childList;
                              });
                              Timer(Duration(milliseconds: 100), () {
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                              });
//                              _scrollController.jumpTo(
//                                  _scrollController.position.maxScrollExtent);
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
