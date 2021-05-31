import 'dart:async';
import 'dart:convert';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/checkoutoffer.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:SellShip/screens/paymentweb.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/phoenix_header.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String messageid;
  final String recipentid;
  final String recipentname;
  final String senderid;

  const ChatPage({
    Key key,
    this.recipentname,
    this.senderid,
    this.messageid,
    this.recipentid,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  var recipentname;
  var messageid;

  var recipentid;

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
    });
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:ChatPage',
      screenClassOverride: 'AppChatPage',
    );
  }

  var senderid;
  TextEditingController messagecontroller = TextEditingController();

  var profilepicture;

  var currency;
  final storage = new FlutterSecureStorage();
  Item itemselling;

  Future<List> getRemoteMessages() async {
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/getmessagesuser/' +
        messageid +
        '/' +
        userid +
        '/' +
        skip.toString();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['senderid'] == userid) {
        setState(() {
          profilepicture = jsonResponse['recieverpp'];
          recipentname = jsonResponse['recieverusername'];
        });
      } else {
        setState(() {
          profilepicture = jsonResponse['senderpp'];
          recipentname = jsonResponse['senderusername'];
        });
      }
      List jsonChat = jsonResponse['chats'];
      return jsonChat;
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
                        color: Color.fromRGBO(245, 246, 250, 1),
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
                                color: Color.fromRGBO(25, 25, 80, 1)),
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
      } else if (jsonResponse[i]['sender'] == 'SELLSHIP') {
        final f = new DateFormat('hh:mm');
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            jsonResponse[i]['date']['\$date']);
        var s = f.format(date);

        childList.add(Padding(
            padding: const EdgeInsets.only(
                right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
            child: Container(
                alignment: Alignment.center,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/logonew.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 3 / 4,
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
                                padding: const EdgeInsets.only(
                                    right: 2.0, left: 2.0),
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
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                    ]))));
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
                          color: Color.fromRGBO(245, 246, 250, 1),
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            style: BorderStyle.solid,
                            color: Color.fromRGBO(245, 246, 250, 1),
                          )),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0),
                          child: Text(jsonResponse[i]['message'],
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Color.fromRGBO(25, 25, 80, 1))),
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
                            color: Colors.black),
                      ),
                    ),
                  ]),
            )));
      }
    }

    return childList;
  }

  Stream<List<Widget>> getMessages() async* {
    yield* Stream<int>.periodic(Duration(seconds: 3), (i) => i)
        .asyncMap((i) => getRemoteMessages())
        .map((json) => mapJsonMessagesToListOfWidgetMessages(json));
  }

  TextEditingController offercontroller = TextEditingController();

  bool disabled = true;

  String allowedoffer = '';

  int offerstage;
  String offerstring;

  @override
  void dispose() {
    super.dispose();
  }

  Widget chatView(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(245, 246, 250, 1),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 30),
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: <Widget>[
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Container(
                    //     height: 30,
                    //     width: 30,
                    //     decoration: BoxDecoration(
                    //       color: Colors.deepOrangeAccent,
                    //       borderRadius: BorderRadius.circular(30),
                    //     ),
                    //     child: Icon(
                    //       Icons.add,
                    //       color: Colors.white,
                    //       size: 20,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: messagecontroller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) async {
                          if (text.isNotEmpty) {
                            final f = new DateFormat('hh:mm');
                            DateTime date =
                                new DateTime.fromMillisecondsSinceEpoch(
                                    DateTime.now().millisecondsSinceEpoch);
                            var s = f.format(date);

                            var msg = text;

                            childList.add(Padding(
                                padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                    top: 4.0,
                                    bottom: 4.0),
                                child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  4,
                                              minWidth: 50),
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                245, 246, 250, 1),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Stack(children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 2.0,
                                                left: 2.0,
                                              ),
                                              child: Text(
                                                text,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(
                                                        25, 25, 80, 1)),
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

                            setState(() {
                              childList = childList;
                            });

                            messagecontroller.clear();
                            Dio dio = new Dio();
                            FormData formData = FormData.fromMap({
                              'message': msg,
                            });

                            var addurl =
                                'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
                            var response =
                                await dio.post(addurl, data: formData);
                          }
                        },
                        scrollPadding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).viewInsets.bottom + 20),
                        decoration: InputDecoration(
                            hintText: "Send message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        if (messagecontroller.text.isNotEmpty) {
                          final f = new DateFormat('hh:mm');
                          DateTime date =
                              new DateTime.fromMillisecondsSinceEpoch(
                                  DateTime.now().millisecondsSinceEpoch);
                          var s = f.format(date);

                          var msg = messagecontroller.text;

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
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                4,
                                            minWidth: 50),
                                        padding: EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(245, 246, 250, 1),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Stack(children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 2.0,
                                              left: 2.0,
                                            ),
                                            child: Text(
                                              messagecontroller.text,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      25, 25, 80, 1)),
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

                          setState(() {
                            childList = childList;
                          });

                          messagecontroller.clear();
                          Dio dio = new Dio();
                          FormData formData = FormData.fromMap({
                            'message': msg,
                          });

                          var addurl =
                              'https://api.sellship.co/api/sendmessage/${widget.senderid}/${widget.recipentid}/${widget.messageid}';
                          var response = await dio.post(addurl, data: formData);
                          print(response.data);
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.deepOrangeAccent,
                      elevation: 0,
                    ),
                  ],
                ),
              )),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: InkWell(
            child: Row(
              children: [
                profilepicture != null && profilepicture.isNotEmpty
                    ? Container(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              height: 200,
                              width: 300,
                              imageUrl: profilepicture,
                              fit: BoxFit.cover,
                            )),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Colors.deepOrangeAccent.withOpacity(0.3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/personplaceholder.png',
                            fit: BoxFit.fitWidth,
                          ),
                        )),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '@' + widget.recipentname.toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 16,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                }),
          ),
          elevation: 0.5,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: InkWell(
                  child: Icon(
                    FeatherIcons.moreVertical,
                    color: Colors.black,
                  ),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => StorePublic(
                    //           storeid: widget.storeid,
                    //           storename: widget.storename)),
                    // );
                  }),
            ),
          ],
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: CustomScrollView(
              slivers: <Widget>[
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
                                          child: SpinKitDoubleBounce(
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
