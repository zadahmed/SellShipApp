import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:SellShip/screens/store/salechooseproducts.dart';
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

  TextEditingController pricecontroller = TextEditingController();
  TextEditingController percentcontroller = TextEditingController();

  TextEditingController salecampaigncollection = TextEditingController();

  List<Item> chosenproducts = List<Item>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = new List();

  List<double> discountpercentage = new List();

  @override
  void initState() {
    super.initState();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:StoreCreateSaleCampaign',
      screenClassOverride: 'AppStoreCreateSaleCampaign',
    );
  }

  calculatepricebyamount() async {
    discountpercentage.clear();
    for (int i = 0; i < chosenproducts.length; i++) {
      double discount = double.parse(pricecontroller.text);
      _controllers[i].text =
          (double.parse(chosenproducts[i].price.toString()) - discount)
              .toStringAsFixed(0);
      var discpercen = calculatediscount(
          double.parse(chosenproducts[i].price.toString()),
          (double.parse(chosenproducts[i].price.toString()) - discount));
      discountpercentage.add(discpercen);
    }
    setState(() {
      discountpercentage = discountpercentage;
    });
  }

  calculatepricefixedpercent() async {
    discountpercentage.clear();
    double percent = double.parse(percentcontroller.text);
    for (int i = 0; i < chosenproducts.length; i++) {
      _controllers[i].text = (double.parse(chosenproducts[i].price.toString()) -
              ((percent / 100.0) *
                  (double.parse(chosenproducts[i].price.toString()))))
          .toStringAsFixed(0);
      discountpercentage.add(percent);
    }
    setState(() {
      discountpercentage = discountpercentage;
    });
  }

  calculatediscount(itemprice, discountprice) {
    var a = itemprice - discountprice;
    var q = a / itemprice;
    var s = q * 100;
    return s;
  }

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
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 36.0, bottom: 10, top: 20, right: 36),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 70,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(131, 146, 165, 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextFormField(
                              onChanged: (text) {},
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Campaign Name empty';
                                } else {
                                  return null;
                                }
                              },
                              controller: salecampaignname,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                hintText: "Campaign Name",
                                hintStyle: TextStyle(
                                    fontFamily: 'Helvetica', fontSize: 16),
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
                    padding: EdgeInsets.only(
                        left: 36.0, bottom: 10, top: 20, right: 36),
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
                    padding: EdgeInsets.only(
                        left: 36.0, bottom: 10, top: 10, right: 36),
                    child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseSaleProducts(
                                    storeid: widget.storeid)),
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
                          child: Container(
                              height: 350,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.0,
                                          bottom: 10,
                                          top: 10,
                                          right: 16),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  useRootNavigator: false,
                                                  builder:
                                                      (_) => StatefulBuilder(
                                                              builder: (context,
                                                                  updateState) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10.0))),
                                                              content: Builder(
                                                                builder:
                                                                    (context) {
                                                                  return Container(
                                                                      height:
                                                                          225,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.grey,
                                                                                  size: 18,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            '⬇️ Reduce Price By Fixed Amount',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: 10,
                                                                            ),
                                                                            child:
                                                                                Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                              Container(
                                                                                height: 60,
                                                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                width: MediaQuery.of(context).size.width - 160,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color.fromRGBO(131, 146, 165, 0.1),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                  Text('Reduce By AED',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Helvetica',
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: TextField(
                                                                                      cursorColor: Color(0xFF979797),
                                                                                      controller: pricecontroller,
                                                                                      onChanged: (te) {
                                                                                        updateState(() {});
                                                                                      },
                                                                                      style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.bold),
                                                                                      keyboardType: TextInputType.numberWithOptions(),
                                                                                      decoration: InputDecoration(
                                                                                        hintText: '0',
                                                                                        hintStyle: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.bold),
                                                                                        focusColor: Colors.black,
                                                                                        border: InputBorder.none,
                                                                                        focusedBorder: InputBorder.none,
                                                                                        enabledBorder: InputBorder.none,
                                                                                        errorBorder: InputBorder.none,
                                                                                        disabledBorder: InputBorder.none,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ]),
                                                                              ),
                                                                            ]),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Padding(
                                                                              padding: EdgeInsets.only(
                                                                                top: 10,
                                                                              ),
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                      setState(() {
                                                                                        pricecontroller = pricecontroller;
                                                                                        calculatepricebyamount();
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                        height: 60,
                                                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                        width: MediaQuery.of(context).size.width - 130,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.deepOrange,
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                        ),
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            'Reduce by AED ${pricecontroller.text}',
                                                                                            style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                        )))
                                                                              ]))
                                                                        ],
                                                                      ));
                                                                },
                                                              ),
                                                            );
                                                          }));
                                            },
                                            child: Container(
                                              height: 30,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  50,
                                              child: Text(
                                                '⬇️ Price By Amount',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 15,
                                                    color: Colors.deepOrange,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  useRootNavigator: false,
                                                  builder:
                                                      (_) => StatefulBuilder(
                                                              builder: (context,
                                                                  updateState) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10.0))),
                                                              content: Builder(
                                                                builder:
                                                                    (context) {
                                                                  return Container(
                                                                      height:
                                                                          225,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.grey,
                                                                                  size: 18,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            '⬇️ Reduce Price By %',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: 10,
                                                                            ),
                                                                            child:
                                                                                Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                              Container(
                                                                                height: 60,
                                                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                width: MediaQuery.of(context).size.width - 160,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color.fromRGBO(131, 146, 165, 0.1),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                  Text('Reduce By Percentage',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Helvetica',
                                                                                        fontSize: 16,
                                                                                      )),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: TextFormField(
                                                                                      validator: (value) {
                                                                                        if (value.isNotEmpty) {
                                                                                          var numValue = int.tryParse(value);
                                                                                          if (numValue >= 0 && numValue < 100) {
                                                                                            return null;
                                                                                          } else {
                                                                                            return 'Invalid Value';
                                                                                          }
                                                                                        } else {
                                                                                          return 'Empty';
                                                                                        }
                                                                                      },
                                                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                      cursorColor: Color(0xFF979797),
                                                                                      controller: percentcontroller,
                                                                                      onChanged: (te) {
                                                                                        updateState(() {});
                                                                                      },
                                                                                      style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.bold),
                                                                                      keyboardType: TextInputType.numberWithOptions(),
                                                                                      decoration: InputDecoration(
                                                                                        hintText: '0',
                                                                                        hintStyle: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.bold),
                                                                                        focusColor: Colors.black,
                                                                                        border: InputBorder.none,
                                                                                        focusedBorder: InputBorder.none,
                                                                                        enabledBorder: InputBorder.none,
                                                                                        errorBorder: InputBorder.none,
                                                                                        disabledBorder: InputBorder.none,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ]),
                                                                              ),
                                                                            ]),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Padding(
                                                                              padding: EdgeInsets.only(
                                                                                top: 10,
                                                                              ),
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                                                InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                      setState(() {
                                                                                        percentcontroller = percentcontroller;
                                                                                        calculatepricefixedpercent();
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                        height: 60,
                                                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                                        width: MediaQuery.of(context).size.width - 130,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.deepOrange,
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                        ),
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            'Reduce by ${percentcontroller.text}%',
                                                                                            style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                        )))
                                                                              ]))
                                                                        ],
                                                                      ));
                                                                },
                                                              ),
                                                            );
                                                          }));
                                            },
                                            child: Container(
                                                height: 30,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    80,
                                                child: Text(
                                                  '⬇️ Price By %',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 15,
                                                      color: Colors.deepOrange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.0,
                                          bottom: 10,
                                          top: 10,
                                          right: 16),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                      ),
                                    ),
                                    Expanded(
                                        child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: chosenproducts.length,
                                      itemBuilder: (context, index) {
                                        _controllers
                                            .add(new TextEditingController());
                                        return Container(
                                          height: 80,
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      115,
                                                                      0,
                                                                      0.7),
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      60)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 200,
                                                          width: 300,
                                                          fadeInDuration:
                                                              Duration(
                                                                  microseconds:
                                                                      5),
                                                          imageUrl:
                                                              chosenproducts[
                                                                      index]
                                                                  .image,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context,
                                                                  url) =>
                                                              SpinKitDoubleBounce(
                                                                  color: Colors
                                                                      .deepOrange),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 80,
                                                          child: Text(
                                                            chosenproducts[
                                                                    index]
                                                                .name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'AED ' +
                                                              chosenproducts[
                                                                      index]
                                                                  .price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        discountpercentage
                                                                .isNotEmpty
                                                            ? Text(
                                                                '- %' +
                                                                    discountpercentage[
                                                                            index]
                                                                        .toStringAsFixed(
                                                                            0),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .deepOrange,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : Container(),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                              vertical: 5),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.7,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            131, 146, 165, 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      child: TextFormField(
                                                        onChanged: (text) {},
                                                        controller:
                                                            _controllers[index],
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return 'Price empty';
                                                          }
                                                          if (double.parse(value
                                                                  .toString()) >=
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
                                                        cursorColor:
                                                            Colors.black,
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              chosenproducts[
                                                                      index]
                                                                  .price,
                                                          hintStyle: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              color: Colors.grey
                                                                  .shade400,
                                                              fontSize: 16),
                                                          icon: Icon(
                                                            FontAwesomeIcons
                                                                .tag,
                                                            color: Colors
                                                                .deepOrangeAccent,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                            ],
                                          ),
                                        );
                                      },
                                    ))
                                  ])))
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 36.0, bottom: 10, top: 20, right: 36),
                    child: Text(
                      "Enter Collection Name (optional)",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18.0,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
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
                                hintStyle: TextStyle(
                                    fontFamily: 'Helvetica', fontSize: 16),
                                icon: Icon(
                                  FontAwesomeIcons.tag,
                                  color: Colors.deepOrange,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 40),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                                onTap: () async {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      useRootNavigator: false,
                                      builder: (_) => new AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            content: Builder(
                                              builder: (context) {
                                                return Container(
                                                    height: 140,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Creating your new Sale Campaign',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Container(
                                                            height: 50,
                                                            width: 50,
                                                            child:
                                                                SpinKitDoubleBounce(
                                                              color: Colors
                                                                  .deepOrange,
                                                            )),
                                                      ],
                                                    ));
                                              },
                                            ),
                                          ));
                                  var valid = _formKey.currentState.validate();

                                  if (valid) {
                                    List<String> itemlist = new List();
                                    List<String> priceslist = new List();
                                    for (int i = 0;
                                        i < chosenproducts.length;
                                        i++) {
                                      itemlist.add(chosenproducts[i].itemid);
                                      priceslist.add(_controllers[i].text);
                                    }
                                    FormData formData = FormData.fromMap({
                                      'itemids': json.encode(itemlist),
                                      'saleprices': json.encode(priceslist),
                                      'campaignname': salecampaignname.text,
                                      'collectionname':
                                          salecampaigncollection.text
                                    });
                                    Dio dio = new Dio();
                                    var url =
                                        'https://api.sellship.co/api/store/sale/campaign/${widget.storeid}';
                                    var response =
                                        await dio.post(url, data: formData);

                                    if (response.statusCode == 200) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: Container(
                                    height: 60,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Create Sale Campaign',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )))
                          ]))
                ],
              ),
            )));
  }
}
