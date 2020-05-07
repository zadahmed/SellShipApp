import 'dart:convert';
import 'package:SellShip/models/messages.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Messages extends StatefulWidget {
  Messages({Key key}) : super(key: key);

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  var userid;
  final storage = new FlutterSecureStorage();

  List<ChatMessages> messagesd = List<ChatMessages>();

  Future<List<ChatMessages>> getMessages() async {
    messagesd.clear();
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://sellship.co/api/user/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        var profilemap = respons;
        var messages = profilemap['messages'];
        if (messages == null) {
          messagesd = [];
        } else {
          for (int i = 0; i < messages.length; i++) {
            if (messages[i]['user1'] == userid) {
              var messageurl = 'https://sellship.co/api/messagedetail/' +
                  messages[i]['msgid'];
              final responsemessage = await http.get(messageurl);
              
              var messageinfo = json.decode(responsemessage.body);
              final f = new DateFormat('hh:mm');
              final t = new DateFormat('yyyy-MM-dd hh:mm');
              if (messageinfo['date'] != null) {
                DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                    messageinfo['date']['\$date']);
                var s = f.format(date);
                var q = t.format(date);
                print(messages[i]);
                ChatMessages msg = ChatMessages(
                    messageid: messages[i]['msgid'],
                    peoplemessaged: messages[i]['username2'],
                    senderid: messages[i]['user1'],
                    lastrecieved: messageinfo['lastrecieved'],
                    unread: messageinfo['unread'],
                    recieveddate: s,
                    hiddendate: q,
                    senderName: messages[i]['username1'],
                    recipentid: messages[i]['user2'],
                    fcmtokenreciever: messages[i]['fcmtokenreciever']);

                messagesd.add(msg);
              }
            } else if (messages[i]['user2'] == userid) {
              var messageurl = 'https://sellship.co/api/messagedetail/' +
                  messages[i]['msgid'];
              final responsemessage = await http.get(messageurl);

              var messageinfo = json.decode(responsemessage.body);
              print(messageinfo['date']);
              final f = new DateFormat('hh:mm');
              final t = new DateFormat('yyyy-MM-dd hh:mm');
              if (messageinfo['date'] != null) {
                DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                    messageinfo['date']['\$date']);
                var s = f.format(date);
                var q = t.format(date);
                print(messages[i]);
                print(messages[i]['fcmtokenreciever']);

                ChatMessages msg = ChatMessages(
                  senderName: messages[i]['username1'],
                  messageid: messages[i]['msgid'],
                  peoplemessaged: messages[i]['username1'],
                  senderid: messages[i]['user2'],
                  lastrecieved: messageinfo['lastrecieved'],
                  unread: messageinfo['unread'],
                  recieveddate: s,

                  hiddendate: q,
                  recipentid: messages[i]['user1'],
                  fcmtokenreciever: messages[i]['fcmtokenreciever'],
                );

                messagesd.add(msg);
              }
            }
          }
        }
      } else {
        print(response.statusCode);
      }
    } else {
      messagesd = null;
    }
    messagesd.sort();
    return messagesd;
  }

  bool loading;

  @override
  void initState() {
    super.initState();
    print(messagesd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          title: Text(
            'Chats',
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 20, color: Colors.white),
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
                child: FutureBuilder(
                    future: getMessages(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                // print(jsonDecode(
                                //     snapshot.data[index].toString()));
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
                                                snapshot
                                                    .data[index].peoplemessaged,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                ),
                                              ),
                                              subtitle: Text(
                                                snapshot
                                                    .data[index].lastrecieved,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 11,
                                                ),
                                              ),
                                              leading: Icon(Icons.person),
                                              trailing: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index]
                                                        .recieveddate,
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  snapshot.data[index].unread ==
                                                          true
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5.0),
                                                          height: 18,
                                                          width: 18,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .deepOrangeAccent,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        25.0),
                                                                  )),
                                                          child: Center(
                                                              child: Text(
                                                            '',
                                                          )),
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPageView(
                                                      senderName: snapshot
                                                          .data[index]
                                                          .senderName,
                                                      messageid: snapshot
                                                          .data[index]
                                                          .messageid,
                                                      recipentname: snapshot
                                                          .data[index]
                                                          .peoplemessaged,
                                                      senderid: snapshot
                                                          .data[index].senderid,
                                                      recipentid: snapshot
                                                          .data[index]
                                                          .recipentid,
                                                      fcmToken: snapshot
                                                          .data[index]
                                                          .fcmtokenreciever,
                                                    ),
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
                                  ],
                                );
                              });
                        } else {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Column(
                                children: [0, 1, 2, 3, 4, 5, 6]
                                    .map((_) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 48.0,
                                                height: 48.0,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 2.0),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 2.0),
                                                    ),
                                                    Container(
                                                      width: 40.0,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                'View your Messages here ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Image.asset(
                              'assets/messages.png',
                              fit: BoxFit.fitWidth,
                            ))
                          ],
                        );
                      } else {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Column(
                              children: [0, 1, 2, 3, 4, 5, 6]
                                  .map((_) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 48.0,
                                              height: 48.0,
                                              color: Colors.white,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 8.0,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 2.0),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 8.0,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 2.0),
                                                  ),
                                                  Container(
                                                    width: 40.0,
                                                    height: 8.0,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                      }
                    }))));
  }
}
