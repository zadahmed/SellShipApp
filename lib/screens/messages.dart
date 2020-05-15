import 'dart:convert';
import 'package:SellShip/models/messages.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  Future<List<ChatMessages>> getMessages() async {
    messagesd.clear();
    userid = await storage.read(key: 'userid');

    var messageurl =
        'https://sellship.co/api/messagedetail/' + userid.toString();
    final responsemessage = await http.get(messageurl);

    var messageinfo = json.decode(responsemessage.body);

    if (messageinfo.isNotEmpty) {
      for (int i = 0; i < messageinfo.length; i++) {
        print(messageinfo[i]);
        var imageprofile = messageinfo[i]['profilepicture'];
        var itemname = messageinfo[i]['itemname'];
        var itemid = messageinfo[i]['itemid']['\$oid'];
        final f = new DateFormat('hh:mm');
        final t = new DateFormat('yyyy-MM-dd hh:mm');

        var offe;
        var offerstage;

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
              unread: messageinfo[i]['unread'],
              recieveddate: s,
              hiddendate: q,
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
    return messagesd;
  }

  @override
  void initState() {
    super.initState();
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
            'CHATS',
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: getMessages,
            child: Container(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        )),
                    child: StreamBuilder(
                        stream: getMessages().asStream(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return ListView.builder(
                                  cacheExtent: double.parse(
                                      snapshot.data.length.toString()),
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
                                                        .data[index].itemname,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  isThreeLine: true,
                                                  subtitle: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        snapshot.data[index]
                                                            .peoplemessaged,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        snapshot.data[index]
                                                            .lastrecieved,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  leading: Container(
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: snapshot
                                                                    .data[index]
                                                                    .profilepicture ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/personplaceholder.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : CachedNetworkImage(
                                                                imageUrl: snapshot
                                                                    .data[index]
                                                                    .profilepicture,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitChasingDots(
                                                                        color: Colors
                                                                            .deepOrange),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              )),
                                                  ),
                                                  trailing: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        snapshot.data[index]
                                                            .recieveddate,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      snapshot.data[index]
                                                                  .unread ==
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
                                                    if (snapshot.data[index]
                                                            .offerstage !=
                                                        null) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
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
                                                                            .data[index]
                                                                            .senderid,
                                                                        recipentid: snapshot
                                                                            .data[index]
                                                                            .recipentid,
                                                                        fcmToken: snapshot
                                                                            .data[index]
                                                                            .fcmtokenreciever,
                                                                        itemid: snapshot
                                                                            .data[index]
                                                                            .itemid,
                                                                        offerstage: snapshot
                                                                            .data[index]
                                                                            .offerstage,
                                                                        offer: snapshot
                                                                            .data[index]
                                                                            .offer,
                                                                      )));
                                                    } else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
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
                                                                            .data[index]
                                                                            .senderid,
                                                                        recipentid: snapshot
                                                                            .data[index]
                                                                            .recipentid,
                                                                        fcmToken: snapshot
                                                                            .data[index]
                                                                            .fcmtokenreciever,
                                                                        itemid: snapshot
                                                                            .data[index]
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical:
                                                                      2.0),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical:
                                                                      2.0),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 8.0,
                                                        color: Colors.white,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 2.0),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 8.0,
                                                        color: Colors.white,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                        })))));
  }
}
