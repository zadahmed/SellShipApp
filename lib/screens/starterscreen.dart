import 'package:SellShip/screens/onboarding.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  final storage = new FlutterSecureStorage();

  final int _numPages = 4;
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

  final items = {
    'US': 'United States',
    'AE': 'United Arab Emirates',
    'GB': 'United Kingdom',
    'CA': 'Canada',
  };

  var selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Container(
          height: 80,
          width: 10,
          child: Image.asset(
            'assets/logotransparent.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
            height: MediaQuery.of(context).size.height / 2,
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
                      height: MediaQuery.of(context).size.height / 3,
                      width: 300.0,
                    ),
                  ),
                  Center(
                    child: Image(
                      image: AssetImage(
                        'assets/043.png',
                      ),
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height / 3,
                      width: 300.0,
                    ),
                  ),
                  Center(
                    child: Image(
                      image: AssetImage(
                        'assets/051.png',
                      ),
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height / 3,
                      width: 300.0,
                    ),
                  ),
                  Center(
                    child: Image(
                      image: AssetImage(
                        'assets/062.png',
                      ),
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height / 3,
                      width: 300.0,
                    ),
                  ),
                ])),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(),
        ),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Text(
            'Choose your country',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(),
          child: Center(
            child: Align(
              alignment: Alignment.center,
              child: DropdownButton(
                autofocus: true,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                icon: Icon(Icons.keyboard_arrow_down),
                hint: Center(
                  child: Text(
                    'Please choose a country',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
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
                                width:
                                    MediaQuery.of(context).size.width / 2 + 80,
                                child: ListTile(
                                  leading: Flag(
                                    e.key,
                                    height: 20,
                                    width: 30,
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
        SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () async {
            if (selectedItem != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seen', true);

              await storage
                  .write(key: 'country', value: selectedItem)
                  .whenComplete(() => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnboardingScreen()),
                      ));
            } else {
              showDialog(
                  context: context,
                  builder: (_) => AssetGiffyDialog(
                        image: Image.asset(
                          'assets/oops.gif',
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          'Oops!',
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.w600),
                        ),
                        description: Text(
                          'Make sure to choose your country!',
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                        onlyOkButton: true,
                        entryAnimation: EntryAnimation.DEFAULT,
                        onOkButtonPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                      ));
            }
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Center(
                child: Text(
                  'Done',
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

//        Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            InkWell(
//              onTap: () async {

//              },
//              child: Container(
//                  height: 100,
//                  width: 100,
//                  child: Column(
//                    children: <Widget>[
//                      ClipRRect(
//                        borderRadius: BorderRadius.circular(50.0),
//                        child: Image.asset('assets/uaeflag.png'),
//                      ),
//                      SizedBox(
//                        height: 5,
//                      ),
//                      Text(
//                        'UAE',
//                        style: TextStyle(
//                            fontFamily: 'Helvetica',
//                            fontSize: 16,
//                            color: Colors.white),
//                      )
//                    ],
//                  )),
//            ),
//            InkWell(
//              onTap: () async {
//                SharedPreferences prefs = await SharedPreferences.getInstance();
//                await prefs.setBool('seen', true);
//
//                await storage
//                    .write(key: 'country', value: 'United States')
//                    .whenComplete(() => Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) => OnboardingScreen()),
//                        ));
//              },
//              child: Container(
//                  height: 100,
//                  width: 100,
//                  child: Column(
//                    children: <Widget>[
//                      ClipRRect(
//                        borderRadius: BorderRadius.circular(50.0),
//                        child: Image.asset('assets/usaflag.png'),
//                      ),
//                      SizedBox(
//                        height: 5,
//                      ),
//                      Text(
//                        'USA',
//                        style: TextStyle(
//                            fontFamily: 'Helvetica',
//                            fontSize: 16,
//                            color: Colors.white),
//                      )
//                    ],
//                  )),
//            ),
//          ],
//        )
      ],
    ));
  }
}
