import 'dart:convert';
import 'dart:io';
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

class AddItem extends StatefulWidget {
  AddItem({Key key}) : super(key: key);

  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  GoogleMapController controller;
  LatLng _lastMapPosition;

  Set<Marker> _markers = Set();

  final businessnameController = TextEditingController();
  final businessdescriptionController = TextEditingController();
  final businesspricecontroller = TextEditingController();
  final businessoriginalpricecontroller = TextEditingController();
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

  LatLng position;
  String city;
  String country;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    readstorage();
    super.initState();
  }

  bool loading;

  var currency;

  bool meetupcheckbox = false;
  bool shippingcheckbox = false;

  void readstorage() async {
    var countr = await storage.read(key: 'locationcountry');
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

    Location _location = new Location();

    var location = await _location.getLocation();
    var positio =
        LatLng(location.latitude.toDouble(), location.longitude.toDouble());
    print(userid);
    setState(() {
      loading = false;
      position = positio;
    });
  }

  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

  List<String> _subsubcategory;

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera2() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image2 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery2() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image2 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera3() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image3 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery3() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image3 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera4() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image4 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery4() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image4 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera5() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image5 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery5() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image5 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera6() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image6 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery6() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image6 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  List<String> brands = List<String>();

  @override
  void dispose() {
    businessdescriptionController.dispose();
    businessnameController.dispose();
    businesspricecontroller.dispose();
    businessoriginalpricecontroller.dispose();
    businessbrandcontroller.dispose();
    businessizecontroller.dispose();
    super.dispose();
  }

  bool salepressed;
  bool freepressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Add an Item",
              style: TextStyle(
                fontFamily: 'SF',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.deepOrange,
          iconTheme: IconThemeData(color: Color(0xFFC5CCD6)),
        ),
        body: loading == false
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: userid != null
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
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
                                  height: 180,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Images',
                                            style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 130,
                                        child: Scrollbar(
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera2();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery2();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image2 == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image2,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera3();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery3();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image3 == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image3,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera4();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery4();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image4 == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image4,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera5();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery5();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image5 == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image5,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final action =
                                                      CupertinoActionSheet(
                                                    message: Text(
                                                      "Upload an Image",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Camera",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageCamera6();
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                            "Upload from Gallery",
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          getImageGallery6();
                                                        },
                                                      )
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                    ),
                                                  );
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          action);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    height: 120,
                                                    width: 120,
                                                    child: _image6 == null
                                                        ? Icon(Icons.add)
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.file(
                                                              _image6,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Category',
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Container(
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
                                  child: ListTile(
                                    title: Text(
                                      'Category',
                                      style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Container(
                                      width: 200,
                                      padding: EdgeInsets.only(),
                                      child: Center(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: DropdownButton(
                                            hint: Text(
                                              'Choose a category',
                                              style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 16,
                                              ),
                                            ), // Not necessary for Option 1
                                            value: _selectedCategory,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                _selectedCategory = newValue;
                                              });
                                              if (_selectedCategory ==
                                                  'Electronics') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }
                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Phones & Accessories',
                                                    'Gaming',
                                                    'TV & Video',
                                                    'Cameras & Photography',
                                                    'Computers,PCs & Laptops',
                                                    'Computer accessories',
                                                    'Home Appliances',
                                                    'Sound & Audio',
                                                    'Tablets & eReaders',
                                                    'Wearables',
                                                    'Virtual Reality',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Fashion & Accessories') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Women',
                                                    'Men',
                                                    'Girls',
                                                    'Boys',
                                                    'Unisex',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Beauty') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Fragrance',
                                                    'Perfume for men',
                                                    'Perfume for women',
                                                    'Makeup',
                                                    'Haircare',
                                                    'Skincare',
                                                    'Tools and Accessories',
                                                    'Mens grooming',
                                                    'Gift sets',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Home & Garden') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Bedding',
                                                    'Bath',
                                                    'Home Decor',
                                                    'Kitchen and Dining',
                                                    'Home storage',
                                                    'Furniture',
                                                    'Garden & outdoor',
                                                    'Lamps & Lighting',
                                                    'Tools & Home improvement',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Baby & Child') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Kids toys',
                                                    'Baby transport',
                                                    'Nursing and feeding',
                                                    'Bathing & Baby care',
                                                    'Baby clothing & shoes',
                                                    'Parenting Books',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Sport & Leisure') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Camping & Hiking',
                                                    'Cycling',
                                                    'Scooters & accessories',
                                                    'Strength & weights',
                                                    'Yoga',
                                                    'Cardio equipment',
                                                    'Water sports',
                                                    'Raquet sports',
                                                    'Boxing',
                                                    'Other',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Books') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Childrens books',
                                                    'Fiction books',
                                                    'Comics',
                                                    'Sports',
                                                    'Science',
                                                    'Diet, Health & Fitness',
                                                    'Business & Finance',
                                                    'Biogpraphy & Autobiography',
                                                    'Crime & Mystery',
                                                    'History',
                                                    'Cook Books & Food',
                                                    'Education',
                                                    'Foreign Language Study',
                                                    'Travel',
                                                    'Magazine',
                                                    'Other',
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Motors') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'Used Cars',
                                                    'Motorcycles & Scooters',
                                                    'Heavy vehicles',
                                                    'Boats',
                                                    'Number plates',
                                                    'Auto accessories',
                                                    'Car Technology'
                                                  ];
                                                });
                                              } else if (_selectedCategory ==
                                                  'Property') {
                                                var categoryurl =
                                                    'https://sellship.co/api/getbrands/' +
                                                        _selectedCategory;
                                                final categoryresponse =
                                                    await http.get(categoryurl);
                                                if (categoryresponse
                                                        .statusCode ==
                                                    200) {
                                                  brands.clear();
                                                  var categoryrespons = json
                                                      .decode(categoryresponse
                                                          .body);
                                                  print(categoryrespons);
                                                  for (int i = 0;
                                                      i <
                                                          categoryrespons
                                                              .length;
                                                      i++) {
                                                    brands.add(
                                                        categoryrespons[i]);
                                                  }

                                                  if (brands == null) {
                                                    brands = [];
                                                  }
                                                  brands.add('Other');
                                                  setState(() {
                                                    brands = brands;
                                                  });
                                                } else {
                                                  print(categoryresponse
                                                      .statusCode);
                                                }
                                                setState(() {
                                                  _subcategories = [
                                                    'For Sale \nHouses & Apartment',
                                                    'For Rent \nHouses & Apartment',
                                                    'For Rent \nShops & Offices',
                                                    'Guest Houses',
                                                  ];
                                                });
                                              } else {
                                                _subcategories = null;
                                              }
                                            },
                                            items: categories.map((location) {
                                              return DropdownMenuItem(
                                                child: new Text(
                                                  location,
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                value: location,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _subcategories == null
                                    ? Container()
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            'Sub Category',
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 16,
                                            ),
                                          ),
                                          trailing: Container(
                                            width: 245,
                                            padding: EdgeInsets.only(),
                                            child: Center(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: DropdownButton(
                                                  hint: Text(
                                                    'Choose a sub category',
                                                    style: TextStyle(
                                                      fontFamily: 'SF',
                                                      fontSize: 16,
                                                    ),
                                                  ), // Not necessary for Option 1
                                                  value: _selectedsubCategory,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _selectedsubCategory =
                                                          newValue;
                                                    });
                                                    if (_selectedsubCategory ==
                                                        'Women') {
                                                      setState(() {
                                                        _subsubcategory = [
                                                          'Sneakers',
                                                          'Flats',
                                                          'Activewear & Sportswear',
                                                          'Jewelry',
                                                          'Dresses',
                                                          'Tops',
                                                          'Coats & Jackets',
                                                          'Jumpers & Cardigans',
                                                          'Bags',
                                                          'Heels',
                                                          'Sandals,slippers and flip-flops',
                                                          'Boots',
                                                          'Sports shoes',
                                                          'Sunglasses',
                                                          'Eye-wear',
                                                          'Hair accessories',
                                                          'Belts',
                                                          'Watches',
                                                          'Modest wear',
                                                          'Jumpsuits & Playsuits',
                                                          'Hoodies & Sweatshirts',
                                                          'Jeans',
                                                          'Suits & Blazers',
                                                          'Swimwear & Beachwear',
                                                          'Bottoms',
                                                          'Skirts',
                                                          'Other',
                                                        ];
                                                      });
                                                    } else if (_selectedsubCategory ==
                                                        'Men') {
                                                      setState(() {
                                                        _subsubcategory = [
                                                          'Shoes & Boots',
                                                          'Activewear & Sportswear',
                                                          'Polo Shirts & T- Shirts',
                                                          'Shirts',
                                                          'Sneakers',
                                                          'Loafers & slip-ons',
                                                          'Formal shoes',
                                                          'Sports shoes',
                                                          'Coats & Jackets',
                                                          'Jumpers & Cardigans',
                                                          'Bags & Wallet',
                                                          'Trousers',
                                                          'Hair accessories',
                                                          'Belts',
                                                          'Eyewear',
                                                          'Sunglasses',
                                                          'Nightwear & Loungewear',
                                                          'Hoodies & Sweatshirts',
                                                          'Jeans',
                                                          'Suits & Blazers',
                                                          'Swimwear & Beachwear',
                                                          'Shorts',
                                                          'Other',
                                                        ];
                                                      });
                                                    } else if (_selectedsubCategory ==
                                                        'Girls') {
                                                      setState(() {
                                                        _subsubcategory = [
                                                          'Bags',
                                                          'Bottoms',
                                                          'Dresses',
                                                          'Tops and Tees',
                                                          'Hats',
                                                          'Accessories',
                                                          'Jumpsuits',
                                                          'Nightwear & Loungewear',
                                                          'Socks',
                                                          'Hoodies & Sweatshirts',
                                                          'Swimwear & Beachwear'
                                                        ];
                                                      });
                                                    } else if (_selectedsubCategory ==
                                                        'Boys') {
                                                      setState(() {
                                                        _subsubcategory = [
                                                          'Hats',
                                                          'Hoodies & Sweatshirts',
                                                          'Nightwear & Loungewear',
                                                          'Bottoms',
                                                          'Shirts & T-Shirts',
                                                          'Socks',
                                                          'Tops',
                                                        ];
                                                      });
                                                    } else if (_selectedsubCategory ==
                                                        'Unisex') {
                                                      setState(() {
                                                        _subsubcategory = [
                                                          'Shoes & Boots',
                                                          'Activewear & Sportswear',
                                                          'Shirts',
                                                          'T- Shirts & Vests',
                                                          'Coats & Jackets',
                                                          'Jumpers & Cardigans',
                                                          'Bags & Accessories',
                                                          'Trousers',
                                                          'Chinos',
                                                          'Jumpsuits & Playsuits',
                                                          'Nightwear',
                                                          'Loungewear',
                                                          'Hoodies & Sweatshirts',
                                                          'Jeans',
                                                          'Suits & Blazers',
                                                          'Swimwear & Beachwear',
                                                          'Shorts',
                                                          'Other',
                                                        ];
                                                      });
                                                    }
                                                  },
                                                  items: _subcategories
                                                      .map((location) {
                                                    return DropdownMenuItem(
                                                      child: new Text(
                                                        location,
                                                        style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: location,
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                _subsubcategory == null
                                    ? Container()
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
//                                          boxShadow: [
//                                            BoxShadow(
//                                              color: Colors.grey.shade300,
//                                              offset: Offset(0.0, 1.0), //(x,y)
//                                              blurRadius: 6.0,
//                                            ),
//                                          ],
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(),
                                          child: Center(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: DropdownButton(
                                                hint: Text(
                                                  'Please choose a sub category',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ), // Not necessary for Option 1
                                                value: _selectedsubsubCategory,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _selectedsubsubCategory =
                                                        newValue;
                                                  });
                                                },
                                                items: _subsubcategory
                                                    .map((location) {
                                                  return DropdownMenuItem(
                                                    child: new Text(
                                                      location,
                                                      style: TextStyle(
                                                        fontFamily: 'SF',
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    value: location,
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, bottom: 10, top: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Product Detail',
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Container(
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
                                    controller: businessnameController,
                                    autocorrect: true,
                                    enableSuggestions: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        labelText: "Title",
                                        labelStyle: TextStyle(
                                          fontFamily: 'SF',
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
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
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
                                    controller: businessdescriptionController,
                                    autocorrect: true,
                                    enableSuggestions: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: 6,
//                                    maxLength: 1000,
                                    decoration: InputDecoration(
                                        labelText: "Description",
                                        alignLabelWithHint: true,
                                        labelStyle: TextStyle(
                                          fontFamily: 'SF',
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
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
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
                                  child: ListTile(
                                    title: Text(
                                      'Condition',
                                      style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Container(
                                        width: 200,
                                        padding: EdgeInsets.only(),
                                        child: Center(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: DropdownButton<String>(
                                                  value: _selectedCondition,
                                                  hint: Text(
                                                      'Please choose the condition of your Item'), // No
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_down),
                                                  iconSize: 20,
                                                  elevation: 10,
                                                  isExpanded: true,
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                  onChanged: (String newValue) {
                                                    setState(() {
                                                      _selectedCondition =
                                                          newValue;
                                                    });
                                                  },
                                                  items: conditions.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'SF',
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    );
                                                  }).toList(),
                                                )))),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                brands.isNotEmpty || brands != null
                                    ? Container(
                                        height: 80,
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
                                        child: Center(
                                            child: ListTile(
                                          title: Text(
                                            'Brand',
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 16,
                                            ),
                                          ),
                                          trailing: Container(
                                              width: 200,
                                              padding: EdgeInsets.only(),
                                              child: Center(
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: DropdownButton<
                                                          String>(
                                                        value: _selectedbrand,
                                                        hint: Text(
                                                            'Item brand'), // No
                                                        icon: Icon(Icons
                                                            .keyboard_arrow_down),
                                                        iconSize: 20,
                                                        elevation: 10,
                                                        isExpanded: true,
                                                        style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 16,
                                                        ),
                                                        onChanged:
                                                            (String newValue) {
                                                          setState(() {
                                                            _selectedbrand =
                                                                newValue;
                                                          });
                                                        },
                                                        items: brands.map<
                                                            DropdownMenuItem<
                                                                String>>((String
                                                            value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )))),
                                        )))
                                    : Container(),
                                _selectedbrand == 'Other'
                                    ? Container(
                                        height: 80,
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
                                        child: Center(
                                            child: ListTile(
                                                title: Text(
                                                  'Other Brand Name',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                trailing: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(),
                                                    child: Center(
                                                      child: TextField(
                                                        cursorColor:
                                                            Color(0xFF979797),
                                                        controller:
                                                            businessbrandcontroller,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Brand Name",
                                                                alignLabelWithHint:
                                                                    true,
                                                                labelStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 16,
                                                                ),
                                                                focusColor:
                                                                    Colors
                                                                        .black,
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                border:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ))),
                                                      ),
                                                    )))))
                                    : Container(),
                                SizedBox(
                                  height: 10.0,
                                ),
                                _selectedCategory == 'Fashion & Accessories'
                                    ? Container(
                                        height: 80,
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
                                        child: Center(
                                            child: ListTile(
                                                title: Text(
                                                  'Size',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                trailing: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(),
                                                    child: Center(
                                                      child: TextField(
                                                        cursorColor:
                                                            Color(0xFF979797),
                                                        controller:
                                                            businessizecontroller,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Size",
                                                                alignLabelWithHint:
                                                                    true,
                                                                labelStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 16,
                                                                ),
                                                                focusColor:
                                                                    Colors
                                                                        .black,
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                border:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ))),
                                                      ),
                                                    )))))
                                    : Container(),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                    height: 130,
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
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Center(
                                            child: ListTile(
                                                title: Text(
                                                  'Original Price (optional)',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                trailing: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(),
                                                    child: Center(
                                                      child: TextField(
                                                        cursorColor:
                                                            Color(0xFF979797),
                                                        controller:
                                                            businessoriginalpricecontroller,
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(),
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Price " +
                                                                        currency,
                                                                alignLabelWithHint:
                                                                    true,
                                                                labelStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 16,
                                                                ),
                                                                focusColor:
                                                                    Colors
                                                                        .black,
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                border:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ))),
                                                      ),
                                                    )))),
                                        Center(
                                            child: ListTile(
                                                title: Text(
                                                  'Selling Price',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                trailing: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(),
                                                    child: Center(
                                                      child: TextField(
                                                        cursorColor:
                                                            Color(0xFF979797),
                                                        controller:
                                                            businesspricecontroller,
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(),
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Price " +
                                                                        currency,
                                                                alignLabelWithHint:
                                                                    true,
                                                                labelStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize: 16,
                                                                ),
                                                                focusColor:
                                                                    Colors
                                                                        .black,
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                border:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                disabledBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                )),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ))),
                                                      ),
                                                    ))))
                                      ],
                                    )),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, bottom: 10, top: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Delivery Method',
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Container(
                                    height: 120,
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
                                    child: Column(children: <Widget>[
                                      CheckboxListTile(
                                        title: const Text('Meetup'),
                                        value: meetupcheckbox,
                                        onChanged: (bool value) {
                                          setState(() {
                                            meetupcheckbox = value;
                                          });
                                        },
                                        secondary:
                                            const Icon(FontAwesome.handshake_o),
                                      ),
                                      CheckboxListTile(
                                        title: const Text('Shipping Included'),
                                        value: shippingcheckbox,
                                        onChanged: (bool value) {
                                          setState(() {
                                            shippingcheckbox = value;
                                          });
                                        },
                                        secondary:
                                            const Icon(Icons.local_shipping),
                                      ),
                                    ])),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Item Location',
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 390,
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
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        'Press on the map to choose the Item\'s location',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Stack(
                                        children: <Widget>[
                                          position != null
                                              ? Container(
                                                  height: 355,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: GoogleMap(
                                                    initialCameraPosition:
                                                        CameraPosition(
                                                            target: position,
                                                            zoom: 18.0,
                                                            bearing: 70),
                                                    onMapCreated: mapCreated,
                                                    onCameraMove: _onCameraMove,
                                                    onTap: _handleTap,
                                                    markers: _markers,
                                                    zoomGesturesEnabled: true,
                                                    myLocationEnabled: true,
                                                    myLocationButtonEnabled:
                                                        true,
                                                    compassEnabled: true,
                                                    gestureRecognizers: Set()
                                                      ..add(Factory<
                                                              EagerGestureRecognizer>(
                                                          () =>
                                                              EagerGestureRecognizer())),
                                                  ),
                                                )
                                              : Text(
                                                  'Oops! Something went wrong. \n Please try again',
                                                  style: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                          Positioned(
                                            top: 10,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            child: SearchMapPlaceWidget(
                                              apiKey:
                                                  'AIzaSyAL0gczX37-cNVHC_4aV6lWE3RSNqeamf4',
                                              // The language of the autocompletion
                                              language: 'en',
                                              location: position,
                                              radius: 10000,
                                              onSelected: (Place place) async {
                                                final geolocation =
                                                    await place.geolocation;

                                                controller.animateCamera(
                                                    CameraUpdate.newLatLng(
                                                        geolocation
                                                            .coordinates));
                                                controller.animateCamera(
                                                    CameraUpdate
                                                        .newLatLngBounds(
                                                            geolocation.bounds,
                                                            0));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Thank you for helping us grow!",
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Scaffold(
                        backgroundColor: Colors.white,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                'Look\'s like you need to \n login to Add an Item️',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Image.asset(
                              'assets/little_theologians_4x.jpg',
                              fit: BoxFit.fitWidth,
                            ))
                          ],
                        ),
                      ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Column(
                    children: [0, 1, 2, 3, 4, 5, 6]
                        .map((_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: 40.0,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
        bottomNavigationBar: userid != null
            ? InkWell(
                onTap: () async {
                  var userurl = 'https://sellship.co/api/user/' + userid;
                  final userresponse = await http.get(userurl);
                  if (userresponse.statusCode == 200) {
                    var userrespons = json.decode(userresponse.body);
                    var profilemap = userrespons;
                    print(profilemap);
                    if (mounted) {
                      setState(() {
                        firstname = profilemap['first_name'];
                        phonenumber = profilemap['phonenumber'];
                        email = profilemap['email'];
                      });
                    }
                  }

                  String brand;
                  String brandcontrollertext =
                      businessbrandcontroller.text.trim();
                  if (brandcontrollertext.isNotEmpty) {
                    brand = businessbrandcontroller.text;
                  } else if (_selectedbrand.isNotEmpty) {
                    brand = _selectedbrand;
                  }

                  if (phonenumber == null || email == null) {
                    showInSnackBar('Please update your Phone Number and Email');
                  } else if (businessnameController.text.isNotEmpty &&
                      _image.path.isNotEmpty &&
                      brand.isNotEmpty &&
                      businesspricecontroller.text.isNotEmpty &&
                      _selectedCondition.isNotEmpty &&
                      businessdescriptionController.text.isNotEmpty &&
                      city != null &&
                      country != null) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20.0)), //this right here
                            child: Container(
                              height: 100,
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SpinKitChasingDots(
                                      color: Colors.deepOrange)),
                            ),
                          );
                        });

                    var url = 'https://sellship.co/api/additem';

                    Dio dio = new Dio();
                    FormData formData;
                    if (_image != null) {
                      String fileName = _image.path.split('/').last;
                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'description': businessdescriptionController.text,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'city': city.trim(),
                        'country': country.trim(),
                        'condition': _selectedCondition,
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'userid': userid,
                        'username': firstname,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName)
                      });
                    }
                    if (_image != null && _image2 != null) {
                      String fileName = _image.path.split('/').last;
                      String fileName2 = _image2.path.split('/').last;
                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'description': businessdescriptionController.text,
                        'city': city.trim(),
                        'condition': _selectedCondition,
                        'userid': userid,
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'country': country.trim(),
                        'username': firstname,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        'image2': await MultipartFile.fromFile(_image2.path,
                            filename: fileName2),
                      });
                    }
                    if (_image != null && _image2 != null && _image3 != null) {
                      String fileName = _image.path.split('/').last;
                      String fileName2 = _image2.path.split('/').last;
                      String fileName3 = _image3.path.split('/').last;

                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'description': businessdescriptionController.text,
                        'city': city.trim(),
                        'condition': _selectedCondition,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'userid': userid,
                        'country': country.trim(),
                        'username': firstname,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        'image2': await MultipartFile.fromFile(_image2.path,
                            filename: fileName2),
                        'image3': await MultipartFile.fromFile(_image3.path,
                            filename: fileName3),
                      });
                    }
                    if (_image != null &&
                        _image2 != null &&
                        _image3 != null &&
                        _image4 != null) {
                      String fileName = _image.path.split('/').last;
                      String fileName2 = _image2.path.split('/').last;
                      String fileName3 = _image3.path.split('/').last;
                      String fileName4 = _image4.path.split('/').last;

                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'description': businessdescriptionController.text,
                        'city': city.trim(),
                        'userid': userid,
                        'condition': _selectedCondition,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'country': country.trim(),
                        'username': firstname,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        'image2': await MultipartFile.fromFile(_image2.path,
                            filename: fileName2),
                        'image3': await MultipartFile.fromFile(_image3.path,
                            filename: fileName3),
                        'image4': await MultipartFile.fromFile(_image4.path,
                            filename: fileName4),
                      });
                    }
                    if (_image != null &&
                        _image2 != null &&
                        _image3 != null &&
                        _image4 != null &&
                        _image5 != null) {
                      String fileName = _image.path.split('/').last;
                      String fileName2 = _image2.path.split('/').last;
                      String fileName3 = _image3.path.split('/').last;
                      String fileName4 = _image4.path.split('/').last;
                      String fileName5 = _image5.path.split('/').last;

                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'description': businessdescriptionController.text,
                        'city': city.trim(),
                        'country': country.trim(),
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'condition': _selectedCondition,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'userid': userid,
                        'username': firstname,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        'image2': await MultipartFile.fromFile(_image2.path,
                            filename: fileName2),
                        'image3': await MultipartFile.fromFile(_image3.path,
                            filename: fileName3),
                        'image4': await MultipartFile.fromFile(_image4.path,
                            filename: fileName4),
                        'image5': await MultipartFile.fromFile(_image5.path,
                            filename: fileName5),
                      });
                    }
                    if (_image != null &&
                        _image2 != null &&
                        _image3 != null &&
                        _image4 != null &&
                        _image5 != null &&
                        _image6 != null) {
                      String fileName = _image.path.split('/').last;
                      String fileName2 = _image2.path.split('/').last;
                      String fileName3 = _image3.path.split('/').last;
                      String fileName4 = _image4.path.split('/').last;
                      String fileName5 = _image5.path.split('/').last;
                      String fileName6 = _image6.path.split('/').last;
                      formData = FormData.fromMap({
                        'name': businessnameController.text,
                        'price': businesspricecontroller.text.trim(),
                        'category': _selectedCategory,
                        'originalprice':
                            businessoriginalpricecontroller.text == null
                                ? ''
                                : businessoriginalpricecontroller.text.trim(),
                        'subcategory': _selectedsubCategory == null
                            ? ''
                            : _selectedsubCategory,
                        'subsubcategory': _selectedsubsubCategory == null
                            ? ''
                            : _selectedsubsubCategory,
                        'latitude': _lastMapPosition.latitude,
                        'longitude': _lastMapPosition.longitude,
                        'description': businessdescriptionController.text,
                        'city': city.trim(),
                        'userid': userid,
                        'country': country.trim(),
                        'username': firstname,
                        'meetup': meetupcheckbox,
                        'shipping': shippingcheckbox,
                        'brand': brand,
                        'size': businessizecontroller.text == null
                            ? ''
                            : businessizecontroller.text,
                        'condition': _selectedCondition,
                        'useremail': email,
                        'usernumber': phonenumber,
                        'date_uploaded': DateTime.now().toString(),
                        'image': await MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        'image2': await MultipartFile.fromFile(_image2.path,
                            filename: fileName2),
                        'image3': await MultipartFile.fromFile(_image3.path,
                            filename: fileName3),
                        'image4': await MultipartFile.fromFile(_image4.path,
                            filename: fileName4),
                        'image5': await MultipartFile.fromFile(_image5.path,
                            filename: fileName5),
                        'image6': await MultipartFile.fromFile(_image6.path,
                            filename: fileName6),
                      });
                    }

                    var response = await dio.post(url, data: formData);

                    if (response.statusCode == 200) {
                      showDialog(
                          context: context,
                          builder: (_) => AssetGiffyDialog(
                                image: Image.asset(
                                  'assets/yay.gif',
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  'Hooray!',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                description: Text(
                                  'Your Item\'s Uploaded',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(),
                                ),
                                onlyOkButton: true,
                                entryAnimation: EntryAnimation.DEFAULT,
                                onOkButtonPressed: () {
                                  businesspricecontroller.clear();
                                  businessnameController.clear();
                                  businessdescriptionController.clear();
                                  businessbrandcontroller.clear();
                                  businessizecontroller.clear();
                                  _image.writeAsStringSync('');
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RootScreen()),
                                  );
                                },
                              ));
                    } else {
                      print(response.statusCode);
                    }
                  } else {
                    showInSnackBar('Oops looks like your missing something!');
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.deepOrangeAccent, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xFF9DA3B4).withOpacity(0.1),
                            blurRadius: 65.0,
                            offset: Offset(0.0, 15.0))
                      ]),
                  child: Center(
                    child: Text(
                      "Add an Item",
                      style: TextStyle(
                          fontFamily: 'SF',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            : Text(''));
  }

  final Geolocator geolocator = Geolocator();

  _handleTap(LatLng point) async {
    if (_markers.isNotEmpty) {
      _markers.remove(_markers.last);
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Location of Item',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        _lastMapPosition = point;
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _lastMapPosition.latitude, _lastMapPosition.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      setState(() {
        city = cit;
        country = countr;
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Location of Item',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        _lastMapPosition = point;
        print(_lastMapPosition);
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _lastMapPosition.latitude, _lastMapPosition.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      setState(() {
        city = cit;
        country = countr;
      });
    }
  }

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

  void mapCreated(GoogleMapController controlle) {
    setState(() {
      controller = controlle;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastMapPosition = position.target;
    });
  }
}
