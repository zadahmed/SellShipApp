import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/notavaialablecountry.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as Location;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/activity.dart';
import 'package:SellShip/screens/chatpagebuyernav.dart';
import 'package:SellShip/screens/chatpagesellernavroute.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/onboardinginterests.dart';
import 'package:SellShip/screens/store/createstore.dart';
import 'package:SellShip/screens/store/createstorename.dart';
import 'package:SellShip/screens/storepage.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:SellShip/screens/additem.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/home.dart';
import 'package:SellShip/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class RootScreen extends StatefulWidget {
  int index;
  RootScreen({Key key, this.index}) : super(key: key);
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final storage = new FlutterSecureStorage();
  PageController pageController;
  int _currentPage = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    Search(),
    CreateStoreName(),
    // AddItem(),
    Activity(),
    ProfilePage(),
  ];

  final List<Widget> _storepages = [
    HomeScreen(),
    Search(),
    // CreateStoreName(),
    AddItem(),
    Activity(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  StreamSubscription<Map> streamSubscription;

  deeplinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey('+clicked_branch_link')) {
        if (data['source'] == 'item') {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Details(
                      itemid: data['itemid'],
                      image: data['itemimage'],
                      name: data['itemname'],
                      sold: data['itemsold'],
                      source: 'dynamic',
                    )),
          );
        } else if (data['source'] == 'store') {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Store(
                      storename: data['storename'],
                      storeid: data['storeid'],
                    )),
          );
        }
      }
    }, onError: (error) {
      print('InitSession error: ');
    });
  }

  var profilepicture;

  getuser() async {
    var userid = await storage.read(key: 'userid');
    storeid = await storage.read(key: 'storeid');

    await OneSignal.shared.setExternalUserId(userid);

    var status = await OneSignal.shared.getPermissionSubscriptionState();

    var playerId = status.subscriptionStatus.userId;

    if (userid != null) {
      var url = 'https://api.sellship.co/api/save/onesignalid/' +
          userid +
          '/' +
          playerId;
      final response = await http.get(url);
    }

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;
      final response = await http.get(url);
      var respons = json.decode(response.body);
      Map<String, dynamic> profilemap = respons;
      var profilepic = profilemap['profilepicture'];
      if (profilepic != null) {
        setState(() {
          profilepicture = profilepic;
          storeid = storeid;
        });
      } else {
        setState(() {
          profilepicture = null;
          storeid = null;
        });
      }
      var businesstier = profilemap['businesstier'];
      if (businesstier != null) {
        setState(() {
          businesstier = businesstier;
        });
      } else {
        setState(() {
          businesstier = 'secondhand';
        });
      }

      await storage.write(key: 'tier', value: businesstier);
    } else {
      setState(() {
        profilepicture = null;
      });
      await storage.write(key: 'tier', value: 'secondhand');
    }
  }

  checklocation() async {
    Location.Location _location = new Location.Location();

    var location = await _location.getLocation();

    var position =
        LatLng(location.latitude.toDouble(), location.longitude.toDouble());

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: 'en');

    Placemark place = placemarks[0];
    var countr = place.country;

    if (countr != 'United Arab Emirates') {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => NoAvailable()),
      );
    } else {}
  }

  initnotifs() async {
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      var jsonrep = result.notification.payload.additionalData;

      if (jsonrep['navroute'] == 'activitysell') {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatPageOfferNav(
                    messageid: jsonrep['navid'],
                    userid: jsonrep['itemid'],
                  )),
        );
      } else if (jsonrep['navroute'] == 'activitybuy') {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatPageViewBuyer(
                    messageid: jsonrep['navid'],
                    userid: jsonrep['itemid'],
                  )),
        );
      } else if (jsonrep['navroute'] == 'item') {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => Details(
                    itemid: jsonrep['itemid'],
                    image: jsonrep['itemimage'],
                    name: jsonrep['itemname'],
                    sold: false,
                    source: 'notifs',
                  )),
        );
      } else if (jsonrep['navroute'] == 'follow') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StorePublic(
                    storeid: jsonrep['storeid'],
                    storename: 'My Store',
                  )),
        );
      } else if (jsonrep['navroute'] == 'orderbuyer') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderBuyer(
                    itemid: jsonrep['itemid'],
                    messageid: jsonrep['messageid'],
                  )),
        );
      } else if (jsonrep['navroute'] == 'orderseller') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderSeller(
                    itemid: jsonrep['itemid'],
                    messageid: jsonrep['messageid'],
                  )),
        );
      } else if (jsonrep['navroute'] == 'comment') {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CommentsPage(
                      itemid: jsonrep['itemid'],
                    )));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    deeplinks();
    checklocation();
    initnotifs();
    setState(() {
      if (widget.index != null) {
        _currentPage = widget.index;
      }
    });
    pageController = new PageController(initialPage: _currentPage);
  }

  bool seenadditem;

  onselected() async {
    storeid = await storage.read(key: 'storeid');
    if (_currentPage == 0) {
      setState(() {
        storeid = storeid;
        home = 'assets/bottomnavbar/Home.svg';

        chat = 'assets/bottomnavbar/Chat.svg';
        selectedActivityColor = Colors.grey[400];
        selectedsearchColor = Colors.grey[400];
      });
    } else if (_currentPage == 1) {
      setState(() {
        storeid = storeid;
        home = 'assets/bottomnavbar/Homeselect.svg';
        selectedsearchColor = Color.fromRGBO(28, 45, 65, 1);
        chat = 'assets/bottomnavbar/Chat.svg';
        selectedActivityColor = Colors.grey[400];
      });
    } else if (_currentPage == 2) {
      setState(() {
        storeid = storeid;
        home = 'assets/bottomnavbar/Homeselect.svg';
        selectedsearchColor = Colors.grey[400];
        chat = 'assets/bottomnavbar/Chat.svg';
        selectedActivityColor = Colors.grey[400];
      });
    } else if (_currentPage == 3) {
      setState(() {
        storeid = storeid;
        home = 'assets/bottomnavbar/Homeselect.svg';

        chat = 'assets/bottomnavbar/Chatselect.svg';
        selectedActivityColor = Color.fromRGBO(28, 45, 65, 1);
        selectedsearchColor = Colors.grey[400];
      });
    } else if (_currentPage == 4) {
      setState(() {
        storeid = storeid;
        home = 'assets/bottomnavbar/Homeselect.svg';

        chat = 'assets/bottomnavbar/Chat.svg';
        selectedActivityColor = Colors.grey[400];
        selectedsearchColor = Colors.grey[400];
      });
    }
  }

  var selectedActivityColor;
  var selectedsearchColor;
  var home = 'assets/bottomnavbar/Home.svg';
  var discover = 'assets/bottomnavbar/Discover.svg';
  var storeid;
  var chat = 'assets/bottomnavbar/Chat.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.85),
        selectedItemColor: Color.fromRGBO(28, 45, 65, 1),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        selectedFontSize: 5,
        unselectedFontSize: 5,
        currentIndex: _currentPage,
        onTap: (i) async {
          if (i != 2) {
            if (seenadditem == true) {
              var check = await storage.read(key: 'additem');
              if (check != null) {
                showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (_) => new AlertDialog(
                          title: new Text("Are you sure you want to exit",
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Exit',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red)),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  seenadditem = false;
                                  storage.delete(key: 'additem');
                                  _currentPage = i;
                                  pageController.jumpToPage(i);
                                  onselected();
                                });
                              },
                            ),
                            FlatButton(
                              child: Text('Continue Editing',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ));
              } else {
                setState(() {
                  _currentPage = i;
                  onselected();
                  pageController.jumpToPage(i);
                });
              }
            } else {
              setState(() {
                _currentPage = i;
                onselected();
                pageController.jumpToPage(i);
              });
            }
          } else {
            setState(() {
              seenadditem = true;
              _currentPage = i;
              onselected();
              pageController.jumpToPage(i);
            });
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                home,
                height: 25,
                width: 25,
                allowDrawingOutsideViewBox: true,
              ),
              title: Text('',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))),
          BottomNavigationBarItem(
              icon: Icon(
                Feather.search,
                color: selectedsearchColor,
              ),
              title: Text('',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/bottomnavbar/plus.svg',
                height: 40,
                width: 40,
                allowDrawingOutsideViewBox: true,
              ),
              title: Text('',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))),
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.comments,
                color: selectedActivityColor,
              ),
              title: Text('',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))),
          BottomNavigationBarItem(
              icon: profilepicture != null && profilepicture.isNotEmpty
                  ? CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      radius: 17,
                      child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                height: 200,
                                width: 300,
                                imageUrl: profilepicture,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    SpinKitDoubleBounce(
                                        color: Colors.deepOrange),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ))))
                  : Icon(
                      FontAwesome.user_circle,
                      size: 25,
                    ),
              title: Text('',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))),
        ],
      ),
      body: PageView(
          physics: NeverScrollableScrollPhysics(),
          children: storeid == null ? _pages : _storepages,
          controller: pageController),
    );
  }
}
