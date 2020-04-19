import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:dio/dio.dart';
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

  List<String> peoplemessaged = List<String>();
  List<String> messageid = List<String>();

  List<String> senderid = List<String>();
  List<String> recipentid = List<String>();

  List<String> lastrecieved = List<String>();
  List<String> recieveddate = List<String>();
  List<bool> unreadlist = List<bool>();

  getmessages() async {
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://sellship.co/api/user/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        var profilemap = respons;

        var messages = profilemap['messages'];
        if (messages == null) {
          setState(() {
            loading = false;
            userid = null;
          });
        } else {
          for (int i = 0; i < messages.length; i++) {
            if (messages[i]['user1'] == userid) {
              var messageurl = 'https://sellship.co/api/messagedetail/' +
                  messages[i]['msgid'];
              final responsemessage = await http.get(messageurl);

              var messageinfo = json.decode(responsemessage.body);

              final f = new DateFormat('hh:mm');
              if (messageinfo['date'] != null) {
                DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                    messageinfo['date']['\$date']);
                var s = f.format(date);

                setState(() {
                  peoplemessaged.add(messages[i]['username2']);
                  messageid.add(messages[i]['msgid']);
                  senderid.add(messages[i]['user1']);
                  lastrecieved.add(messageinfo['lastrecieved']);
                  unreadlist.add(messageinfo['unread']);
                  recieveddate.add(s);
                  recipentid.add(messages[i]['user2']);
                });
              }
            } else if (messages[i]['user2'] == userid) {
              var messageurl = 'https://sellship.co/api/messagedetail/' +
                  messages[i]['msgid'];
              final responsemessage = await http.get(messageurl);

              var messageinfo = json.decode(responsemessage.body);
              print(messageinfo['date']);
              final f = new DateFormat('hh:mm');
              if (messageinfo['date'] != null) {
                DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                    messageinfo['date']['\$date']);
                var s = f.format(date);

                setState(() {
                  peoplemessaged.add(messages[i]['username1']);
                  messageid.add(messages[i]['msgid']);
                  senderid.add(messages[i]['user2']);
                  lastrecieved.add(messageinfo['lastrecieved']);
                  unreadlist.add(messageinfo['unread']);
                  recieveddate.add(s);
                  recipentid.add(messages[i]['user1']);
                });
              }
            }
          }
        }
        setState(() {
          loading = false;
        });
      } else {
        print(response.statusCode);
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  bool loading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getmessages();
    loading = true;
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
      body: loading == false
          ? Container(
              child: userid != null
                  ? Container(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                recieveddate[Index],
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              unreadlist[Index] == true
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      height: 18,
                                                      width: 18,
                                                      decoration: BoxDecoration(
                                                          color: Colors.amber,
                                                          borderRadius:
                                                              BorderRadius.all(
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
                                                        messageid:
                                                            messageid[Index],
                                                        recipentname:
                                                            peoplemessaged[
                                                                Index],
                                                        senderid:
                                                            senderid[Index],
                                                        recipentid:
                                                            recipentid[Index]),
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
                          }),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Text(
                            'View your Messages\'s here ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(
                            child: Image.asset(
                          'assets/messages.png',
                          fit: BoxFit.fitWidth,
                        ))
                      ],
                    ),
            )
          : Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Column(
                  children: [0, 1, 2, 3, 4, 5, 6]
                      .map((_) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48.0,
                                  height: 48.0,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
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
            ),
    );
  }
}
