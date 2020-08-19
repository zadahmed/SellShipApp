import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/messages.dart';
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

class NotifcationPage extends StatefulWidget {
  NotifcationPage({Key key}) : super(key: key);

  _NotifcationPageState createState() => _NotifcationPageState();
}

class Notifications {
  final String message;
  final String date;
  final bool unread;

  Notifications({
    this.message,
    this.date,
    this.unread,
  });
}

class _NotifcationPageState extends State<NotifcationPage> {
  List<Notifications> notifs = List<Notifications>();

  final storage = new FlutterSecureStorage();
  var userid;

  @override
  void initState() {
    super.initState();
    refreshnotification();
  }

  List<Notifications> notificationlist = List<Notifications>();

  refreshnotification() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl = 'https://api.sellship.co/api/getnotifications/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        print(jsonResponse);

        for (int i = 0; i < jsonResponse.length; i++) {
          var q = Map<String, dynamic>.from(jsonResponse[i]['date']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
          var dateuploaded = timeago.format(dateuploade);

          Notifications withd = Notifications(
            message: jsonResponse[i]['message'],
            date: dateuploaded,
            unread: jsonResponse[i]['unread'],
          );
          notificationlist.add(withd);
        }

        Iterable inReverse = notificationlist.reversed;
        List<Notifications> jsoninreverse = inReverse.toList();

        setState(() {
          notifs = jsoninreverse;
        });
      }
    } else {
      setState(() {
        notifs = [];
      });
    }
    return notifs;
  }

  refresh() async {
    notifs.clear();
    notificationlist.clear();
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl =
          'https://api.sellship.co/api/getnotificationsrefresh/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        for (int i = 0; i < jsonResponse.length; i++) {
          var q = Map<String, dynamic>.from(jsonResponse[i]['date']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
          var dateuploaded = timeago.format(dateuploade);

          Notifications withd = Notifications(
            message: jsonResponse[i]['message'],
            date: dateuploaded,
            unread: jsonResponse[i]['unread'],
          );
          notificationlist.add(withd);
        }

        Iterable inReverse = notificationlist.reversed;
        List<Notifications> jsoninreverse = inReverse.toList();

        notifs.clear();

        setState(() {
          notifs = jsoninreverse;
        });
      }
    } else {
      setState(() {
        notifs = [];
      });
    }
    return notifs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.deepOrange,
          ),
        ),
        title: Text(
          'Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Helvetica', fontSize: 18, color: Colors.black),
        ),
      ),
      body: notifs.isNotEmpty
          ? EasyRefresh(
              child: ListView.builder(
                  itemCount: notifs.length,
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
                              trailing: Icon(
                                Feather.arrow_right,
                                color: Colors.deepOrange,
                              ),
                              title: notifs[index].unread == false
                                  ? Text(
                                      notifs[index].message,
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                      ),
                                    )
                                  : Text(
                                      notifs[index].message,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                              subtitle: Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: notifs[index].unread == false
                                      ? Text(
                                          notifs[index].date,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 10,
                                          ),
                                        )
                                      : Text(
                                          notifs[index].date,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        )),
                            )));
                  }),
              onRefresh: () async {
                refresh();
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
                    'View your Notifications here ',
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
            ),
    );
  }
}
