import 'dart:convert';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/addlocation.dart';
import 'package:SellShip/screens/store/createstorename.dart';
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
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as Location;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:random_string/random_string.dart';

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
    getStoreData();
    focusNode = FocusNode();
  }

  ColorSwatch _tempMainColor;
  Color _tempShadeColor;

  ColorSwatch _mainColor = Colors.blue;

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

  List<Color> colorslist = [
    Colors.red,
    Colors.black,
    Colors.white,
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.tealAccent,
    Colors.teal,
    Colors.lime,
    Colors.limeAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.brown,
    Colors.indigo,
    Colors.grey,
  ];

  List<Color> selectedColors = List<Color>();

  int quantity = 1;

  getStoreData() async {
    var userid = await storage.read(key: 'userid');
    var storeurl = 'https://api.sellship.co/api/userstores/' + userid;

    final storeresponse = await http.get(storeurl);

    if (storeresponse.statusCode == 200) {
      var jsonbody = json.decode(storeresponse.body);
      List<Stores> ites = List<Stores>();
      for (int i = 0; i < jsonbody.length; i++) {
        var approved;
        if (jsonbody[i]['approved'] == null) {
          approved = false;
        } else {
          approved = jsonbody[i]['approved'];
        }

        Stores store = Stores(
            approved: approved,
            storeid: jsonbody[i]['_id']['\$oid'],
            storecategory: jsonbody[i]['storecategory'],
            storelogo: jsonbody[i]['storelogo'],
            storename: jsonbody[i]['storename']);

        ites.add(store);
      }

      ites.add(Stores(
          approved: true,
          storeid: 'createastore',
          storename: 'Create a New Store'));

      setState(() {
        storeslist = ites;

        loading = false;
      });
    } else {
      List<Stores> ites = List<Stores>();
      ites.add(Stores(
          approved: true,
          storeid: 'createastore',
          storename: 'Create a New Store'));

      setState(() {
        storeslist = ites;

        loading = false;
      });
      print(storeresponse.statusCode);
    }

    print(storeslist.length);
  }

  List<Stores> storeslist = List<Stores>();

  getuser() async {
    // await storage.delete(key: 'storeid');
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
        position = positio;
      });
    }
  }

  GlobalKey _toolTipKey = GlobalKey();
  LatLng position;

  Stores _selectedStore;
  String locdetials;
  final businessnameController = TextEditingController();

  final businessdescriptionController = TextEditingController();

  final businessbrandcontroller = TextEditingController();
  final tagscontroller = TextEditingController();
  final businessizecontroller = TextEditingController();

  List<String> tags = List<String>();
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

  Map<String, String> mapconditions = {
    'New':
        'Items that are brand new, never used, with the tags still attached.',
    'Excellent':
        'Used it just once or a few times, has little to no signs of wear',
    'Good': 'Gently used, with signs of wear',
    'Poor': 'Items that might have discoloration, minor damages from use.'
  };

  List<String> conditionssubtitles = [
    'Items that are brand new, never used, with the tags still attached.',
    'Used it just once or a few times, has little to no signs of wear',
    'Gently used, with signs of wear',
    'Items that might have discoloration, minor damages from use.'
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

  var _selectedsize;
  var _selectedcolor;

  bool quantityswitch = false;
  bool acceptoffers = false;

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

  loadbrands(category) async {
    var categoryurl = 'https://api.sellship.co/api/getbrands/' + category;
    final categoryresponse = await http.get(categoryurl);

    if (categoryresponse.statusCode == 200) {
      brands.clear();
      var categoryrespons = json.decode(categoryresponse.body);

      for (int i = 0; i < categoryrespons.length; i++) {
        brands.add(categoryrespons[i]);
      }

      brands.add('Other');

      if (brands == null || brands.isEmpty) {
        brands = ['No Brand', 'Other'];
      }

      setState(() {
        brands = brands.toSet().toList();
      });
    }
  }

  List<Asset> images = List<Asset>();
  Future getImageGallery() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
            takePhotoIcon: "camera", autoCloseOnSelectionLimit: true),
        materialOptions: MaterialOptions(
          autoCloseOnSelectionLimit: true,
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

    await storage.write(key: 'additem', value: 'true');

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
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color.fromRGBO(248, 248, 248, 1),
        appBar: AppBar(
          title: Text(
            "Add an Item",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          elevation: 0.5,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
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
                progressColor: Colors.deepOrange,
              ),
            )),
        body: loading == false
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: userid != null
                    ? EasyRefresh(
                        header: CustomHeader(
                            extent: 40.0,
                            enableHapticFeedback: true,
                            triggerDistance: 50.0,
                            headerBuilder: (context,
                                loadState,
                                pulledExtent,
                                loadTriggerPullDistance,
                                loadIndicatorExtent,
                                axisDirection,
                                float,
                                completeDuration,
                                enableInfiniteLoad,
                                success,
                                noMore) {
                              return SpinKitFadingCircle(
                                color: Colors.deepOrange,
                                size: 30.0,
                              );
                            }),
                        onRefresh: () {
                          setState(() {
                            _selectedStore = null;
                            loading = true;
                          });
                          getuser();
                          return getStoreData();
                        },
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, bottom: 5),
                                      child: Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Store',
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
                                          left: 15,
                                          bottom: 5,
                                          top: 10,
                                          right: 15),
                                      child: Container(
                                        height: 70,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        child: Center(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<Stores>(
                                              isExpanded: true,
                                              hint: Text(
                                                'Choose your Store',
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.blueGrey),
                                              ),
                                              value: _selectedStore,
                                              onChanged: (Stores newValue) {
                                                if (newValue.storeid ==
                                                    'createastore') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreateStoreName()),
                                                  );
                                                }
                                                if (newValue.approved == true) {
                                                  setState(() {
                                                    _selectedStore = newValue;
                                                  });
                                                } else {
                                                  showInSnackBar(
                                                      'Store is still under review. Please wait to start listing items.');
                                                }
                                              },
                                              items: storeslist
                                                  .map((Stores store) {
                                                return new DropdownMenuItem<
                                                    Stores>(
                                                  value: store,
                                                  child: new Text(
                                                    store.storename,
                                                    style: new TextStyle(
                                                        color: store.approved ==
                                                                true
                                                            ? Colors.black
                                                            : Colors.grey,
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, bottom: 5),
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
                                                          color:
                                                              Color(0xFF737373),
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: new BorderRadius
                                                                          .only(
                                                                      topLeft: const Radius
                                                                              .circular(
                                                                          20.0),
                                                                      topRight:
                                                                          const Radius.circular(
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
                                                                        alignment: Alignment.centerLeft,
                                                                        child: InkWell(
                                                                            child: Icon(Icons.clear),
                                                                            onTap: () {
                                                                              Navigator.pop(context);
                                                                            })),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: 15,
                                                                      top: 10,
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Eye-catching photos help sell your item quicker.',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w800),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            15,
                                                                        top: 10,
                                                                        bottom:
                                                                            15),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
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
                                                                          height:
                                                                              195,
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              child: Image.asset(
                                                                                photoguidelinesimages[i],
                                                                                fit: BoxFit.cover,
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
                                                    fontWeight:
                                                        FontWeight.w300),
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
                                            if (await Permission
                                                .Permission.photos
                                                .request()
                                                .isGranted) {
                                              getImageGallery();
                                            } else {
                                              Map<
                                                      Permission.Permission,
                                                      Permission
                                                          .PermissionStatus>
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
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: DottedBorder(
                                                          borderType:
                                                              BorderType.RRect,
                                                          radius:
                                                              Radius.circular(
                                                                  12),
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          dashPattern: [12, 4],
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                          child: ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                              child: Container(
                                                                  color: Colors
                                                                      .white,
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: images.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int position) {
                                                    Asset asset =
                                                        images[position];
                                                    return Stack(children: <
                                                        Widget>[
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 4.0)),
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
                                                          width: 100,
                                                          height: 100,
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
                                                          child: CircleAvatar(
                                                            child: Icon(
                                                              Icons
                                                                  .delete_forever,
                                                              color:
                                                                  Colors.white,
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
                                  ),
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
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 5,
                                        top: 10,
                                        right: 15),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        child: ListTile(
                                            onTap: () async {
                                              final catdetails =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddCategory()),
                                              );
                                              await storage.write(
                                                  key: 'additem',
                                                  value: 'true');
                                              setState(() {
                                                percentindictor = 0.1;
                                                _selectedCategory =
                                                    catdetails['category'];
                                                _selectedsubCategory =
                                                    catdetails['subcategory'];
                                                _selectedsubsubCategory =
                                                    catdetails[
                                                        'subsubcategory'];

                                                loadbrands(_selectedCategory);

                                                categoryinfo =
                                                    _selectedCategory +
                                                        ' > ' +
                                                        _selectedsubCategory +
                                                        ' > ' +
                                                        _selectedsubsubCategory;
                                              });
                                            },
                                            title: categoryinfo == null
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'Choose your Category',
                                                          textAlign:
                                                              TextAlign.right,
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
                                                    ))
                                                : Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          child: Text(
                                                            categoryinfo,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .deepPurple),
                                                          ),
                                                        ),
                                                        Icon(
                                                            Icons
                                                                .keyboard_arrow_right,
                                                            color: Colors
                                                                .deepPurple)
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
                                      child: Text('Product Info',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 5,
                                        top: 10,
                                        right: 15),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
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
                                          left: 15,
                                          bottom: 5,
                                          top: 10,
                                          right: 15),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            cursorColor: Color(0xFF979797),
                                            controller:
                                                businessdescriptionController,
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
                                                          color:
                                                              Color(0xFF737373),
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: new BorderRadius
                                                                          .only(
                                                                      topLeft: const Radius
                                                                              .circular(
                                                                          20.0),
                                                                      topRight:
                                                                          const Radius.circular(
                                                                              20.0))),
                                                              child: ListView(
                                                                children: [
                                                                  Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .warning_rounded,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 150,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: 15,
                                                                      top: 10,
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Attention!',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.w800),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: 15,
                                                                      top: 10,
                                                                      bottom:
                                                                          10,
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Please note purchases are only accepted through the buy option in the app. Adding mobile numbers and asking for payments outside the app is strictly prohibited and is against our community guidelines in order to protect buyer and seller privacy.',
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
                                                                  Padding(
                                                                    child: InkWell(
                                                                        child: Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width - 30,
                                                                          height:
                                                                              50,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.redAccent,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 65.0, offset: Offset(0.0, 15.0))
                                                                              ]),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "I Accept",
                                                                              style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.white, fontWeight: FontWeight.w300),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                    padding: EdgeInsets.only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10,
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
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
                                              hintText:
                                                  "Enter Description here..",
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
                                      left: 15,
                                      bottom: 5,
                                      top: 10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Tags',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 5,
                                          top: 10,
                                          right: 15),
                                      child: Container(
                                          height: tags.isNotEmpty ? 100 : 55,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          child: Column(
                                            children: [
                                              tags.isNotEmpty
                                                  ? Expanded(
                                                      child: ListView.builder(
                                                          itemCount:
                                                              tags.length,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                child:
                                                                    InputChip(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepOrangeAccent,
                                                                  label: Text(
                                                                    tags[index],
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  onDeleted:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      tags.removeAt(
                                                                          index);
                                                                    });
                                                                  },
                                                                ));
                                                          }))
                                                  : Container(),
                                              Expanded(
                                                child: TextField(
                                                  cursorColor:
                                                      Color(0xFF979797),
                                                  controller: tagscontroller,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      tags.add(value);
                                                    });
                                                    tagscontroller.clear();
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "dubaifashion,abudhabilifestyle,topdeals",
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.blueGrey),
                                                    focusColor: Colors.black,
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ))),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 5,
                                          top: 10,
                                          right: 15),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
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
                                              left: 15,
                                              bottom: 5,
                                              top: 10,
                                              right: 15),
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                              ),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 15,
                                                        bottom: 5,
                                                      ),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Quantity of Item',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .blueGrey),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        height: 70,
                                                        width: 130,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.remove),
                                                              iconSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (quantity >
                                                                      0) {
                                                                    quantity =
                                                                        quantity -
                                                                            1;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                            Container(
                                                              width: 25,
                                                              child: Text(
                                                                quantity
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.add),
                                                              iconSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (quantity >=
                                                                      0) {
                                                                    quantity =
                                                                        quantity +
                                                                            1;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ))
                                                  ])))
                                      : Container(),
                                  _selectedCategory != null &&
                                          _selectedCategory != 'Books'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            bottom: 5,
                                            top: 10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Brand',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  _selectedCategory != null &&
                                          _selectedCategory != 'Books'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              bottom: 5,
                                              top: 10,
                                              right: 15),
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
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Brands(
                                                                          brands:
                                                                              brands,
                                                                          category:
                                                                              _selectedCategory,
                                                                        )),
                                                          );
                                                          setState(() {
                                                            brand = bran;

                                                            percentindictor =
                                                                0.6;
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
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      brand,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.deepPurple),
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
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'Choose your Brand',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.blueGrey),
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
                                              left: 15,
                                              bottom: 5,
                                              top: 10,
                                              right: 15),
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
                                                  cursorColor:
                                                      Color(0xFF979797),
                                                  controller:
                                                      businessbrandcontroller,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Other Brand Name",
                                                    alignLabelWithHint: true,
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.blueGrey),
                                                    focusColor: Colors.black,
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                  ),
                                                ),
                                              ))))
                                      : Container(),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _selectedStore != null
                                      ? _selectedStore.storecategory ==
                                              'Secondhand Seller'
                                          ? Padding(
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
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            )
                                          : Container()
                                      : Container(),
                                  _selectedStore != null
                                      ? _selectedStore.storecategory ==
                                              'Secondhand Seller'
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  bottom: 5,
                                                  top: 10,
                                                  right: 15),
                                              child: Container(
                                                height: 90,
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    isDense: true,
                                                    isExpanded: true,
                                                    hint: Text(
                                                      'Condition of Item',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color:
                                                              Colors.blueGrey),
                                                    ),
                                                    value: _selectedcondition,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        _selectedcondition =
                                                            newValue;
                                                        percentindictor = 0.7;
                                                      });
                                                    },
                                                    items: mapconditions
                                                        .map((description,
                                                            value) {
                                                          return MapEntry(
                                                              description,
                                                              DropdownMenuItem(
                                                                child: ListTile(
                                                                  dense: true,
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  title: Text(
                                                                    description,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  subtitle:
                                                                      Text(
                                                                    value,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                value:
                                                                    description,
                                                              ));
                                                        })
                                                        .values
                                                        .toList(),
                                                  ),
                                                ),
                                              ))
                                          : Container()
                                      : Container(),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _selectedsubCategory == 'Activewear & Sportswear' ||
                                          _selectedsubCategory == 'Dresses' ||
                                          _selectedsubCategory ==
                                              'Tops & Blouses' ||
                                          _selectedsubCategory ==
                                              'Coats & Jackets' ||
                                          _selectedsubCategory == 'Sweaters' ||
                                          _selectedsubCategory == 'Shoes' ||
                                          _selectedsubCategory ==
                                              'Modest wear' ||
                                          _selectedsubCategory == 'Jeans' ||
                                          _selectedsubCategory ==
                                              'Suits & Blazers' ||
                                          _selectedsubCategory ==
                                              'Swimwear & Beachwear' ||
                                          _selectedsubCategory == 'Bottoms' ||
                                          _selectedsubCategory == 'Tops' ||
                                          _selectedsubCategory ==
                                              'Girls Dresses' ||
                                          _selectedsubCategory ==
                                              'Girls One-pieces' ||
                                          _selectedsubCategory ==
                                              'Girls Tops & T-shirts' ||
                                          _selectedsubCategory ==
                                              'Girls Bottoms' ||
                                          _selectedsubCategory ==
                                              'Girls Shoes' ||
                                          _selectedsubCategory ==
                                              'Boys Tops & T-shirts' ||
                                          _selectedsubCategory ==
                                              'Boys Bottoms' ||
                                          _selectedsubCategory ==
                                              'Boys One-pieces' ||
                                          _selectedsubCategory ==
                                              'Boys Shoes' ||
                                          _selectedsubCategory == 'Clothing' ||
                                          _selectedsubCategory == 'Shoes'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15, bottom: 5, top: 10),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Size',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  _selectedsubCategory == 'Activewear & Sportswear' ||
                                          _selectedsubCategory == 'Dresses' ||
                                          _selectedsubCategory ==
                                              'Tops & Blouses' ||
                                          _selectedsubCategory ==
                                              'Coats & Jackets' ||
                                          _selectedsubCategory == 'Sweaters' ||
                                          _selectedsubCategory == 'Shoes' ||
                                          _selectedsubCategory ==
                                              'Modest wear' ||
                                          _selectedsubCategory == 'Jeans' ||
                                          _selectedsubCategory ==
                                              'Suits & Blazers' ||
                                          _selectedsubCategory ==
                                              'Swimwear & Beachwear' ||
                                          _selectedsubCategory == 'Bottoms' ||
                                          _selectedsubCategory == 'Tops' ||
                                          _selectedsubCategory ==
                                              'Girls Dresses' ||
                                          _selectedsubCategory ==
                                              'Girls One-pieces' ||
                                          _selectedsubCategory ==
                                              'Girls Tops & T-shirts' ||
                                          _selectedsubCategory ==
                                              'Girls Bottoms' ||
                                          _selectedsubCategory ==
                                              'Girls Shoes' ||
                                          _selectedsubCategory ==
                                              'Boys Tops & T-shirts' ||
                                          _selectedsubCategory ==
                                              'Boys Bottoms' ||
                                          _selectedsubCategory ==
                                              'Boys One-pieces' ||
                                          _selectedsubCategory ==
                                              'Boys Shoes' ||
                                          _selectedsubCategory == 'Clothing' ||
                                          _selectedsubCategory == 'Shoes'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              bottom: 5,
                                              top: 10,
                                              right: 15),
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
                                                          List<String>
                                                              topsizes = [
                                                            'XXS',
                                                            'XS',
                                                            'S',
                                                            'M',
                                                            'L',
                                                            'XL',
                                                            'XXL'
                                                          ];

                                                          List<String>
                                                              bottomsizes = [
                                                            '26',
                                                            '27',
                                                            '28',
                                                            '29',
                                                            '30',
                                                            '31',
                                                            '32',
                                                            '33',
                                                            '34',
                                                            '35',
                                                            '36',
                                                            '37',
                                                            '38',
                                                            '39',
                                                            '40',
                                                            '41',
                                                            '42',
                                                            '43',
                                                            '44'
                                                          ];

                                                          List<String>
                                                              shoesizes = [
                                                            '5',
                                                            '5.5',
                                                            '6',
                                                            '6.5',
                                                            '7',
                                                            '7.5',
                                                            '8',
                                                            '8.5',
                                                            '9',
                                                            '9.5',
                                                            '10',
                                                            '10.5',
                                                            '11',
                                                            '11.5',
                                                            '12',
                                                            '12.5',
                                                            '13',
                                                            '14',
                                                            '15'
                                                          ];

                                                          List<String>
                                                              accessoriessizes =
                                                              [
                                                            'OS',
                                                            '26',
                                                            '28',
                                                            '30',
                                                            '32',
                                                            '34',
                                                            '36',
                                                            '38',
                                                            '40',
                                                            '42',
                                                            '44',
                                                            '46'
                                                          ];

                                                          List<String>
                                                              selectedsize =
                                                              List<String>();

                                                          showModalBottomSheet(
                                                              context: context,
                                                              useRootNavigator:
                                                                  false,
                                                              isScrollControlled:
                                                                  true,
                                                              builder: (_) {
                                                                return DraggableScrollableSheet(
                                                                    expand:
                                                                        false,
                                                                    initialChildSize:
                                                                        0.7,
                                                                    builder: (_,
                                                                        controller) {
                                                                      return StatefulBuilder(
                                                                          // You need this, notice the parameters below:
                                                                          builder:
                                                                              (BuildContext context, StateSetter updateState) {
                                                                        return Container(
                                                                            height:
                                                                                350.0,
                                                                            color:
                                                                                Color(0xFF737373),
                                                                            child: Container(
                                                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                                                decoration: new BoxDecoration(color: Colors.white, borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
                                                                                child: Column(children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
                                                                                            updateState(() {
                                                                                              _selectedsize = selectedsize[0];
                                                                                            });
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.only(right: 15, top: 15, bottom: 5),
                                                                                            child: Text(
                                                                                              "Done",
                                                                                              style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.w300),
                                                                                            ),
                                                                                          ))
                                                                                    ],
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 15, bottom: 15),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        'Choose your Size',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  _selectedsubCategory.contains('Hoodies & Sweatshirts') || _selectedsubCategory.contains('Nightwear & Loungewear') || _selectedsubCategory.contains('Swimwear & Beachwear') || _selectedsubCategory.contains('Tops') || _selectedsubCategory.contains('Activewear & Sportswear') || _selectedsubCategory.contains('Coats & Jackets') || _selectedsubCategory.contains('Dresses') || _selectedsubCategory.contains('Modest wear') || _selectedsubCategory.contains('Tops & Blouses') || _selectedsubCategory.contains('Girls Tops & T-shirts') || _selectedsubCategory.contains('Girls One-pieces') || _selectedsubCategory.contains('Girls Dresses') || _selectedsubCategory.contains('Clothing') || _selectedsubCategory.contains('Boys Tops & T-shirts') || _selectedsubCategory.contains('Girls Tops & T-shirts') || _selectedsubCategory.contains('Girls Dresses') || _selectedsubCategory.contains('Boys One-pieces') || _selectedsubCategory.contains('Girls One-pieces') || _selectedsubCategory.contains('Suits & Blazers') || _selectedsubCategory.contains('Sweaters')
                                                                                      ? Expanded(
                                                                                          child: GridView.builder(
                                                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 5.0, crossAxisSpacing: 5.0, crossAxisCount: 4, childAspectRatio: 1),
                                                                                            itemBuilder: (_, i) {
                                                                                              return Padding(
                                                                                                  padding: EdgeInsets.all(5),
                                                                                                  child: InkWell(
                                                                                                      onTap: () {
                                                                                                        selectedsize.clear();
                                                                                                        updateState(() {
                                                                                                          selectedsize.add(topsizes[i]);
                                                                                                        });
                                                                                                        print(topsizes[i]);
                                                                                                      },
                                                                                                      child: Container(
                                                                                                          height: 100,
                                                                                                          width: MediaQuery.of(context).size.width,
                                                                                                          decoration: BoxDecoration(
                                                                                                              color: selectedsize.contains(topsizes[i]) ? Colors.black : Colors.white,
                                                                                                              border: Border.all(
                                                                                                                color: Colors.grey,
                                                                                                              ),
                                                                                                              borderRadius: BorderRadius.circular(10)),
                                                                                                          child: Center(
                                                                                                              child: Text(
                                                                                                            topsizes[i],
                                                                                                            style: selectedsize.contains(topsizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
                                                                                                          )))));
                                                                                            },
                                                                                            itemCount: topsizes.length,
                                                                                          ),
                                                                                        )
                                                                                      : _selectedsubCategory.contains('Shoes') || _selectedsubCategory.contains('Boys Shoes') || _selectedsubCategory.contains('Girls Shoes')
                                                                                          ? Expanded(
                                                                                              child: GridView.builder(
                                                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 5.0, crossAxisSpacing: 5.0, crossAxisCount: 4, childAspectRatio: 1),
                                                                                                itemBuilder: (_, i) {
                                                                                                  return Padding(
                                                                                                      padding: EdgeInsets.all(5),
                                                                                                      child: InkWell(
                                                                                                          onTap: () {
                                                                                                            selectedsize.clear();
                                                                                                            updateState(() {
                                                                                                              selectedsize.add(shoesizes[i]);
                                                                                                            });
                                                                                                            print(shoesizes[i]);
                                                                                                          },
                                                                                                          child: Container(
                                                                                                              height: 100,
                                                                                                              width: MediaQuery.of(context).size.width,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: selectedsize.contains(shoesizes[i]) ? Colors.black : Colors.white,
                                                                                                                  border: Border.all(
                                                                                                                    color: Colors.grey,
                                                                                                                  ),
                                                                                                                  borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Center(
                                                                                                                  child: Text(
                                                                                                                shoesizes[i],
                                                                                                                style: selectedsize.contains(shoesizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
                                                                                                              )))));
                                                                                                },
                                                                                                itemCount: shoesizes.length,
                                                                                              ),
                                                                                            )
                                                                                          : Expanded(
                                                                                              child: GridView.builder(
                                                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 5.0, crossAxisSpacing: 5.0, crossAxisCount: 4, childAspectRatio: 1),
                                                                                                itemBuilder: (_, i) {
                                                                                                  return Padding(
                                                                                                      padding: EdgeInsets.all(5),
                                                                                                      child: InkWell(
                                                                                                          onTap: () {
                                                                                                            selectedsize.clear();
                                                                                                            updateState(() {
                                                                                                              selectedsize.add(bottomsizes[i]);
                                                                                                            });
                                                                                                            print(bottomsizes[i]);
                                                                                                          },
                                                                                                          child: Container(
                                                                                                              height: 100,
                                                                                                              width: MediaQuery.of(context).size.width,
                                                                                                              decoration: BoxDecoration(
                                                                                                                  color: selectedsize.contains(bottomsizes[i]) ? Colors.black : Colors.white,
                                                                                                                  border: Border.all(
                                                                                                                    color: Colors.grey,
                                                                                                                  ),
                                                                                                                  borderRadius: BorderRadius.circular(10)),
                                                                                                              child: Center(
                                                                                                                  child: Text(
                                                                                                                bottomsizes[i],
                                                                                                                style: selectedsize.contains(bottomsizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
                                                                                                              )))));
                                                                                                },
                                                                                                itemCount: bottomsizes.length,
                                                                                              ),
                                                                                            ),
                                                                                ])));
                                                                      });
                                                                    });
                                                              });
                                                        },
                                                        child: Container(
                                                            width: 200,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                _selectedsize !=
                                                                        null
                                                                    ? Text(
                                                                        'Size - ' +
                                                                            _selectedsize,
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.blueGrey),
                                                                      )
                                                                    : Text(
                                                                        'Choose your Size',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.blueGrey),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _selectedCategory == 'Women' ||
                                          _selectedCategory == 'Men' ||
                                          _selectedCategory == 'Kids' ||
                                          _selectedCategory == 'Luxury'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15, bottom: 5, top: 10),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Color',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  _selectedCategory == 'Women' ||
                                          _selectedCategory == 'Men' ||
                                          _selectedCategory == 'Kids' ||
                                          _selectedCategory == 'Luxury'
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              bottom: 5,
                                              top: 10,
                                              right: 15),
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
                                                          showModalBottomSheet(
                                                              context: context,
                                                              useRootNavigator:
                                                                  false,
                                                              isScrollControlled:
                                                                  true,
                                                              builder: (_) {
                                                                return DraggableScrollableSheet(
                                                                    expand:
                                                                        false,
                                                                    initialChildSize:
                                                                        0.7,
                                                                    builder: (_,
                                                                        controller) {
                                                                      return StatefulBuilder(
                                                                          // You need this, notice the parameters below:
                                                                          builder:
                                                                              (BuildContext context, StateSetter updateState) {
                                                                        return Container(
                                                                            height:
                                                                                350.0,
                                                                            color:
                                                                                Color(0xFF737373),
                                                                            child: Container(
                                                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                                                decoration: new BoxDecoration(color: Colors.white, borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
                                                                                child: Column(children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.only(right: 15, top: 15, bottom: 5),
                                                                                            child: Text(
                                                                                              "Done",
                                                                                              style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.w300),
                                                                                            ),
                                                                                          ))
                                                                                    ],
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 15, bottom: 15),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        'Choose your Color',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: GridView.builder(
                                                                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 5.0, crossAxisSpacing: 5.0, crossAxisCount: 4, childAspectRatio: 1.3),
                                                                                      itemBuilder: (_, i) {
                                                                                        return Padding(
                                                                                            padding: EdgeInsets.all(5),
                                                                                            child: InkWell(
                                                                                              onTap: () {
                                                                                                if (selectedColors.length > 3) {
                                                                                                  selectedColors.removeAt(0);
                                                                                                  selectedColors.add(colorslist[i]);
                                                                                                } else if (selectedColors.contains(colorslist[i])) {
                                                                                                  selectedColors.remove(colorslist[i]);
                                                                                                } else {
                                                                                                  selectedColors.add(colorslist[i]);
                                                                                                }
                                                                                                updateState(() {
                                                                                                  selectedColors = selectedColors;
                                                                                                });
                                                                                              },
                                                                                              child: Container(
                                                                                                  height: 30,
                                                                                                  width: 30,
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                    border: Border.all(
                                                                                                      color: Colors.grey.shade300,
                                                                                                    ),
                                                                                                    color: colorslist[i],
                                                                                                  ),
                                                                                                  child: selectedColors.contains(colorslist[i])
                                                                                                      ? CircleAvatar(
                                                                                                          radius: 18,
                                                                                                          backgroundColor: Colors.black12,
                                                                                                          child: Icon(
                                                                                                            Icons.check,
                                                                                                            color: Colors.white,
                                                                                                          ))
                                                                                                      : Container()),
                                                                                            ));
                                                                                      },
                                                                                      itemCount: colorslist.length,
                                                                                    ),
                                                                                  )
                                                                                ])));
                                                                      });
                                                                    });
                                                              });
                                                        },
                                                        child: Container(
                                                            width: 200,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                selectedColors !=
                                                                        null
                                                                    ? Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                              height: 30,
                                                                              width: 200,
                                                                              child: ListView.builder(
                                                                                scrollDirection: Axis.horizontal,
                                                                                itemCount: selectedColors.length,
                                                                                itemBuilder: (context, index) {
                                                                                  return Container(
                                                                                      height: 30,
                                                                                      width: 30,
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        border: Border.all(
                                                                                          color: Colors.grey.shade300,
                                                                                        ),
                                                                                        color: selectedColors[index],
                                                                                      ));
                                                                                },
                                                                              ))
                                                                        ],
                                                                      )
                                                                    : Text(
                                                                        'Choose your Color',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.blueGrey),
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
                                  SizedBox(height: 10),
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
                                        left: 15,
                                        bottom: 20,
                                        top: 4,
                                        right: 15),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 70,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
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
                                                        itemweight = int.parse(
                                                            weights[position]);
                                                      });
                                                    },
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 0.2,
                                                              color:
                                                                  Colors.grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          color: _selectedweight ==
                                                                  position
                                                              ? Colors
                                                                  .deepOrangeAccent
                                                              : Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              offset: Offset(
                                                                  0.0,
                                                                  1.0), //(x,y)
                                                              blurRadius: 6.0,
                                                            ),
                                                          ],
                                                        ),
                                                        width: 80,
                                                        height: 10,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '< ' +
                                                                  weights[
                                                                      position] +
                                                                  ' ' +
                                                                  metric,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 14,
                                                                color: _selectedweight ==
                                                                        position
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ))));
                                          }),
                                    ),
                                  ),
                                  _selectedStore != null
                                      ? _selectedStore.storecategory ==
                                              'Secondhand Seller'
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  bottom: 5,
                                                  top: 10,
                                                  right: 15),
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child: SwitchListTile(
                                                  value: acceptoffers,
                                                  activeColor:
                                                      Colors.deepPurple,
                                                  title: Text(
                                                    'Accept offers from buyers?',
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.blueGrey),
                                                  ),
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    acceptoffers = value;
                                                  }),
                                                ),
                                              ))
                                          : Container()
                                      : Container(),
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
                                        left: 15,
                                        bottom: 5,
                                        top: 10,
                                        right: 15),
                                    child: Container(
                                      height: 85,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: TextField(
                                                  cursorColor:
                                                      Color(0xFF979797),
                                                  controller:
                                                      businesspricecontroller,
                                                  onChanged: (text) async {
                                                    await storage.write(
                                                        key: 'additem',
                                                        value: 'true');
                                                    var weightfees;
                                                    if (_selectedweight == 0) {
                                                      weightfees = 20;
                                                    } else if (_selectedweight ==
                                                        1) {
                                                      weightfees = 30;
                                                    } else if (_selectedweight ==
                                                        2) {
                                                      weightfees = 50;
                                                    } else if (_selectedweight ==
                                                        3) {
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
                                                        var s = (int.parse(
                                                                businesspricecontroller
                                                                    .text) +
                                                            weightfees);
                                                        s = s * 0.15;
                                                        fees = int.parse(
                                                                businesspricecontroller
                                                                    .text) +
                                                            weightfees +
                                                            s;
                                                      }
                                                    } else {
                                                      var s = (int.parse(
                                                              businesspricecontroller
                                                                  .text) +
                                                          weightfees);
                                                      s = s * 0.15;
                                                      fees = int.parse(
                                                              businesspricecontroller
                                                                  .text) +
                                                          weightfees +
                                                          s;
                                                    }

                                                    setState(() {
                                                      totalpayable =
                                                          totalpayable;
                                                      fees = fees;

                                                      percentindictor = 0.8;
                                                    });
                                                  },
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(),
                                                  decoration: InputDecoration(
                                                    hintText: '0',
//                                                alignLabelWithHint: true,
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    focusColor: Colors.black,
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                  ),
                                                ),
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
                                      ? GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                useRootNavigator: false,
                                                isScrollControlled: true,
                                                builder: (_) {
                                                  return DraggableScrollableSheet(
                                                      expand: false,
                                                      initialChildSize: 0.3,
                                                      builder: (_, controller) {
                                                        return Container(
                                                            height: 100.0,
                                                            color: Color(
                                                                0xFF737373),
                                                            child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            20),
                                                                decoration: new BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius: new BorderRadius
                                                                            .only(
                                                                        topLeft:
                                                                            const Radius.circular(
                                                                                20.0),
                                                                        topRight:
                                                                            const Radius.circular(
                                                                                20.0))),
                                                                child: Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Padding(
                                                                                padding: EdgeInsets.only(right: 15, bottom: 10),
                                                                                child: Text(
                                                                                  "Done",
                                                                                  style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.w300),
                                                                                ),
                                                                              ))
                                                                        ],
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                      ),
                                                                      Text(
                                                                        'SellShip Listing Protection & Pricing',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        'The SellShip listing protection and pricing helps us offer you 24/7 support, cover the transaction fees, free delivery and protect you as a seller. Also covering Buyers to be provided free delivery and protection throughout all their purchases on SellShip',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      )
                                                                    ])));
                                                      });
                                                });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 15, top: 2, right: 15),
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15)),
                                              ),
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              'Listing Price',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Icon(
                                                              FontAwesome5
                                                                  .question_circle,
                                                              size: 15,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        currency +
                                                            ' ' +
                                                            fees.toStringAsFixed(
                                                                2),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          ))
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
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15)),
                                            ),
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
                                                          fontFamily:
                                                              'Helvetica',
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
                                                          fontFamily:
                                                              'Helvetica',
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
                                        left: 15,
                                        bottom: 5,
                                        top: 10,
                                        right: 15),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
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
                                                percentindictor = 1;
                                                city = locationdetails['city'];
                                                country =
                                                    locationdetails['country'];
                                                _lastMapPosition =
                                                    locationdetails[
                                                        'lastmapposition'];

                                                locdetials =
                                                    country + ' > ' + city;
                                              });
                                            },
                                            title: locdetials == null
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          'Choose your Location',
                                                          textAlign:
                                                              TextAlign.right,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2 +
                                                            50,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          child: Text(
                                                            locdetials,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .deepPurple),
                                                          ),
                                                        ),
                                                        Icon(
                                                            Icons
                                                                .keyboard_arrow_right,
                                                            color: Colors
                                                                .deepPurple)
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
                                          if (_selectedStore.storecategory !=
                                              'Secondhand Seller') {
                                            _selectedCondition = 'New';
                                            acceptoffers = false;
                                          }

                                          if (_selectedStore == null) {
                                            showInSnackBar(
                                                'Please choose your store');
                                          } else if (images.isEmpty) {
                                            showInSnackBar(
                                                'Please upload a picture for your item!');
                                          } else if (businessnameController
                                              .text.isEmpty) {
                                            showInSnackBar(
                                                'Oops looks like your missing a title for your item!');
                                          } else if (_selectedCategory ==
                                              null) {
                                            showInSnackBar(
                                                'Please choose a category for your item!');
                                          } else if (_selectedsubCategory ==
                                              null) {
                                            showInSnackBar(
                                                'Please choose a sub category for your item!');
                                          } else if (_selectedCondition ==
                                              null) {
                                            showInSnackBar(
                                                'Please choose the condition of your item!');
                                          } else if (businesspricecontroller
                                              .text.isEmpty) {
                                            showInSnackBar(
                                                'Oops looks like your missing a price for your item!');
                                          } else if (_selectedsize == null &&
                                              (_selectedsubCategory ==
                                                      'Activewear & Sportswear' ||
                                                  _selectedsubCategory ==
                                                      'Dresses' ||
                                                  _selectedsubCategory ==
                                                      'Tops & Blouses' ||
                                                  _selectedsubCategory ==
                                                      'Coats & Jackets' ||
                                                  _selectedsubCategory ==
                                                      'Sweaters' ||
                                                  _selectedsubCategory ==
                                                      'Shoes' ||
                                                  _selectedsubCategory ==
                                                      'Modest wear' ||
                                                  _selectedsubCategory ==
                                                      'Jeans' ||
                                                  _selectedsubCategory ==
                                                      'Suits & Blazers' ||
                                                  _selectedsubCategory ==
                                                      'Swimwear & Beachwear' ||
                                                  _selectedsubCategory ==
                                                      'Bottoms' ||
                                                  _selectedsubCategory ==
                                                      'Tops' ||
                                                  _selectedsubCategory ==
                                                      'Girls Dresses' ||
                                                  _selectedsubCategory ==
                                                      'Girls One-pieces' ||
                                                  _selectedsubCategory ==
                                                      'Girls Tops & T-shirts' ||
                                                  _selectedsubCategory ==
                                                      'Girls Bottoms' ||
                                                  _selectedsubCategory ==
                                                      'Girls Shoes' ||
                                                  _selectedsubCategory ==
                                                      'Boys Tops & T-shirts' ||
                                                  _selectedsubCategory ==
                                                      'Boys Bottoms' ||
                                                  _selectedsubCategory ==
                                                      'Boys One-pieces' ||
                                                  _selectedsubCategory ==
                                                      'Boys Shoes' ||
                                                  _selectedsubCategory ==
                                                      'Clothing' ||
                                                  _selectedsubCategory ==
                                                      'Shoes')) {
                                            showInSnackBar(
                                                'Please choose the size for your item!');
                                          } else if (_selectedweight == -1) {
                                            showInSnackBar(
                                                'Please choose the weight of your item');
                                          } else if (city == null ||
                                              country == null) {
                                            showInSnackBar(
                                                'Please choose the location of your item on the map!');
                                          } else {
                                            if (businessdescriptionController
                                                .text.isEmpty) {
                                              businessdescriptionController
                                                  .text = '';
                                            }

                                            String bran;
                                            if (brand == 'Other') {
                                              if (businessbrandcontroller !=
                                                  null) {
                                                String brandcontrollertext =
                                                    businessbrandcontroller.text
                                                        .trim();
                                                if (brandcontrollertext
                                                    .isNotEmpty) {
                                                  bran = businessbrandcontroller
                                                      .text;
                                                }
                                              } else if (businessbrandcontroller ==
                                                      null &&
                                                  _selectedCategory !=
                                                      'Books') {
                                                showInSnackBar(
                                                    'Please choose a brand for your item!');
                                              } else if (businessbrandcontroller ==
                                                      null &&
                                                  _selectedCategory ==
                                                      'Books') {
                                                bran = '';
                                              }
                                            } else {
                                              bran = brand;
                                            }

                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                useRootNavigator: false,
                                                builder: (_) => new AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      10.0))),
                                                      content: Builder(
                                                        builder: (context) {
                                                          return Container(
                                                              height: 140,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Uploading Item.. Please hold on! Large images might take longer than expected.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      child:
                                                                          SpinKitDoubleBounce(
                                                                        color: Colors
                                                                            .deepOrange,
                                                                      )),
                                                                ],
                                                              ));
                                                        },
                                                      ),
                                                    ));

                                            var userurl =
                                                'https://api.sellship.co/api/user/' +
                                                    userid;
                                            final userresponse =
                                                await http.get(userurl);
                                            if (userresponse.statusCode ==
                                                200) {
                                              var userrespons = json
                                                  .decode(userresponse.body);
                                              var profilemap = userrespons;

                                              if (profilemap['username'] ==
                                                  null) {
                                                firstname =
                                                    profilemap['first_name'];
                                              } else {
                                                firstname =
                                                    profilemap['username'];
                                              }
                                              setState(() {
                                                firstname = firstname;
                                                phonenumber =
                                                    profilemap['phonenumber'];
                                                email = profilemap['email'];
                                              });

                                              print('I am here');

                                              List<int> _image;
                                              List<int> _image2;
                                              List<int> _image3;
                                              List<int> _image4;
                                              List<int> _image5;
                                              List<int> _image6;

                                              if (images.length == 1) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();
                                              } else if (images.length == 2) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();

                                                ByteData byteData2 =
                                                    await images[1].getByteData(
                                                        quality: 40);
                                                _image2 = byteData2.buffer
                                                    .asUint8List();
                                              } else if (images.length == 3) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();

                                                ByteData byteData2 =
                                                    await images[1].getByteData(
                                                        quality: 40);
                                                _image2 = byteData2.buffer
                                                    .asUint8List();

                                                ByteData byteData3 =
                                                    await images[2].getByteData(
                                                        quality: 40);
                                                _image3 = byteData3.buffer
                                                    .asUint8List();
                                              } else if (images.length == 4) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();

                                                ByteData byteData2 =
                                                    await images[1].getByteData(
                                                        quality: 40);
                                                _image2 = byteData2.buffer
                                                    .asUint8List();

                                                ByteData byteData3 =
                                                    await images[2].getByteData(
                                                        quality: 40);
                                                _image3 = byteData3.buffer
                                                    .asUint8List();

                                                ByteData byteData4 =
                                                    await images[3].getByteData(
                                                        quality: 40);
                                                _image4 = byteData4.buffer
                                                    .asUint8List();
                                              } else if (images.length == 5) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();

                                                ByteData byteData2 =
                                                    await images[1].getByteData(
                                                        quality: 40);
                                                _image2 = byteData2.buffer
                                                    .asUint8List();

                                                ByteData byteData3 =
                                                    await images[2].getByteData(
                                                        quality: 40);
                                                _image3 = byteData3.buffer
                                                    .asUint8List();

                                                ByteData byteData4 =
                                                    await images[3].getByteData(
                                                        quality: 40);
                                                _image4 = byteData4.buffer
                                                    .asUint8List();

                                                ByteData byteData5 =
                                                    await images[4].getByteData(
                                                        quality: 40);
                                                _image5 = byteData5.buffer
                                                    .asUint8List();
                                              } else if (images.length == 6) {
                                                ByteData byteData =
                                                    await images[0].getByteData(
                                                        quality: 40);
                                                _image = byteData.buffer
                                                    .asUint8List();

                                                ByteData byteData2 =
                                                    await images[1].getByteData(
                                                        quality: 40);
                                                _image2 = byteData2.buffer
                                                    .asUint8List();

                                                ByteData byteData3 =
                                                    await images[2].getByteData(
                                                        quality: 40);
                                                _image3 = byteData3.buffer
                                                    .asUint8List();

                                                ByteData byteData4 =
                                                    await images[3].getByteData(
                                                        quality: 40);
                                                _image4 = byteData4.buffer
                                                    .asUint8List();

                                                ByteData byteData5 =
                                                    await images[4].getByteData(
                                                        quality: 40);
                                                _image5 = byteData5.buffer
                                                    .asUint8List();

                                                ByteData byteData6 =
                                                    await images[5].getByteData(
                                                        quality: 40);
                                                _image6 = byteData6.buffer
                                                    .asUint8List();
                                              }

                                              Dio dio = new Dio();
                                              FormData formData;

                                              if (_image != null) {
                                                String fileName =
                                                    randomAlphaNumeric(20);

                                                formData = FormData.fromMap({
                                                  'name': businessnameController
                                                      .text,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
                                                  'category': _selectedCategory,
                                                  'subcategory':
                                                      _selectedsubCategory,
                                                  'subsubcategory':
                                                      _selectedsubsubCategory ==
                                                              null
                                                          ? ''
                                                          : _selectedsubsubCategory,
                                                  'acceptoffers': acceptoffers,
                                                  'latitude':
                                                      _lastMapPosition.latitude,
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
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
                                                  'name': businessnameController
                                                      .text,
                                                  'acceptoffers': acceptoffers,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
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
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
                                                          _image,
                                                          filename: fileName),
                                                  'image2':
                                                      MultipartFile.fromBytes(
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
                                                  'name': businessnameController
                                                      .text,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'acceptoffers': acceptoffers,
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
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
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
                                                          _image,
                                                          filename: fileName),
                                                  'image2':
                                                      MultipartFile.fromBytes(
                                                          _image2,
                                                          filename: fileName2),
                                                  'image3':
                                                      MultipartFile.fromBytes(
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
                                                  'name': businessnameController
                                                      .text,
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'acceptoffers': acceptoffers,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
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
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
                                                          _image,
                                                          filename: fileName),
                                                  'image2':
                                                      MultipartFile.fromBytes(
                                                          _image2,
                                                          filename: fileName2),
                                                  'image3':
                                                      MultipartFile.fromBytes(
                                                          _image3,
                                                          filename: fileName3),
                                                  'image4':
                                                      MultipartFile.fromBytes(
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
                                                  'name': businessnameController
                                                      .text,
                                                  'acceptoffers': acceptoffers,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
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
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
                                                          _image,
                                                          filename: fileName),
                                                  'image2':
                                                      MultipartFile.fromBytes(
                                                          _image2,
                                                          filename: fileName2),
                                                  'image3':
                                                      MultipartFile.fromBytes(
                                                          _image3,
                                                          filename: fileName3),
                                                  'image4':
                                                      MultipartFile.fromBytes(
                                                          _image4,
                                                          filename: fileName4),
                                                  'image5':
                                                      MultipartFile.fromBytes(
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
                                                  'name': businessnameController
                                                      .text,
                                                  'price':
                                                      fees.toStringAsFixed(2),
                                                  'storeid':
                                                      _selectedStore.storeid,
                                                  'originalprice':
                                                      businesspricecontroller
                                                          .text
                                                          .toString(),
                                                  'colors':
                                                      selectedColors.isEmpty
                                                          ? []
                                                          : {selectedColors},
                                                  'size': _selectedsize == null
                                                      ? ''
                                                      : _selectedsize,
                                                  'selleruserid': userid,
                                                  'sellerusername': firstname,
                                                  'tags': tags.isEmpty
                                                      ? []
                                                      : {tags},
                                                  'category': _selectedCategory,
                                                  'acceptoffers': acceptoffers,
                                                  'subcategory':
                                                      _selectedsubCategory,
                                                  'subsubcategory':
                                                      _selectedsubsubCategory ==
                                                              null
                                                          ? ''
                                                          : _selectedsubsubCategory,
                                                  'latitude':
                                                      _lastMapPosition.latitude,
                                                  'longitude': _lastMapPosition
                                                      .longitude,
                                                  'description':
                                                      businessdescriptionController
                                                          .text,
                                                  'city': city.trim(),
                                                  'country': country.trim(),
                                                  'condition':
                                                      _selectedCondition,
                                                  'brand': bran,
                                                  'userid':
                                                      _selectedStore.storeid,
                                                  'username':
                                                      _selectedStore.storename,
                                                  'useremail': email,
                                                  'usernumber': phonenumber,
                                                  'weight': itemweight,
                                                  'weightmetric': metric,
                                                  'quantity': quantity,
                                                  'date_uploaded':
                                                      DateTime.now().toString(),
                                                  'image':
                                                      MultipartFile.fromBytes(
                                                          _image,
                                                          filename: fileName),
                                                  'image2':
                                                      MultipartFile.fromBytes(
                                                          _image2,
                                                          filename: fileName2),
                                                  'image3':
                                                      MultipartFile.fromBytes(
                                                          _image3,
                                                          filename: fileName3),
                                                  'image4':
                                                      MultipartFile.fromBytes(
                                                          _image4,
                                                          filename: fileName4),
                                                  'image5':
                                                      MultipartFile.fromBytes(
                                                          _image5,
                                                          filename: fileName5),
                                                  'image6':
                                                      MultipartFile.fromBytes(
                                                          _image6,
                                                          filename: fileName6),
                                                });
                                              }

                                              print('Ue');

                                              var addurl =
                                                  'https://api.sellship.co/api/additem';
                                              var response = await dio
                                                  .post(addurl, data: formData);
                                              print(response.data);
                                              print(response.statusCode);

                                              if (response.statusCode == 200) {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    useRootNavigator: false,
                                                    builder:
                                                        (_) => new AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10.0))),
                                                              content: Builder(
                                                                builder:
                                                                    (context) {
                                                                  return Container(
                                                                      height:
                                                                          280,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                150,
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              child: Image.asset(
                                                                                'assets/yay.gif',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            'Hooray! Your Item has been send for review! We will keep you updated when the Item has been approved!',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 16,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              width: MediaQuery.of(context).size.width - 30,
                                                                              height: 50,
                                                                              decoration: BoxDecoration(color: Color.fromRGBO(255, 115, 0, 1), borderRadius: BorderRadius.circular(10), boxShadow: [
                                                                                BoxShadow(color: Color(0xFF9DA3B4).withOpacity(0.1), blurRadius: 65.0, offset: Offset(0.0, 15.0))
                                                                              ]),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Close",
                                                                                  style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);

                                                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootScreen()));
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ));
                                                                },
                                                              ),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  255, 115, 0, 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                    )
                                  : Text(''),
                            ),
                            SliverToBoxAdapter(
                                child: SizedBox(
                              height: 20,
                            ))
                          ],
                        ))
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
                                'Please Login to \n Login to Start Selling',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: Image.asset(
                              'assets/little_theologians_4x.png',
                              fit: BoxFit.fitWidth,
                            ))
                          ],
                        ),
                      ))
            : Center(
                child: SpinKitDoubleBounce(
                color: Colors.deepOrange,
              )));
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
            fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 1),
    ));
  }

  String userid;

  var firstname;
  var email;
  var phonenumber;
}
