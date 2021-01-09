import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/home.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:SellShip/screens/rootscreen.dart';
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

    await storage.write(key: 'additem', value: 'true');

    setState(() {
      images = resultList;
      percentindictor = 0.3;
    });
  }

  double percentindictor = 0.0;
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

  final storage = new FlutterSecureStorage();

  var itemname;
  var itemdescription;
  var itemprice;
  var itemimage;

  var userid;
  File image;

  void getProfileData() async {
    var url = 'https://api.sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      imagesList.clear();
      var jsonbody = json.decode(response.body);

      newItem = Item(
          name: jsonbody[0]['name'],
          itemid: jsonbody[0]['_id']['\$oid'].toString(),
          price: jsonbody[0]['price'].toString(),
          description: jsonbody[0]['description'],
          category: jsonbody[0]['category'],
          condition: jsonbody[0]['condition'] == null
              ? 'Like New'
              : jsonbody[0]['condition'],
          image: jsonbody[0]['image'],
          image1: jsonbody[0]['image1'],
          image2: jsonbody[0]['image2'],
          image3: jsonbody[0]['image3'],
          image4: jsonbody[0]['image4'],
          image5: jsonbody[0]['image5'],
          sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
          likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
          city: jsonbody[0]['city'],
          username: jsonbody[0]['username'],
          brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
          size: jsonbody[0]['size'] == null ? '' : jsonbody[0]['size'],
          useremail: jsonbody[0]['useremail'],
          usernumber: jsonbody[0]['usernumber'],
          userid: jsonbody[0]['userid'],
          latitude: jsonbody[0]['latitude'],
          comments: jsonbody[0]['comments'] == null
              ? 0
              : jsonbody[0]['comments'].length,
          longitude: jsonbody[0]['longitude'],
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

      if (mounted) {
        setState(() {
          newItem = newItem;
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

  List<String> imagesList = List<String>();

  Item newItem;
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

  TextEditingController firstnamecontr = TextEditingController();
  TextEditingController lastnamecontr = TextEditingController();
  TextEditingController emailnamecontr = TextEditingController();
  TextEditingController phonenamecontr = TextEditingController();

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
                                          print(imagesList.length);

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
                        )
                      ],
                    ),
                  ),
                ),
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

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
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
