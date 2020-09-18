import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/balance.dart';
import 'package:SellShip/screens/changecountry.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/reviews.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/search.dart';

import 'package:SellShip/screens/termscondition.dart';

import 'package:SellShip/verification/verifyemail.dart';
import 'package:SellShip/verification/verifyphone.dart';
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
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shimmer/shimmer.dart';
import 'package:package_info/package_info.dart';

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
  String version;
  @override
  void initState() {
    readdetails();
    super.initState();
  }

  bool verified;

  final facebookLogin = FacebookLogin();
  bool confirmedfb;
  bool confirmedemail;
  bool confirmedphone;

  verifyFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');

        final profile = json.decode(graphResponse.body);
        var email = profile['email'];
        var url = 'https://api.sellship.co/verify/fb/' + userid + '/' + email;
        final response = await http.get(url);
        if (response.statusCode == 200) {
          setState(() {
            confirmedfb = true;
          });
          Navigator.of(context, rootNavigator: true).pop('dialog');
        } else {
          setState(() {
            confirmedfb = false;
          });
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }

        break;

      case FacebookLoginStatus.cancelledByUser:
        Navigator.of(context, rootNavigator: true).pop('dialog');
        break;
      case FacebookLoginStatus.error:
        Navigator.of(context, rootNavigator: true).pop('dialog');
        break;
    }
  }

  readdetails() async {
    userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;

        var confirmedemai = profilemap['confirmedemail'];
        if (confirmedemai != null) {
        } else {
          confirmedemai = false;
        }

        var confirmedphon = profilemap['confirmedphone'];
        if (confirmedphon != null) {
        } else {
          confirmedphon = false;
        }

        var confirmedf = profilemap['confirmedfb'];
        if (confirmedf != null) {
        } else {
          confirmedf = false;
        }

        if (profilemap != null) {
          if (mounted) {
            setState(() {
              email = profilemap['email'];
              confirmedfb = confirmedf;
              confirmedemail = confirmedemai;
              confirmedphone = confirmedphon;
            });
          }
        }
      }
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String versio = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
      userid = userid;
      email = widget.email;
      version = versio + buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios)),
          iconTheme: IconThemeData(color: Colors.deepOrange),
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: <Widget>[
            userid != null
                ? Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account Settings',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
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
                      title: Text(
                        'Balance',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Balance()),
                        );
                      },
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.edit,
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
                          fontFamily: 'Helvetica',
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
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await Intercom.initialize(
                          'z4m2b833',
                          androidApiKey:
                              'android_sdk-78eb7d5e9dd5f4b508ddeec4b3c54d7491676661',
                          iosApiKey:
                              'ios_sdk-2744ef1f27a14461bfda4cb07e8fc44364a38005',
                        );
                        await Intercom.registerIdentifiedUser(email: email);

                        Intercom.displayMessenger();
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
                        title: Text(
                          'Help & Support',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ))
                : Container(),
            Divider(
              color: Colors.grey,
              thickness: 0.1,
            ),
            userid != null
                ? Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Verification',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.alternate_email,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedemail == false
                          ? Icon(
                              Feather.arrow_right,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Feather.check),
                      title: confirmedemail == false
                          ? Text(
                              'Verify Email',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            )
                          : Text(
                              'Email Verified',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyEmail(
                                    email: email,
                                    userid: userid,
                                  )),
                        );
                      },
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.phone,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedphone == false
                          ? Icon(
                              Feather.arrow_right,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Feather.check),
                      title: confirmedphone == false
                          ? Text(
                              'Verify Phone',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            )
                          : Text(
                              'Phone Verified',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyPhone(
                                    userid: userid,
                                  )),
                        );
                      },
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        FontAwesome.facebook,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedfb == false
                          ? Icon(
                              Feather.arrow_right,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Feather.check),
                      title: confirmedfb == false
                          ? Text(
                              'Verify Facebook',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            )
                          : Text(
                              'Facebook Verified',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16.0,
                              ),
                            ),
                      onTap: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => new AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  content: Builder(
                                    builder: (context) {
                                      return Container(
                                          height: 50,
                                          width: 50,
                                          child: SpinKitChasingDots(
                                            color: Colors.deepOrange,
                                          ));
                                    },
                                  ),
                                ));
                        verifyFB();
                      },
                    ),
                  )
                : Container(),
            Divider(
              color: Colors.grey,
              thickness: 0.1,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Settings',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
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
                    fontFamily: 'Helvetica',
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
                  Icons.insert_drive_file,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  Feather.arrow_right,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'Licenses',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  showLicensePage(
                      context: context,
                      applicationName: 'SellShip',
                      applicationIcon: Image.asset(
                        'assets/logotransparent.png',
                        scale: 0.5,
                      ));
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
                    fontFamily: 'Helvetica',
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
                    fontFamily: 'Helvetica',
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
                          fontFamily: 'Helvetica',
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
                              builder: (context) => RootScreen(index: 1)),
                        );
                      },
                    ))
                : Container(),
            Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: version != null
                      ? Text(
                          'v' + version,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      : Container()),
            )
          ],
        ));
  }
}
