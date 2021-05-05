import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CommentsPage extends StatefulWidget {
  final String itemid;
  CommentsPage({Key key, this.itemid}) : super(key: key);

  _CommentsPageState createState() => _CommentsPageState();
}

class Comments {
  final String message;
  final String date;
  final String userid;
  final String userpp;
  final String username;
  final String id;
  final String itemid;

  Comments({
    this.itemid,
    this.id,
    this.message,
    this.date,
    this.userid,
    this.userpp,
    this.username,
  });
}

class _CommentsPageState extends State<CommentsPage> {
  final storage = new FlutterSecureStorage();
  var userid;
  var itemid;

  bool enableSlideOff = true;
  bool hideCloseButton = false;
  bool onlyOne = true;
  bool crossPage = true;
  int seconds = 5;
  int animationMilliseconds = 200;
  int animationReverseMilliseconds = 200;

  @override
  void initState() {
    super.initState();
    setState(() {
      itemid = widget.itemid;
      commentsloader = true;
    });
    loadcomments();
  }

  bool commentsloader;

  List<Comments> commentslist = List<Comments>();
  TextEditingController commentcontroller = new TextEditingController();

  final commentState = GlobalKey<ScaffoldState>();

  loadcomments() async {
    userid = await storage.read(key: 'userid');
    commentslist.clear();
    var url = 'https://api.sellship.co/api/comment/' + itemid;

    List<Comments> commentslis = List<Comments>();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        final f = new DateFormat('yyyy-MM-dd hh:mm');
        DateTime s = f.parse(jsonbody[i]['date']);

        var datecommented = timeago.format(s);

        Comments comm = Comments(
            itemid: jsonbody[i]['itemid'],
            id: jsonbody[i]['id'],
            message: jsonbody[i]['comment'],
            userid: jsonbody[i]['userid'],
            userpp: jsonbody[i]['userpp'],
            username: jsonbody[i]['username'],
            date: datecommented);
        commentslis.add(comm);
      }

      setState(() {
        commentslist = commentslis;
        commentsloader = false;
      });
    } else {
      print(response.statusCode);
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    commentState.currentState?.removeCurrentSnackBar();
    commentState.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: commentState,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                FeatherIcons.chevronLeft,
                color: Colors.black,
              ),
            ),
            title: Text(
              'Comments',
              style: TextStyle(
                fontFamily: 'Helvetica',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )),
        bottomNavigationBar: Container(
          color: Colors.grey.withOpacity(0.1),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: EdgeInsets.only(bottom: 25, left: 10, right: 10, top: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  maxLines: 20,
                  controller: commentcontroller,
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontFamily: 'Helvetica', fontSize: 16),
                  decoration: InputDecoration(
                      // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(5),
                        child: InkWell(
                            child: CircleAvatar(
                              child: Icon(
                                FeatherIcons.messageCircle,
                                size: 20,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.deepOrange,
                            ),
                            onTap: () async {
                              if (commentcontroller.text.isNotEmpty) {
                                var comment = commentcontroller.text;
                                var userid = await storage.read(key: 'userid');
                                final f = new DateFormat('yyyy-MM-dd hh:mm');

                                DateTime s = f.parse(DateTime.now().toString());
                                var datecommented = timeago.format(s);

                                var uui = Uuid();
                                var uuid = uui.v4();
                                Comments comm = Comments(
                                    itemid: widget.itemid,
                                    id: uuid,
                                    message: commentcontroller.text.trim(),
                                    userid: userid,
                                    userpp: '',
                                    username: 'User',
                                    date: datecommented);
                                commentslist.add(comm);

                                setState(() {
                                  commentslist = commentslist;
                                });
                                commentcontroller.clear();
                                var url =
                                    'https://api.sellship.co/api/comment/' +
                                        itemid;

                                if (userid != null) {
                                  final response = await http
                                      .post(Uri.parse(url), body: {
                                    'userid': userid,
                                    'comment': comment
                                  });

                                  if (response.statusCode == 200) {
                                    if (response.body == 'Matched') {
                                      print('Matched');
                                    }
                                    loadcomments();
                                  } else {
                                    print(response.statusCode);
                                  }
                                } else {
                                  showInSnackBar('Please Login to Comment');
                                }
                              }
                            }),
                      ),
                      border: InputBorder.none,
                      hintText: "Enter your comment",
                      hintStyle: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          color: Colors.grey)),
                ),
              ),
            ),
          ),
        ),
        body: EasyRefresh.custom(
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
            onRefresh: () {
              return loadcomments();
            },
            slivers: <Widget>[
              SliverFillRemaining(
                  child: commentslist.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Column(children: [
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                                child: ListView.builder(
                                    itemCount: commentslist.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return new Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        child: commentslist[
                                                                    index]
                                                                .userpp
                                                                .isNotEmpty
                                                            ? CachedNetworkImage(
                                                                height: 200,
                                                                width: 300,
                                                                imageUrl:
                                                                    commentslist[
                                                                            index]
                                                                        .userpp,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.asset(
                                                                'assets/personplaceholder.png',
                                                                fit: BoxFit
                                                                    .fitWidth,
                                                              )),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            100,
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UserItems(
                                                                          userid:
                                                                              commentslist[index].userid,
                                                                          username:
                                                                              commentslist[index].username,
                                                                        )),
                                                          );
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                commentslist[
                                                                        index]
                                                                    .username,
                                                                style:
                                                                    new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 14,
                                                                )),
                                                            Text(
                                                              commentslist[
                                                                      index]
                                                                  .date,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    width: 260,
                                                    child: Text(
                                                      commentslist[index]
                                                          .message,
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          var url =
                                                              'https://api.sellship.co/api/report/comment/' +
                                                                  commentslist[
                                                                          index]
                                                                      .id +
                                                                  '/' +
                                                                  itemid;

                                                          final response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      url));
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            showInSnackBar(
                                                                'The comment has been reported. Thank you for making a SellShip a safer community!');
                                                          }
                                                        },
                                                        child: Text(
                                                          'Report',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      commentslist[index]
                                                                  .userid ==
                                                              userid
                                                          ? InkWell(
                                                              onTap: () async {
                                                                var url = 'https://api.sellship.co/api/delete/comment/' +
                                                                    commentslist[
                                                                            index]
                                                                        .id +
                                                                    '/' +
                                                                    itemid;

                                                                final response =
                                                                    await http.get(
                                                                        Uri.parse(
                                                                            url));
                                                                if (response
                                                                        .statusCode ==
                                                                    200) {
                                                                  showInSnackBar(
                                                                      'The comment has been deleted.');
                                                                }
                                                              },
                                                              child: Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ));
                                    })),
                          ]))
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, top: 10),
                                      child: InkWell(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(
                                              FeatherIcons.messageCircle,
                                              color: Colors.deepOrange,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Add a comment',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommentsPage(
                                                      itemid: itemid,
                                                    )),
                                          );
                                        },
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              commentsloader == false
                                  ? Center(
                                      child: Text(
                                        'No Comments',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: SpinKitDoubleBounce(
                                      color: Colors.deepOrange,
                                    )),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ))
            ]));
  }
}
