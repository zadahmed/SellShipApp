import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:SellShip/screens/store/salechooseproducts.dart';
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

class CreateSaleCampaign extends StatefulWidget {
  final String storeid;

  CreateSaleCampaign({
    Key key,
    this.storeid,
  }) : super(key: key);

  @override
  _CreateSaleCampaignState createState() => new _CreateSaleCampaignState();
}

class _CreateSaleCampaignState extends State<CreateSaleCampaign> {
  TextEditingController salecampaignname = TextEditingController();
  TextEditingController salecampaigncollection = TextEditingController();

  List<Item> chosenproducts = List<Item>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Create Sale Campaign',
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
                EdgeInsets.only(left: 36.0, bottom: 10, top: 20, right: 36),
            child: Text(
              "What\'s your new campaign called? 🛍",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Color.fromRGBO(28, 45, 65, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica'),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width - 70,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(131, 146, 165, 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: (text) {},
                      controller: salecampaignname,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Campaign Name",
                        hintStyle:
                            TextStyle(fontFamily: 'Helvetica', fontSize: 16),
                        icon: Icon(
                          FontAwesomeIcons.bandcamp,
                          color: Colors.deepOrange,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              )),
          Padding(
            padding:
                EdgeInsets.only(left: 36.0, bottom: 10, top: 20, right: 36),
            child: Text(
              "Choose products for Sale",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Color.fromRGBO(28, 45, 65, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica'),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 36.0, bottom: 10, top: 10, right: 36),
            child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ChooseSaleProducts(storeid: widget.storeid)),
                  );
                  setState(() {
                    chosenproducts = result;
                  });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      )
                    ],
                  )),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                )),
          ),
          SizedBox(
            width: 5,
          ),
          chosenproducts != null && chosenproducts.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                      left: 36.0, bottom: 10, top: 10, right: 36),
                  child: Form(
                    key: _formKey,
                    child: Container(
                        height: 300,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, bottom: 10, top: 10, right: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      child: Text(
                                        chosenproducts.length.toString() +
                                            ' Products',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Sale Price',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: chosenproducts.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 0.7),
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(60),
                                                  child: CachedNetworkImage(
                                                    height: 200,
                                                    width: 300,
                                                    fadeInDuration: Duration(
                                                        microseconds: 5),
                                                    imageUrl:
                                                        chosenproducts[index]
                                                            .image,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        SpinKitDoubleBounce(
                                                            color: Colors
                                                                .deepOrange),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    child: Text(
                                                      chosenproducts[index]
                                                          .name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    'AED ' +
                                                        chosenproducts[index]
                                                            .price,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ]),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: 60,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 5),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.5,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      131, 146, 165, 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: TextFormField(
                                                  onChanged: (text) {},
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Price empty';
                                                    }
                                                    if (double.parse(
                                                            value.toString()) >=
                                                        double.parse(
                                                            chosenproducts[
                                                                    index]
                                                                .price
                                                                .toString())) {
                                                      return 'Price Invalid';
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  cursorColor: Colors.black,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        chosenproducts[index]
                                                            .price,
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16),
                                                    icon: Icon(
                                                      FontAwesomeIcons.tag,
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    ),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ])
                                      ],
                                    ),
                                  );
                                },
                              ))
                            ])),
                  ),
                )
              : Container(),
          Padding(
            padding:
                EdgeInsets.only(left: 36.0, bottom: 10, top: 20, right: 36),
            child: Text(
              "Enter Collection Name (optional)",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Color.fromRGBO(28, 45, 65, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica'),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width - 70,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(131, 146, 165, 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: (text) {},
                      controller: salecampaigncollection,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Collection Name",
                        hintStyle:
                            TextStyle(fontFamily: 'Helvetica', fontSize: 16),
                        icon: Icon(
                          FontAwesomeIcons.tag,
                          color: Colors.blueGrey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
