import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviewBuyer extends StatefulWidget {
  final String reviewuserid;
  final String messageid;

  ReviewBuyer({
    Key key,
    this.messageid,
    this.reviewuserid,
  }) : super(key: key);

  @override
  _ReviewBuyerState createState() => _ReviewBuyerState();
}

class _ReviewBuyerState extends State<ReviewBuyer> {
  var reviewuser;
  var messageid;

  @override
  void initState() {
    super.initState();

    setState(() {
      reviewuser = widget.reviewuserid;
      messageid = widget.messageid;
    });
  }

  TextEditingController reviewcontroller = TextEditingController();

  var rating = 3.0;
  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Review Buyer',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      rating.toString(),
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 50,
                          color: Colors.black,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.deepOrange,
                      ),
                      itemSize: 20,
                      ignoreGestures: true,
                      onRatingUpdate: (v) {
                        setState(() {
                          rating = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: TextField(
                        cursorColor: Color(0xFF979797),
                        controller: reviewcontroller,
                        enableSuggestions: true,
                        maxLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            labelText: "Buyer Review",
                            labelStyle: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                            focusColor: Colors.black,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ))),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  ),
                  InkWell(
                      onTap: () async {
                        if (reviewcontroller.text.isNotEmpty) {
                          showDialog(
                              context: context,
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
                                                  'Loading..',
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
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
                          var userid = await storage.read(key: 'userid');
                          var url = 'https://api.sellship.co/api/buyerreview/' +
                              messageid +
                              '/' +
                              userid +
                              '/' +
                              reviewuser +
                              '/' +
                              rating.toString() +
                              '/' +
                              reviewcontroller.text;

                          final response = await http.get(Uri.parse(url));

                          if (response.statusCode == 200) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RootScreen()),
                            );
                          }
                        } else {
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
                                            height: 380,
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 250,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: Image.asset(
                                                      'assets/oops.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Oops!',
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            30,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Color(
                                                                      0xFF9DA3B4)
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 65.0,
                                                              offset: Offset(
                                                                  0.0, 15.0))
                                                        ]),
                                                    child: Center(
                                                      child: Text(
                                                        "Close",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop('dialog');
                                                  },
                                                ),
                                              ],
                                            ));
                                      },
                                    ),
                                  ));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.deepOrange.withOpacity(0.4),
                                  offset: const Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Submit Review',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                ]))));
  }
}
