import 'dart:convert';
import 'dart:io';
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

class CreateLayout extends StatefulWidget {
  final String userid;
  final String storename;
  final String username;
  final File storelogo;
  final String storecategory;
  final String storeabout;
  final String storetype;

  CreateLayout(
      {Key key,
      this.userid,
      this.storename,
      this.username,
      this.storelogo,
      this.storetype,
      this.storecategory,
      this.storeabout})
      : super(key: key);

  @override
  _CreateLayoutState createState() => new _CreateLayoutState();
}

class _CreateLayoutState extends State<CreateLayout> {
  @override
  void initState() {
    super.initState();
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

  var selectedlayout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Feather.arrow_left)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Choose Store Layout',
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
                  percent: 0.85,
                  progressColor: Color.fromRGBO(255, 115, 0, 1),
                ),
              ),
            ),
          ),
          FadeAnimation(
            1,
            Padding(
                padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedlayout = 1;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedlayout == 1
                                    ? Colors.black
                                    : Colors.blueGrey.shade100,
                              ),
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            setState(() {
                              selectedlayout = 2;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedlayout == 2
                                      ? Colors.black
                                      : Colors.blueGrey.shade100,
                                ),
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 35,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 35,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 35,
                                      color: Colors.blueGrey,
                                    ),
                                    Container(
                                      height: 25,
                                      width: 30,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          )),
                    ])),
          ),
          FadeAnimation(
            1,
            Padding(
              padding: EdgeInsets.only(left: 36, top: 40, right: 36),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {},
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
                          'Create Store',
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
          ),
        ],
      ),
    );
  }
}
