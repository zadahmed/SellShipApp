import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';

import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/store/createstore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

class CreateStoreBusinessDetail extends StatefulWidget {
  final String userid;
  final String username;
  final String storename;

  CreateStoreBusinessDetail(
      {Key key, this.userid, this.username, this.storename})
      : super(key: key);

  @override
  _CreateStoreBusinessDetailState createState() =>
      new _CreateStoreBusinessDetailState();
}

class _CreateStoreBusinessDetailState extends State<CreateStoreBusinessDetail> {
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
  }

  bool disabled = true;
  var storetype;
  var storecategory;

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

  TextEditingController storenamecontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();

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
              child: Icon(Feather.arrow_left)),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Create My Store',
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
          child: ListView(
            children: <Widget>[
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/storedetails.jpg',
                    fit: BoxFit.fitWidth,
                  )),
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(
                      left: 56.0, bottom: 10, top: 20, right: 36),
                  child: Center(
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 100,
                      lineHeight: 10.0,
                      percent: 0.35,
                      progressColor: Color.fromRGBO(255, 115, 0, 1),
                    ),
                  ),
                ),
              ),
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(
                      left: 56.0, bottom: 10, top: 20, right: 36),
                  child: Center(
                    child: Text(
                      "Tell us more about @" + widget.storename,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Helvetica'),
                    ),
                  ),
                ),
              ),
              FadeAnimation(
                1,
                Padding(
                    padding: EdgeInsets.only(
                      top: 30,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 100,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(131, 146, 165, 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: DropdownButton<String>(
                              value: storetype,
                              icon: Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              hint: Text(
                                'Store Type',
                                style: TextStyle(
                                    fontFamily: 'Helvetica', fontSize: 16),
                              ),
                              elevation: 16,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  color: Colors.black,
                                  fontSize: 16),
                              isExpanded: true,
//                        underline: Container(
//                            height: 2, color: Color.fromRGBO(255, 28, 89, 1)),
                              onChanged: (String newValue) {
                                setState(() {
                                  storetype = newValue;
                                });
                              },
                              items: <String>[
                                'Retail',
                                'Home Business',
                                'Reseller',
                                'Secondhand Seller',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )),
                      ],
                    )),
              ),
              storetype != null &&
                      storetype != 'Secondhand Seller' &&
                      storetype != 'Reseller'
                  ? FadeAnimation(
                      1,
                      Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(131, 146, 165, 0.1),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: DropdownButton<String>(
                                    value: storecategory,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    iconSize: 24,
                                    hint: Text(
                                      'Category',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16),
                                    ),
                                    elevation: 16,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        color: Colors.black,
                                        fontSize: 16),
                                    isExpanded: true,
//                        underline: Container(
//                            height: 2, color: Color.fromRGBO(255, 28, 89, 1)),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        storecategory = newValue;
                                      });
                                    },
                                    items: <String>[
                                      'Electronics',
                                      'Women',
                                      'Men',
                                      'Toys',
                                      'Beauty',
                                      'Home',
                                      'Kids',
                                      'Sport & Leisure',
                                      'Books',
                                      'Vintage',
                                      'Luxury',
                                      'Garden',
                                      'Handmade'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )),
                            ],
                          )),
                    )
                  : Container(),
              storetype != null &&
                      storetype != 'Secondhand Seller' &&
                      storetype != 'Reseller'
                  ? FadeAnimation(
                      1,
                      Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 140,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: MediaQuery.of(context).size.width - 100,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(131, 146, 165, 0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  maxLines: 10,
                                  onChanged: (text) {},
                                  controller: usernamecontroller,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: "Describe your store",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.blueGrey,
                                    ),
                                    icon: Icon(
                                      Icons.store,
                                      color: Colors.blueGrey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )
                  : Container(),
              storetype != null &&
                      storetype != 'Secondhand Seller' &&
                      storetype != 'Reseller'
                  ? Container(
                      padding: EdgeInsets.only(
                          left: 56, right: 56, top: 10, bottom: 10),
                      width: MediaQuery.of(context).size.width - 100,
                      child: Center(
                        child: Text(
                          'Tell us more about your new store. A great store description would include a paragraph on what your store is about and what products you are planning to sell in your new store. This description helps us understand your store better and approve it quicker!',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (storetype == null) {
                              showInSnackBar('Please choose your store type');
                            } else if (storetype != null &&
                                storetype != 'Secondhand Seller' &&
                                storetype != 'Reseller' &&
                                usernamecontroller.text.isEmpty) {
                              showInSnackBar(
                                  'Please enter a description for your store');
                            } else {
                              if (storetype != 'Secondhand Seller' &&
                                  storetype != 'Reseller' &&
                                  storecategory == null) {
                                showInSnackBar(
                                    'Please choose your store category');
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateStore(
                                        storedescription: storetype != null &&
                                                storetype !=
                                                    'Secondhand Seller' &&
                                                storetype != 'Reseller'
                                            ? usernamecontroller.text
                                            : '',
                                        userid: widget.userid,
                                        username: widget.username,
                                        storename: widget.storename,
                                        storetype: storetype,
                                        category: storecategory,
                                      ),
                                    ));
                              }
                            }
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 100,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 115, 0, 1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                                child: Text(
                              'Next',
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
              ),
            ],
          ),
        ));
  }
}
