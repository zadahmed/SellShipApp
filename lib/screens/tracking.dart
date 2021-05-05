import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/tracking.dart';

import 'package:SellShip/screens/ReviewSeller.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/useritems.dart';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrackingDetails extends StatefulWidget {
  String trackingnumber;

  TrackingDetails({Key key, this.trackingnumber}) : super(key: key);
  @override
  _TrackingDetailsState createState() => _TrackingDetailsState();
}

class _TrackingDetailsState extends State<TrackingDetails> {
  List<Tracking> trackinglist = List<Tracking>();

  @override
  void initState() {
    fetchtrack();
    super.initState();
  }

  fetchtrack() async {
    var url = 'https://api.sellship.co/api/gettrackinghistory/' +
        widget.trackingnumber;
    final response = await http.get(Uri.parse(url));

    List<Tracking> trackinglis = List<Tracking>();
    var jsonbody = json.decode(response.body);

    var jsonresponse = jsonbody['trackingbyawbResult']['response'];

    print(jsonresponse);
    if (response.statusCode == 200) {
      for (int i = 0; i < jsonresponse.length; i++) {
        var status;
        if (jsonresponse[i]['Status'] == 'POD') {
          status = 'Item Delivered';
          Tracking track = new Tracking(
              deliverydate: jsonresponse[i]['colDate'],
              detailedstatus: jsonresponse[i]['colStatus'],
              deliverystatus: status);
          trackinglis.add(track);
        } else if (jsonresponse[i]['Status'] == 'OFD') {
          status = 'Order Out For Delivery';
          Tracking track = new Tracking(
              deliverydate: jsonresponse[i]['colDate'],
              detailedstatus: jsonresponse[i]['colStatus'],
              deliverystatus: status);
          trackinglis.add(track);
        } else if (jsonresponse[i]['Status'] == 'CheckedIn') {
          status = 'Item Picked Up';
          Tracking track = new Tracking(
              deliverydate: jsonresponse[i]['colDate'],
              detailedstatus: jsonresponse[i]['colStatus'],
              deliverystatus: status);
          trackinglis.add(track);
        } else if (jsonresponse[i]['Status'] == 'PickedUp') {
          status = 'Order Created';
          Tracking track = new Tracking(
              deliverydate: jsonresponse[i]['colDate'],
              detailedstatus: jsonresponse[i]['colStatus'],
              deliverystatus: status);
          trackinglis.add(track);
        } else {
          status = jsonresponse[i]['Status'];
        }
      }
    }

    setState(() {
      loading = false;
      trackinglist = trackinglis;
    });
  }

  bool loading = true;

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Tracking #' + widget.trackingnumber,
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: loading == false
            ? Padding(
                padding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
                child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    child: Column(
                      children: [
                        trackinglist.isNotEmpty
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Current Delivery Status: ',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                  ),
                                  Container(
                                      child: Text(
                                    trackinglist[0].deliverystatus,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        trackinglist.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Delivery History: ',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 5,
                        ),
                        trackinglist.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                    itemCount: trackinglist.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 5,
                                          ),
                                          child: Container(
                                              height: 100,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 25,
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2 -
                                                                  10,
                                                              child: Text(
                                                                trackinglist[
                                                                        index]
                                                                    .deliverystatus,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3 -
                                                              10,
                                                          child: Text(
                                                            trackinglist[index]
                                                                .deliverydate,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        )
                                                      ])
                                                ],
                                              )));
                                    }))
                            : Container(),
                      ],
                    )))
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                ),
              ));
  }
}
