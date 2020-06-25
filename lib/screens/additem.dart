import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/additeminfo.dart';
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
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    getuser();
  }

  var currency;
  getuser() async {
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
    setState(() {
      userid = userid;
    });
  }

  final businessnameController = TextEditingController();

  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

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
  final businesspricecontroller = TextEditingController();

  @override
  void dispose() {
    businessnameController.dispose();
    businesspricecontroller.dispose();
    super.dispose();
  }

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
                color: Colors.deepOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: GestureDetector(
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
                            height: 360,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 15),
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
                                  height: 300,
                                  child: Scrollbar(
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final action = CupertinoActionSheet(
                                              message: Text(
                                                "Upload an Image",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              actions: <Widget>[
                                                CupertinoActionSheetAction(
                                                  child: Text(
                                                      "Upload from Camera",
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight
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
                                                          fontWeight: FontWeight
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
                                                            FontWeight.normal)),
                                                isDestructiveAction: true,
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                              ),
                                            );
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder: (context) => action);
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: 250,
                                              width: 250,
                                              child: _image == null
                                                  ? Icon(Icons.add)
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.file(
                                                        _image,
                                                        fit: BoxFit.cover,
                                                      ))),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _image != null
                                            ? GestureDetector(
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
                                                    height: 250,
                                                    width: 250,
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
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _image2 != null
                                            ? GestureDetector(
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
                                                    height: 250,
                                                    width: 250,
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
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _image3 != null
                                            ? GestureDetector(
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
                                                    height: 250,
                                                    width: 250,
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
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _image4 != null
                                            ? GestureDetector(
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
                                                    height: 250,
                                                    width: 250,
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
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _image5 != null
                                            ? GestureDetector(
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
                                                    height: 250,
                                                    width: 250,
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
                                              )
                                            : Container(),
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
                            height: 120,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Title',
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
                              ],
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
                            height: 120,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Price',
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
                                    controller: businesspricecontroller,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                        labelText: "Price " + currency,
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
                              ],
                            ),
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
                        'assets/little_theologians_4x.png',
                        fit: BoxFit.fitWidth,
                      ))
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: userid != null
            ? InkWell(
                onTap: () async {
                  if (_image == null) {
                    showInSnackBar('Please upload a picture for your item!');
                  } else if (businessnameController.text.isEmpty) {
                    showInSnackBar(
                        'Oops looks like your missing a title for your item!');
                  } else if (businesspricecontroller.text.isEmpty) {
                    showInSnackBar(
                        'Oops looks like your missing a price for your item!');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddItemInfo(
                                image: _image,
                                image2: _image2,
                                image3: _image3,
                                image4: _image4,
                                image5: _image5,
                                price: businesspricecontroller.text.trim(),
                                userid: userid,
                                image6: _image6,
                                itemname: businessnameController.text.trim(),
                              )),
                    );
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 50,
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
                      "Next ( Product Information )",
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
