import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:SellShip/screens/store/createsalecampaign.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Discounts extends StatefulWidget {
  final String storeid;

  Discounts({
    Key key,
    this.storeid,
  }) : super(key: key);

  @override
  _DiscountsState createState() => new _DiscountsState();
}

class Campaigns {
  final String campaignname;
  final List items;

  Campaigns({
    this.campaignname,
    this.items,
  });
}

class _DiscountsState extends State<Discounts> {
  @override
  void initState() {
    super.initState();
    getsalecampaigns();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:StoreDiscounts',
      screenClassOverride: 'AppStoreDiscounts',
    );
  }

  getsalecampaigns() async {
    var url = 'https://api.sellship.co/api/sale/campaigns/' + widget.storeid;

    var response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);

    for (int i = 0; i < jsonbody.length; i++) {
      Campaigns campaign = new Campaigns(
          campaignname: jsonbody[i]['campaignname'],
          items: jsonbody[i]['items']);
      print(campaign);
      campaignList.add(campaign);
    }
    setState(() {
      campaignList = campaignList;
    });
  }

  List<Campaigns> campaignList = new List<Campaigns>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Discounts',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
                padding:
                    EdgeInsets.only(left: 26.0, bottom: 10, top: 20, right: 26),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade100),
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateSaleCampaign(storeid: widget.storeid)),
                        );
                      },
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            dashPattern: [12, 4],
                            color: Colors.deepOrangeAccent,
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                child: Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.tag,
                                          color: Colors.blueGrey,
                                          size: 45,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Create a new Sale Campaign',
                                          style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 16,
                                              fontFamily: 'Helvetica'),
                                        )
                                      ],
                                    )))),
                          ))),
                )),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: campaignList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: 26.0, bottom: 10, top: 20, right: 26),
                          child: Container(
                              height: 210,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  color: Colors.white),
                              width: MediaQuery.of(context).size.width - 250,
                              child: GestureDetector(
                                  onTap: () async {},
                                  child: Column(children: [
                                    Container(
                                        child: Column(
                                      children: [
                                        Text(
                                          campaignList[index].campaignname,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                            height: 160,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: campaignList[index]
                                                    .items
                                                    .length,
                                                itemBuilder: (context, i) {
                                                  return InkWell(
                                                    onTap: () {},
                                                    child: Container(
                                                      height: 110,
                                                      width: 110,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Stack(children: [
                                                            Container(
                                                              height: 95,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  height: 200,
                                                                  width: 300,
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          microseconds:
                                                                              5),
                                                                  imageUrl: campaignList[
                                                                              index]
                                                                          .items[i]
                                                                      ['image'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitDoubleBounce(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            campaignList[index]
                                                                    .items[i]
                                                                ['name'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text: 'AED ' +
                                                                      campaignList[
                                                                              index]
                                                                          .items[
                                                                              i]
                                                                              [
                                                                              'saleprice']
                                                                          .toString(),
                                                                  style: new TextStyle(
                                                                      color: Colors
                                                                          .redAccent,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                new TextSpan(
                                                                  text: '\nAED ' +
                                                                      campaignList[
                                                                              index]
                                                                          .items[
                                                                              i]
                                                                              [
                                                                              'price']
                                                                          .toString(),
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                  ),
                                                                ),
                                                                new TextSpan(
                                                                  text: ' -' +
                                                                      (((double.parse(campaignList[index].items[i]['price'].toString()) - double.parse(campaignList[index].items[i]['saleprice'].toString())) / double.parse(campaignList[index].items[i]['price'].toString())) *
                                                                              100)
                                                                          .toStringAsFixed(
                                                                              0) +
                                                                      '%',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          // Text(
                                                          //   'AED ' +
                                                          //       campaignList[
                                                          //               index]
                                                          //           .items[i][
                                                          //               'price']
                                                          //           .toString(),
                                                          //   style: TextStyle(
                                                          //     fontFamily:
                                                          //         'Helvetica',
                                                          //     fontSize: 12,
                                                          //   ),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }))
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ))
                                  ]))));
                    }))
          ],
        ));
  }
}
