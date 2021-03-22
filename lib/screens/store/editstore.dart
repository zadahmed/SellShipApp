import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

class EditStore extends StatefulWidget {
  final String storeid;

  EditStore({
    Key key,
    this.storeid,
  }) : super(key: key);

  @override
  _EditStoreState createState() => new _EditStoreState();
}

class _EditStoreState extends State<EditStore> {
  String userid;
  String storename;
  var phonenumber;

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

  var profilepicture;
  AddressModel selectedaddress;

  @override
  void initState() {
    super.initState();
    setState(() {
      storeid = widget.storeid;
    });
    getstoreinfo();
  }

  getstoreinfo() async {
    var url = 'https://api.sellship.co/api/store/' + storeid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      Stores store = Stores(
          storeid: jsonbody['_id']['\$oid'],
          storecategory: jsonbody['storecategory'],
          storelogo: jsonbody['storelogo'],
          storebio: jsonbody['storebio'],
          storename: jsonbody['storename']);

      setState(() {
        mystore = store;
        loading = false;
      });
    }
  }

  var storeid;
  Stores mystore;
  bool loading = true;
  bool disabled = true;
  var dropdownvalue;

  TextEditingController usernamecontroller = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 40);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Edit Store',
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
                width: 200,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade100, width: 5),
                              borderRadius: BorderRadius.circular(100)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: _image == null
                                  ? CachedNetworkImage(
                                      height: 300,
                                      width: 300,
                                      imageUrl: mystore.storelogo,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Image.file(
                                      _image,
                                      fit: BoxFit.fitWidth,
                                    )),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: InkWell(
                          onTap: () {
                            getImage();
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Color.fromRGBO(28, 45, 65, 1),
                            child: Icon(
                              Feather.camera,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                child: Container(
                    height: 140,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(131, 146, 165, 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Store Category:',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            mystore.storecategory,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                        ])),
              ),
              FadeAnimation(
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
                                  horizontal: 20, vertical: 10),
                              width: MediaQuery.of(context).size.width - 80,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(131, 146, 165, 0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    child: Text(
                                      'Delivery Pick-Up Address',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                        onTap: () async {
                                          final addressresult =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Address()),
                                          );
                                          if (addressresult != null) {
                                            setState(() {
                                              selectedaddress =
                                                  addressresult['address'];
                                              phonenumber =
                                                  addressresult['phonenumber'];
                                            });
                                          } else {
                                            setState(() {
                                              selectedaddress = null;
                                              phonenumber = null;
                                            });
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                selectedaddress == null
                                                    ? 'Choose Address'
                                                    : selectedaddress.address,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              size: 16,
                                              color: Colors.blueGrey,
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ]))),
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {},
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 80,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 115, 0, 1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                                child: Text(
                              'Save',
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
              )
            ],
          ),
        ));
  }
}
