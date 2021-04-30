import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/addlocation.dart';
import 'package:SellShip/screens/home.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:random_string/random_string.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as Location;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;

class EditItem extends StatefulWidget {
  final String itemid;
  final String itemname;

  EditItem({Key key, this.itemid, this.itemname}) : super(key: key);

  @override
  EditItemState createState() => EditItemState();
}

class EditItemState extends State<EditItem>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  String itemid;

  var loading;

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

  String _selectedCondition = 'Like new';

  String _selectedsubCategory;
  String _selectedsubsubCategory;

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

  double percentindictor = 0.0;

  var fees;

  List<String> brands = List<String>();

  int itemweight;

  String categoryinfo;

  LatLng position;

  String locdetials;
  final businessnameController = TextEditingController();

  final businessdescriptionController = TextEditingController();

  final businessbrandcontroller = TextEditingController();
  final tagscontroller = TextEditingController();
  final businessizecontroller = TextEditingController();

  List<String> tags = List<String>();

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

  @override
  void initState() {
    super.initState();
    setState(() {
      itemid = widget.itemid;
      loading = true;
    });
    getProfileData();
  }

  Future getImage() async {
    var images = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      image = images;
    });
  }

  List<String> weights = [
    '5',
    '10',
    '20',
    '50',
  ];

  int quantity = 1;

  var _selectedsize;
  var _selectedcolor;

  bool quantityswitch = false;

  int _selectedweight = -1;

  String _selectedcondition;

  double totalpayable;

  final storage = new FlutterSecureStorage();

  var itemname;
  var itemdescription;
  var itemprice;
  var itemimage;
  List<String> selectedSizes = List<String>();

  var userid;
  File image;

  void getProfileData() async {
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

    var url = 'https://api.sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      imagesList.clear();
      var jsonbody = json.decode(response.body);

      var sfs = jsonbody[0]['size'];

      if (sfs == null || sfs.isEmpty) {
        sfs = [];
      } else {
        sfs = jsonbody[0]['size'].substring(2, jsonbody[0]['size'].length - 2);
        sfs = sfs.split(',');
      }

      // var col = jsonbody[0]['colors'];
      //
      // if (col == null || col.isEmpty) {
      //   col = [];
      // } else {
      //   col = jsonbody[0]['colors']
      //       .substring(2, jsonbody[0]['colors'].length - 2);
      //   col = sfs.split(',');
      // }

      newItem = Item(
          name: jsonbody[0]['name'],
          itemid: jsonbody[0]['_id']['\$oid'].toString(),
          price: jsonbody[0]['price'].toString(),
          description: jsonbody[0]['description'],
          category: jsonbody[0]['category'],
          condition: jsonbody[0]['condition'] == null
              ? 'New'
              : jsonbody[0]['condition'],
          image: jsonbody[0]['image'],
          image1: jsonbody[0]['image1'],
          country: jsonbody[0]['country'],
          image2: jsonbody[0]['image2'],
          image3: jsonbody[0]['image3'],
          image4: jsonbody[0]['image4'],
          image5: jsonbody[0]['image5'],
          sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
          likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
          city: jsonbody[0]['city'],
          username: jsonbody[0]['username'],
          brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
          size: sfs,
          useremail: jsonbody[0]['useremail'],
          tags: jsonbody[0]['tags'],
          quantity: int.parse(jsonbody[0]['quantity']),
          usernumber: jsonbody[0]['usernumber'],
          userid: jsonbody[0]['userid'],
          latitude: jsonbody[0]['latitude'],
          comments: jsonbody[0]['comments'] == null
              ? 0
              : jsonbody[0]['comments'].length,
          longitude: jsonbody[0]['longitude'],
          weight: jsonbody[0]['weight'].toString(),
          subsubcategory: jsonbody[0]['subsubcategory'],
          subcategory: jsonbody[0]['subcategory']);

      if (newItem.image != null) {
        imagesList.add(newItem.image);
      }
      if (newItem.image1 != null) {
        imagesList.add(newItem.image1);
      }
      if (newItem.image2 != null) {
        imagesList.add(newItem.image2);
      }
      if (newItem.image3 != null) {
        imagesList.add(newItem.image3);
      }
      if (newItem.image4 != null) {
        imagesList.add(newItem.image4);
      }
      if (newItem.image5 != null) {
        imagesList.add(newItem.image5);
      }

      imagesList.add('upload');
      double weightfees;

      if (mounted) {
        setState(() {
          newItem = newItem;
          _selectedcondition = newItem.condition;
          _selectedCategory = newItem.category;
          _selectedsubCategory = newItem.subcategory;
          _selectedsubsubCategory = newItem.subsubcategory;
          loadbrands(_selectedCategory);
          businessnameController.text = newItem.name;
          brand = newItem.brand;
          businessdescriptionController.text = newItem.description;
          firstname = newItem.username;
          email = newItem.useremail;
          phonenumber = newItem.usernumber;

          print(newItem.size);
          // selectedSizes = newItem.size;
          //
          newItem.quantity > 1 ? quantityswitch = true : quantityswitch = false;
          //
          buyerprotection =
              jsonbody[0]['buyerprotection'] == 'true' ? true : false;
          freedelivery = jsonbody[0]['freedelivery'] == 'true' ? true : false;
          acceptoffers = jsonbody[0]['acceptoffers'] == 'true' ? true : false;
          quantity = newItem.quantity;

          _lastMapPosition = LatLng(
              double.parse(newItem.latitude), double.parse(newItem.longitude));
          print(newItem.weight);
          _selectedweight = weights.indexOf(newItem.weight.toString());
          itemweight = int.parse((newItem.weight.toString()));

          if (freedelivery == true) {
            var weightfees;
            if (_selectedweight == 0) {
              weightfees = 20.0;
            } else if (_selectedweight == 1) {
              weightfees = 30.0;
            } else if (_selectedweight == 2) {
              weightfees = 50.0;
            } else if (_selectedweight == 3) {
              weightfees = 110.0;
            }

            var ffees = double.parse(newItem.price.toString()) / 1.15;
            totalpayable = ffees - weightfees;
            businesspricecontroller.text = totalpayable.toStringAsFixed(2);
            ourfees = (totalpayable + weightfees) * 0.15;
            fees = double.parse(newItem.price);
            weightfee = weightfees;
          } else {
            var ffees = double.parse(newItem.price.toString()) / 1.15;
            totalpayable = ffees;
            businesspricecontroller.text = totalpayable.toStringAsFixed(2);
            ourfees = (totalpayable) * 0.15;
            fees = double.parse(newItem.price);
            weightfee = 0;
          }

          city = newItem.city;

          country = newItem.country;

          locdetials = country + ' > ' + city;

          categoryinfo = _selectedCategory +
              ' > ' +
              _selectedsubCategory +
              ' > ' +
              _selectedsubsubCategory;
          imagesList = imagesList;
          loading = false;
        });
        userid = await storage.read(key: 'userid');
        setState(() {
          userid = userid;
        });
      }
    } else {
      print('Error');
    }
  }

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
    Colors.redAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.brown,
    Colors.indigo,
  ];

  List<Color> selectedColors = List<Color>();

  List<String> imagesList = List<String>();

  Item newItem;
  var currency;
  var metric;

  var buyerprotection;
  var acceptoffers;
  var freedelivery;
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

  TextEditingController firstnamecontr = TextEditingController();
  TextEditingController lastnamecontr = TextEditingController();
  TextEditingController emailnamecontr = TextEditingController();
  TextEditingController phonenamecontr = TextEditingController();
  var brand;

  var firstname;
  var email;
  var phonenumber;

  final businesspricecontroller = TextEditingController();

  calculateearning() async {
    if (freedelivery == true) {
      await storage.write(key: 'additem', value: 'true');
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

      var s;

      if (double.parse(businesspricecontroller.text.toString()) < 20) {
        if (double.parse(businesspricecontroller.text.toString()) <= 0) {
          fees = 0;
        } else {
          s = (double.parse(businesspricecontroller.text.toString()) +
              weightfees);
          s = s * 0.15;
          fees = double.parse(businesspricecontroller.text.toString()) +
              weightfees +
              s;
        }
      } else {
        s = (double.parse(businesspricecontroller.text.toString()) +
            weightfees);
        s = s * 0.15;
        fees = double.parse(businesspricecontroller.text.toString()) +
            weightfees +
            s;
      }

      setState(() {
        totalpayable = totalpayable;
        fees = fees;
        ourfees = s;
        weightfee = weightfees;
        percentindictor = 0.8;
      });
    } else {
      var s = (double.parse(businesspricecontroller.text));
      s = s * 0.15;
      fees = double.parse(businesspricecontroller.text) + s;
      setState(() {
        fees = fees;
        ourfees = s;
        weightfee = 0;
        percentindictor = 0.8;
      });
    }
  }

  var weightfee;

  var ourfees;

  @override
  void dispose() {
    businessnameController.dispose();
    businesspricecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Edit ' + widget.itemname,
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Feather.arrow_left,
            color: Colors.black,
          ),
        ),
      ),
      body: loading == false
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: CustomScrollView(slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                      height: 229,
                      child: Column(children: <Widget>[
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
                                                            topLeft: const Radius
                                                                .circular(20.0),
                                                            topRight: const Radius
                                                                    .circular(
                                                                20.0))),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 15,
                                                            top: 10,
                                                          ),
                                                          child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: InkWell(
                                                                  child: Icon(
                                                                      Icons
                                                                          .clear),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  })),
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
                                                              'Eye-catching photos help sell your item quicker.',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
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
                                                                  bottom: 15),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Check out some of our favorites!',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              GridView.builder(
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
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                15),
                                                                        child: Image
                                                                            .asset(
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
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imagesList.length,
                                        itemBuilder: (BuildContext context,
                                            int position) {
                                          return Stack(children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 4.0)),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      imagesList[position],
                                                      width: 300,
                                                      height: 300,
                                                      fit: BoxFit.cover,
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
                                                    imagesList
                                                        .removeAt(position);
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  radius: 14,
                                                ),
                                              ),
                                            ),
                                          ]);
                                        })
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
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 4.0)),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    images.removeAt(position);
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  radius: 14,
                                                ),
                                              ),
                                            ),
                                          ]);
                                        })),
                          ),
                        ),
                      ])),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 15,
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
                                        builder: (context) => AddCategory()),
                                  );

                                  setState(() {
                                    percentindictor = 0.1;
                                    _selectedCategory = catdetails['category'];
                                    _selectedsubCategory =
                                        catdetails['subcategory'];
                                    _selectedsubsubCategory =
                                        catdetails['subsubcategory'];

                                    loadbrands(_selectedCategory);

                                    categoryinfo = _selectedCategory +
                                        ' > ' +
                                        _selectedsubCategory +
                                        ' > ' +
                                        _selectedsubsubCategory;
                                  });
                                },
                                title: categoryinfo == null
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                    color: Colors.deepPurple),
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
                          child: Text('Product Info',
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                              textCapitalization: TextCapitalization.sentences,
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
                                    left: 15, bottom: 11, top: 11, right: 15),
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
                                                              .circular(20.0),
                                                          topRight: const Radius
                                                              .circular(20.0))),
                                                  child: ListView(
                                                    children: [
                                                      Center(
                                                        child: Icon(
                                                          Icons.warning_rounded,
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
                                                                fontSize: 20,
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
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        child: InkWell(
                                                            child: Container(
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
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .redAccent
                                                                            .withOpacity(
                                                                                0.1),
                                                                        blurRadius:
                                                                            65.0,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            15.0))
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
                                                                          FontWeight
                                                                              .w300),
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
                                      left: 15, bottom: 11, top: 11, right: 15),
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
                              height: tags.isNotEmpty ? 100 : 55,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Column(
                                children: [
                                  tags.isNotEmpty
                                      ? Expanded(
                                          child: ListView.builder(
                                              itemCount: tags.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                    padding: EdgeInsets.all(2),
                                                    child: InputChip(
                                                      backgroundColor: Colors
                                                          .deepOrangeAccent,
                                                      label: Text(
                                                        tags[index],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onDeleted: () {
                                                        setState(() {
                                                          tags.removeAt(index);
                                                        });
                                                      },
                                                    ));
                                              }))
                                      : Container(),
                                  Expanded(
                                    child: TextField(
                                      cursorColor: Color(0xFF979797),
                                      controller: tagscontroller,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onSubmitted: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            tags.add(value);
                                          });
                                          tagscontroller.clear();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Add a Tag ↵",
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
                                  )
                                ],
                              ))),
                      _selectedCategory != null && _selectedCategory != 'Books'
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
                      _selectedCategory != null && _selectedCategory != 'Books'
                          ? Padding(
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
                                      title: Container(
                                          width: 200,
                                          child: InkWell(
                                            onTap: () async {
                                              final bran = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Brands(
                                                          brands: brands,
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
                                                              TextAlign.left,
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
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
                      newItem.condition != 'New'
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
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          : Container(),
                      newItem.condition != 'New'
                          ? Padding(
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
                              ))
                          : Container(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _selectedsubCategory == 'Activewear & Sportswear' ||
                              _selectedsubCategory == 'Dresses' ||
                              _selectedsubCategory == 'Tops & Blouses' ||
                              _selectedsubCategory == 'Coats & Jackets' ||
                              _selectedsubCategory == 'Sweaters' ||
                              _selectedsubCategory == 'Shoes' ||
                              _selectedsubCategory == 'Modest wear' ||
                              _selectedsubCategory == 'Jeans' ||
                              _selectedsubCategory == 'Suits & Blazers' ||
                              _selectedsubCategory == 'Swimwear & Beachwear' ||
                              _selectedsubCategory == 'Bottoms' ||
                              _selectedsubCategory == 'Tops' ||
                              _selectedsubCategory == 'Girls Dresses' ||
                              _selectedsubCategory == 'Girls One-pieces' ||
                              _selectedsubCategory == 'Girls Tops & T-shirts' ||
                              _selectedsubCategory == 'Girls Bottoms' ||
                              _selectedsubCategory == 'Girls Shoes' ||
                              _selectedsubCategory == 'Boys Tops & T-shirts' ||
                              _selectedsubCategory == 'Boys Bottoms' ||
                              _selectedsubCategory == 'Boys One-pieces' ||
                              _selectedsubCategory == 'Boys Shoes' ||
                              _selectedsubCategory == 'Clothing' ||
                              _selectedsubCategory == 'Shoes'
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          : Container(),
                      _selectedsubCategory == 'Activewear & Sportswear' ||
                              _selectedsubCategory == 'Dresses' ||
                              _selectedsubCategory == 'Tops & Blouses' ||
                              _selectedsubCategory == 'Coats & Jackets' ||
                              _selectedsubCategory == 'Sweaters' ||
                              _selectedsubCategory == 'Shoes' ||
                              _selectedsubCategory == 'Modest wear' ||
                              _selectedsubCategory == 'Jeans' ||
                              _selectedsubCategory == 'Suits & Blazers' ||
                              _selectedsubCategory == 'Swimwear & Beachwear' ||
                              _selectedsubCategory == 'Bottoms' ||
                              _selectedsubCategory == 'Tops' ||
                              _selectedsubCategory == 'Girls Dresses' ||
                              _selectedsubCategory == 'Girls One-pieces' ||
                              _selectedsubCategory == 'Girls Tops & T-shirts' ||
                              _selectedsubCategory == 'Girls Bottoms' ||
                              _selectedsubCategory == 'Girls Shoes' ||
                              _selectedsubCategory == 'Boys Tops & T-shirts' ||
                              _selectedsubCategory == 'Boys Bottoms' ||
                              _selectedsubCategory == 'Boys One-pieces' ||
                              _selectedsubCategory == 'Boys Shoes' ||
                              _selectedsubCategory == 'Clothing' ||
                              _selectedsubCategory == 'Shoes'
                          ? Padding(
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
                                      title: Container(
                                          width: 200,
                                          child: InkWell(
                                            onTap: () async {
                                              List<String> topsizes = [
                                                'XXS',
                                                'XS',
                                                'S',
                                                'M',
                                                'L',
                                                'XL',
                                                'XXL',
                                                'XXXL'
                                              ];

                                              List<String> bottomsizes = [
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
                                                '44',
                                                '46',
                                                '48',
                                              ];

                                              List<String> shoesizes = [
                                                '4',
                                                '4.5',
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

                                              List<String> accessoriessizes = [
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

                                              List<String> selectedsize =
                                                  List<String>();

                                              showModalBottomSheet(
                                                  context: context,
                                                  useRootNavigator: false,
                                                  isScrollControlled: true,
                                                  builder: (_) {
                                                    return DraggableScrollableSheet(
                                                        expand: false,
                                                        initialChildSize: 0.7,
                                                        builder:
                                                            (_, controller) {
                                                          return StatefulBuilder(
                                                              // You need this, notice the parameters below:
                                                              builder: (BuildContext
                                                                      context,
                                                                  StateSetter
                                                                      updateState) {
                                                            return Container(
                                                                height: 350.0,
                                                                color: Color(
                                                                    0xFF737373),
                                                                child:
                                                                    Container(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        decoration: new BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
                                                                        child: Column(children: [
                                                                          Row(
                                                                            children: [
                                                                              InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.pop(context);
                                                                                    updateState(() {
                                                                                      selectedSizes = selectedSizes;
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 15, bottom: 15),
                                                                            child:
                                                                                Center(
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
                                                                                                if (selectedSizes.contains(topsizes[i])) {
                                                                                                  selectedSizes.remove(topsizes[i]);
                                                                                                } else {
                                                                                                  selectedSizes.add(topsizes[i]);
                                                                                                }
                                                                                                updateState(() {
                                                                                                  selectedSizes = selectedsize;
                                                                                                });
                                                                                              },
                                                                                              child: Container(
                                                                                                  height: 100,
                                                                                                  width: MediaQuery.of(context).size.width,
                                                                                                  decoration: BoxDecoration(
                                                                                                      color: selectedSizes.contains(topsizes[i]) ? Colors.black : Colors.white,
                                                                                                      border: Border.all(
                                                                                                        color: Colors.grey,
                                                                                                      ),
                                                                                                      borderRadius: BorderRadius.circular(10)),
                                                                                                  child: Center(
                                                                                                      child: Text(
                                                                                                    topsizes[i],
                                                                                                    style: selectedSizes.contains(topsizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
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
                                                                                                    if (selectedSizes.contains(shoesizes[i])) {
                                                                                                      selectedSizes.remove(shoesizes[i]);
                                                                                                    } else {
                                                                                                      selectedSizes.add(shoesizes[i]);
                                                                                                    }
                                                                                                    updateState(() {
                                                                                                      selectedSizes = selectedSizes;
                                                                                                    });
                                                                                                  },
                                                                                                  child: Container(
                                                                                                      height: 100,
                                                                                                      width: MediaQuery.of(context).size.width,
                                                                                                      decoration: BoxDecoration(
                                                                                                          color: selectedSizes.contains(shoesizes[i]) ? Colors.black : Colors.white,
                                                                                                          border: Border.all(
                                                                                                            color: Colors.grey,
                                                                                                          ),
                                                                                                          borderRadius: BorderRadius.circular(10)),
                                                                                                      child: Center(
                                                                                                          child: Text(
                                                                                                        shoesizes[i],
                                                                                                        style: selectedSizes.contains(shoesizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
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
                                                                                                    if (selectedSizes.contains(bottomsizes[i])) {
                                                                                                      selectedSizes.remove(bottomsizes[i]);
                                                                                                    } else {
                                                                                                      selectedSizes.add(bottomsizes[i]);
                                                                                                    }
                                                                                                    updateState(() {
                                                                                                      selectedSizes = selectedSizes;
                                                                                                    });
                                                                                                  },
                                                                                                  child: Container(
                                                                                                      height: 100,
                                                                                                      width: MediaQuery.of(context).size.width,
                                                                                                      decoration: BoxDecoration(
                                                                                                          color: selectedSizes.contains(bottomsizes[i]) ? Colors.black : Colors.white,
                                                                                                          border: Border.all(
                                                                                                            color: Colors.grey,
                                                                                                          ),
                                                                                                          borderRadius: BorderRadius.circular(10)),
                                                                                                      child: Center(
                                                                                                          child: Text(
                                                                                                        bottomsizes[i],
                                                                                                        style: selectedSizes.contains(bottomsizes[i]) ? TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.white) : TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
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
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    selectedSizes != null
                                                        ? Container(
                                                            height: 35,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                1.5,
                                                            child: ListView
                                                                .builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount:
                                                                  selectedSizes
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(1),
                                                                    child: Container(
                                                                        height: 35,
                                                                        width: 35,
                                                                        decoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                                                                        child: Center(
                                                                            child: Text(
                                                                          selectedSizes[
                                                                              index],
                                                                          style: TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 16,
                                                                              color: Colors.white),
                                                                        ))));
                                                              },
                                                            ))
                                                        : Text(
                                                            'Choose your Size',
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
                                                        color:
                                                            Colors.deepPurple)
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
                                left: 15,
                                bottom: 5,
                              ),
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
                                  left: 15, bottom: 5, top: 10, right: 15),
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: ListTile(
                                      title: Container(
                                          width: 200,
                                          child: InkWell(
                                            onTap: () async {
                                              showModalBottomSheet(
                                                  context: context,
                                                  useRootNavigator: false,
                                                  isScrollControlled: true,
                                                  builder: (_) {
                                                    return DraggableScrollableSheet(
                                                        expand: false,
                                                        initialChildSize: 0.7,
                                                        builder:
                                                            (_, controller) {
                                                          return StatefulBuilder(
                                                              // You need this, notice the parameters below:
                                                              builder: (BuildContext
                                                                      context,
                                                                  StateSetter
                                                                      updateState) {
                                                            return Container(
                                                                height: 350.0,
                                                                color: Color(
                                                                    0xFF737373),
                                                                child:
                                                                    Container(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        decoration: new BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 15, bottom: 15),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                'Choose your Color',
                                                                                textAlign: TextAlign.right,
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                GridView.builder(
                                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 5.0, crossAxisSpacing: 5.0, crossAxisCount: 4, childAspectRatio: 1.3),
                                                                              itemBuilder: (_, i) {
                                                                                return Padding(
                                                                                    padding: EdgeInsets.all(5),
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        if (selectedColors.length > 3) {
                                                                                          selectedColors.removeAt(0);
                                                                                          selectedColors.add(colorslist[i]);
                                                                                        }
                                                                                        if (selectedColors.contains(colorslist[i])) {
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
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    selectedColors != null
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                  height: 30,
                                                                  width: 200,
                                                                  child: ListView
                                                                      .builder(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    itemCount:
                                                                        selectedColors
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.grey.shade300,
                                                                            ),
                                                                            color:
                                                                                selectedColors[index],
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
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .blueGrey),
                                                          ),
                                                    Icon(
                                                        Icons
                                                            .keyboard_arrow_right,
                                                        color:
                                                            Colors.deepPurple)
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
                            left: 15, bottom: 20, top: 4, right: 15),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                            itemweight =
                                                int.parse(weights[position]);
                                          });
                                          calculateearning();
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: _selectedweight == position
                                                  ? Colors.deepOrangeAccent
                                                  : Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
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
                                                    color: _selectedweight ==
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
                          padding:
                              EdgeInsets.only(left: 15, bottom: 10, right: 15),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: SwitchListTile(
                                value: freedelivery,
                                activeColor: Colors.deepPurple,
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Offer free delivery to buyers?',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Buyers are more interested in items that have free delivery.',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 12,
                                          color: Colors.deepOrange),
                                    ),
                                  ],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    freedelivery = value;
                                  });
                                  calculateearning();
                                }),
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 5, right: 15),
                        child: Container(
                          height: 85,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      cursorColor: Color(0xFF979797),
                                      controller: businesspricecontroller,
                                      onChanged: (text) async {
                                        calculateearning();
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
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Delivery Fees',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          weightfee.toString().isNotEmpty
                                              ? currency +
                                                  ' ' +
                                                  weightfee.toString()
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
                      fees != null
                          ? Padding(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Service Fees',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          ourfees.toString().isNotEmpty
                                              ? currency +
                                                  ' ' +
                                                  ourfees.toStringAsFixed(1)
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
                                          'You Earn',
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
                                                  businesspricecontroller.text
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
                                          initialChildSize: 0.6,
                                          builder: (_, controller) {
                                            return Container(
                                                height: 100.0,
                                                color: Color(0xFF737373),
                                                child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    decoration: new BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: new BorderRadius
                                                                .only(
                                                            topLeft: const Radius
                                                                .circular(20.0),
                                                            topRight: const Radius
                                                                    .circular(
                                                                20.0))),
                                                    child: Column(children: [
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            15,
                                                                        bottom:
                                                                            10),
                                                                child: Text(
                                                                  "Done",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300),
                                                                ),
                                                              ))
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                      ),
                                                      Text(
                                                        'SellShip Listing Protection & Pricing',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        """All fees are simple and straightforward:\n\n • It’s always free to list an item for sale on SellShip.\n\ • You earn exactly the same amount as the listing price you enter. We add an additional 15% on top of your listing price including delivery to cover for buyer protection and transaction charges.\n\nWhat you get:\n • Free pre-paid shipping label.\n • Free credit card processing.\n • Customer support and SellShip buyer protection.\nDelivery cost added to the listing price are as follows:\n<5kg = AED 20, <10kg = AED 30, <20kg = AED 50, <50kg =AED 110\n\nPlease note, your earnings are based on the listing price and actual earnings will vary based on the final offer price, seller discounts, and any other applicable taxes and discounts.""",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ])));
                                          });
                                    });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: 155,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Listing Price',
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Read more about our fees and pricing',
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 12,
                                                      color: Colors.deepOrange),
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
                              ))
                          : Container(),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
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
                                                        quantity = quantity - 1;
                                                      }
                                                    });
                                                  },
                                                ),
                                                Container(
                                                  width: 25,
                                                  child: Text(
                                                    quantity.toString(),
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.add),
                                                  iconSize: 16,
                                                  color: Colors.deepOrange,
                                                  onPressed: () {
                                                    setState(() {
                                                      if (quantity >= 0) {
                                                        quantity = quantity + 1;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ))
                                      ])))
                          : Container(),
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
                              value: acceptoffers,
                              activeColor: Colors.deepPurple,
                              title: Text(
                                'Accept offers from buyers?',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.blueGrey),
                              ),
                              onChanged: (value) => setState(() {
                                acceptoffers = value;
                              }),
                            ),
                          )),
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
                              value: buyerprotection,
                              activeColor: Colors.deepPurple,
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activate Buyer Protection?',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          backgroundColor: Color(0xFF737373),
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10, top: 20),
                                              decoration: new BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(20.0),
                                                          topRight: const Radius
                                                              .circular(20.0))),
                                              child: Scaffold(
                                                backgroundColor: Colors.white,
                                                body: ListView(
                                                  children: <Widget>[
                                                    ListTile(
                                                      title: Text(
                                                        'Buyer Protection',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 20,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        'Secure Payments',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'All transcations within SellShip are secure and encrypted.',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                      ),
                                                      leading: Icon(
                                                        Icons.lock,
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 1),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        'Money Back Guarantee',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Product\'s that are not described as listed by the seller in the listing, that has undisclosed damage or if the seller has not shipped the item. The buyer can receive a refund for the item, as long as the refund request is made within 2 days of confirmed delivery or order',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                      ),
                                                      leading: Icon(
                                                        FontAwesome.money,
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 1),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        '24/7 Support',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'The SellShip support team works 24/7 around the clock to deal with all support requests, queries and concerns.',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                      ),
                                                      leading: Icon(
                                                        Icons.live_help,
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 1),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                bottomNavigationBar: Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      height: 48,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              10,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255, 115, 0, 1),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(5.0),
                                                        ),
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                              color:
                                                                  Color.fromRGBO(
                                                                      255,
                                                                      115,
                                                                      0,
                                                                      0.4),
                                                              offset:
                                                                  const Offset(
                                                                      1.1, 1.1),
                                                              blurRadius: 10.0),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Done',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )));
                                    },
                                    child: Text(
                                      'Buyers are more prone to purchase items that have Buyer Protection active. Read more about Buyer Protection',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 12,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                ],
                              ),
                              onChanged: (value) => setState(() {
                                buyerprotection = value;
                              }),
                            ),
                          )),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                    child: userid != null
                        ? Row(children: [
                            Padding(
                              child: InkWell(
                                onTap: () async {
                                  String bran;
                                  if (brand == 'Other') {
                                    if (businessbrandcontroller != null) {
                                      String brandcontrollertext =
                                          businessbrandcontroller.text.trim();
                                      if (brandcontrollertext.isNotEmpty) {
                                        bran = businessbrandcontroller.text;
                                      }
                                    } else if (businessbrandcontroller ==
                                            null &&
                                        _selectedCategory != 'Books') {
                                      showInSnackBar(
                                          'Please choose a brand for your item!');
                                    } else if (businessbrandcontroller ==
                                            null &&
                                        _selectedCategory == 'Books') {
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
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
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
                                                          'Editing Item..',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Container(
                                                            height: 50,
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

                                  if (images.isNotEmpty) {
                                    print('sds');
                                    if (businessnameController.text.isEmpty) {
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
                                    } else if (_selectedsize == null &&
                                        _selectedCategory == 'Women') {
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
                                        businessdescriptionController.text = '';
                                      }

                                      List<int> _image;
                                      List<int> _image2;
                                      List<int> _image3;
                                      List<int> _image4;
                                      List<int> _image5;
                                      List<int> _image6;

                                      if (images.length == 1) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();
                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                      } else if (images.length == 2) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();

                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                        ByteData byteData2 =
                                            await images[1].getByteData();
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                        _image2 = await FlutterImageCompress
                                            .compressWithList(_image2,
                                                quality: 15);
                                      } else if (images.length == 3) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();
                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                        ByteData byteData2 =
                                            await images[1].getByteData();
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                        _image2 = await FlutterImageCompress
                                            .compressWithList(_image2,
                                                quality: 15);
                                        ByteData byteData3 =
                                            await images[2].getByteData();
                                        _image3 =
                                            byteData3.buffer.asUint8List();
                                        _image3 = await FlutterImageCompress
                                            .compressWithList(_image3,
                                                quality: 15);
                                      } else if (images.length == 4) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();
                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                        ByteData byteData2 =
                                            await images[1].getByteData();
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                        _image2 = await FlutterImageCompress
                                            .compressWithList(_image2,
                                                quality: 15);
                                        ByteData byteData3 =
                                            await images[2].getByteData();
                                        _image3 =
                                            byteData3.buffer.asUint8List();
                                        _image3 = await FlutterImageCompress
                                            .compressWithList(_image3,
                                                quality: 15);
                                        ByteData byteData4 =
                                            await images[3].getByteData();
                                        _image4 =
                                            byteData4.buffer.asUint8List();
                                        _image4 = await FlutterImageCompress
                                            .compressWithList(_image4,
                                                quality: 15);
                                      } else if (images.length == 5) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();
                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                        ByteData byteData2 =
                                            await images[1].getByteData();
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                        _image2 = await FlutterImageCompress
                                            .compressWithList(_image2,
                                                quality: 15);
                                        ByteData byteData3 =
                                            await images[2].getByteData();
                                        _image3 =
                                            byteData3.buffer.asUint8List();
                                        _image3 = await FlutterImageCompress
                                            .compressWithList(_image3,
                                                quality: 15);
                                        ByteData byteData4 =
                                            await images[3].getByteData();
                                        _image4 =
                                            byteData4.buffer.asUint8List();
                                        _image4 = await FlutterImageCompress
                                            .compressWithList(_image4,
                                                quality: 15);
                                        ByteData byteData5 =
                                            await images[4].getByteData();
                                        _image5 =
                                            byteData5.buffer.asUint8List();
                                        _image5 = await FlutterImageCompress
                                            .compressWithList(_image5,
                                                quality: 15);
                                      } else if (images.length == 6) {
                                        ByteData byteData =
                                            await images[0].getByteData();
                                        _image = byteData.buffer.asUint8List();
                                        _image = await FlutterImageCompress
                                            .compressWithList(_image,
                                                quality: 15);
                                        ByteData byteData2 =
                                            await images[1].getByteData();
                                        _image2 =
                                            byteData2.buffer.asUint8List();
                                        _image2 = await FlutterImageCompress
                                            .compressWithList(_image2,
                                                quality: 15);
                                        ByteData byteData3 =
                                            await images[2].getByteData();
                                        _image3 =
                                            byteData3.buffer.asUint8List();
                                        _image3 = await FlutterImageCompress
                                            .compressWithList(_image3,
                                                quality: 15);
                                        ByteData byteData4 =
                                            await images[3].getByteData();
                                        _image4 =
                                            byteData4.buffer.asUint8List();
                                        _image4 = await FlutterImageCompress
                                            .compressWithList(_image4,
                                                quality: 15);
                                        ByteData byteData5 =
                                            await images[4].getByteData();
                                        _image5 =
                                            byteData5.buffer.asUint8List();
                                        _image5 = await FlutterImageCompress
                                            .compressWithList(_image5,
                                                quality: 15);
                                        ByteData byteData6 =
                                            await images[5].getByteData();
                                        _image6 =
                                            byteData6.buffer.asUint8List();
                                        _image6 = await FlutterImageCompress
                                            .compressWithList(_image6,
                                                quality: 15);
                                      }

                                      Dio dio = new Dio();
                                      FormData formData;

                                      if (_image != null) {
                                        String fileName =
                                            randomAlphaNumeric(20);

                                        formData = FormData.fromMap({
                                          'name': businessnameController.text,
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'tags': tags.isEmpty ? [] : {tags},
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'itemid': newItem.itemid,
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
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
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
                                          'tags': tags.isEmpty ? [] : {tags},
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'freedelivery': freedelivery,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
                                          'itemid': newItem.itemid,
                                          'weight': itemweight,
                                          'weightmetric': metric,
                                          'quantity': quantity,
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
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
                                          'tags': tags.isEmpty ? [] : {tags},
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'freedelivery': freedelivery,
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
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
                                          'weight': itemweight,
                                          'itemid': newItem.itemid,
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
                                          'weightmetric': metric,
                                          'quantity': quantity,
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
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'freedelivery': freedelivery,
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
                                          'tags': tags.isEmpty ? [] : {tags},
                                          'category': _selectedCategory,
                                          'subcategory': _selectedsubCategory,
                                          'subsubcategory':
                                              _selectedsubsubCategory == null
                                                  ? ''
                                                  : _selectedsubsubCategory,
                                          'latitude': _lastMapPosition.latitude,
                                          'longitude':
                                              _lastMapPosition.longitude,
                                          'itemid': newItem.itemid,
                                          'description':
                                              businessdescriptionController
                                                  .text,
                                          'city': city.trim(),
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
                                          'weight': itemweight,
                                          'weightmetric': metric,
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
                                          'quantity': quantity,
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
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'freedelivery': freedelivery,
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
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
                                          'city': city.trim(),
                                          'itemid': newItem.itemid,
                                          'tags': tags.isEmpty ? [] : {tags},
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
                                          'weight': itemweight,
                                          'weightmetric': metric,
                                          'quantity': quantity,
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
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
                                          'itemid': newItem.itemid,
                                          'price': fees.toStringAsFixed(2),
                                          'originalprice':
                                              businesspricecontroller.text
                                                  .toString(),
                                          'colors': selectedColors.isEmpty
                                              ? []
                                              : {selectedColors},
                                          'size': _selectedsize == null
                                              ? ''
                                              : _selectedsize,
                                          'tags': tags.isEmpty ? [] : {tags},
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
                                          'size': selectedSizes.isEmpty
                                              ? []
                                              : {selectedSizes},
                                          'freedelivery': freedelivery,
                                          'acceptoffers': acceptoffers,
                                          'buyerprotection': buyerprotection,
                                          'city': city.trim(),
                                          'country': country.trim(),
                                          'condition': _selectedCondition,
                                          'brand': bran,
                                          'weight': itemweight,
                                          'weightmetric': metric,
                                          'quantity': quantity,
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

                                      var addurl =
                                          'https://api.sellship.co/api/updateitem';
                                      var response = await dio.post(addurl,
                                          data: formData);
                                      print(response.data);
                                      print(response.statusCode);

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
                                                    'Your Item has been Updated!',
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

                                                    Navigator.pushReplacement(
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
                                  } else {
                                    print(newItem.itemid);
                                    FormData formData = FormData.fromMap({
                                      'name': businessnameController.text,
                                      'itemid': newItem.itemid,
                                      'price': fees.toStringAsFixed(2),
                                      'originalprice': totalpayable.toString(),
                                      'colors': selectedColors.isEmpty
                                          ? []
                                          : {selectedColors},
                                      'size': selectedSizes.isEmpty
                                          ? []
                                          : {selectedSizes},
                                      'acceptoffers': acceptoffers,
                                      'buyerprotection': buyerprotection,
                                      'tags': tags.isEmpty ? [] : {tags},
                                      'category': _selectedCategory,
                                      'subcategory': _selectedsubCategory,
                                      'subsubcategory':
                                          _selectedsubsubCategory == null
                                              ? ''
                                              : _selectedsubsubCategory,
                                      'latitude': _lastMapPosition.latitude,
                                      'longitude': _lastMapPosition.longitude,
                                      'freedelivery': freedelivery,
                                      'description':
                                          businessdescriptionController.text,
                                      'city': city.trim(),
                                      'country': country.trim(),
                                      'condition': newItem.condition != 'New'
                                          ? _selectedCondition
                                          : 'New',
                                      'brand': bran,
                                      'weight': itemweight,
                                      'weightmetric': metric,
                                      'quantity': quantity,
                                      'date_uploaded':
                                          DateTime.now().toString(),
                                    });

                                    Dio dio = new Dio();

                                    var addurl =
                                        'https://api.sellship.co/api/updateitem';
                                    var response =
                                        await dio.post(addurl, data: formData);
                                    print(response.data);
                                    print(response.statusCode);

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
                                                  'Your Item\'s Updated',
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

                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RootScreen()),
                                                  );
                                                },
                                              ));
                                    } else {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      showInSnackBar(
                                          'Looks like something went wrong!');
                                    }
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
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
                                      "Update",
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
                            ),
                            Padding(
                              child: InkWell(
                                onTap: () async {
                                  var url =
                                      'https://api.sellship.co/api/deleteitem/' +
                                          itemid +
                                          "/" +
                                          userid;

                                  var response = await http.get(url);

                                  if (response.statusCode == 200) {
                                    print(response.body);
                                    setState(() {
                                      _status = true;
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RootScreen()),
                                      );
                                    });
                                  } else {
                                    print(response.statusCode);
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.red.withOpacity(0.1),
                                            blurRadius: 65.0,
                                            offset: Offset(0.0, 15.0))
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Delete",
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
                            ),
                          ])
                        : Text('')),
                SliverToBoxAdapter(
                    child: SizedBox(
                  height: 30,
                )),
              ]))
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
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save",
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                    )),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () async {
                  var url = 'https://api.sellship.co/api/updateitem/' + itemid;

                  Dio dio = new Dio();
                  var response;

                  if (image != null) {
                    String fileName = image.path.split('/').last;
                    FormData formData = FormData.fromMap({
                      'name': firstnamecontr.text,
                      'description': lastnamecontr.text,
                      'price': emailnamecontr.text,
                      'image': await MultipartFile.fromFile(image.path,
                          filename: fileName)
                    });
                    response = await dio.post(url, data: formData);
                  } else {
                    FormData formData = FormData.fromMap({
                      'name': firstnamecontr.text,
                      'description': lastnamecontr.text,
                      'price': emailnamecontr.text,
                    });
                    response = await dio.post(url, data: formData);
                  }

                  if (response.statusCode == 200) {
                    print(response.data);
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(new FocusNode());
                      getProfileData();
                    });
                  } else {
                    print(response.statusCode);
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                  ),
                ),
                textColor: Colors.white,
                color: Colors.deepOrange,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text(
                  "Delete",
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                  ),
                ),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () async {
                  var url = 'https://api.sellship.co/api/deleteitem/' +
                      itemid +
                      "/" +
                      userid;

                  var response = await http.get(url);

                  if (response.statusCode == 200) {
                    print(response.body);
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(new FocusNode());

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RootScreen()),
                      );
                    });
                  } else {
                    print(response.statusCode);
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
