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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:location/location.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:shimmer/shimmer.dart';

class NotifcationPage extends StatefulWidget {
  NotifcationPage({Key key}) : super(key: key);

  _NotifcationPageState createState() => _NotifcationPageState();
}

class _NotifcationPageState extends State<NotifcationPage> {
  List<dynamic> notifs = List<String>();

  final storage = new FlutterSecureStorage();
  var userid;

  @override
  void initState() {
    super.initState();
    refreshnotification();
  }

  refreshnotification() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl = 'https://api.sellship.co/api/getnotifications/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        setState(() {
          notifs = jsonResponse;
        });
      }
    } else {
      notifs = [];
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
          style: TextStyle(fontFamily: 'SF', fontSize: 18, color: Colors.black),
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
                                leading: Icon(
                                  FontAwesome5.smile_beam,
                                  color: Colors.deepOrange,
                                ),
                                trailing: Icon(
                                  Feather.arrow_right,
                                  color: Colors.deepOrange,
                                ),
                                title: Text(
                                  notifs[index].toString(),
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 14,
                                  ),
                                ))));
                  }),
              onRefresh: () async {
                userid = await storage.read(key: 'userid');
                if (userid != null) {
                  var messageurl =
                      'https://api.sellship.co/api/getnotifications/' + userid;
                  final response = await http.get(messageurl);

                  if (response.statusCode == 200) {
                    List jsonResponse = json.decode(response.body);

                    notifs = jsonResponse;
                  }
                } else {
                  notifs = [];
                }
                return notifs;
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

//      RefreshIndicator(
//        onRefresh: refreshnotfication,
//        child: ListView.builder(
//            itemCount: notifs.length,
//            itemBuilder: (BuildContext ctxt, int index) {
//              return new Card(
//                  child: Padding(
//                      padding: EdgeInsets.all(5),
//                      child: ListTile(
//                          onTap: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => Messages()),
//                            );
//                          },
//                          leading: Icon(
//                            FontAwesome5.smile_beam,
//                            color: Colors.deepOrange,
//                          ),
//                          trailing: Icon(
//                            Feather.arrow_right,
//                            color: Colors.deepOrange,
//                          ),
//                          title: Text(
//                            notifs[index].toString(),
//                            style: TextStyle(
//                              fontFamily: 'SF',
//                              fontSize: 14,
//                            ),
//                          ))));
//            }),
//      ),
    );
  }
}
