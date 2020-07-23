import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/additemlocation.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:location/location.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:shimmer/shimmer.dart';

class AddItemInfo extends StatefulWidget {
  final File image;
  final File image2;
  final File image3;
  final File image4;
  final File image5;
  final String userid;
  final String price;
  final File image6;
  final String itemname;

  AddItemInfo(
      {Key key,
      this.image,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.price,
      this.userid,
      this.itemname})
      : super(key: key);

  _AddItemInfoState createState() => _AddItemInfoState();
}

class _AddItemInfoState extends State<AddItemInfo> {
  final businessdescriptionController = TextEditingController();

  final businessbrandcontroller = TextEditingController();
  final businessizecontroller = TextEditingController();

  List<String> categories = [
    'Electronics',
    'Fashion & Accessories',
    'Beauty',
    'Home & Garden',
    'Baby & Child',
    'Sport & Leisure',
    'Books',
    'Motors',
    'Property',
    'Other'
  ];
  String _selectedCategory;

  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];

  String _selectedCondition = 'Like new';

  String _selectedsubCategory;
  String _selectedsubsubCategory;
  String _selectedbrand;
  List<String> _subcategories;

  var price;
  var itemname;

  final storage = new FlutterSecureStorage();
  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

  @override
  void initState() {
    readstorage();
    setState(() {
      _image = widget.image;
      _image2 = widget.image2;
      _image3 = widget.image3;
      _image4 = widget.image4;
      _image5 = widget.image5;
      _image6 = widget.image6;
      price = widget.price;
      userid = widget.userid;
      itemname = widget.itemname;
    });
    super.initState();
  }

  var currency;

  void readstorage() async {
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
      });
    }

    userid = await storage.read(key: 'userid');
  }

  List<String> _subsubcategory;

  List<String> brands = List<String>();

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
            fontFamily: 'SF',
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RootScreen()),
        );
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continue",
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Cancel Item Upload?",
        style: TextStyle(
            fontFamily: 'SF',
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Would you like to cancel uploading your item?",
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  var brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Item Details",
              style: TextStyle(
                fontFamily: 'SF',
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            InkWell(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'X',
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              onTap: () {
                showAlertDialog(context);
              },
            ),
          ],
          iconTheme: IconThemeData(color: Colors.deepOrange),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[],
                  ),
                ),
              ),
            )),
        bottomNavigationBar: userid != null
            ? Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () async {
                    if (businessdescriptionController.text.isEmpty) {
                      businessdescriptionController.text = '';
                    }

                    if (_selectedCategory == null) {
                      showInSnackBar('Please choose a category for your item!');
                    } else if (_selectedCondition == null) {
                      showInSnackBar(
                          'Please choose the condition of your item!');
                    } else if (brand == null) {
                      showInSnackBar('Please choose the brand for your item!');
                    } else {
                      String bran;
                      if (businessbrandcontroller != null) {
                        String brandcontrollertext =
                            businessbrandcontroller.text.trim();
                        if (brandcontrollertext.isNotEmpty) {
                          bran = businessbrandcontroller.text;
                        } else if (brand != null) {
                          bran = brand;
                        }
                      } else if (businessbrandcontroller == null) {
                        showInSnackBar('Please choose a brand for your item!');
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddItemLocation(
                                  image: _image,
                                  image2: _image2,
                                  image3: _image3,
                                  image4: _image4,
                                  image5: _image5,
                                  price: price,
                                  brand: bran,
                                  category: _selectedCategory,
                                  subcategory: _selectedsubCategory == null
                                      ? ''
                                      : _selectedsubCategory,
                                  subsubcategory:
                                      _selectedsubsubCategory == null
                                          ? ''
                                          : _selectedsubsubCategory,
                                  size: businessizecontroller.text == null
                                      ? ''
                                      : businessizecontroller.text,
                                  condition: _selectedCondition,
                                  description:
                                      businessdescriptionController.text,
                                  userid: userid,
                                  image6: _image6,
                                  itemname: itemname,
                                )),
                      );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.deepOrangeAccent,
                              Colors.deepOrange
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xFF9DA3B4).withOpacity(0.1),
                              blurRadius: 65.0,
                              offset: Offset(0.0, 15.0))
                        ]),
                    child: Center(
                      child: Text(
                        "Next ( Delivery Information )",
                        style: TextStyle(
                            fontFamily: 'SF',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ))
            : Text(''));
  }

  final Geolocator geolocator = Geolocator();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  String userid;

  var firstname;
  var email;
  var phonenumber;
}
