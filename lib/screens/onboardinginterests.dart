import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OnboardingInterests extends StatefulWidget {
  final String userid;

  OnboardingInterests({
    Key key,
    this.userid,
  }) : super(key: key);

  @override
  _OnboardingInterestsState createState() => new _OnboardingInterestsState();
}

class _OnboardingInterestsState extends State<OnboardingInterests> {
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:OnboardingInterests',
      screenClassOverride: 'AppOnboardingInterests',
    );
  }

  List<String> categoryimages = [
    'assets/interests/women.jpg',
    'assets/interests/men.jpg',
    'assets/interests/beauty.jpg',
    'assets/interests/electronics.jpg',
    'assets/interests/luxury.jpg',
    'assets/interests/home.jpeg',
    'assets/interests/vintage.jpg',
    'assets/interests/handmade.jpg',
    'assets/interests/garden.jpg',
    'assets/interests/kids.jpg',
    'assets/interests/sports.jpg',
    'assets/interests/toys.jpg',
  ];

  List<String> categories = [
    'Women',
    'Men',
    'Beauty',
    'Electronics',
    'Luxury',
    'Home',
    'Vintage',
    'Handmade',
    'Garden',
    'Kids',
    'Sports',
    'Toys',
  ];

  List<String> selectedinterests = List<String>();
  TextEditingController usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 20),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: false,
                        builder: (_) => new AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              content: Builder(
                                builder: (context) {
                                  return Container(
                                      height: 100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Loading..',
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                              height: 50,
                                              width: 50,
                                              child: SpinKitDoubleBounce(
                                                color: Colors.deepOrange,
                                              )),
                                        ],
                                      ));
                                },
                              ),
                            ));
                    final storage = new FlutterSecureStorage();
                    var userid = await storage.read(key: 'userid');
                    if (selectedinterests.length >= 2) {
                      var url =
                          'https://api.sellship.co/api/interests/' + userid;

                      FormData formData = FormData.fromMap({
                        'interests': selectedinterests,
                      });

                      FirebaseAnalytics analytics = FirebaseAnalytics();
                      await analytics.setUserProperty(
                          name: 'interests',
                          value: selectedinterests.toString());
                      Dio dio = new Dio();
                      var response = await dio.post(url, data: formData);

                      print(response.statusCode);

                      if (response.statusCode == 200) {
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RootScreen()),
                            ModalRoute.withName(Routes.settings));
                      } else {
                        print(response.statusCode);
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    decoration: BoxDecoration(
                      color: selectedinterests.length >= 2
                          ? Color.fromRGBO(255, 115, 0, 1)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Text(
                      'Start SellShipping',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ]),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(FeatherIcons.chevronLeft)),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Choose Interests',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, bottom: 10, top: 30, right: 16),
                    child: Text(
                      "Let's get to know you better",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Helvetica'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, bottom: 20, top: 10, right: 16),
                    child: Text(
                      "Please select atleast two categories that you are interested in.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blueGrey,
                          fontFamily: 'Helvetica'),
                    ),
                  ),
                ])),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.7),
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return new InkWell(
                    onTap: () {
                      if (selectedinterests.contains(categories[index])) {
                        selectedinterests.remove(categories[index]);
                      } else {
                        selectedinterests.add(categories[index]);
                      }
                      setState(() {
                        selectedinterests = selectedinterests;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color.fromRGBO(255, 115, 0, 0.7),
                                    width: 5),
                                borderRadius: BorderRadius.circular(60)),
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      categoryimages[index],
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    )),
                                selectedinterests.contains(categories[index])
                                    ? Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            border: Border.all(
                                                color: Colors.white, width: 5),
                                            borderRadius:
                                                BorderRadius.circular(60)),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 28,
                                        ))
                                    : Container(),
                              ],
                            )),
                        Container(
                          width: 120,
                          height: 50,
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Text(
                              categories[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ));

                // InkWell(
                //
                //     child: Column(
                //       children: [
                //         Stack(
                //           children: [
                //             Container(
                //               height: 100,
                //               width: 100,
                //               decoration: BoxDecoration(
                //                   color: Colors.white,
                //                   border: Border.all(
                //                       color: Color.fromRGBO(255, 115, 0, 0.7),
                //                       width: 5),
                //                   borderRadius: BorderRadius.circular(60)),
                //               child: ClipRRect(
                //                   borderRadius: BorderRadius.circular(60),
                //                   child: Image.asset(
                //                     categoryimages[index],
                //                     height: 120,
                //                     width: 120,
                //                     fit: BoxFit.cover,
                //                   )),
                //             ),
                //             selectedinterests.contains(categories[index])
                //                 ? Container(
                //                     height: MediaQuery.of(context).size.height,
                //                     width: MediaQuery.of(context).size.width,
                //                     color: Colors.black.withOpacity(0.6),
                //                     child: Icon(
                //                       Icons.check,
                //                       color: Colors.white,
                //                       size: 28,
                //                     ))
                //                 : Container(),
                //           ],
                //         ),
                //         Container(
                //           height: 50,
                //           width: 120,
                //           padding: EdgeInsets.all(5),
                //           child: Center(
                //             child: Text(
                //               categories[index],
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   fontFamily: 'Helvetica',
                //                   fontSize: 14,
                //                   color: Colors.black,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ));
              }, childCount: categoryimages.length),
            )
          ],
        ));
  }
}
