import 'dart:convert';
import 'dart:io';

import 'package:SellShip/screens/store/createlayout.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

class CreateStore extends StatefulWidget {
  final String userid;
  final String storename;
  final String storetype;
  final String category;
  final String storeusername;
  final String storedescription;

  CreateStore({
    Key key,
    this.userid,
    this.storedescription,
    this.storename,
    this.storeusername,
    this.storetype,
    this.category,
  }) : super(key: key);

  @override
  _CreateStoreState createState() => new _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
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

  AddressModel selectedaddress;

  var storelocation;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
      storename = widget.storename;
    });
  }

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
            'Create My Store',
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
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(
                      left: 56.0, bottom: 10, top: 30, right: 36),
                  child: Center(
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 100,
                      lineHeight: 10.0,
                      percent: 0.65,
                      progressColor: Color.fromRGBO(255, 115, 0, 1),
                    ),
                  ),
                ),
              ),
              FadeAnimation(
                1,
                Padding(
                  padding: EdgeInsets.only(
                      left: 36.0, bottom: 10, top: 20, right: 36),
                  child: Center(
                    child: Text(
                      "Awesome! Let\'s get you all setup",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Color.fromRGBO(28, 45, 65, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Helvetica'),
                    ),
                  ),
                ),
              ),
              FadeAnimation(
                1,
                Padding(
                    padding: EdgeInsets.only(
                        left: 36.0, bottom: 10, top: 20, right: 36),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromRGBO(131, 146, 165, 0.1),
                      ),
                      width: MediaQuery.of(context).size.width - 250,
                      child: GestureDetector(
                          onTap: () async {
                            if (await Permission.Permission.photos
                                .request()
                                .isGranted) {
                              getImage();
                            } else {
                              Map<Permission.Permission,
                                      Permission.PermissionStatus> statuses =
                                  await [
                                Permission.Permission.photos,
                              ].request();
                              Permission.openAppSettings();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: _image == null
                                ? DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(12),
                                    padding: EdgeInsets.all(6),
                                    dashPattern: [12, 4],
                                    color: Colors.deepOrangeAccent,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        child: Container(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Feather.image,
                                                  color: Colors.blueGrey,
                                                  size: 45,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Tap to upload your store logo',
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 16,
                                                      fontFamily: 'Helvetica'),
                                                )
                                              ],
                                            )))),
                                  )
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    child: Container(
                                        color: Colors.white,
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.file(
                                          _image,
                                          fit: BoxFit.cover,
                                        ))),
                          )),
                    )),
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
                                              storelocation =
                                                  addressresult['location'];
                                              selectedaddress =
                                                  addressresult['address'];
                                              phonenumber =
                                                  addressresult['phonenumber'];
                                            });
                                          } else {
                                            setState(() {
                                              selectedaddress = null;
                                              phonenumber = null;
                                              storelocation = null;
                                            });
                                          }
                                          print(storelocation);
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
                          onTap: () async {
                            if (widget.storetype == 'Secondhand Seller') {
                              if (selectedaddress == null || _image == null) {
                                showInSnackBar(
                                    'Looks like something is missing. Please ensure all your store information has been entered');
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateLayout(
                                        userid: widget.userid,
                                        storename: widget.storename,
                                        storelogo: _image,
                                        storecategory: widget.category,
                                        storeusername: widget.storeusername,
                                        storeabout: '',
                                        storeaddress: selectedaddress.address,
                                        storetype: widget.storetype,
                                        storecity: selectedaddress.city,
                                        storelocation: storelocation,
                                        storedescription:
                                            widget.storedescription,
                                      ),
                                    ));
                              }
                            } else {
                              if (selectedaddress == null || _image == null) {
                                showInSnackBar(
                                    'Looks like something is missing. Please ensure all your store information has been entered');
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateLayout(
                                        userid: widget.userid,
                                        storetype: widget.storetype,
                                        storename: widget.storename,
                                        storelogo: _image,
                                        storecategory: widget.category,
                                        storeusername: widget.storeusername,
                                        storeabout: '',
                                        storeaddress: selectedaddress.address,
                                        storecity: selectedaddress.city,
                                        storelocation: storelocation,
                                        storedescription:
                                            widget.storedescription,
                                      ),
                                    ));
                              }
                            }
                          },
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
                              'Next',
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
