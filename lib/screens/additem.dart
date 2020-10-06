import 'dart:convert';

import 'package:SellShip/screens/addbrans.dart';
import 'package:SellShip/screens/addcategory.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as Location;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:random_string/random_string.dart';
import 'package:search_map_place/search_map_place.dart' as SearchMap;
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
    Location.Location _location = new Location.Location();

    bool _serviceEnabled;
    Location.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == Location.PermissionStatus.denied) {
      setState(() {
        loading = false;
        position = LatLng(25.2048, 55.2708);
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AssetGiffyDialog(
                image: Image.asset(
                  'assets/oops.gif',
                  fit: BoxFit.cover,
                ),
                title: Text(
                  'Turn on Location Services!',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                ),
                description: Text(
                  'You need to provide access to your location in order to Add an Item within your community',
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
                onlyOkButton: true,
                entryAnimation: EntryAnimation.DEFAULT,
                onOkButtonPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  AppSettings.openLocationSettings();
                },
              ));
    } else if (_permissionGranted == Location.PermissionStatus.granted) {
      var location = await _location.getLocation();
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

  List<String> weights = ['2', '5', '10', '20', '50', '100'];

  int _selectedweight = -1;

  int _selectedcondition = -1;

  var totalpayable;
  var fees;

  List<String> brands = List<String>();

  List<Asset> images = List<Asset>();
  Future getImageGallery() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "SellShip",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
    });
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

      List<Geocoding.Placemark> placemarks =
          await Geocoding.placemarkFromCoordinates(
              position.latitude, position.longitude,
              localeIdentifier: 'en');

      Geocoding.Placemark place = placemarks[0];
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
      List<Geocoding.Placemark> placemarks =
          await Geocoding.placemarkFromCoordinates(
              position.latitude, position.longitude,
              localeIdentifier: 'en');

      Geocoding.Placemark place = placemarks[0];
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

  String categoryinfo;
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
            "Upload an Item",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
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
                            height: 200,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 10),
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
                                  height: 150,
                                  child: GestureDetector(
                                      onTap: () async {
                                        if (await Permission.Permission.photos
                                            .request()
                                            .isGranted) {
                                          getImageGallery();
                                        } else {
                                          Map<Permission.Permission,
                                                  Permission.PermissionStatus>
                                              statuses = await [
                                            Permission.Permission.photos,
                                          ].request();
                                          Permission.openAppSettings();
                                        }
                                      },
                                      child: images.isEmpty
                                          ? Row(
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        height: 150,
                                                        width: 150,
                                                        child: Icon(Icons.add)))
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                            )
                                          : ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: images.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int position) {
                                                Asset asset = images[position];
                                                return Stack(children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Container(
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: AssetThumb(
                                                            asset: asset,
                                                            width: 300,
                                                            height: 300,
                                                          )),
                                                      width: 155,
                                                      height: 155,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          images.removeAt(
                                                              position);
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.delete_forever,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ]);
                                              })),
                                )
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
                                    onTap: () async {
                                      final catdetails = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddCategory()),
                                      );
                                      print(catdetails);
                                      setState(() {
                                        _selectedCategory =
                                            catdetails['category'];
                                        _selectedsubCategory =
                                            catdetails['subcategory'];
                                        _selectedsubsubCategory =
                                            catdetails['subsubcategory'];

                                        categoryinfo = _selectedCategory +
                                            ' > ' +
                                            _selectedsubCategory +
                                            ' > ' +
                                            _selectedsubsubCategory;
                                      });
                                    },
                                    title: Text(
                                      'Category',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: categoryinfo == null
                                        ? Icon(Icons.keyboard_arrow_right)
                                        : Container(
                                            width: 300,
                                            child: Center(
                                                child: Text(
                                              categoryinfo,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.deepPurple),
                                            )),
                                          ),
                                  )),
                              SizedBox(
                                height: 10.0,
                              ),
                              _selectedCategory != null
                                  ? Container(
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
                                                  onTap: () async {
                                                    final bran =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Brands(
                                                                category:
                                                                    _selectedCategory,
                                                              )),
                                                    );
                                                    setState(() {
                                                      brand = bran;
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
                                                            children: <Widget>[
                                                              Text(
                                                                'Choose Brand',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
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
                                                                  Colors.black,
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
                                      itemBuilder:
                                          (BuildContext context, int position) {
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
                                                          BorderRadius.circular(
                                                              15),
                                                      color: _selectedcondition ==
                                                              position
                                                          ? Colors
                                                              .deepPurpleAccent
                                                          : Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
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
                                                          conditions[position],
                                                          textAlign:
                                                              TextAlign.center,
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
                                                              labelText: "Size",
                                                              alignLabelWithHint:
                                                                  true,
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
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
                                padding: EdgeInsets.only(left: 15, bottom: 15),
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
                                      top: 10, bottom: 15, left: 15, right: 15),
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
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
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
                                                              color:
                                                                  Colors.white,
                                                              boxShadow: <
                                                                  BoxShadow>[
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.2),
                                                                    offset:
                                                                        const Offset(
                                                                            0.0,
                                                                            0.6),
                                                                    blurRadius:
                                                                        5.0),
                                                              ],
                                                            ),
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                      fees.toStringAsFixed(2),
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
                                                      totalpayable
                                                          .toStringAsFixed(2),
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
                                            itemBuilder: (BuildContext context,
                                                int position) {
                                              return Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedweight =
                                                              position;
                                                          itemweight =
                                                              int.parse(weights[
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
                                                                : Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                offset: Offset(
                                                                    0.0,
                                                                    1.0), //(x,y)
                                                                blurRadius: 6.0,
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
                                                                  fontSize: 14,
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
                                                  myLocationButtonEnabled: true,
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
                                          child: SearchMap.SearchMapPlaceWidget(
                                            apiKey:
                                                'AIzaSyAL0gczX37-cNVHC_4aV6lWE3RSNqeamf4',
                                            language: 'en',
                                            location: position,
                                            radius: 10000,
                                            onSelected:
                                                (SearchMap.Place places) async {
                                              final geolocations =
                                                  await places.geolocation;

                                              controller.animateCamera(
                                                  CameraUpdate.newLatLng(
                                                      geolocations
                                                          .coordinates));
                                              controller.animateCamera(
                                                  CameraUpdate.newLatLngBounds(
                                                      geolocations.bounds, 0));

                                              setState(() {
                                                position =
                                                    geolocations.coordinates;
                                              });

                                              List<Geocoding.Placemark>
                                                  placemarks = await Geocoding
                                                      .placemarkFromCoordinates(
                                                          position.latitude,
                                                          position.longitude,
                                                          localeIdentifier:
                                                              'en');

                                              Geocoding.Placemark place =
                                                  placemarks[0];
                                              var cit =
                                                  place.administrativeArea;
                                              var countr = place.country;
                                              setState(() {
                                                city = cit;
                                                country = countr;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: userid != null
                              ? Padding(
                                  child: InkWell(
                                    onTap: () async {
                                      if (images.isEmpty) {
                                        showInSnackBar(
                                            'Please upload a picture for your item!');
                                      } else if (businessnameController
                                          .text.isEmpty) {
                                        showInSnackBar(
                                            'Oops looks like your missing a title for your item!');
                                      } else if (_selectedCategory == null) {
                                        showInSnackBar(
                                            'Please choose a category for your item!');
                                      } else if (_selectedsubCategory == null) {
                                        showInSnackBar(
                                            'Please choose a sub category for your item!');
                                      } else if (_selectedCondition == null) {
                                        showInSnackBar(
                                            'Please choose the condition of your item!');
                                      } else if (businesspricecontroller
                                          .text.isEmpty) {
                                        showInSnackBar(
                                            'Oops looks like your missing a price for your item!');
                                      } else if (businessizecontroller ==
                                              null &&
                                          _selectedCategory ==
                                              'Fashion & Accessories') {
                                        showInSnackBar(
                                            'Please choose the size for your item!');
                                      } else if (meetupcheckbox == false &&
                                          shippingcheckbox == false) {
                                        showInSnackBar(
                                            'Please choose a delivery method!');
                                      } else if (shippingcheckbox == true &&
                                          _selectedweight == -1) {
                                        showInSnackBar(
                                            'Please choose the weight of your item');
                                      } else if (city == null ||
                                          country == null) {
                                        showInSnackBar(
                                            'Please choose the location of your item on the map!');
                                      } else {
                                        if (businessdescriptionController
                                            .text.isEmpty) {
                                          businessdescriptionController.text =
                                              '';
                                        }

                                        String bran;
                                        if (businessbrandcontroller != null) {
                                          String brandcontrollertext =
                                              businessbrandcontroller.text
                                                  .trim();
                                          if (brandcontrollertext.isNotEmpty) {
                                            bran = businessbrandcontroller.text;
                                          } else if (brand != null) {
                                            bran = brand;
                                          }
                                        } else if (businessbrandcontroller ==
                                            null) {
                                          showInSnackBar(
                                              'Please choose a brand for your item!');
                                        }

                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)), //this right here
                                                child: Container(
                                                  height: 100,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: SpinKitChasingDots(
                                                          color: Colors
                                                              .deepOrange)),
                                                ),
                                              );
                                            });
                                        var userurl =
                                            'https://api.sellship.co/api/user/' +
                                                userid;
                                        final userresponse =
                                            await http.get(userurl);
                                        if (userresponse.statusCode == 200) {
                                          var userrespons =
                                              json.decode(userresponse.body);
                                          var profilemap = userrespons;
                                          print(profilemap);
                                          if (mounted) {
                                            setState(() {
                                              firstname =
                                                  profilemap['first_name'];
                                              phonenumber =
                                                  profilemap['phonenumber'];
                                              email = profilemap['email'];
                                            });
                                          }
                                        }

                                        if (meetupcheckbox == false &&
                                            shippingcheckbox == false) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                          showInSnackBar(
                                              'Please choose a checkbox for delivery method!');
                                        } else if (city == null) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                          showInSnackBar(
                                              'Please choose the location of your item!');
                                        } else {
                                          var url =
                                              'https://api.sellship.co/api/additem';

                                          List<int> _image;
                                          List<int> _image2;
                                          List<int> _image3;
                                          List<int> _image4;
                                          List<int> _image5;
                                          List<int> _image6;

                                          if (images.length == 1) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();
                                          } else if (images.length == 2) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();

                                            ByteData byteData2 = await images[1]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image2 =
                                                byteData2.buffer.asUint8List();
                                          } else if (images.length == 3) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();

                                            ByteData byteData2 = await images[1]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image2 =
                                                byteData2.buffer.asUint8List();

                                            ByteData byteData3 = await images[2]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image3 =
                                                byteData3.buffer.asUint8List();
                                          } else if (images.length == 4) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();

                                            ByteData byteData2 = await images[1]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image2 =
                                                byteData2.buffer.asUint8List();

                                            ByteData byteData3 = await images[2]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image3 =
                                                byteData3.buffer.asUint8List();

                                            ByteData byteData4 = await images[3]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image4 =
                                                byteData4.buffer.asUint8List();
                                          } else if (images.length == 5) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();

                                            ByteData byteData2 = await images[1]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image2 =
                                                byteData2.buffer.asUint8List();

                                            ByteData byteData3 = await images[2]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image3 =
                                                byteData3.buffer.asUint8List();

                                            ByteData byteData4 = await images[3]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image4 =
                                                byteData4.buffer.asUint8List();

                                            ByteData byteData5 = await images[4]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image5 =
                                                byteData5.buffer.asUint8List();
                                          } else if (images.length == 6) {
                                            ByteData byteData = await images[0]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image =
                                                byteData.buffer.asUint8List();

                                            ByteData byteData2 = await images[1]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image2 =
                                                byteData2.buffer.asUint8List();

                                            ByteData byteData3 = await images[2]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image3 =
                                                byteData3.buffer.asUint8List();

                                            ByteData byteData4 = await images[3]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image4 =
                                                byteData4.buffer.asUint8List();

                                            ByteData byteData5 = await images[4]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image5 =
                                                byteData5.buffer.asUint8List();

                                            ByteData byteData6 = await images[5]
                                                .getThumbByteData(
                                              600,
                                              600,
                                            );
                                            _image6 =
                                                byteData6.buffer.asUint8List();
                                          }

                                          Dio dio = new Dio();
                                          FormData formData;
                                          if (_image != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'originalprice': '',
                                              'category': _selectedCategory,
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'meetup': meetupcheckbox,
                                              'shipping': shippingcheckbox,
                                              'city': city.trim(),
                                              'country': country.trim(),
                                              'condition': _selectedCondition,
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
                                                  ? ''
                                                  : businessizecontroller.text,
                                              'userid': userid,
                                              'username': firstname,
                                              'useremail': email,
                                              'usernumber': phonenumber,
                                              'weight': itemweight,
                                              'weightmetric': metric,
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                _image,
                                                filename: fileName,
                                              )
                                            });
                                          }
                                          if (_image != null &&
                                              _image2 != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            String fileName2 =
                                                randomAlphaNumeric(20);
                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'originalprice': '',
                                              'category': _selectedCategory,
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'meetup': meetupcheckbox,
                                              'shipping': shippingcheckbox,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'city': city.trim(),
                                              'condition': _selectedCondition,
                                              'userid': userid,
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
                                                  ? ''
                                                  : businessizecontroller.text,
                                              'country': country.trim(),
                                              'username': firstname,
                                              'useremail': email,
                                              'usernumber': phonenumber,
                                              'weight': itemweight,
                                              'weightmetric': metric,
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                  _image,
                                                  filename: fileName),
                                              'image2': MultipartFile.fromBytes(
                                                  _image2,
                                                  filename: fileName2),
                                            });
                                          }
                                          if (_image != null &&
                                              _image2 != null &&
                                              _image3 != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            String fileName2 =
                                                randomAlphaNumeric(20);
                                            String fileName3 =
                                                randomAlphaNumeric(20);

                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'category': _selectedCategory,
                                              'originalprice': '',
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'city': city.trim(),
                                              'condition': _selectedCondition,
                                              'meetup': meetupcheckbox,
                                              'shipping': shippingcheckbox,
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
                                                  ? ''
                                                  : businessizecontroller.text,
                                              'userid': userid,
                                              'country': country.trim(),
                                              'username': firstname,
                                              'useremail': email,
                                              'usernumber': phonenumber,
                                              'weight': itemweight,
                                              'weightmetric': metric,
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                  _image,
                                                  filename: fileName),
                                              'image2': MultipartFile.fromBytes(
                                                  _image2,
                                                  filename: fileName2),
                                              'image3': MultipartFile.fromBytes(
                                                  _image3,
                                                  filename: fileName3),
                                            });
                                          }
                                          if (_image != null &&
                                              _image2 != null &&
                                              _image3 != null &&
                                              _image4 != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            String fileName2 =
                                                randomAlphaNumeric(20);
                                            String fileName3 =
                                                randomAlphaNumeric(20);
                                            String fileName4 =
                                                randomAlphaNumeric(20);

                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'category': _selectedCategory,
                                              'originalprice': '',
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'city': city.trim(),
                                              'userid': userid,
                                              'condition': _selectedCondition,
                                              'meetup': meetupcheckbox,
                                              'shipping': shippingcheckbox,
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
                                                  ? ''
                                                  : businessizecontroller.text,
                                              'country': country.trim(),
                                              'username': firstname,
                                              'useremail': email,
                                              'usernumber': phonenumber,
                                              'weight': itemweight,
                                              'weightmetric': metric,
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                  _image,
                                                  filename: fileName),
                                              'image2': MultipartFile.fromBytes(
                                                  _image2,
                                                  filename: fileName2),
                                              'image3': MultipartFile.fromBytes(
                                                  _image3,
                                                  filename: fileName3),
                                              'image4': MultipartFile.fromBytes(
                                                  _image4,
                                                  filename: fileName4),
                                            });
                                          }
                                          if (_image != null &&
                                              _image2 != null &&
                                              _image3 != null &&
                                              _image4 != null &&
                                              _image5 != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            String fileName2 =
                                                randomAlphaNumeric(20);
                                            String fileName3 =
                                                randomAlphaNumeric(20);
                                            String fileName4 =
                                                randomAlphaNumeric(20);
                                            String fileName5 =
                                                randomAlphaNumeric(20);

                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'category': _selectedCategory,
                                              'originalprice': '',
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'city': city.trim(),
                                              'country': country.trim(),
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
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
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                  _image,
                                                  filename: fileName),
                                              'image2': MultipartFile.fromBytes(
                                                  _image2,
                                                  filename: fileName2),
                                              'image3': MultipartFile.fromBytes(
                                                  _image3,
                                                  filename: fileName3),
                                              'image4': MultipartFile.fromBytes(
                                                  _image4,
                                                  filename: fileName4),
                                              'image5': MultipartFile.fromBytes(
                                                  _image5,
                                                  filename: fileName5),
                                            });
                                          }
                                          if (_image != null &&
                                              _image2 != null &&
                                              _image3 != null &&
                                              _image4 != null &&
                                              _image5 != null &&
                                              _image6 != null) {
                                            String fileName =
                                                randomAlphaNumeric(20);
                                            String fileName2 =
                                                randomAlphaNumeric(20);
                                            String fileName3 =
                                                randomAlphaNumeric(20);
                                            String fileName4 =
                                                randomAlphaNumeric(20);
                                            String fileName5 =
                                                randomAlphaNumeric(20);
                                            String fileName6 =
                                                randomAlphaNumeric(20);
                                            formData = FormData.fromMap({
                                              'name':
                                                  businessnameController.text,
                                              'price':
                                                  businesspricecontroller.text,
                                              'category': _selectedCategory,
                                              'originalprice': '',
                                              'subcategory':
                                                  _selectedsubCategory,
                                              'subsubcategory':
                                                  _selectedsubsubCategory ==
                                                          null
                                                      ? ''
                                                      : _selectedsubsubCategory,
                                              'latitude':
                                                  _lastMapPosition.latitude,
                                              'longitude':
                                                  _lastMapPosition.longitude,
                                              'description':
                                                  businessdescriptionController
                                                      .text,
                                              'city': city.trim(),
                                              'userid': userid,
                                              'country': country.trim(),
                                              'username': firstname,
                                              'meetup': meetupcheckbox,
                                              'shipping': shippingcheckbox,
                                              'brand': bran,
                                              'size': businessizecontroller
                                                          .text ==
                                                      null
                                                  ? ''
                                                  : businessizecontroller.text,
                                              'condition': _selectedCondition,
                                              'useremail': email,
                                              'usernumber': phonenumber,
                                              'weight': itemweight,
                                              'weightmetric': metric,
                                              'date_uploaded':
                                                  DateTime.now().toString(),
                                              'image': MultipartFile.fromBytes(
                                                  _image,
                                                  filename: fileName),
                                              'image2': MultipartFile.fromBytes(
                                                  _image2,
                                                  filename: fileName2),
                                              'image3': MultipartFile.fromBytes(
                                                  _image3,
                                                  filename: fileName3),
                                              'image4': MultipartFile.fromBytes(
                                                  _image4,
                                                  filename: fileName4),
                                              'image5': MultipartFile.fromBytes(
                                                  _image5,
                                                  filename: fileName5),
                                              'image6': MultipartFile.fromBytes(
                                                  _image6,
                                                  filename: fileName6),
                                            });
                                          }

                                          var response = await dio.post(url,
                                              data: formData);

                                          if (response.statusCode == 200) {
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    AssetGiffyDialog(
                                                      image: Image.asset(
                                                        'assets/yay.gif',
                                                        fit: BoxFit.cover,
                                                      ),
                                                      title: Text(
                                                        'Hooray!',
                                                        style: TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      description: Text(
                                                        'Your Item\'s Uploaded',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(),
                                                      ),
                                                      onlyOkButton: true,
                                                      entryAnimation:
                                                          EntryAnimation
                                                              .DEFAULT,
                                                      onOkButtonPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RootScreen()),
                                                        );
                                                      },
                                                    ));
                                          } else {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            showInSnackBar(
                                                'Looks like something went wrong!');
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.deepOrangeAccent,
                                                Colors.deepOrange
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color(0xFF9DA3B4)
                                                    .withOpacity(0.1),
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
                                  ),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                )
                              : Text(''),
                        ),
                        SliverToBoxAdapter(
                            child: SizedBox(
                          height: 80,
                        ))
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
    );
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
