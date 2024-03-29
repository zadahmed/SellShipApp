import 'dart:convert';
import 'dart:io';

import 'package:SellShip/screens/store/createstorepage.dart';
import 'package:SellShip/screens/store/mystorepage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

class CreateStoreTier extends StatefulWidget {
  final String userid;
  final String storename;
  final File storelogo;
  final String storecategory;
  final String storeabout;
  final String storetype;
  final String storeaddress;
  final String storecity;
  final String storedescription;
  final String storeusername;
  List<double> storelocation;

  CreateStoreTier(
      {Key key,
      this.userid,
      this.storename,
      this.storelogo,
      this.storetype,
      this.storedescription,
      this.storelocation,
      this.storeaddress,
      this.storecity,
      this.storecategory,
      this.storeusername,
      this.storeabout})
      : super(key: key);

  @override
  _CreateStoreTierState createState() => new _CreateStoreTierState();
}

class _CreateStoreTierState extends State<CreateStoreTier> {
  @override
  void initState() {
    super.initState();
  }

  bool disabled = true;
  var dropdownvalue;

  TextEditingController usernamecontroller = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  var selectedlayout;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  var businesstier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(FeatherIcons.chevronLeft)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Choose Business Plan',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 36.0, bottom: 5, top: 20, right: 36),
            child: Center(
              child: Text(
                "Set up and grow your store with the right plan.",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 30.0,
                    color: Color.fromRGBO(28, 45, 65, 1),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Helvetica'),
              ),
            ),
          ),

          Padding(
            padding:
                EdgeInsets.only(left: 56.0, bottom: 10, top: 30, right: 36),
            child: Center(
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 100,
                lineHeight: 10.0,
                percent: 0.95,
                progressColor: Color.fromRGBO(255, 115, 0, 1),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 36, top: 20, right: 36),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedlayout = 1;
                  businesstier = 'Start-Up';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedlayout == 1
                          ? Colors.deepOrange
                          : Colors.blueGrey.shade100,
                      width: selectedlayout == 1 ? 5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start-Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "-1 Online Store",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    Text(
                      "Include ecommerce store for web and app",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- 20 Listings",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- 24/7 Support",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- Standard themes and templates",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    Text(
                      "Choose from a variety of our themes and templates",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- Secure online payments",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- Fully integrated and customizable sales and product management tools.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- Order Tracking and Management.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "- Delivery Solution",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "AED 0 Forever",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontFamily: 'Helvetica'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FadeAnimation(
          //   1,
          //   Padding(
          //     padding: EdgeInsets.only(left: 36, top: 20, right: 36),
          //     child: InkWell(
          //       onTap: () {
          //         setState(() {
          //           selectedlayout = 2;
          //           businesstier = 'Grow';
          //         });
          //       },
          //       child: Container(
          //         width: MediaQuery.of(context).size.width,
          //         padding: EdgeInsets.all(15),
          //         decoration: BoxDecoration(
          //             border: Border.all(
          //               color: selectedlayout == 2
          //                   ? Colors.deepOrange
          //                   : Colors.blueGrey.shade100,
          //               width: selectedlayout == 2 ? 5 : 1,
          //             ),
          //             borderRadius: BorderRadius.circular(15)),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Grow",
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                   fontSize: 22.0,
          //                   fontWeight: FontWeight.bold,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- 3 Online Stores",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Include Ecommerce store for web and app",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- 100 Listings",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- 24/7 Support",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Premium themes and templates",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Choose from a variety of our Pro themes and templates",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Store Analytics",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Deep dive into listing, store and earning analytics to understand and feel the growth of your store",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Access to Annual SellShip Parties and Conferences",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Network and grow with fellow store owners.",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "AED 320 per month",
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                   fontSize: 22.0,
          //                   fontWeight: FontWeight.bold,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // FadeAnimation(
          //   1,
          //   Padding(
          //     padding: EdgeInsets.only(left: 36, top: 20, right: 36),
          //     child: InkWell(
          //       onTap: () {
          //         setState(() {
          //           selectedlayout = 3;
          //           businesstier = 'Enterprise';
          //         });
          //       },
          //       child: Container(
          //         width: MediaQuery.of(context).size.width,
          //         padding: EdgeInsets.all(15),
          //         decoration: BoxDecoration(
          //             border: Border.all(
          //               color: selectedlayout == 3
          //                   ? Colors.deepOrange
          //                   : Colors.blueGrey.shade100,
          //               width: selectedlayout == 3 ? 5 : 1,
          //             ),
          //             borderRadius: BorderRadius.circular(15)),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Enterprise",
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                   fontSize: 22.0,
          //                   fontWeight: FontWeight.bold,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Unlimited Online Stores",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Include ecommerce stores for web and app",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Unlimited Listings",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Upload Unlimited listings. Flexible solutions for the top businesses.",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- 24/7 Support and Dedicated Business Manager",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Premium themes and templates",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Choose from a variety of our Pro themes and templates",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Store Analytics",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Deep dive into listing, store and earning analytics to understand and feel the growth of your store",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Listing and Store Reports",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "Understand your store performance with professional reports created by experts.",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "- Access to Annual SellShip Parties and Conferences",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 16.0,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             Text(
          //               "- Network and grow with fellow store owners.",
          //               textAlign: TextAlign.left,
          //               style: TextStyle(
          //                   fontSize: 14.0,
          //                   color: Colors.grey,
          //                   fontFamily: 'Helvetica'),
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               "AED 1250 per month",
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                   fontSize: 22.0,
          //                   fontWeight: FontWeight.bold,
          //                   color: Color.fromRGBO(28, 45, 65, 1),
          //                   fontFamily: 'Helvetica'),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          Padding(
            padding: EdgeInsets.only(left: 36, top: 30, right: 36),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    enableFeedback: true,
                    onTap: () async {
                      if (selectedlayout != null) {
                        showDialog(
                            context: context,
                            useRootNavigator: false,
                            barrierDismissible: false,
                            builder: (_) => new AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  content: Builder(
                                    builder: (context) {
                                      return Container(
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Creating your shiny new store..',
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SpinKitDoubleBounce(
                                                    color: Colors.deepOrange,
                                                  )),
                                            ],
                                          ));
                                    },
                                  ),
                                ));

                        Dio dio = new Dio();
                        FormData formData;
                        var addurl = 'https://api.sellship.co/create/store';
                        String fileName = widget.storelogo.path.split('/').last;
                        var userid = await storage.read(key: 'userid');

                        print(widget.storelocation);

                        formData = FormData.fromMap({
                          'storecategory': widget.storecategory,
                          'storetype': widget.storetype,
                          'storename': widget.storename,
                          'userid': userid,
                          'layout': 'default',
                          'latitude': widget.storelocation[0].toString(),
                          'longitude': widget.storelocation[1].toString(),
                          'storeaddress': widget.storeaddress,
                          'storeusername': widget.storeusername,
                          'storecity': widget.storecity,
                          'storedescription': widget.storedescription,
                          'storebio': widget.storeabout,
                          'storelogo': await MultipartFile.fromFile(
                              widget.storelogo.path,
                              filename: fileName)
                        });

                        var response = await dio.post(addurl, data: formData);

                        var jsoni = response.data;

                        print(jsoni);

                        var storeid = jsoni['id']['\$oid'];

                        if (response.statusCode == 200) {
                          var amount;
                          if (selectedlayout == 1) {
                            await storage.write(key: 'storeid', value: storeid);
                            Navigator.of(context, rootNavigator: false).pop();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CreateStorePage(
                                          storeid: storeid,
                                        )),
                                ModalRoute.withName('/'));
                          }
                          // } else if (selectedlayout == 2) {
                          //   amount = 320;
                          //   Map<String, Object> noonbody = {
                          //     "apiOperation": "INITIATE",
                          //     "order": {
                          //       "name": businesstier + '/' + storeid.toString(),
                          //       "channel": "web",
                          //       "reference": storeid.toString(),
                          //       "amount": amount.toString(),
                          //       "currency": "AED",
                          //       "category": "pay",
                          //     },
                          //     "configuration": {
                          //       "tokenizeCC": true,
                          //       "paymentAction": "Sale",
                          //       "returnUrl":
                          //       'https://api.sellship.co/api/payment/subscription/${storeid}/${businesstier}/${amount.toString()}'
                          //     },
                          //     "subscription": {
                          //       "type": "Recurring",
                          //       "amount": amount.toString(),
                          //       "name": businesstier,
                          //     }
                          //   };
                          //
                          //   var returnurl =
                          //       'https://api.sellship.co/api/payment/subscription/${storeid}/${businesstier}/${amount.toString()}';
                          //   var noonurl =
                          //       "https://api.noonpayments.com/payment/v1/order";
                          //
                          //   var key =
                          //       "SellShip.SellShipApp:a42e7bc936354e9c807c0ff02670ab37";
                          //   List encodedText = utf8.encode(key);
                          //   String base64Str = base64Encode(encodedText);
                          //
                          //   var heade = 'Key_Live $base64Str';
                          //
                          //   Map<String, String> headers = {
                          //     'Authorization': heade,
                          //     'Content-type': 'application/json',
                          //     'Accept': 'application/json',
                          //   };
                          //
                          //   final noonresponse = await http.post(
                          //     noonurl,
                          //     body: json.encode(noonbody),
                          //     headers: headers,
                          //   );
                          //
                          //   print(noonresponse.body);
                          //   var jsonmessage = json.decode(noonresponse.body);
                          //
                          //   if (jsonmessage != null) {
                          //     var posturl = jsonmessage['result']
                          //     ['checkoutData']['postUrl'];
                          //
                          //     var orderid =
                          //     jsonmessage['result']['order']['id'];
                          //
                          //     final orderresponse = await http.get(
                          //       'https://api.sellship.co/api/noon/save/orderid/subscription/${orderid}/${storeid}',
                          //     );
                          //
                          //     print(orderresponse.statusCode);
                          //
                          //     await storage.write(
                          //         key: 'storeid', value: storeid);
                          //
                          //     Navigator.of(context, rootNavigator: false).pop();
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (BuildContext context) =>
                          //               Paymentsubs(
                          //                   orderid: orderid.toString(),
                          //                   storeid: storeid,
                          //                   businesstier: businesstier,
                          //                   url: posturl,
                          //                   returnurl: returnurl)),
                          //     );
                          //   }
                          // } else if (selectedlayout == 3) {
                          //   amount = 1250;
                          //   Map<String, Object> noonbody = {
                          //     "apiOperation": "INITIATE",
                          //     "order": {
                          //       "name": businesstier + '/' + storeid.toString(),
                          //       "channel": "web",
                          //       "reference": storeid.toString(),
                          //       "amount": amount.toString(),
                          //       "currency": "AED",
                          //       "category": "pay",
                          //     },
                          //     "configuration": {
                          //       "tokenizeCC": true,
                          //       "paymentAction": "Sale",
                          //       "returnUrl":
                          //       'https://api.sellship.co/api/payment/subscription/${storeid}/${businesstier}/${amount.toString()}'
                          //     },
                          //     "subscription": {
                          //       "type": "Recurring",
                          //       "amount": amount.toString(),
                          //       "name": businesstier,
                          //     }
                          //   };
                          //
                          //   var returnurl =
                          //       'https://api.sellship.co/api/payment/subscription/${storeid}/${businesstier}/${amount.toString()}';
                          //   var noonurl =
                          //       "https://api.noonpayments.com/payment/v1/order";
                          //
                          //   var key =
                          //       "SellShip.SellShipApp:a42e7bc936354e9c807c0ff02670ab37";
                          //   List encodedText = utf8.encode(key);
                          //   String base64Str = base64Encode(encodedText);
                          //
                          //   var heade = 'Key_Live $base64Str';
                          //
                          //   Map<String, String> headers = {
                          //     'Authorization': heade,
                          //     'Content-type': 'application/json',
                          //     'Accept': 'application/json',
                          //   };
                          //
                          //   final noonresponse = await http.post(
                          //     noonurl,
                          //     body: json.encode(noonbody),
                          //     headers: headers,
                          //   );
                          //
                          //   print(noonresponse.body);
                          //   var jsonmessage = json.decode(noonresponse.body);
                          //
                          //   if (jsonmessage != null) {
                          //     var posturl = jsonmessage['result']
                          //     ['checkoutData']['postUrl'];
                          //
                          //     var orderid =
                          //     jsonmessage['result']['order']['id'];
                          //
                          //     final orderresponse = await http.get(
                          //       'https://api.sellship.co/api/noon/save/orderid/subscription/${orderid}/${storeid}',
                          //     );
                          //
                          //     print(orderresponse.statusCode);
                          //
                          //     await storage.write(
                          //         key: 'storeid', value: storeid);
                          //
                          //     Navigator.of(context, rootNavigator: false).pop();
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (BuildContext context) =>
                          //               Paymentsubs(
                          //                   orderid: orderid.toString(),
                          //                   storeid: storeid,
                          //                   businesstier: businesstier,
                          //                   url: posturl,
                          //                   returnurl: returnurl)),
                          //     );
                          //   }
                          // }

                        } else {
                          Navigator.of(context, rootNavigator: false).pop();
                          showInSnackBar('Looks like something went wrong');
                        }
                      } else {
                        showInSnackBar('Please choose a plan for your store');
                      }
                    },
                    child: Container(
                      height: 60,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: MediaQuery.of(context).size.width - 80,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 115, 0, 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                          child: Text(
                        'Create Store',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      )),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  final storage = new FlutterSecureStorage();
}
