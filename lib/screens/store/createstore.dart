import 'dart:convert';
import 'dart:io';

import 'package:SellShip/screens/store/createlayout.dart';
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
  final String username;
  final String storetype;
  final String category;

  CreateStore({
    Key key,
    this.userid,
    this.storename,
    this.storetype,
    this.category,
    this.username,
  }) : super(key: key);

  @override
  _CreateStoreState createState() => new _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
  String userid;
  String storename;

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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

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
      body: ListView(
        children: <Widget>[
          FadeAnimation(
            1,
            Padding(
              padding:
                  EdgeInsets.only(left: 56.0, bottom: 10, top: 30, right: 36),
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
              padding:
                  EdgeInsets.only(left: 36.0, bottom: 10, top: 20, right: 36),
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
                padding:
                    EdgeInsets.only(left: 36.0, bottom: 10, top: 20, right: 36),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueGrey.shade50,
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
                              Permission.PermissionStatus> statuses = await [
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    child: Container(
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                    width: MediaQuery.of(context).size.width,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: MediaQuery.of(context).size.width - 80,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(131, 146, 165, 0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        maxLines: 100,
                        onChanged: (text) {},
                        controller: usernamecontroller,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "About My Store",
                          hintStyle: TextStyle(fontFamily: 'Helvetica'),
                          icon: Icon(
                            Icons.store,
                            color: Colors.blueGrey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
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
                        if (widget.category == 'Secondhand Seller') {
                          //move to store page. create a store and move to store page.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateLayout(
                                  userid: widget.userid,
                                  username: widget.username,
                                  storename: widget.storename,
                                  storelogo: _image,
                                  storecategory: widget.category,
                                  storeabout: usernamecontroller.text,
                                ),
                              ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateLayout(
                                  userid: widget.userid,
                                  username: widget.username,
                                  storetype: widget.storetype,
                                  storename: widget.storename,
                                  storelogo: _image,
                                  storecategory: widget.category,
                                  storeabout: usernamecontroller.text,
                                ),
                              ));
                        }
                      },
                      child: Container(
                        height: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
    );
  }
}
