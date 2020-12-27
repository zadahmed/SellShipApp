import 'dart:convert';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/addlocation.dart';
import 'package:dotted_border/dotted_border.dart';
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
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as Location;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:random_string/random_string.dart';

import 'package:shimmer/shimmer.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

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
    focusNode = FocusNode();
  }

  var currency;
  var metric;
  LatLng _lastMapPosition;

  List<String> photoguidelinesimages = [
    'assets/photoguidelines/7.jpeg',
    'assets/photoguidelines/8.jpeg',
    'assets/photoguidelines/1.jpeg',
    'assets/photoguidelines/2.jpeg',
    'assets/photoguidelines/3.jpeg',
    'assets/photoguidelines/4.jpeg',
    'assets/photoguidelines/5.jpeg',
    'assets/photoguidelines/6.jpeg',
  ];

  String city;
  String country;

  int quantity = 0;

  getuser() async {
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        metric = 'Kg';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
        metric = 'lbs';
      });
    } else {
      setState(() {
        currency = 'USD';
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
          useRootNavigator: false,
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
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  GlobalKey _toolTipKey = GlobalKey();
  LatLng position;

  String locdetials;
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

  List<String> weights = [
    '5',
    '10',
    '20',
    '50',
  ];

  bool quantityswitch = false;

  int _selectedweight = -1;

  String _selectedcondition;

  var totalpayable;

  FocusNode focusNode;

  void showKeyboard() {
    focusNode.requestFocus();
  }

  void dismissKeyboard() {
    focusNode.unfocus();
  }

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
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "camera"),
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
      percentindictor = 0.3;
    });
  }

  bool meetupcheckbox = false;
  bool shippingcheckbox = false;
  var brand;
  final businesspricecontroller = TextEditingController();

  @override
  void dispose() {
    businessnameController.dispose();
    businesspricecontroller.dispose();
    super.dispose();
  }

  int itemweight;

  String categoryinfo;

  double percentindictor = 0.0;
  bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color.fromRGBO(242, 244, 248, 1).withOpacity(0.4),
        appBar: AppBar(
          title: Center(
            child: Text(
              "Add an Item",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 0.5,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBar: Padding(
            padding: EdgeInsets.only(left: 15, bottom: 5, top: 10, right: 15),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 50,
                lineHeight: 8.0,
                percent: percentindictor,
                progressColor: Colors.orange,
              ),
            )),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: userid != null
              ? CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Container(
                        height: 229,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 15, bottom: 5),
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Upload Images',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 15, bottom: 10, right: 15),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          useRootNavigator: false,
                                          isScrollControlled: true,
                                          builder: (_) {
                                            return DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: 0.7,
                                              builder: (_, controller) {
                                                return Container(
                                                    height: 350.0,
                                                    color: Color(0xFF737373),
                                                    child: Container(
                                                        decoration: new BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: new BorderRadius
                                                                    .only(
                                                                topLeft:
                                                                    const Radius
                                                                            .circular(
                                                                        20.0),
                                                                topRight:
                                                                    const Radius
                                                                            .circular(
                                                                        20.0))),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: 15,
                                                                top: 10,
                                                              ),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: InkWell(
                                                                      child: Icon(Icons.clear),
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      })),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: 15,
                                                                top: 10,
                                                              ),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  'Eye-catching photos help sell your item quicker.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 15,
                                                                      top: 10,
                                                                      bottom:
                                                                          15),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  'Check out some of our favorites!',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: GridView
                                                                  .builder(
                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                    mainAxisSpacing:
                                                                        10.0,
                                                                    crossAxisSpacing:
                                                                        10.0,
                                                                    crossAxisCount:
                                                                        2,
                                                                    childAspectRatio:
                                                                        1),
                                                                itemBuilder:
                                                                    (_, i) {
                                                                  return Container(
                                                                    height: 195,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        child: Image.asset(
                                                                          photoguidelinesimages[
                                                                              i],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )),
                                                                  );
                                                                },
                                                                itemCount:
                                                                    photoguidelinesimages
                                                                        .length,
                                                              ),
                                                            ),
                                                          ],
                                                        )));
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Read our photo upload tips',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 14,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                              ),
                              child: Container(
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
                                                  child: DottedBorder(
                                                    borderType:
                                                        BorderType.RRect,
                                                    radius: Radius.circular(12),
                                                    padding: EdgeInsets.all(6),
                                                    dashPattern: [12, 4],
                                                    color:
                                                        Colors.deepOrangeAccent,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                        child: Container(
                                                            color: Colors.white,
                                                            height: 100,
                                                            width: 100,
                                                            child: Icon(
                                                              Icons.add,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ))),
                                                  ))
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                          )
                                        : ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: images.length,
                                            itemBuilder: (BuildContext context,
                                                int position) {
                                              Asset asset = images[position];
                                              return Stack(children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 4.0)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: AssetThumb(
                                                          asset: asset,
                                                          width: 300,
                                                          height: 300,
                                                        )),
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        images
                                                            .removeAt(position);
                                                      });
                                                    },
                                                    child: CircleAvatar(
                                                      child: Icon(
                                                        Icons.delete_forever,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      radius: 14,
                                                    ),
                                                  ),
                                                ),
                                              ]);
                                            })),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              top: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Category',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
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
                                        percentindictor = 0.1;
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
                                    title: categoryinfo == null
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Choose your Category',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.blueGrey),
                                                ),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color: Colors.deepPurple)
                                              ],
                                            ))
                                        : Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  child: Text(
                                                    categoryinfo,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color:
                                                            Colors.deepPurple),
                                                  ),
                                                ),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color: Colors.deepPurple)
                                              ],
                                            )))),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              bottom: 5,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Item Info',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: businessnameController,
                                  autocorrect: true,
                                  enableSuggestions: true,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {
                                      setState(() {
                                        percentindictor = 0.4;
                                      });
                                    }
                                  },
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: "Product Name",
                                    hintStyle: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                    focusColor: Colors.black,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 11,
                                        top: 11,
                                        right: 15),
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
                                  left: 15, bottom: 5, top: 10, right: 15),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Center(
                                  child: TextField(
                                    cursorColor: Color(0xFF979797),
                                    controller: businessdescriptionController,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        setState(() {
                                          percentindictor = 0.5;
                                        });
                                      }
                                    },
                                    autocorrect: true,
                                    enableSuggestions: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: 6,
                                    maxLength: 1000,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        useRootNavigator: false,
                                        isScrollControlled: true,
                                        builder: (_) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            initialChildSize: 0.5,
                                            builder: (_, controller) {
                                              return Container(
                                                  height: 350.0,
                                                  color: Color(0xFF737373),
                                                  child: Container(
                                                      decoration: new BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: new BorderRadius
                                                                  .only(
                                                              topLeft: const Radius
                                                                      .circular(
                                                                  20.0),
                                                              topRight: const Radius
                                                                      .circular(
                                                                  20.0))),
                                                      child: ListView(
                                                        children: [
                                                          Center(
                                                            child: Icon(
                                                              Icons
                                                                  .warning_rounded,
                                                              color: Colors.red,
                                                              size: 150,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 15,
                                                              top: 10,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Attention!',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 15,
                                                              top: 10,
                                                              bottom: 10,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Please note purchases are only accepted through the buy option in the app. Adding mobile numbers and asking for payments outside the app is strictly prohibited and is against our community guidelines in order to protect buyer and seller privacy.',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            child: InkWell(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      30,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .redAccent,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color: Colors.redAccent.withOpacity(
                                                                                0.1),
                                                                            blurRadius:
                                                                                65.0,
                                                                            offset:
                                                                                Offset(0.0, 15.0))
                                                                      ]),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "I Accept",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w300),
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                }),
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10,
                                                                    left: 10,
                                                                    right: 10),
                                                          )
                                                        ],
                                                      )));
                                            },
                                          );
                                        },
                                      );
                                    },
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w200),
                                    decoration: InputDecoration(
                                      hintText: "Enter Description here..",
                                      alignLabelWithHint: true,
                                      hintStyle: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.blueGrey),
                                      focusColor: Colors.black,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 11,
                                          top: 11,
                                          right: 15),
                                    ),
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 15, bottom: 5, top: 10, right: 15),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: SwitchListTile(
                                  value: quantityswitch,
                                  activeColor: Colors.deepPurple,
                                  title: Text(
                                    'Selling more than one of the same item?',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                  ),
                                  onChanged: (value) => setState(() {
                                    quantityswitch = value;
                                  }),
                                ),
                              )),
                          quantityswitch == true
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 10, right: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 15,
                                                bottom: 5,
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Quantity of Item',
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.blueGrey),
                                                ),
                                              ),
                                            ),
                                            Container(
                                                height: 70,
                                                width: 130,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.remove),
                                                      iconSize: 16,
                                                      color: Colors.deepOrange,
                                                      onPressed: () {
                                                        setState(() {
                                                          if (quantity > 0) {
                                                            quantity =
                                                                quantity - 1;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Container(
                                                      width: 25,
                                                      child: Text(
                                                        quantity.toString(),
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.add),
                                                      iconSize: 16,
                                                      color: Colors.deepOrange,
                                                      onPressed: () {
                                                        setState(() {
                                                          if (quantity >= 0) {
                                                            quantity =
                                                                quantity + 1;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ))
                                          ])))
                              : Container(),
                          _selectedCategory != null
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    bottom: 5,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Brand',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                )
                              : Container(),
                          _selectedCategory != null
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 10, right: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: ListTile(
                                          title: Container(
                                              width: 200,
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

                                                    percentindictor = 0.6;
                                                  });
                                                },
                                                child: brand != null
                                                    ? Container(
                                                        width: 200,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Text(
                                                              brand,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .deepPurple),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: Colors
                                                                    .deepPurple)
                                                          ],
                                                        ))
                                                    : Container(
                                                        width: 200,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Text(
                                                              'Choose your Brand',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blueGrey),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: Colors
                                                                    .deepPurple)
                                                          ],
                                                        )),
                                              )))))
                              : Container(),
                          brand == 'Other'
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 10, right: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Center(
                                          child: ListTile(
                                        title: TextField(
                                          cursorColor: Color(0xFF979797),
                                          controller: businessbrandcontroller,
                                          keyboardType: TextInputType.text,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: InputDecoration(
                                            hintText: "Other Brand Name",
                                            alignLabelWithHint: true,
                                            hintStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.blueGrey),
                                            focusColor: Colors.black,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ))))
                              : Container(),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              bottom: 5,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 15, bottom: 5, top: 10, right: 15),
                              child: Container(
                                height: 70,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      hint: Text(
                                        'Condition of Item',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            color: Colors.blueGrey),
                                      ),
                                      value: _selectedcondition,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedcondition = newValue;
                                          percentindictor = 0.7;
                                        });
                                      },
                                      items: conditions.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(
                                            location,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          value: location,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 10.0,
                          ),
                          _selectedCategory == 'Women' ||
                                  _selectedCategory == 'Men' ||
                                  _selectedCategory == 'Kids'
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    bottom: 5,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Size',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                )
                              : Container(),
                          _selectedCategory == 'Women' ||
                                  _selectedCategory == 'Men' ||
                                  _selectedCategory == 'Kids'
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 10, right: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Center(
                                          child: ListTile(
                                              title: Container(
                                        width: 200,
                                        child: Center(
                                          child: TextField(
                                              cursorColor: Color(0xFF979797),
                                              controller: businessizecontroller,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                hintText: "Choose your Size",
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.blueGrey),
                                                focusColor: Colors.black,
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                              )),
                                        ),
                                      )))))
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              top: 5,
                              bottom: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Item Weight',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 20, top: 4, right: 15),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: weights.length,
                                  itemBuilder:
                                      (BuildContext context, int position) {
                                    return Padding(
                                        padding: EdgeInsets.all(5),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _selectedweight = position;
                                                itemweight = int.parse(
                                                    weights[position]);
                                              });
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: _selectedweight ==
                                                          position
                                                      ? Colors.deepOrangeAccent
                                                      : Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                ),
                                                width: 80,
                                                height: 10,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '< ' +
                                                          weights[position] +
                                                          ' ' +
                                                          metric,
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                        color:
                                                            _selectedweight ==
                                                                    position
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ))));
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              bottom: 5,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Price',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                              height: 85,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: TextField(
                                          cursorColor: Color(0xFF979797),
                                          controller: businesspricecontroller,
                                          onChanged: (text) {
                                            var weightfees;
                                            if (_selectedweight == 0) {
                                              weightfees = 20;
                                            } else if (_selectedweight == 1) {
                                              weightfees = 30;
                                            } else if (_selectedweight == 2) {
                                              weightfees = 50;
                                            } else if (_selectedweight == 3) {
                                              weightfees = 110;
                                            }

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
                                                var s = 0.15 *
                                                    int.parse(
                                                        businesspricecontroller
                                                            .text);
                                                fees = int.parse(
                                                        businesspricecontroller
                                                            .text) +
                                                    s +
                                                    weightfees;
                                              }
                                            } else {
                                              fees = int.parse(
                                                      businesspricecontroller
                                                          .text) +
                                                  weightfees +
                                                  0.15 *
                                                      int.parse(
                                                          businesspricecontroller
                                                              .text);
                                            }

                                            print(fees);
                                            setState(() {
                                              totalpayable = totalpayable;
                                              fees = fees;

                                              percentindictor = 0.8;
                                            });
                                          },
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                          keyboardType:
                                              TextInputType.numberWithOptions(),
                                          decoration: InputDecoration(
                                            hintText: '0',
//                                                alignLabelWithHint: true,
                                            hintStyle: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                            focusColor: Colors.black,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                        width: 100,
                                      ),
                                      Text(currency,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 22,
                                          )),
                                    ]),
                              ),
                            ),
                          ),
                          fees != null
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, top: 2, right: 15),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15)),
                                    ),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: 155,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Listing Price',
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      final dynamic tooltip =
                                                          _toolTipKey
                                                              .currentState;
                                                      tooltip
                                                          .ensureTooltipVisible();
                                                    },
                                                    child: Tooltip(
                                                        key: _toolTipKey,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
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
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
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
                                                          color: Colors.grey,
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
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                  ),
                                )
                              : Container(),
                          fees != null
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, right: 15),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                                    ),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'You earn',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              businesspricecontroller
                                                      .text.isNotEmpty
                                                  ? currency +
                                                      ' ' +
                                                      businesspricecontroller
                                                          .text
                                                  : '0',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                  ))
                              : Container(),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              top: 15,
                              bottom: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Location',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: ListTile(
                                    onTap: () async {
                                      final locationdetails =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddLocation()),
                                      );
                                      print(locationdetails);

                                      setState(() {
                                        percentindictor = 0.9;
                                        city = locationdetails['city'];
                                        country = locationdetails['country'];
                                        _lastMapPosition =
                                            locationdetails['lastmapposition'];

                                        locdetials = country + ' > ' + city;
                                      });
                                    },
                                    title: locdetials == null
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Choose your Location',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.deepPurple),
                                                ),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color: Colors.deepPurple)
                                              ],
                                            ))
                                        : Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 +
                                                50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  child: Text(
                                                    locdetials,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color:
                                                            Colors.deepPurple),
                                                  ),
                                                ),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color: Colors.deepPurple)
                                              ],
                                            )))),
                          ),
                          SizedBox(
                            height: 10.0,
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
                                  } else if (businessizecontroller == null &&
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
                                  } else if (city == null || country == null) {
                                    showInSnackBar(
                                        'Please choose the location of your item on the map!');
                                  } else {
                                    if (businessdescriptionController
                                        .text.isEmpty) {
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
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: SpinKitChasingDots(
                                                      color:
                                                          Colors.deepOrange)),
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

                                      if (mounted) {
                                        setState(() {
                                          firstname = profilemap['username'];
                                          phonenumber =
                                              profilemap['phonenumber'];
                                          email = profilemap['email'];
                                        });
                                      }
                                    } else if (city == null) {
                                      Navigator.of(context, rootNavigator: true)
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
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();
                                      } else if (images.length == 2) {
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();

                                        ByteData byteData2 =
                                            await images[1].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                      } else if (images.length == 3) {
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();

                                        ByteData byteData2 =
                                            await images[1].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image2 =
                                            byteData2.buffer.asUint8List();

                                        ByteData byteData3 =
                                            await images[2].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image3 =
                                            byteData3.buffer.asUint8List();
                                      } else if (images.length == 4) {
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();

                                        ByteData byteData2 =
                                            await images[1].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image2 =
                                            byteData2.buffer.asUint8List();

                                        ByteData byteData3 =
                                            await images[2].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image3 =
                                            byteData3.buffer.asUint8List();

                                        ByteData byteData4 =
                                            await images[3].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image4 =
                                            byteData4.buffer.asUint8List();
                                      } else if (images.length == 5) {
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();

                                        ByteData byteData2 =
                                            await images[1].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image2 =
                                            byteData2.buffer.asUint8List();

                                        ByteData byteData3 =
                                            await images[2].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image3 =
                                            byteData3.buffer.asUint8List();

                                        ByteData byteData4 =
                                            await images[3].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image4 =
                                            byteData4.buffer.asUint8List();

                                        ByteData byteData5 =
                                            await images[4].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image5 =
                                            byteData5.buffer.asUint8List();
                                      } else if (images.length == 6) {
                                        ByteData byteData =
                                            await images[0].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image = byteData.buffer.asUint8List();

                                        ByteData byteData2 =
                                            await images[1].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image2 =
                                            byteData2.buffer.asUint8List();

                                        ByteData byteData3 =
                                            await images[2].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image3 =
                                            byteData3.buffer.asUint8List();

                                        ByteData byteData4 =
                                            await images[3].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image4 =
                                            byteData4.buffer.asUint8List();

                                        ByteData byteData5 =
                                            await images[4].getThumbByteData(
                                          400,
                                          400,
                                        );
                                        _image5 =
                                            byteData5.buffer.asUint8List();

                                        ByteData byteData6 =
                                            await images[5].getThumbByteData(
                                          400,
                                          400,
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
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'originalprice': '',
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
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
                                          'size':
                                              businessizecontroller.text == null
                                                  ? ''
                                                  : businessizecontroller.text,
                                          'userid': userid,
                                          'username': firstname,
                                          'useremail': email,
                                          'usernumber': phonenumber,
                                          'weight': itemweight,
                                          'weightmetric': metric,
                                          'quantity': quantity,
                                          'date_uploaded':
                                              DateTime.now().toString(),
                                          'image': MultipartFile.fromBytes(
                                            _image,
                                            filename: fileName,
                                          )
                                        });
                                      }
                                      if (_image != null && _image2 != null) {
                                        String fileName =
                                            randomAlphaNumeric(20);
                                        String fileName2 =
                                            randomAlphaNumeric(20);
                                        formData = FormData.fromMap({
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'originalprice': '',
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
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
                                          'size':
                                              businessizecontroller.text == null
                                                  ? ''
                                                  : businessizecontroller.text,
                                          'country': country.trim(),
                                          'username': firstname,
                                          'useremail': email,
                                          'usernumber': phonenumber,
                                          'quantity': quantity,
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
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'category': _selectedCategory,
                                          'originalprice': '',
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'condition': _selectedCondition,
                                          'meetup': meetupcheckbox,
                                          'shipping': shippingcheckbox,
                                          'quantity': quantity,
                                          'brand': bran,
                                          'size':
                                              businessizecontroller.text == null
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
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'category': _selectedCategory,
                                          'originalprice': '',
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'quantity': quantity,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'userid': userid,
                                          'condition': _selectedCondition,
                                          'meetup': meetupcheckbox,
                                          'shipping': shippingcheckbox,
                                          'brand': bran,
                                          'size':
                                              businessizecontroller.text == null
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
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'category': _selectedCategory,
                                          'originalprice': '',
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'quantity': quantity,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'country': country.trim(),
                                          'brand': bran,
                                          'size':
                                              businessizecontroller.text == null
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
                                          'name': businessnameController.text,
                                          'price': businesspricecontroller.text,
                                          'category': _selectedCategory,
                                          'originalprice': '',
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'userid': userid,
                                          'quantity': quantity,
                                          'country': country.trim(),
                                          'username': firstname,
                                          'meetup': meetupcheckbox,
                                          'shipping': shippingcheckbox,
                                          'brand': bran,
                                          'size':
                                              businessizecontroller.text == null
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

                                      var response =
                                          await dio.post(url, data: formData);

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
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  description: Text(
                                                    'Your Item\'s Uploaded',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(),
                                                  ),
                                                  onlyOkButton: true,
                                                  entryAnimation:
                                                      EntryAnimation.DEFAULT,
                                                  onOkButtonPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop('dialog');
                                                    Navigator.of(context,
                                                            rootNavigator: true)
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
                                  width: MediaQuery.of(context).size.width - 30,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 115, 0, 1),
                                      borderRadius: BorderRadius.circular(10),
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
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300),
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
                      height: 20,
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
        ));
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
