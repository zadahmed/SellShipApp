import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/messages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:intl/intl.dart';

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

  Comments({
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

  @override
  void initState() {
    super.initState();
    setState(() {
      itemid = widget.itemid;
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
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['date']);
        DateTime datecomment = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var datecommented = timeago.format(datecomment);

        Comments comm = Comments(
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
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Comments',
            style: TextStyle(
                fontFamily: 'SF',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600),
          ),
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.deepOrange,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                }),
          ),
        ),
        body: commentslist.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: ListView.builder(
                    itemCount: commentslist.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new Card(
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Messages()),
                                  );
                                },
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: commentslist[index]
                                              .userpp
                                              .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  commentslist[index].userpp,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/personplaceholder.png',
                                              fit: BoxFit.fitWidth,
                                            )),
                                ),
                                title: Text(
                                  commentslist[index].message,
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  commentslist[index].username,
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  commentslist[index].date,
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                  ),
                                ),
                              )));
                    }))
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        'No comments here ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF',
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
                ),
              ),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              color: Colors.white,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  maxLines: 20,
                  controller: commentcontroller,
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontFamily: 'SF', fontSize: 16),
                  decoration: InputDecoration(
                      // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(5),
                        child: InkWell(
                          child: CircleAvatar(
                            child: Icon(
                              Feather.message_circle,
                              size: 20,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.deepOrange,
                          ),
                          onTap: () async {
                            var url =
                                'https://api.sellship.co/api/comment/' + itemid;
                            var userid = await storage.read(key: 'userid');
                            if (userid != null) {
                              final response = await http.post(url, body: {
                                'userid': userid,
                                'comment': commentcontroller.text
                              });
                              commentcontroller.clear();
                              if (response.statusCode == 200) {
                                print(response.body);
                                loadcomments();
                              } else {
                                print(response.statusCode);
                              }
                            } else {
                              showInSnackBar('Please Login to Comment');
                            }
                          },
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: "Enter your comment",
                      hintStyle: TextStyle(fontFamily: 'SF', fontSize: 16)),
                ),
              ),
            ),
          ),
        ));
  }
}
