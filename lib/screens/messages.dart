import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

class Messages extends StatefulWidget {
  Messages({Key key}) : super(key: key);

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  var userid;
  final storage = new FlutterSecureStorage();

  List<String> peoplemessaged = List<String>();
  List<String> messageid = List<String>();

  List<String> senderid = List<String>();
  List<String> recipentid = List<String>();

  List<String> lastrecieved = List<String>();
  List<String> recieveddate = List<String>();

  getmessages() async {
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://sellship.co/api/user/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        var profilemap = respons;

        var messages = profilemap['messages'];
        for (int i = 0; i < messages.length; i++) {
          if (messages[i]['user1'] == userid) {
            var messageurl =
                'https://sellship.co/api/messagedetail/' + messages[i]['msgid'];
            final responsemessage = await http.get(messageurl);

            var messageinfo = json.decode(responsemessage.body);
            var date = new DateTime.fromMillisecondsSinceEpoch(
                messageinfo['date']['\$date'] * 1000);
            var hour = date.hour;
            var minute = date.minute;
            var time = hour.toString() + ':' + minute.toString();

            setState(() {
              peoplemessaged.add(messages[i]['username2']);
              messageid.add(messages[i]['msgid']);
              senderid.add(messages[i]['user1']);
              lastrecieved.add(messageinfo['lastrecieved']);
              recieveddate.add(time);
              recipentid.add(messages[i]['user2']);
            });
          } else if (messages[i]['user2'] == userid) {
            var messageurl =
                'https://sellship.co/api/messagedetail/' + messages[i]['msgid'];
            final responsemessage = await http.get(messageurl);

            var messageinfo = json.decode(responsemessage.body);
            var date = new DateTime.fromMillisecondsSinceEpoch(
                messageinfo['date']['\$date'] * 1000);
            var hour = date.hour;
            var minute = date.minute;
            var time = hour.toString() + ':' + minute.toString();

            setState(() {
              print(messages[i]);
              peoplemessaged.add(messages[i]['username1']);
              messageid.add(messages[i]['msgid']);
              senderid.add(messages[i]['user2']);
              lastrecieved.add(messageinfo['lastrecieved']);
              recieveddate.add(time);
              recipentid.add(messages[i]['user1']);
            });
          }
        }
      } else {
        print(response.statusCode);
      }
    } else {
      //user id is null so display placeholder here
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getmessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Container(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              )),
          child: ListView.builder(
              itemCount: peoplemessaged.length,
              itemBuilder: (BuildContext ctxt, int Index) {
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: ListTile(
                              title: Text(
                                peoplemessaged[Index],
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                lastrecieved[Index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              leading: Icon(Icons.person),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    recieveddate[Index],
                                    style: TextStyle(fontSize: 12),
                                  ),
//                      hasUnreadMessage
//                          ? Container(
//                              margin: const EdgeInsets.only(top: 5.0),
//                              height: 18,
//                              width: 18,
//                              decoration: BoxDecoration(
//                                  color: Colors.orange,
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(25.0),
//                                  )),
//                              child: Center(
//                                  child: Text(
//                                newMesssageCount.toString(),
//                                style: TextStyle(fontSize: 11),
//                              )),
//                            )
//                          : SizedBox()
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPageView(
                                        messageid: messageid[Index],
                                        recipentname: peoplemessaged[Index],
                                        senderid: senderid[Index],
                                        recipentid: recipentid[Index]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        endIndent: 12.0,
                        indent: 12.0,
                        height: 0,
                      ),
                    ],
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Archive',
                      color: Colors.blue,
                      icon: Icons.archive,
                      onTap: () {},
                    ),
                    IconSlideAction(
                      caption: 'Share',
                      color: Colors.indigo,
                      icon: Icons.share,
                      onTap: () {},
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
