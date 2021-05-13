import 'dart:async';
import 'dart:convert';
import 'package:SellShip/models/messages.dart';
import 'package:SellShip/screens/chatpage.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      final responsemessage = await http.get(Uri.parse(messageurl));

      var messageinfo = json.decode(responsemessage.body);
      print(messageinfo);
      for (int i = 0; i < messageinfo.length; i++) {
        if (messageinfo[i]['senderid'] == userid) {
          final f = new DateFormat('hh:mm');
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              messageinfo[i]['lastdate']['\$date']);
          var s = f.format(date);

          ChatMessages chats = ChatMessages(
              messageid: messageinfo[i]['msgid'],
              recievername: messageinfo[i]['recieverusername'],
              senderid: messageinfo[i]['senderid'],
              recipentid: messageinfo[i]['recieverid'],
              profilepicture: messageinfo[i]['recieverpp'],
              lastrecieved: messageinfo[i].containsKey('lastmessage')
                  ? messageinfo[i]['lastmessage']
                  : null,
              unread: messageinfo[i].containsKey('unread')
                  ? messageinfo[i]['unread']
                  : false,
              recieveddate: s);
          messagesd.add(chats);
        } else {
          final f = new DateFormat('hh:mm');
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              messageinfo[i]['lastdate']['\$date']);
          var s = f.format(date);
          ChatMessages chats = ChatMessages(
              messageid: messageinfo[i]['msgid'],
              recievername: messageinfo[i]['senderusername'],
              senderid: messageinfo[i]['recieverid'],
              recipentid: messageinfo[i]['senderid'],
              profilepicture: messageinfo[i]['senderpp'],
              lastrecieved: messageinfo[i].containsKey('lastmessage')
                  ? messageinfo[i]['lastmessage']
                  : null,
              unread: messageinfo[i].containsKey('unread')
                  ? messageinfo[i]['unread']
                  : false,
              recieveddate: s);
          messagesd.add(chats);
        }
      }
      setState(() {
        messagesd = messagesd;
        loading = false;
      });
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
      body: loading == false
          ? messagesd.isNotEmpty
              ? EasyRefresh(
                  header: CustomHeader(
                      extent: 160.0,
                      enableHapticFeedback: true,
                      triggerDistance: 160.0,
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
                  child: ListView.builder(
                      itemCount: messagesd.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          messageid: messagesd[index].messageid,
                                          recipentid:
                                              messagesd[index].recipentid,
                                          recipentname:
                                              messagesd[index].recievername,
                                          senderid: userid,
                                        )),
                              );
                            },
                            title: Text(
                              '@' + messagesd[index].recievername.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              messagesd[index].recieveddate,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                            // isThreeLine: true,
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  messagesd[index].lastrecieved != null
                                      ? messagesd[index].lastrecieved
                                      : '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight:
                                          messagesd[index].unread == true
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                ),
                              ],
                            ),
                            leading: messagesd[index].profilepicture != null &&
                                    messagesd[index].profilepicture.isNotEmpty
                                ? Container(
                                    height: 50,
                                    width: 50,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                          height: 200,
                                          width: 300,
                                          imageUrl:
                                              messagesd[index].profilepicture,
                                          fit: BoxFit.cover,
                                        )),
                                  )
                                : CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.deepOrangeAccent
                                        .withOpacity(0.3),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.asset(
                                        'assets/personplaceholder.png',
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )),
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: FeatherIcons.trash,
                              onTap: () async {
                                var messageurl =
                                    'https://api.sellship.co/api/delete/message/' +
                                        userid.toString() +
                                        '/' +
                                        messagesd[index].messageid;
                                final responsemessage =
                                    await http.get(Uri.parse(messageurl));
                                if (responsemessage.statusCode == 200) {
                                  getMessages();
                                }
                              },
                            ),
                          ],
                        );
                      }),
                  onRefresh: () async {
                    setState(() {
                      loading = true;
                    });
                    getMessages();
                  },
                )
              : Container(
                  width: double.infinity,
                  child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '💬',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Nothing to see here',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'You don\'t have any new messages.',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                                color: Colors.black),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color:
                                            Colors.deepOrange.withOpacity(0.4),
                                        offset: const Offset(1.1, 1.1),
                                        blurRadius: 5.0),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Start Messaging',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RootScreen(
                                          index: 2,
                                        )),
                              );
                            },
                          ),
                        ],
                      )))
          : Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Column(
                  children: [
                    0,
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    9,
                  ]
                      .map((_) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10.0, top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50.0,
                                  height: 50.0,
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
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 5.0,
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
                                      SizedBox(
                                        height: 10,
                                      )
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
