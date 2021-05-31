import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/main.dart';
import 'package:SellShip/screens/balance.dart';
import 'package:SellShip/screens/changecountry.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/helpcentre.dart';
import 'package:SellShip/screens/myitems.dart';
import 'package:SellShip/screens/onboardinginterests.dart';
import 'package:SellShip/screens/privacypolicy.dart';
import 'package:SellShip/screens/reviews.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/store/createstorename.dart';

import 'package:SellShip/screens/termscondition.dart';
import 'package:SellShip/usernamesettings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:SellShip/verification/verifyemail.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/editprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shimmer/shimmer.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  final String email;
  final bool confirmedfb;
  final bool confirmedemail;
  final bool confirmedphone;
  final String userid;
  final String tier;
  Settings(
      {Key key,
      this.email,
      this.confirmedfb,
      this.tier,
      this.confirmedemail,
      this.confirmedphone,
      this.userid})
      : super(key: key);

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
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:SettingsPage',
      screenClassOverride: 'AppSettingsPage',
    );
  }

  bool verified;

  final facebookLogin = FacebookLogin();
  bool confirmedfb;
  bool confirmedemail;
  bool confirmedphone;

  verifyFB() async {
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken token = result.accessToken;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token'));

        final profile = json.decode(graphResponse.body);
        var email = profile['email'];
        var url = 'https://api.sellship.co/verify/fb/' + userid + '/' + email;
        final response = await http.get(Uri.parse(url));
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

      case FacebookLoginStatus.cancel:
        Navigator.of(context, rootNavigator: true).pop('dialog');
        break;
      case FacebookLoginStatus.error:
        Navigator.of(context, rootNavigator: true).pop('dialog');
        break;
    }
  }

  readdetails() async {
    setState(() => {
          userid = widget.userid,
          confirmedphone = widget.confirmedphone,
          confirmedemail = widget.confirmedemail,
          confirmedfb = widget.confirmedfb
        });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String versio = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
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
              child: Icon(FeatherIcons.chevronLeft)),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(28, 45, 65, 1),
          ),
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(
                color: Colors.black,
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
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        FeatherIcons.edit,
                        color: Colors.deepOrange,
                      ),
                      trailing: Icon(
                        FeatherIcons.chevronRight,
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
                    child: ListTile(
                      leading: Icon(
                        FeatherIcons.user,
                        color: Colors.deepOrange,
                      ),
                      trailing: Icon(
                        FeatherIcons.chevronRight,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      title: Text(
                        'Change Username',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UsernameSettings(
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
                        FeatherIcons.heart,
                        color: Colors.deepOrange,
                      ),
                      trailing: Icon(
                        FeatherIcons.chevronRight,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      title: Text(
                        'Change Interests',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OnboardingInterests(
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
                        FeatherIcons.dollarSign,
                        color: Colors.deepOrange,
                      ),
                      trailing: Icon(
                        FeatherIcons.chevronRight,
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
            // Container(
            //   color: Colors.white,
            //   child: ListTile(
            //     leading: Icon(
            //       FeatherIcons.business,
            //       color: Colors.deepOrange,
            //     ),
            //     trailing: Icon(
            //       FeatherIcons.chevronRight,
            //       size: 16,
            //       color: Colors.deepOrange,
            //     ),
            //     title: Text(
            //       'Create a Store',
            //       style: TextStyle(
            //         fontFamily: 'Helvetica',
            //         fontSize: 16.0,
            //       ),
            //     ),
            //     onTap: () {
            //       //TODO Send them to subscription based on Tier
            //
            //       //
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => CreateStoreName()),
            //       );
            //     },
            //   ),
            // ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FeatherIcons.fileText,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  FeatherIcons.chevronRight,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'FAQ & Help Centre',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCentre()),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FeatherIcons.star,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  FeatherIcons.chevronRight,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'Review Us',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16.0,
                  ),
                ),
                onTap: () {
                  final InAppReview _inAppReview = InAppReview.instance;
                  _inAppReview.openStoreListing(
                    appStoreId: '1550513300',
                  );
                },
              ),
            ),
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
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.alternate_email_rounded,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedemail == false
                          ? Icon(
                              FeatherIcons.chevronRight,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(FeatherIcons.check),
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
                        FeatherIcons.phone,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedphone == false
                          ? Icon(
                              FeatherIcons.chevronRight,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(FeatherIcons.check),
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
                        FontAwesomeIcons.facebook,
                        color: Colors.deepOrange,
                      ),
                      trailing: confirmedfb == false
                          ? Icon(
                              FeatherIcons.chevronRight,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(FeatherIcons.check),
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
                                          child: SpinKitDoubleBounce(
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
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
                          FeatherIcons.helpCircle,
                          color: Colors.deepOrange,
                        ),
                        trailing: Icon(
                          FeatherIcons.chevronRight,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        title: Text(
                          'Contact Support',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ))
                : Container(),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FeatherIcons.fileText,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  FeatherIcons.chevronRight,
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
                  FeatherIcons.eye,
                  color: Colors.deepOrange,
                ),
                trailing: Icon(
                  FeatherIcons.chevronRight,
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
            Divider(),
            userid != null
                ? Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        FeatherIcons.logOut,
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
                        storage.delete(key: 'storeid');
                        setState(() {
                          userid = null;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OnboardingScreen()),
                            ModalRoute.withName(Routes.settings));
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
