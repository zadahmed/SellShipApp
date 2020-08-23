import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
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
  var metric;

  getuser() async {
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        loading = true;
        metric = 'Kg';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
        loading = true;
        metric = 'lbs';
      });
    } else {
      setState(() {
        currency = 'USD';
        loading = true;
        metric = 'lbs';
      });
    }
    userid = await storage.read(key: 'userid');

    setState(() {
      userid = userid;
    });
    Location _location = new Location();

    var location = await _location.getLocation();
    if (location == null) {
      _location.requestPermission();
//      getuser();
      setState(() {
        loading = false;
        position = LatLng(25.2048, 55.2708);
      });
    } else {
      var positio =
          LatLng(location.latitude.toDouble(), location.longitude.toDouble());

      setState(() {
        loading = false;
        position = positio;
      });
    }
  }

  GlobalKey _toolTipKey = GlobalKey();
  LatLng position;

  final businessnameController = TextEditingController();

  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

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
    'Good, some flaws visible'
  ];

  List<IconData> conditionicons = [
    Feather.tag,
    Feather.box,
    Feather.award,
    Icons.new_releases,
    Feather.eye,
  ];

  String _selectedCondition = 'Like new';

  String _selectedsubCategory;
  String _selectedsubsubCategory;
  String _selectedbrand;
  List<String> _subcategories;

  List<String> weights = ['2', '5', '10', '20', '50', '100'];

  int _selectedweight = -1;

  int _selectedcondition = -1;

  List<String> _subsubcategory;

  var totalpayable;
  var fees;

  List<String> brands = List<String>();

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera2() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image2 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery2() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image2 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera3() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image3 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery3() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image3 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera4() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image4 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery4() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image4 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera5() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image5 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery5() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image5 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageCamera6() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image6 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future getImageGallery6() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

    setState(() {
      _image6 = image;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  GoogleMapController controller;
  LatLng _lastMapPosition;

  Set<Marker> _markers = Set();
  bool meetupcheckbox = false;
  bool shippingcheckbox = false;
  var brand;
  final businesspricecontroller = TextEditingController();

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

  final Geolocator geolocator = Geolocator();
  String city;
  String country;

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
          _lastMapPosition.latitude, _lastMapPosition.longitude,
          localeIdentifier: 'en');
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
          _lastMapPosition.latitude, _lastMapPosition.longitude,
          localeIdentifier: 'en');
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      setState(() {
        city = cit;
        country = countr;
      });
    }
  }

  @override
  void dispose() {
    businessnameController.dispose();
    businesspricecontroller.dispose();
    super.dispose();
  }

  int itemweight;

  bool loading;

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
                fontFamily: 'Helvetica',
                fontSize: 20,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          elevation: 0.5,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: loading == false
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: userid != null
                    ? CustomScrollView(
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Container(
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
                              height: 150,
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
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 100,
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
                                                      fontWeight:
                                                          FontWeight.normal),
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
                                                          fontWeight: FontWeight
                                                              .normal)),
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
                                                height: 100,
                                                width: 100,
                                                child: _image == null
                                                    ? Icon(Icons.add)
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text(
                                                              "Upload from Camera",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
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
                                                                  fontSize:
                                                                      15.0,
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
                                                        isDestructiveAction:
                                                            true,
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
                                                                  .circular(
                                                                      10)),
                                                      height: 100,
                                                      width: 100,
                                                      child: _image2 == null
                                                          ? Icon(Icons.add)
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Image.file(
                                                                _image2,
                                                                fit: BoxFit
                                                                    .cover,
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text(
                                                              "Upload from Camera",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
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
                                                                  fontSize:
                                                                      15.0,
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
                                                        isDestructiveAction:
                                                            true,
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
                                                                  .circular(
                                                                      10)),
                                                      height: 100,
                                                      width: 100,
                                                      child: _image3 == null
                                                          ? Icon(Icons.add)
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Image.file(
                                                                _image3,
                                                                fit: BoxFit
                                                                    .cover,
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text(
                                                              "Upload from Camera",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
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
                                                                  fontSize:
                                                                      15.0,
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
                                                        isDestructiveAction:
                                                            true,
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
                                                                  .circular(
                                                                      10)),
                                                      height: 100,
                                                      width: 100,
                                                      child: _image4 == null
                                                          ? Icon(Icons.add)
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Image.file(
                                                                _image4,
                                                                fit: BoxFit
                                                                    .cover,
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text(
                                                              "Upload from Camera",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
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
                                                                  fontSize:
                                                                      15.0,
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
                                                        isDestructiveAction:
                                                            true,
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
                                                                  .circular(
                                                                      10)),
                                                      height: 100,
                                                      width: 100,
                                                      child: _image5 == null
                                                          ? Icon(Icons.add)
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Image.file(
                                                                _image5,
                                                                fit: BoxFit
                                                                    .cover,
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text(
                                                              "Upload from Camera",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
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
                                                                  fontSize:
                                                                      15.0,
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
                                                        isDestructiveAction:
                                                            true,
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
                                                                  .circular(
                                                                      10)),
                                                      height: 100,
                                                      width: 100,
                                                      child: _image6 == null
                                                          ? Icon(Icons.add)
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Image.file(
                                                                _image6,
                                                                fit: BoxFit
                                                                    .cover,
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
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                SizedBox(
                                  height: 10,
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
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 10, top: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Product Detail',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
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
                                      'Category',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                                                fontFamily: 'Helvetica',
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    'https://api.sellship.co/api/getbrands/' +
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
                                                    fontFamily: 'Helvetica',
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
                                              fontFamily: 'Helvetica',
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
                                                      fontFamily: 'Helvetica',
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
                                                          fontFamily:
                                                              'Helvetica',
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
                                                    fontFamily: 'Helvetica',
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
                                                        fontFamily: 'Helvetica',
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
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Item Condition',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    bottom: 10,
                                  ),
                                  child: Container(
                                    height: 100,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: conditions.length,
                                        itemBuilder: (BuildContext context,
                                            int position) {
                                          return Padding(
                                              padding: EdgeInsets.all(5),
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedcondition =
                                                          position;
                                                      _selectedCondition =
                                                          conditions[position];
                                                    });
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 0.2,
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        color: _selectedcondition ==
                                                                position
                                                            ? Colors
                                                                .deepPurpleAccent
                                                            : Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .grey.shade300,
                                                            offset: Offset(0.0,
                                                                1.0), //(x,y)
                                                            blurRadius: 6.0,
                                                          ),
                                                        ],
                                                      ),
                                                      height: 100,
                                                      width: 90,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            conditionicons[
                                                                position],
                                                            size: 30,
                                                            color: _selectedcondition ==
                                                                    position
                                                                ? Colors.white
                                                                : Colors
                                                                    .deepPurpleAccent,
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            conditions[
                                                                position],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 14,
                                                              color: _selectedcondition ==
                                                                      position
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .deepPurpleAccent,
                                                            ),
                                                          ),
                                                        ],
                                                      ))));
                                        }),
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
                                        labelText: "Description (optional)",
                                        alignLabelWithHint: true,
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
                                SizedBox(
                                  height: 10,
                                ),
                                brands.isNotEmpty && brands != null
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
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                trailing: Container(
                                                  width: 250,
                                                  padding: EdgeInsets.only(),
                                                  child: Center(
                                                      child: InkWell(
                                                    onTap: () {
                                                      _scaffoldKey.currentState
                                                          .showBottomSheet(
                                                              (context) {
                                                        return Container(
                                                          height: 500,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(Feather
                                                                    .chevron_down),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Center(
                                                                  child: Text(
                                                                    'Brand',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .deepOrange),
                                                                  ),
                                                                ),
                                                                Flexible(
//                  height: 600,
                                                                    child:
                                                                        AlphabetListScrollView(
                                                                  showPreview:
                                                                      true,
                                                                  strList:
                                                                      brands,
                                                                  indexedHeight:
                                                                      (i) {
                                                                    return 40;
                                                                  },
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          brand =
                                                                              brands[index];
                                                                        });

                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: brands[index] !=
                                                                                null
                                                                            ? Text(brands[index])
                                                                            : Text('sd'),
                                                                      ),
                                                                    );
                                                                  },
                                                                ))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: brand != null
                                                        ? Flex(
                                                            direction:
                                                                Axis.horizontal,
                                                            children: [
                                                                Flexible(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      brand,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    Icon(Icons
                                                                        .arrow_drop_down)
                                                                  ],
                                                                ))
                                                              ])
                                                        : Container(
                                                            width: 140,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Choose Brand',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                Icon(Icons
                                                                    .arrow_drop_down)
                                                              ],
                                                            )),
                                                  )),
                                                ))))
                                    : Container(),
                                brand == 'Other'
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
                                                    fontFamily: 'Helvetica',
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
                                                                      'Helvetica',
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
                                                    fontFamily: 'Helvetica',
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
                                                                      'Helvetica',
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
                                SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 15, bottom: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
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
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 15,
                                        left: 15,
                                        right: 15),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('Price',
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                )),
                                            Container(
                                              child: TextField(
                                                cursorColor: Color(0xFF979797),
                                                controller:
                                                    businesspricecontroller,
                                                onChanged: (text) {
                                                  if (int.parse(
                                                          businesspricecontroller
                                                              .text) <
                                                      20) {
                                                    if (int.parse(
                                                            businesspricecontroller
                                                                .text) <=
                                                        0) {
                                                      fees = 0;
                                                    } else {
                                                      fees = 2.0;
                                                    }
                                                  } else {
                                                    fees = 0.10 *
                                                        int.parse(
                                                            businesspricecontroller
                                                                .text);
                                                  }

                                                  totalpayable = double.parse(
                                                          businesspricecontroller
                                                              .text) -
                                                      fees;
                                                  if (totalpayable <= 0) {
                                                    totalpayable = 0;
                                                  }
                                                  setState(() {
                                                    totalpayable = totalpayable;
                                                    fees = fees;
                                                  });
                                                },
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Price " + currency,
                                                    alignLabelWithHint: true,
                                                    labelStyle: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                    focusColor: Colors.black,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ))),
                                              ),
                                              width: 100,
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                                fees != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 10,
                                              bottom: 15,
                                              left: 15,
                                              right: 15),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    width: 155,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          'Selling fee (10%)',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            final dynamic
                                                                tooltip =
                                                                _toolTipKey
                                                                    .currentState;
                                                            tooltip
                                                                .ensureTooltipVisible();
                                                          },
                                                          child: Tooltip(
                                                              key: _toolTipKey,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: <
                                                                    BoxShadow>[
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.2),
                                                                      offset: const Offset(
                                                                          0.0,
                                                                          0.6),
                                                                      blurRadius:
                                                                          5.0),
                                                                ],
                                                              ),
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 12,
                                                              ),
                                                              message:
                                                                  'This helps us offer you 24/7 support, cover the transaction fees and protect you as a seller. Overall improve the SellShip community.',
                                                              child: Icon(
                                                                FontAwesome5
                                                                    .question_circle,
                                                                size: 15,
                                                                color:
                                                                    Colors.grey,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    currency +
                                                        ' ' +
                                                        fees.toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  )
                                                ],
                                              )),
                                        ),
                                      )
                                    : Container(),
                                fees != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 10,
                                              bottom: 15,
                                              left: 15,
                                              right: 15),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'You earn',
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                  Text(
                                                    currency +
                                                        ' ' +
                                                        totalpayable.toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  )
                                                ],
                                              )),
                                        ))
                                    : Container(),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 10, top: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Delivery Method',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
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
                                        title: const Text('Meetup',
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                            )),
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
                                        title: const Text(
                                          'Shipping',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                          ),
                                        ),
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
                                shippingcheckbox == true
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 10,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Item Weight',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                shippingcheckbox == true
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 10,
                                        ),
                                        child: Container(
                                          height: 80,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: weights.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int position) {
                                                return Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedweight =
                                                                position;
                                                            itemweight = int
                                                                .parse(weights[
                                                                    position]);
                                                          });
                                                        },
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 0.2,
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              color: _selectedweight ==
                                                                      position
                                                                  ? Colors
                                                                      .deepPurpleAccent
                                                                  : Colors
                                                                      .white,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  offset: Offset(
                                                                      0.0,
                                                                      1.0), //(x,y)
                                                                  blurRadius:
                                                                      6.0,
                                                                ),
                                                              ],
                                                            ),
                                                            height: 80,
                                                            width: 90,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Feather.box,
                                                                  size: 30,
                                                                  color: _selectedweight ==
                                                                          position
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .deepPurpleAccent,
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  'Upto ' +
                                                                      weights[
                                                                          position] +
                                                                      ' ' +
                                                                      metric,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        14,
                                                                    color: _selectedweight ==
                                                                            position
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .deepPurpleAccent,
                                                                  ),
                                                                ),
                                                              ],
                                                            ))));
                                              }),
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Item Location',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
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
                                          fontFamily: 'Helvetica',
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
                                                  height: 350,
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
                                                    fontFamily: 'Helvetica',
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
                                SizedBox(
                                  height: 60.0,
                                ),
                              ],
                            ),
                          )
                        ],
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
                                  fontFamily: 'Helvetica',
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
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: ListView(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: userid != null
            ? InkWell(
                onTap: () async {
                  if (_image == null) {
                    showInSnackBar('Please upload a picture for your item!');
                  } else if (businessnameController.text.isEmpty) {
                    showInSnackBar(
                        'Oops looks like your missing a title for your item!');
                  } else if (_selectedCategory == null) {
                    showInSnackBar('Please choose a category for your item!');
                  } else if (_selectedsubCategory == null) {
                    showInSnackBar(
                        'Please choose a sub category for your item!');
                  } else if (_selectedCondition == null) {
                    showInSnackBar('Please choose the condition of your item!');
                  } else if (businesspricecontroller.text.isEmpty) {
                    showInSnackBar(
                        'Oops looks like your missing a price for your item!');
                  } else if (businessizecontroller == null &&
                      _selectedCategory == 'Fashion & Accessories') {
                    showInSnackBar('Please choose the size for your item!');
                  } else if (meetupcheckbox == false &&
                      shippingcheckbox == false) {
                    showInSnackBar('Please choose a delivery method!');
                  } else if (_selectedweight == -1) {
                    showInSnackBar('Please choose the weight of your item');
                  } else if (city == null || country == null) {
                    showInSnackBar(
                        'Please choose the location of your item on the map!');
                  } else {
                    if (businessdescriptionController.text.isEmpty) {
                      businessdescriptionController.text = '';
                    }

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

                    showDialog(
                        context: context,
                        barrierDismissible: false,
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
                    var userurl = 'https://api.sellship.co/api/user/' + userid;
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

                    if (meetupcheckbox == false && shippingcheckbox == false) {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      showInSnackBar(
                          'Please choose a checkbox for delivery method!');
                    } else if (city == null) {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      showInSnackBar(
                          'Please choose the location of your item!');
                    } else {
                      var url = 'https://api.sellship.co/api/additem';

                      Dio dio = new Dio();
                      FormData formData;
                      if (_image != null) {
                        String fileName = _image.path.split('/').last;
                        formData = FormData.fromMap({
                          'name': businessnameController.text,
                          'price': businesspricecontroller.text,
                          'originalprice': '',
                          'category': _selectedCategory,
                          'subcategory': _selectedsubCategory,
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
                          'brand': bran,
                          'size': businessizecontroller.text == null
                              ? ''
                              : businessizecontroller.text,
                          'userid': userid,
                          'username': firstname,
                          'useremail': email,
                          'usernumber': phonenumber,
                          'weight': itemweight,
                          'weightmetric': metric,
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
                          'price': businesspricecontroller.text,
                          'originalprice': '',
                          'category': _selectedCategory,
                          'subcategory': _selectedsubCategory,
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
                          'brand': bran,
                          'size': businessizecontroller.text == null
                              ? ''
                              : businessizecontroller.text,
                          'country': country.trim(),
                          'username': firstname,
                          'useremail': email,
                          'usernumber': phonenumber,
                          'weight': itemweight,
                          'weightmetric': metric,
                          'date_uploaded': DateTime.now().toString(),
                          'image': await MultipartFile.fromFile(_image.path,
                              filename: fileName),
                          'image2': await MultipartFile.fromFile(_image2.path,
                              filename: fileName2),
                        });
                      }
                      if (_image != null &&
                          _image2 != null &&
                          _image3 != null) {
                        String fileName = _image.path.split('/').last;
                        String fileName2 = _image2.path.split('/').last;
                        String fileName3 = _image3.path.split('/').last;

                        formData = FormData.fromMap({
                          'name': businessnameController.text,
                          'price': businesspricecontroller.text,
                          'category': _selectedCategory,
                          'originalprice': '',
                          'subcategory': _selectedsubCategory,
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
                          'brand': bran,
                          'size': businessizecontroller.text == null
                              ? ''
                              : businessizecontroller.text,
                          'userid': userid,
                          'country': country.trim(),
                          'username': firstname,
                          'useremail': email,
                          'usernumber': phonenumber,
                          'weight': itemweight,
                          'weightmetric': metric,
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
                          'price': businesspricecontroller.text,
                          'category': _selectedCategory,
                          'originalprice': '',
                          'subcategory': _selectedsubCategory,
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
                          'brand': bran,
                          'size': businessizecontroller.text == null
                              ? ''
                              : businessizecontroller.text,
                          'country': country.trim(),
                          'username': firstname,
                          'useremail': email,
                          'usernumber': phonenumber,
                          'weight': itemweight,
                          'weightmetric': metric,
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
                          'price': businesspricecontroller.text,
                          'category': _selectedCategory,
                          'originalprice': '',
                          'subcategory': _selectedsubCategory,
                          'subsubcategory': _selectedsubsubCategory == null
                              ? ''
                              : _selectedsubsubCategory,
                          'latitude': _lastMapPosition.latitude,
                          'longitude': _lastMapPosition.longitude,
                          'description': businessdescriptionController.text,
                          'city': city.trim(),
                          'country': country.trim(),
                          'brand': bran,
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
                          'weight': itemweight,
                          'weightmetric': metric,
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
                          'price': businesspricecontroller.text,
                          'category': _selectedCategory,
                          'originalprice': '',
                          'subcategory': _selectedsubCategory,
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
                          'brand': bran,
                          'size': businessizecontroller.text == null
                              ? ''
                              : businessizecontroller.text,
                          'condition': _selectedCondition,
                          'useremail': email,
                          'usernumber': phonenumber,
                          'weight': itemweight,
                          'weightmetric': metric,
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
                        showInSnackBar('Looks like something went wrong!');
                      }
                    }
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
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xFF9DA3B4).withOpacity(0.1),
                            blurRadius: 65.0,
                            offset: Offset(0.0, 15.0))
                      ]),
                  child: Center(
                    child: Text(
                      "Upload Item",
                      style: TextStyle(
                          fontFamily: 'Helvetica',
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
          fontFamily: 'Helvetica',
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
