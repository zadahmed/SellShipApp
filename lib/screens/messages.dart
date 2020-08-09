import 'dart:async';
import 'dart:convert';
import 'package:SellShip/models/messages.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  getMessages() async {
    messagesd.clear();
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var messageurl =
          'https://api.sellship.co/api/messagedetail/' + userid.toString();
      final responsemessage = await http.get(messageurl);

      var messageinfo = json.decode(responsemessage.body);

      if (messageinfo.isNotEmpty) {
        for (int i = 0; i < messageinfo.length; i++) {
          var imageprofile = messageinfo[i]['profilepicture'];
          var itemname = messageinfo[i]['itemname'];
          var itemid = messageinfo[i]['itemid']['\$oid'];
          final f = new DateFormat('hh:mm');
          final t = new DateFormat('yyyy-MM-dd hh:mm');

          var offe;
          var offerstage;
          var unread;
          var msgcount;

          if (messageinfo[i]['offer'] != null) {
            offe = messageinfo[i]['offer'];
          } else if (messageinfo[i]['offer'] == null) {
            offe = null;
          }

          if (messageinfo[i]['offerstage'] != null) {
            offerstage = messageinfo[i]['offerstage'];
          } else if (messageinfo[i]['offerstage'] == null) {
            offerstage = null;
          }

          if (messageinfo[i]['lastid'] != null) {
            var lastid = messageinfo[i]['lastid'];

            if (lastid == userid) {
              unread = false;
            } else if (lastid != userid) {
              if (messageinfo[i]['unread'] == true) {
                unread = true;
                if (messageinfo[i]['msgcount'] != null) {
                  msgcount = messageinfo[i]['msgcount'];
                } else if (messageinfo[i]['msgcount'] == null) {
                  msgcount = null;
                }
              } else {
                unread = false;
              }
            }
          }

          if (messageinfo[i]['date'] != null) {
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                messageinfo[i]['date']['\$date']);
            var s = f.format(date);
            var q = t.format(date);

            ChatMessages msg = ChatMessages(
                messageid: messageinfo[i]['msgid'],
                peoplemessaged: messageinfo[i]['user2name'],
                senderid: messageinfo[i]['user1'],
                offer: offe,
                offerstage: offerstage,
                lastrecieved: messageinfo[i]['lastrecieved'],
                unread: unread,
                recieveddate: s,
                hiddendate: q,
                msgcount: msgcount,
                itemname: itemname,
                senderName: messageinfo[i]['user1name'],
                recipentid: messageinfo[i]['user2'],
                profilepicture: imageprofile,
                itemid: itemid,
                fcmtokenreciever: messageinfo[i]['fcmtokenreciever']);

            messagesd.add(msg);
          }
        }
      } else {
        messagesd = [];
      }

      messagesd.sort();

      if (mounted) {
        setState(() {
          messagesd = messagesd;
          loading = false;
        });
      } else {
        messagesd = messagesd;
        loading = false;
      }
    } else {
      setState(() {
        messagesd = [];
        loading = false;
      });
    }
  }

  bool loading;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.deepOrange,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.deepOrange,
          ),
          centerTitle: true,
          title: Text(
            'CHATS',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.all(20),
                child: InkWell(
                  onTap: () async {
                    var messageurl =
                        'https://api.sellship.co/api/clearnotification/' +
                            userid.toString();
                    final responsemessage = await http.get(messageurl);
                    print(responsemessage.statusCode);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        color: Colors.deepOrangeAccent,
                        fontWeight: FontWeight.w400),
                  ),
                )),
          ],
        ),
        body: messagesd.isNotEmpty
            ? EasyRefresh(
                child: loading == false
                    ? ListView.builder(
                        cacheExtent: double.parse(messagesd.length.toString()),
                        itemCount: messagesd.length,
                        itemBuilder: (BuildContext ctxt, int index) {
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
                                          messagesd[index].itemname,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                          ),
                                        ),
                                        isThreeLine: true,
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              messagesd[index].peoplemessaged,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      messagesd[index].unread ==
                                                              true
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            Text(
                                              messagesd[index].lastrecieved,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 11,
                                                  color:
                                                      messagesd[index].unread ==
                                                              true
                                                          ? Colors.black
                                                          : Colors.grey,
                                                  fontWeight:
                                                      messagesd[index].unread ==
                                                              true
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                          ],
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
                                              child: messagesd[index]
                                                          .profilepicture ==
                                                      null
                                                  ? Image.asset(
                                                      'assets/personplaceholder.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: messagesd[index]
                                                          .profilepicture,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitChasingDots(
                                                              color: Colors
                                                                  .deepOrange),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    )),
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              messagesd[index].recieveddate,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 11,
                                                  fontWeight:
                                                      messagesd[index].unread ==
                                                              true
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            messagesd[index].unread == true
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .deepOrangeAccent,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(20.0),
                                                        )),
                                                    child: Center(
                                                        child: Text(
                                                      '',
                                                      style: TextStyle(
                                                          fontSize: 8,
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white),
                                                    )),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                        onTap: () {
                                          if (messagesd[index].offerstage !=
                                              null) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPageView(
                                                          senderName:
                                                              messagesd[index]
                                                                  .senderName,
                                                          messageid:
                                                              messagesd[index]
                                                                  .messageid,
                                                          recipentname:
                                                              messagesd[index]
                                                                  .peoplemessaged,
                                                          senderid:
                                                              messagesd[index]
                                                                  .senderid,
                                                          recipentid:
                                                              messagesd[index]
                                                                  .recipentid,
                                                          fcmToken: messagesd[
                                                                  index]
                                                              .fcmtokenreciever,
                                                          itemid:
                                                              messagesd[index]
                                                                  .itemid,
                                                          offerstage:
                                                              messagesd[index]
                                                                  .offerstage,
                                                          offer:
                                                              messagesd[index]
                                                                  .offer,
                                                        )));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPageView(
                                                          senderName:
                                                              messagesd[index]
                                                                  .senderName,
                                                          messageid:
                                                              messagesd[index]
                                                                  .messageid,
                                                          recipentname:
                                                              messagesd[index]
                                                                  .peoplemessaged,
                                                          senderid:
                                                              messagesd[index]
                                                                  .senderid,
                                                          recipentid:
                                                              messagesd[index]
                                                                  .recipentid,
                                                          fcmToken: messagesd[
                                                                  index]
                                                              .fcmtokenreciever,
                                                          itemid:
                                                              messagesd[index]
                                                                  .itemid,
                                                        )));
                                          }
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
                        })
                    : Container(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2.0),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2.0),
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
                onRefresh: () async {
                  getMessages();
                },
              )
            : Column(
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
                        fontFamily: 'Helvetica',
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
              ));
  }
}
