import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/details.dart';
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
import 'package:shimmer/shimmer.dart';
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
  final String image;
  final String navroute;
  final String navigationid;
  final String itemid;
  final bool unread;

  Notifications({
    this.message,
    this.date,
    this.itemid,
    this.navigationid,
    this.navroute,
    this.image,
    this.unread,
  });
}

class _NotifcationPageState extends State<NotifcationPage>
    with AutomaticKeepAliveClientMixin {
  List<Notifications> notifs = List<Notifications>();

  bool alive = true;

  @override
  bool get wantKeepAlive => alive;

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
            image: jsonResponse[i]['image'] != null
                ? jsonResponse[i]['image']
                : '',
            itemid: jsonResponse[i]['itemid'] != null
                ? jsonResponse[i]['itemid']
                : '',
            navigationid: jsonResponse[i]['navid'] != null
                ? jsonResponse[i]['navid']
                : '',
            navroute: jsonResponse[i]['navroute'] != null
                ? jsonResponse[i]['navroute']
                : '',
            date: dateuploaded,
            unread: jsonResponse[i]['unread'],
          );
          notificationlist.add(withd);
        }

        Iterable inReverse = notificationlist.reversed;
        List<Notifications> jsoninreverse = inReverse.toList();

        setState(() {
          loading = false;
          notifs = jsoninreverse;
          alive = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        alive = true;
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
            image: jsonResponse[i]['image'] != null
                ? jsonResponse[i]['image']
                : '',
            itemid: jsonResponse[i]['itemid'] != null
                ? jsonResponse[i]['itemid']
                : '',
            navigationid: jsonResponse[i]['navid'] != null
                ? jsonResponse[i]['navid']
                : '',
            navroute: jsonResponse[i]['navroute'] != null
                ? jsonResponse[i]['navroute']
                : '',
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
          alive = true;
        });
      }
    } else {
      setState(() {
        alive = true;
        notifs = [];
      });
    }
    return notifs;
  }

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: loading == false
            ? notifs.isNotEmpty
                ? EasyRefresh(
                    child: ListView.builder(
                        itemCount: notifs.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return new Card(
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: ListTile(
                                    onTap: () {
                                      if (notifs[index].navroute ==
                                          ('activity')) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => RootScreen(
                                                    index: 3,
                                                  )),
                                        );
                                      } else if (notifs[index].navroute ==
                                          ('item')) {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Details(
                                                    itemid:
                                                        notifs[index].itemid,
                                                    image: notifs[index].image,
                                                    name: 'My Item',
                                                    sold: false,
                                                    source: 'notif',
                                                  )),
                                        );
                                      }
                                    },
                                    leading: Container(
                                        height: 60,
                                        width: 60,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: notifs[index].image.isEmpty
                                                ? CachedNetworkImage(
                                                    height: 200,
                                                    width: 300,
                                                    fadeInDuration: Duration(
                                                        microseconds: 5),
                                                    imageUrl:
                                                        notifs[index].image,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        SpinKitDoubleBounce(
                                                            color: Colors
                                                                .deepOrange),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )
                                                : SpinKitDoubleBounce(
                                                    color: Colors.deepOrange,
                                                  ))),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: Colors.blueGrey,
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                  )));
                        }),
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
                    onRefresh: () async {
                      setState(() {
                        alive = false;
                      });
                      refresh();
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 300,
                          child: Image.asset(
                            'assets/messages.png',
                            fit: BoxFit.fitHeight,
                          )),
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Text(
                          'Looks like no new updates so far! ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  )
            : Container(
                height: MediaQuery.of(context).size.height,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: ListView(
                      children: [0, 1, 2, 3, 4, 5, 6]
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: MediaQuery.of(context).size.width -
                                          32,
                                      height: 100.0,
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                )));
  }
}
