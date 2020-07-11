import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/balance.dart';
import 'package:SellShip/screens/changecountry.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/termscondition.dart';
import 'package:SellShip/support.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shimmer/shimmer.dart';

class Settings extends StatefulWidget {
  final String email;
  Settings({Key key, this.email}) : super(key: key);

  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  var userid;
  String email;
  final storage = new FlutterSecureStorage();
  @override
  void initState() {
    readdetails();
    super.initState();
  }

  readdetails() async {
    userid = await storage.read(key: 'userid');
    setState(() {
      userid = userid;
      email = widget.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RootScreen(index: 2)),
                );
              },
              child: Icon(Icons.arrow_back_ios)),
          iconTheme: IconThemeData(color: Colors.deepOrange),
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF'),
          ),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: <Widget>[
            userid != null
                ? Container(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Balance()),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.attach_money,
                          color: Colors.deepOrange,
                        ),
                        trailing: Icon(
                          Feather.arrow_right,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        title: Text('Balance'),
                      ),
                    ))
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Feather.edit_3,
                        color: Colors.deepOrange,
                      ),
                      trailing: Icon(
                        Feather.arrow_right,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      title: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontFamily: 'SF',
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile()),
                        );
                      },
                    ))
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Support(email: email)),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: Colors.deepOrange,
                        ),
                        trailing: Icon(
                          Feather.arrow_right,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        title: Text('Help & Support'),
                      ),
                    ))
                : Container(),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Feather.file_text,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  Feather.arrow_right,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsandConditions()),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Feather.eye,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  Feather.arrow_right,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Feather.flag,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  Feather.arrow_right,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'Change Country',
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeCountry()),
                  );
                },
              ),
            ),
            Divider(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Feather.log_out,
                        color: Colors.deepOrange,
                      ),
                      title: Text(
                        'Log out',
                        style: TextStyle(
                          fontFamily: 'SF',
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: () {
                        storage.delete(key: 'userid');
                        setState(() {
                          userid = null;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RootScreen(index: 2)),
                        );
                      },
                    ))
                : Container()
          ],
        ));
  }
}
