import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:SellShip/screens/store/createsalecampaign.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
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
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
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

class _DiscountsState extends State<Discounts> {
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
      body: ListView(
        children: [
          Padding(
              padding:
                  EdgeInsets.only(left: 26.0, bottom: 10, top: 20, right: 26),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade100),
                width: MediaQuery.of(context).size.width - 250,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }
}
