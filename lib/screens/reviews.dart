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
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:intl/intl.dart';

class ReviewsPage extends StatefulWidget {
  ReviewsPage({Key key}) : super(key: key);

  _ReviewsPageState createState() => _ReviewsPageState();
}

class Reviews {
  final String message;
  final String date;
  final String profilepicture;
  final String username;
  final double rating;

  Reviews({
    this.message,
    this.date,
    this.profilepicture,
    this.username,
    this.rating,
  });
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Reviews> reviews = List<Reviews>();

  final storage = new FlutterSecureStorage();
  var userid;

  @override
  void initState() {
    super.initState();
    refreshreviews();
  }

  List<Reviews> reviewlist = List<Reviews>();

  refreshreviews() async {
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl = 'https://api.sellship.co/api/getreviews/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        print(jsonResponse);

        for (int i = 0; i < jsonResponse.length; i++) {
          var q = Map<String, dynamic>.from(jsonResponse[i]['date']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
          var dateuploaded = timeago.format(dateuploade);

          Reviews withd = Reviews(
            message: jsonResponse[i]['review'],
            date: dateuploaded,
            rating: jsonResponse[i]['rating'],
            username: jsonResponse[i]['reviewedusername'],
            profilepicture: jsonResponse[i]['reviewedprofilepic'],
          );
          reviewlist.add(withd);
        }

        Iterable inReverse = reviewlist.reversed;
        List<Reviews> jsoninreverse = inReverse.toList();

        setState(() {
          reviews = jsoninreverse;
        });
      }
    } else {
      setState(() {
        reviews = [];
      });
    }
    return reviews;
  }

  refresh() async {
    reviews.clear();
    reviewlist.clear();
    userid = await storage.read(key: 'userid');
    if (userid != null) {
      var messageurl = 'https://api.sellship.co/api/getreviews/' + userid;
      final response = await http.get(messageurl);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        print(jsonResponse);
        for (int i = 0; i < jsonResponse.length; i++) {
          var q = Map<String, dynamic>.from(jsonResponse[i]['date']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
          var dateuploaded = timeago.format(dateuploade);

          Reviews withd = Reviews(
            message: jsonResponse[i]['review'],
            date: dateuploaded,
            rating: jsonResponse[i]['rating'],
            username: jsonResponse[i]['reviewedusername'],
            profilepicture: jsonResponse[i]['reviewedprofilepic'],
          );
          reviewlist.add(withd);
        }

        Iterable inReverse = reviewlist.reversed;
        List<Reviews> jsoninreverse = inReverse.toList();

        reviews.clear();

        setState(() {
          reviews = jsoninreverse;
        });
      }
    } else {
      setState(() {
        reviews = [];
      });
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reviews.isNotEmpty
          ? EasyRefresh(
              child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Card(
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: ListTile(
                              dense: true,
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: reviews[index]
                                            .profilepicture
                                            .isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                reviews[index].profilepicture,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/personplaceholder.png',
                                            fit: BoxFit.fitWidth,
                                          )),
                              ),
                              trailing: Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    reviews[index].date,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 10,
                                    ),
                                  )),
                              title: SmoothStarRating(
                                  allowHalfRating: true,
                                  starCount: 5,
                                  isReadOnly: true,
                                  rating: reviews[index].rating,
                                  size: 20.0,
                                  color: Colors.deepPurple,
                                  borderColor: Colors.deepPurpleAccent,
                                  spacing: 0.0),
                              subtitle: Column(children: <Widget>[
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 250,
                                  child: Text(
                                    reviews[index].username,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(reviews[index].message,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        color: Colors.black)),
                              ]),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 16.0),
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
                    'View your Reviews here ',
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
