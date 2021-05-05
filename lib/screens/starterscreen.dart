import 'package:SellShip/screens/onboarding.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StarterPage extends StatefulWidget {
  @override
  _StarterPageState createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  bool _textVisible = true;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    _animation =
        Tween<double>(begin: 1.0, end: 25.0).animate(_animationController);

    super.initState();

    onesignal();
  }

  onesignal() async {
    bool allowed =
        await OneSignal.shared.promptUserForPushNotificationPermission();
    if (!allowed) {
      OneSignal.shared.promptUserForPushNotificationPermission();
    }
    await OneSignal.shared.sendTags({
      "device_type": "mobile",
    });
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  final storage = new FlutterSecureStorage();

  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepOrangeAccent : Colors.deepOrange,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  final items = {'AE': 'United Arab Emirates'};

  var selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'assets/bgonboard.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: PageView(
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: <Widget>[
                          Center(
                            child: Image(
                              image: AssetImage(
                                'assets/153.png',
                              ),
                              fit: BoxFit.cover,
                              height: 250,
                              width: 250,
                            ),
                          ),
                          Center(
                            child: Image(
                              image: AssetImage(
                                'assets/043.png',
                              ),
                              fit: BoxFit.cover,
                              height: 250,
                              width: 250,
                            ),
                          ),
                          Center(
                            child: Image(
                              image: AssetImage(
                                'assets/051.png',
                              ),
                              fit: BoxFit.cover,
                              height: 250,
                              width: 250,
                            ),
                          ),
                        ])),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                )
              ],
            )),
        Padding(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 18, top: 20, right: 18),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 60,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: MediaQuery.of(context).size.width - 50,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(131, 146, 165, 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Align(
                              alignment: Alignment.center,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  autofocus: true,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  hint: Center(
                                    child: Text(
                                      'Please choose a country',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  value: selectedItem,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedItem = value;
                                    });
                                  },
                                  items: items.entries
                                      .map<DropdownMenuItem<String>>(
                                          (MapEntry<String, String> e) =>
                                              DropdownMenuItem<String>(
                                                value: e.value,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2 +
                                                      70,
                                                  child: ListTile(
                                                    leading: Flag(
                                                      e.key,
                                                      height: 20,
                                                      width: 35,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    title: Text(e.value),
                                                  ),
                                                ),
                                              ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ])),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  if (selectedItem != null) {
//                    SharedPreferences prefs =
//                        await SharedPreferences.getInstance();
//                    await prefs.setBool('seen', true);

                  } else {
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
                                      height: 380,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 250,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.asset(
                                                'assets/oops.gif',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Oops!',
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  30,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      255, 115, 0, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color(0xFF9DA3B4)
                                                            .withOpacity(0.1),
                                                        blurRadius: 65.0,
                                                        offset:
                                                            Offset(0.0, 15.0))
                                                  ]),
                                              child: Center(
                                                child: Text(
                                                  "Close",
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop('dialog');
                                            },
                                          ),
                                        ],
                                      ));
                                },
                              ),
                            ));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 36, top: 30, right: 36),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width - 200,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 115, 0, 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: 40),
        ),
      ],
    ));
  }
}
