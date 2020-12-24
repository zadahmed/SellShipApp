import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

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
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.deepPurple),
          backgroundColor: Colors.white,
          title: Text(
            'Review',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: SingleChildScrollView(
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
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: SmoothStarRating(
                    allowHalfRating: true,
                    onRated: (v) {
                      setState(() {
                        rating = v;
                      });
                    },
                    starCount: 5,
                    rating: rating,
                    size: 50.0,
                    color: Colors.deepPurple,
                    borderColor: Colors.deepPurpleAccent,
                    spacing: 0.0),
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
                        labelText: "Comment ( optional )",
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
                      print(';sdcsdcsdcrvdfvisdjnosdjsd');
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

                      final response = await http.get(url);

                      if (response.statusCode == 200) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RootScreen()),
                        );
                      }
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => AssetGiffyDialog(
                                image: Image.asset(
                                  'assets/oops.gif',
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  'Oops!',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                description: Text(
                                  'You need to enter a review for your Buyer!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(),
                                ),
                                onlyOkButton: true,
                                entryAnimation: EntryAnimation.DEFAULT,
                                onOkButtonPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                },
                              ));
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.4),
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
            ])));
  }
}
