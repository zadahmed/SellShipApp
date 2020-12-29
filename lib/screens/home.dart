import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/filter.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/search.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as Location;
import 'package:numeral/numeral.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  ScrollController _scrollController = ScrollController();

  var currency;

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<String> ites = List<String>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              if (profilemap[i] != null) {
                ites.add(profilemap[i]['_id']['\$oid']);
              }
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            setState(() {
              favourites = jsoninreverse;
            });
          } else {
            favourites = [];
          }
        }
      }
    } else {
      setState(() {
        favourites = [];
      });
    }
    print(favourites);
  }

  List<String> favourites;

  List<Item> below100list = List<Item>();

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/belowhundred/' +
        country +
        '/' +
        0.toString() +
        '/' +
        20.toString();

    final response = await http.get(url);
    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      below100list.add(item);
    }
    if (below100list != null) {
      setState(() {
        below100list = below100list;
      });
    } else {
      setState(() {
        below100list = [];
      });
    }

    return below100list;
  }

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://api.sellship.co/api/highestprice/' +
          country +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();
      final response = await http.get(url);

      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    }
  }

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://api.sellship.co/api/lowestprice/' +
          country +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();

      final response = await http.get(url);

      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    }
  }

  Future<List<Item>> fetchbrands(String brand) async {
    var categoryurl = 'https://api.sellship.co/api/filter/brand/' +
        country +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchCondition(String condition) async {
    var categoryurl = 'https://api.sellship.co/api/filter/condition/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchPrice(String minprice, String maxprice) async {
    var categoryurl = 'https://api.sellship.co/api/filter/price/' +
        country +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorecondition(String condition) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/condition/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorePrice(String minprice, String maxprice) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/price/' +
        country +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorebrands(String brand) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/brand/' +
        country +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var jsonbody = json.decode(categoryresponse.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldState.currentState?.removeCurrentSnackBar();
    scaffoldState.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/highestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/lowestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  _getmorebelowhundred() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/belowhundred/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );

      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
    if (itemsgrid == itemsgrid) {
      print('No New Items');
    }
  }

  LatLng position;
  bool loading;

  final storage = new FlutterSecureStorage();

  TabController _tabController;
  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 40;
      loading = true;
      notifbadge = false;
      notbadge = false;
    });
    _tabController = new TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));

    gettopdata();
    readstorage();
  }

  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];

  String _selectedCondition;

  PersistentBottomSheetController _bottomsheetcontroller;

  _getLocation() async {
    Location.Location _location = new Location.Location();
    var location;

    try {
      location = await _location.getLocation();
      await storage.write(key: 'latitude', value: location.latitude.toString());
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      var userid = await storage.read(key: 'userid');

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

      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());
        getcity();
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: 'en');

      Placemark place = placemarks[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      await OneSignal.shared.sendTags({
        "country": countr,
      });
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'locationcountry', value: countr);
      setState(() {
        city = cit;
        locationcountry = countr;
      });
      fetchnearme(skip, limit);
    } on Exception catch (e) {
      print(e);
      Location.Location().requestPermission();
      setState(() {
        loading = false;
      });
    }
  }

  String locationcountry;
  String country;

  String brand;
  String minprice;
  String maxprice;
  String condition;

  bool gridtoggle = true;

  final scaffoldState = GlobalKey<ScaffoldState>();

  void getcity() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: 'en');

    Placemark place = placemarks[0];
    var cit = place.administrativeArea;
    var countr = place.country;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'locationcountry', value: countr);

    setState(() {
      city = cit;
      locationcountry = countr;
    });
  }

  String city;
  var notcount;

  PersistentBottomSheetController bottomsheetcontroller;

  bool notbadge;

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/getnotification/' + userid;

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var notificationinfo = json.decode(response.body);
        var notif = notificationinfo['notification'];
        var notcoun = notificationinfo['notcount'];
        if (notif <= 0) {
          setState(() {
            notifcount = notif;
            notifbadge = false;
          });
          FlutterAppBadger.removeBadge();
        } else if (notif > 0) {
          setState(() {
            notifcount = notif;
            notifbadge = true;
          });
        }

        print(notifcount);

        if (notcoun <= 0) {
          setState(() {
            notcount = notcoun;
            notbadge = false;
          });
          FlutterAppBadger.removeBadge();
        } else if (notcoun > 0) {
          setState(() {
            notcount = notcoun;
            notbadge = true;
          });
        }

        print(notcount);

        FlutterAppBadger.updateBadgeCount(notifcount + notcount);
      } else {
        print(response.statusCode);
      }
    }
  }

  var notifcount;
  var notifbadge;

  void readstorage() async {
    getnotification();
    getfavourites();
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
      });
    }
    setState(() {
      country = countr;
    });

    fetchRecentlyAdded(skip, limit);
    fetchbelowhundred(skip, limit);

    _getLocation();
  }

  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();
  TextEditingController searchcontroller = new TextEditingController();

  var crossaxiscount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Container(
              height: 40,
              width: 180,
              child: Image.asset(
                'assets/logotransparent.png',
                fit: BoxFit.cover,
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Badge(
                showBadge: notbadge,
                position: BadgePosition.topEnd(top: 2, end: -4),
                animationType: BadgeAnimationType.slide,
                badgeContent: Text(
                  notcount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotifcationPage()),
                    );
                  },
                  child: Icon(
                    Feather.bell,
                    color: Color.fromRGBO(28, 45, 65, 1),
                    size: 24,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
//              Padding(
//                child: InkWell(
//                  onTap: () {
//                    _bottomsheetcontroller =
//                        scaffoldState.currentState.showBottomSheet((context) {
//                      return Container(
//                          decoration: BoxDecoration(
//                              border:
//                                  Border.all(width: 0.2, color: Colors.grey),
//                              borderRadius: BorderRadius.circular(20),
//                              color: Colors.white),
//                          height: 525,
//                          width: MediaQuery.of(context).size.width,
//                          child: Padding(
//                              padding: const EdgeInsets.all(1.0),
//                              child: Column(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  children: [
//                                    SizedBox(
//                                      height: 5,
//                                    ),
//                                    AppBar(
//                                      title: Text('Filter',
//                                          style: TextStyle(
//                                            fontFamily: 'Helvetica',
//                                            fontSize: 18,
//                                            fontWeight: FontWeight.bold,
//                                            color:
//                                                Color.fromRGBO(28, 45, 65, 1),
//                                          )),
//                                      elevation: 0.5,
//                                      backgroundColor: Colors.white,
//                                      excludeHeaderSemantics: true,
//                                      automaticallyImplyLeading: false,
//                                      actions: [
//                                        Padding(
//                                            padding: EdgeInsets.all(15),
//                                            child: InkWell(
//                                                onTap: () {
//                                                  Navigator.pop(context);
//                                                },
//                                                child: Text('Done',
//                                                    style: TextStyle(
//                                                      fontFamily: 'Helvetica',
//                                                      fontSize: 18,
//                                                      color: Color.fromRGBO(
//                                                          28, 45, 65, 1),
//                                                    ))))
//                                      ],
//                                    ),
//                                    Padding(
//                                        padding:
//                                            const EdgeInsets.only(top: 10.0),
//                                        child: Row(
//                                            crossAxisAlignment:
//                                                CrossAxisAlignment.start,
//                                            children: <Widget>[
//                                              Container(
//                                                width: MediaQuery.of(context)
//                                                        .size
//                                                        .width *
//                                                    0.2,
//                                                height: 450,
//                                                child: ListView(
//                                                  scrollDirection:
//                                                      Axis.vertical,
//                                                  children: [
//                                                    Container(
//                                                        width: MediaQuery.of(
//                                                                context)
//                                                            .size
//                                                            .width,
//                                                        child: InkWell(
//                                                          child: Column(
//                                                            mainAxisAlignment:
//                                                                MainAxisAlignment
//                                                                    .center,
//                                                            crossAxisAlignment:
//                                                                CrossAxisAlignment
//                                                                    .center,
//                                                            children: <Widget>[
//                                                              Align(
//                                                                alignment: Alignment
//                                                                    .bottomCenter,
//                                                                child: Text(
//                                                                  'Sort',
//                                                                  style: TextStyle(
//                                                                      fontFamily:
//                                                                          'Helvetica',
//                                                                      fontSize:
//                                                                          14,
//                                                                      color: Color
//                                                                          .fromRGBO(
//                                                                              28,
//                                                                              45,
//                                                                              65,
//                                                                              1),
//                                                                      fontWeight:
//                                                                          FontWeight
//                                                                              .w600),
//                                                                  textAlign:
//                                                                      TextAlign
//                                                                          .center,
//                                                                ),
//                                                              ),
//                                                              Divider()
//                                                            ],
//                                                          ),
//                                                          onTap: () {
//                                                            _bottomsheetcontroller
//                                                                .setState(() {
//                                                              _filter = 'Sort';
//                                                            });
//                                                          },
//                                                        )),
//                                                    Container(
//                                                        width: MediaQuery.of(
//                                                                context)
//                                                            .size
//                                                            .width,
//                                                        child: InkWell(
//                                                          child: Column(
//                                                            mainAxisAlignment:
//                                                                MainAxisAlignment
//                                                                    .center,
//                                                            crossAxisAlignment:
//                                                                CrossAxisAlignment
//                                                                    .center,
//                                                            children: <Widget>[
//                                                              Align(
//                                                                alignment: Alignment
//                                                                    .bottomCenter,
//                                                                child: Text(
//                                                                  'Brand',
//                                                                  style: TextStyle(
//                                                                      fontFamily:
//                                                                          'Helvetica',
//                                                                      fontSize:
//                                                                          14,
//                                                                      color: Color
//                                                                          .fromRGBO(
//                                                                              28,
//                                                                              45,
//                                                                              65,
//                                                                              1),
//                                                                      fontWeight:
//                                                                          FontWeight
//                                                                              .w600),
//                                                                  textAlign:
//                                                                      TextAlign
//                                                                          .center,
//                                                                ),
//                                                              ),
//                                                              Divider()
//                                                            ],
//                                                          ),
//                                                          onTap: () async {
//                                                            brands.clear();
//                                                            var categoryurl =
//                                                                'https://api.sellship.co/api/getallbrands';
//                                                            final categoryresponse =
//                                                                await http.get(
//                                                                    categoryurl);
//                                                            if (categoryresponse
//                                                                    .statusCode ==
//                                                                200) {
//                                                              var categoryrespons =
//                                                                  json.decode(
//                                                                      categoryresponse
//                                                                          .body);
//
//                                                              for (int i = 0;
//                                                                  i <
//                                                                      categoryrespons
//                                                                          .length;
//                                                                  i++) {
//                                                                brands.add(
//                                                                    categoryrespons[
//                                                                        i]);
//                                                              }
//                                                              _bottomsheetcontroller
//                                                                  .setState(() {
//                                                                brands = brands;
//                                                              });
//                                                            } else {
//                                                              print(categoryresponse
//                                                                  .statusCode);
//                                                            }
//                                                            _bottomsheetcontroller
//                                                                .setState(() {
//                                                              _filter = 'Brand';
//                                                            });
//                                                          },
//                                                        )),
//                                                    Container(
//                                                        width: MediaQuery.of(
//                                                                context)
//                                                            .size
//                                                            .width,
//                                                        child: InkWell(
//                                                          child: Column(
//                                                            mainAxisAlignment:
//                                                                MainAxisAlignment
//                                                                    .center,
//                                                            crossAxisAlignment:
//                                                                CrossAxisAlignment
//                                                                    .center,
//                                                            children: <Widget>[
//                                                              Align(
//                                                                alignment: Alignment
//                                                                    .bottomCenter,
//                                                                child: Text(
//                                                                  'Condition',
//                                                                  style: TextStyle(
//                                                                      fontFamily:
//                                                                          'Helvetica',
//                                                                      fontSize:
//                                                                          14,
//                                                                      color: Color
//                                                                          .fromRGBO(
//                                                                              28,
//                                                                              45,
//                                                                              65,
//                                                                              1),
//                                                                      fontWeight:
//                                                                          FontWeight
//                                                                              .w600),
//                                                                  textAlign:
//                                                                      TextAlign
//                                                                          .center,
//                                                                ),
//                                                              ),
//                                                              Divider()
//                                                            ],
//                                                          ),
//                                                          onTap: () {
//                                                            _bottomsheetcontroller
//                                                                .setState(() {
//                                                              _filter =
//                                                                  'Condition';
//                                                            });
//                                                          },
//                                                        )),
//                                                    Container(
//                                                        width: MediaQuery.of(
//                                                                context)
//                                                            .size
//                                                            .width,
//                                                        child: InkWell(
//                                                          child: Column(
//                                                            mainAxisAlignment:
//                                                                MainAxisAlignment
//                                                                    .center,
//                                                            crossAxisAlignment:
//                                                                CrossAxisAlignment
//                                                                    .center,
//                                                            children: <Widget>[
//                                                              Align(
//                                                                alignment: Alignment
//                                                                    .bottomCenter,
//                                                                child: Text(
//                                                                  'Price',
//                                                                  style: TextStyle(
//                                                                      fontFamily:
//                                                                          'Helvetica',
//                                                                      fontSize:
//                                                                          14,
//                                                                      color: Color
//                                                                          .fromRGBO(
//                                                                              28,
//                                                                              45,
//                                                                              65,
//                                                                              1),
//                                                                      fontWeight:
//                                                                          FontWeight
//                                                                              .w600),
//                                                                  textAlign:
//                                                                      TextAlign
//                                                                          .center,
//                                                                ),
//                                                              ),
//                                                              Divider()
//                                                            ],
//                                                          ),
//                                                          onTap: () {
//                                                            _bottomsheetcontroller
//                                                                .setState(() {
//                                                              _filter = 'Price';
//                                                            });
//                                                          },
//                                                        )),
//                                                  ],
//                                                ),
//                                              ),
//                                              filters(context)
//                                            ]))
//                                  ])));
//                    });
//                  },
//                  child: CircleAvatar(
//                    backgroundColor: Color.fromRGBO(255, 115, 0, 0.2),
//                    child: SvgPicture.asset(
//                        'assets/bottomnavbar/sound-module-fill.svg'),
//                  ),
//                ),

//                padding: EdgeInsets.only(right: 10),
//              )
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Search()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Icon(
                    Feather.shopping_bag,
                    size: 24,
                    color: Color.fromRGBO(28, 45, 65, 1),
                  ),
                ),
              )
            ]),
        body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        pinned: true,
                        title: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.circular(20))),
                          child: Center(
                            child: TabBar(
                              controller: _tabController,
                              labelStyle: tabTextStyle,
                              unselectedLabelStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Helvetica',
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                      width: 2.0, color: Colors.deepOrange)),
                              isScrollable: true,
                              labelColor: Colors.black,
                              tabs: [
                                new Tab(
                                  text: 'Discover',
                                ),
                                new Tab(
                                  text: 'For You',
                                ),
                              ],
                            ),
                          ),
                        )),
                  ];
                },
                body: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(229, 233, 242, 1).withOpacity(0.5),
                    ),
                    child: Container(
                        padding: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: TabBarView(
                            controller: _tabController,
                            children: [
                              homePage(context),
                              foryouPage(context)
                            ]))))));
  }

  String view = 'home';

  Widget foryouPage(BuildContext context) {
    return loading == false
        ? EasyRefresh.custom(
            topBouncing: true,
            footer: MaterialFooter(
              enableInfiniteLoad: true,
              enableHapticFeedback: true,
            ),
            slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Text('For You'),
                )
              ])
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: ListView(
                  children: [0, 1, 2, 3, 4, 5, 6]
                      .map((_) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ));
  }

  Widget homePage(BuildContext context) {
    return loading == false
        ? EasyRefresh.custom(
            topBouncing: true,
            footer: MaterialFooter(
              enableInfiniteLoad: true,
              enableHapticFeedback: true,
            ),
            slivers: <Widget>[
              topitems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16, top: 10, bottom: 10, right: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Top Picks',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          )),
                    )
                  : SliverToBoxAdapter(),
              topitems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: 20,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  new InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid:
                                                      topitems[index].itemid,
                                                  sold: topitems[index].sold,
                                                )),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 150,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(microseconds: 5),
                                            imageUrl: topitems[index]
                                                    .image
                                                    .isEmpty
                                                ? SpinKitChasingDots(
                                                    color: Colors.deepOrange)
                                                : topitems[index].image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitChasingDots(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      topitems[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ))
                                          : Container(),
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topitems[index].name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Text(
                                            currency +
                                                ' ' +
                                                topitems[index].price,
                                          )
                                        ],
                                      )),
                                      favourites != null
                                          ? favourites.contains(
                                                  topitems[index].itemid)
                                              ? InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            topitems[index]
                                                                .itemid,
                                                      };

                                                      favourites.remove(
                                                          topitems[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        topitems[index].likes =
                                                            topitems[index]
                                                                    .likes -
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.deepPurple,
                                                    child: Icon(
                                                      FontAwesome.heart,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ))
                                              : InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            topitems[index]
                                                                .itemid,
                                                      };

                                                      favourites.add(
                                                          topitems[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        topitems[index].likes =
                                                            topitems[index]
                                                                    .likes +
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Feather.heart,
                                                      color: Colors.blueGrey,
                                                      size: 16,
                                                    ),
                                                  ))
                                          : CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Feather.heart,
                                                color: Colors.blueGrey,
                                                size: 16,
                                              ),
                                            )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                  : SliverToBoxAdapter(),
              SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16, top: 10, bottom: 10, right: 36),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Shop by Category',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    )),
              ),
              nearmeItems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16, top: 10, bottom: 10, right: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Near You',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          )),
                    )
                  : SliverToBoxAdapter(),
              nearmeItems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: nearmeItems.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  new InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid:
                                                      nearmeItems[index].itemid,
                                                  sold: nearmeItems[index].sold,
                                                )),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 150,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(microseconds: 5),
                                            imageUrl: nearmeItems[index]
                                                    .image
                                                    .isEmpty
                                                ? SpinKitChasingDots(
                                                    color: Colors.deepOrange)
                                                : nearmeItems[index].image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitChasingDots(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      nearmeItems[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ))
                                          : Container(),
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nearmeItems[index].name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Text(
                                            currency +
                                                ' ' +
                                                nearmeItems[index].price,
                                          )
                                        ],
                                      )),
                                      favourites != null
                                          ? favourites.contains(
                                                  nearmeItems[index].itemid)
                                              ? InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            nearmeItems[index]
                                                                .itemid,
                                                      };

                                                      favourites.remove(
                                                          topitems[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        nearmeItems[index]
                                                                .likes =
                                                            nearmeItems[index]
                                                                    .likes -
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.deepPurple,
                                                    child: Icon(
                                                      FontAwesome.heart,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ))
                                              : InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            nearmeItems[index]
                                                                .itemid,
                                                      };

                                                      favourites.add(
                                                          nearmeItems[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        nearmeItems[index]
                                                                .likes =
                                                            nearmeItems[index]
                                                                    .likes +
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Feather.heart,
                                                      color: Colors.blueGrey,
                                                      size: 16,
                                                    ),
                                                  ))
                                          : CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Feather.heart,
                                                color: Colors.blueGrey,
                                                size: 16,
                                              ),
                                            )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                  : SliverToBoxAdapter(),
              SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16, top: 10, bottom: 10, right: 36),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Deals under 100',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    )),
              ),
              below100list.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: below100list.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  new InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid: below100list[index]
                                                      .itemid,
                                                  sold:
                                                      below100list[index].sold,
                                                )),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 150,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(microseconds: 5),
                                            imageUrl: below100list[index]
                                                    .image
                                                    .isEmpty
                                                ? SpinKitChasingDots(
                                                    color: Colors.deepOrange)
                                                : below100list[index].image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitChasingDots(
                                                    color: Colors.deepOrange),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      below100list[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurpleAccent
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ))
                                          : Container(),
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            below100list[index].name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Text(
                                            currency +
                                                ' ' +
                                                below100list[index].price,
                                          )
                                        ],
                                      )),
                                      favourites != null
                                          ? favourites.contains(
                                                  below100list[index].itemid)
                                              ? InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            below100list[index]
                                                                .itemid,
                                                      };

                                                      favourites.remove(
                                                          below100list[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        below100list[index]
                                                                .likes =
                                                            below100list[index]
                                                                    .likes -
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.deepPurple,
                                                    child: Icon(
                                                      FontAwesome.heart,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ))
                                              : InkWell(
                                                  enableFeedback: true,
                                                  onTap: () async {
                                                    var userid = await storage
                                                        .read(key: 'userid');

                                                    if (userid != null) {
                                                      var url =
                                                          'https://api.sellship.co/api/favourite/' +
                                                              userid;

                                                      Map<String, String> body =
                                                          {
                                                        'itemid':
                                                            below100list[index]
                                                                .itemid,
                                                      };

                                                      favourites.add(
                                                          below100list[index]
                                                              .itemid);
                                                      setState(() {
                                                        favourites = favourites;
                                                        below100list[index]
                                                                .likes =
                                                            below100list[index]
                                                                    .likes +
                                                                1;
                                                      });
                                                      final response =
                                                          await http.post(url,
                                                              body: body);

                                                      if (response.statusCode ==
                                                          200) {
                                                      } else {
                                                        print(response
                                                            .statusCode);
                                                      }
                                                    } else {
                                                      showInSnackBar(
                                                          'Please Login to use Favourites');
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Feather.heart,
                                                      color: Colors.blueGrey,
                                                      size: 16,
                                                    ),
                                                  ))
                                          : CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Feather.heart,
                                                color: Colors.blueGrey,
                                                size: 16,
                                              ),
                                            )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                  : SliverToBoxAdapter(),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 36),
                  child: Text(
                    'New In',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                    crossAxisCount: 2,
                    childAspectRatio: 1),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index != 0 && index % 8 == 0) {
                      return Platform.isIOS == true
                          ? Padding(
                              padding: EdgeInsets.all(7),
                              child: Container(
                                height: 200,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: NativeAdmob(
                                  adUnitID: _iosadUnitID,
                                  controller: _controller,
                                ),
                              ))
                          : Padding(
                              padding: EdgeInsets.all(7),
                              child: Container(
                                height: 200,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: NativeAdmob(
                                  adUnitID: _androidadUnitID,
                                  controller: _controller,
                                ),
                              ));
                    }

                    return new Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            new InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: itemsgrid[index].itemid,
                                            sold: itemsgrid[index].sold,
                                          )),
                                );
                              },
                              child: Stack(children: <Widget>[
                                Container(
                                  height: 150,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      fadeInDuration: Duration(microseconds: 5),
                                      imageUrl: itemsgrid[index].image.isEmpty
                                          ? SpinKitChasingDots(
                                              color: Colors.deepOrange)
                                          : itemsgrid[index].image,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          SpinKitChasingDots(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                itemsgrid[index].sold == true
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurpleAccent
                                                .withOpacity(0.8),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: Text(
                                              'Sold',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ))
                                    : Container(),
                              ]),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemsgrid[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      currency + ' ' + itemsgrid[index].price,
                                    )
                                  ],
                                )),
                                favourites != null
                                    ? favourites
                                            .contains(itemsgrid[index].itemid)
                                        ? InkWell(
                                            enableFeedback: true,
                                            onTap: () async {
                                              var userid = await storage.read(
                                                  key: 'userid');

                                              if (userid != null) {
                                                var url =
                                                    'https://api.sellship.co/api/favourite/' +
                                                        userid;

                                                Map<String, String> body = {
                                                  'itemid':
                                                      itemsgrid[index].itemid,
                                                };

                                                favourites.remove(
                                                    itemsgrid[index].itemid);
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes -
                                                          1;
                                                });
                                                final response = await http
                                                    .post(url, body: body);

                                                if (response.statusCode ==
                                                    200) {
                                                } else {
                                                  print(response.statusCode);
                                                }
                                              } else {
                                                showInSnackBar(
                                                    'Please Login to use Favourites');
                                              }
                                            },
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Colors.deepPurple,
                                              child: Icon(
                                                FontAwesome.heart,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ))
                                        : InkWell(
                                            enableFeedback: true,
                                            onTap: () async {
                                              var userid = await storage.read(
                                                  key: 'userid');

                                              if (userid != null) {
                                                var url =
                                                    'https://api.sellship.co/api/favourite/' +
                                                        userid;

                                                Map<String, String> body = {
                                                  'itemid':
                                                      itemsgrid[index].itemid,
                                                };

                                                favourites.add(
                                                    itemsgrid[index].itemid);
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes +
                                                          1;
                                                });
                                                final response = await http
                                                    .post(url, body: body);

                                                if (response.statusCode ==
                                                    200) {
                                                } else {
                                                  print(response.statusCode);
                                                }
                                              } else {
                                                showInSnackBar(
                                                    'Please Login to use Favourites');
                                              }
                                            },
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Feather.heart,
                                                color: Colors.blueGrey,
                                                size: 16,
                                              ),
                                            ))
                                    : CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Feather.heart,
                                          color: Colors.blueGrey,
                                          size: 16,
                                        ),
                                      )
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    );
                  },
                  childCount: itemsgrid.length,
                ),
              )
            ],
            onLoad: () async {
              _getmoreRecentData();
            },
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: ListView(
                  children: [0, 1, 2, 3, 4, 5, 6]
                      .map((_) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
  }

  List<Item> topitems = List<Item>();

  gettopdata() async {
    var country = await storage.read(key: 'country');
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/top/' +
        country +
        '/' +
        userid +
        '/' +
        '0' +
        '/' +
        '20';

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          userid: jsonbody[i]['userid'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        topitems.add(item);
      }

      if (topitems != null) {
        setState(() {
          topitems = topitems;
        });
      } else {
        setState(() {
          topitems = [];
        });
      }
    } else {
      print('error');
    }
  }

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 40;
      skip = skip + 40;
    });

    var country = await storage.read(key: 'country');

    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          date: dateuploaded,
          name: jsonbody[i]['name'],
          condition: jsonbody[i]['condition'] == null
              ? 'Like New'
              : jsonbody[i]['condition'],
          username: jsonbody[i]['username'],
          image: jsonbody[i]['image'],
          userid: jsonbody[i]['userid'],
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        itemsgrid.add(item);
      }

      if (itemsgrid != null) {
        setState(() {
          itemsgrid = itemsgrid;
          loading = false;
        });
      } else {
        setState(() {
          itemsgrid = [];
          loading = false;
        });
      }
    } else {
      print(response.statusCode);
    }
  }

  String _FilterLoad = "Recently Added";
  String _selectedFilter = "Recently Added";

  String _filter = 'Sort';

  Widget filters(BuildContext context) {
    if (_filter == 'Sort') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 2,
              ),
              ListTile(
                title: Text(
                  'Sort by Price Low to High',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Filtered(
                              filter: 'Lowest Price',
                            )),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Sort by Price High to Low',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Filtered(
                              filter: 'Highest Price',
                            )),
                  );
                },
              ),
            ],
          ));
    } else if (_filter == 'Condition') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                      height: 450,
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: conditions.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Filtered(
                                          filter: 'Condition',
                                          condition: conditions[index],
                                        )),
                              );
                            },
                            child: ListTile(
                              title: conditions[index] != null
                                  ? Text(
                                      conditions[index],
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text('sd'),
                            ),
                          );
                        },
                      ))
                ],
              ),
            ),
          ));
    } else if (_filter == 'Price') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: ListTile(
                          title: Text(
                            'Minimum Price',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                              width: 100,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: minpricecontroller,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                      labelText: "Price " + currency,
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                      focusColor: Colors.black,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                                ),
                              )))),
                  SizedBox(
                    height: 2,
                  ),
                  Center(
                      child: ListTile(
                          title: Text(
                            'Maximum Price',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                              width: 100,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: maxpricecontroller,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                      labelText: "Price " + currency,
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                      ),
                                      focusColor: Colors.black,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                                ),
                              )))),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Filtered(
                                        filter: 'Price',
                                        minprice: minpricecontroller.text,
                                        maxprice: maxpricecontroller.text,
                                      )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.deepOrangeAccent),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                'Filter',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ),
                          ))),
                ],
              ))));
    } else if (_filter == 'Brand') {
      return Container(
          color: Color.fromRGBO(229, 233, 242, 0.5),
          width: MediaQuery.of(context).size.width * 0.8 - 5,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
//                  height: 600,
                    child: AlphabetListScrollView(
                  showPreview: true,
                  strList: brands,
                  indexedHeight: (i) {
                    return 40;
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Filtered(
                                    filter: 'Brand',
                                    brand: brands[index],
                                  )),
                        );

                        fetchbrands(brands[index]);
                      },
                      child: ListTile(
                        title: brands[index] != null
                            ? Text(
                                brands[index],
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                ),
                              )
                            : Text('No Brand'),
                      ),
                    );
                  },
                ))
              ],
            ),
          ));
    }
  }

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        userid: jsonbody[i]['userid'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }

    setState(() {
      loading = false;
      itemsgrid = itemsgrid;
    });

    return itemsgrid;
  }

  Future<List<Item>> fetchnearme(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/getitems/' +
        country +
        '/' +
        0.toString() +
        '/' +
        20.toString();

    final response = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    });

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        userid: jsonbody[i]['userid'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      nearmeItems.add(item);
    }

    setState(() {
      nearmeItems = nearmeItems;
    });

    return nearmeItems;
  }

  List<Item> nearmeItems = List<Item>();

  List<String> brands = List<String>();

  TextEditingController searchcontrollerr = TextEditingController();

  loadbrands() async {
    brands.clear();
    var categoryurl = 'https://api.sellship.co/api/getallbrands';
    final categoryresponse = await http.get(categoryurl);
    if (categoryresponse.statusCode == 200) {
      var categoryrespons = json.decode(categoryresponse.body);
      print(categoryrespons);
      for (int i = 0; i < categoryrespons.length; i++) {
        brands.add(categoryrespons[i]);
      }
      setState(() {
        brands = brands;
      });
    } else {
      print(categoryresponse.statusCode);
    }

    scaffoldState.currentState.showBottomSheet((context) {
      return Container(
        height: 550,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Feather.chevron_down),
              SizedBox(
                height: 2,
              ),
              Center(
                child: Text(
                  'Brand',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      color: Colors.deepOrange),
                ),
              ),
              Flexible(
//                  height: 600,
                  child: AlphabetListScrollView(
                showPreview: true,
                strList: brands,
                indexedHeight: (i) {
                  return 40;
                },
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        _selectedFilter = 'Brand';
                        _FilterLoad = "Brand";
                        brand = brands[index];
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();
                      Navigator.of(context).pop();

                      fetchbrands(brands[index]);
                    },
                    child: ListTile(
                      title: brands[index] != null
                          ? Text(brands[index])
                          : Text('sd'),
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      );
    });
  }
}

class UserSearchDelegate extends SearchDelegate {
  final String country;

  UserSearchDelegate(this.country);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon((Icons.clear)),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  @override
  Widget buildResults(BuildContext context) {
    getfavourites();
    return StreamBuilder<List<Item>>(
        stream: getItemsSearch(query).asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return EasyRefresh.custom(
              topBouncing: true,
              footer: MaterialFooter(
                enableInfiniteLoad: true,
                enableHapticFeedback: true,
              ),
              slivers: <Widget>[
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                    crossAxisCount: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index != 0 && index % 8 == 0) {
                        return Platform.isIOS == true
                            ? Padding(
                                padding: EdgeInsets.all(7),
                                child: Container(
                                  height: 220,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 20.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.2, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: NativeAdmob(
                                    adUnitID: _iosadUnitID,
                                    controller: _controller,
                                  ),
                                ))
                            : Padding(
                                padding: EdgeInsets.all(7),
                                child: Container(
                                  height: 220,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 20.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.2, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: NativeAdmob(
                                    adUnitID: _androidadUnitID,
                                    controller: _controller,
                                  ),
                                ));
                      }

                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return new Padding(
                            padding: EdgeInsets.all(7),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Details(
                                            itemid: snapshot.data[index].itemid,
                                            sold: snapshot.data[index].sold,
                                          )),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.2, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    new Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 199,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: snapshot
                                                      .data[index].image.isEmpty
                                                  ? SpinKitChasingDots(
                                                      color: Colors.deepOrange)
                                                  : snapshot.data[index].image,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SpinKitChasingDots(
                                                      color: Colors.deepOrange),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        snapshot.data[index].sold == true
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .deepPurpleAccent
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10)),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Center(
                                                    child: Text(
                                                      'Sold',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            : favourites != null
                                                ? favourites.contains(
                                                        itemsgrid[index].itemid)
                                                    ? InkWell(
                                                        enableFeedback: true,
                                                        onTap: () async {
                                                          var userid =
                                                              await storage.read(
                                                                  key:
                                                                      'userid');

                                                          if (userid != null) {
                                                            var url =
                                                                'https://api.sellship.co/api/favourite/' +
                                                                    userid;

                                                            Map<String, String>
                                                                body = {
                                                              'itemid':
                                                                  itemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.remove(
                                                                itemsgrid[index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              itemsgrid[index]
                                                                      .likes =
                                                                  itemsgrid[index]
                                                                          .likes -
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                            } else {
                                                              print(response
                                                                  .statusCode);
                                                            }
                                                          } else {
                                                            print(
                                                                'Please Login to use Favourites');
                                                          }
                                                        },
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                    FontAwesome
                                                                        .heart,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                    : InkWell(
                                                        enableFeedback: true,
                                                        onTap: () async {
                                                          var userid =
                                                              await storage.read(
                                                                  key:
                                                                      'userid');

                                                          if (userid != null) {
                                                            var url =
                                                                'https://api.sellship.co/api/favourite/' +
                                                                    userid;

                                                            Map<String, String>
                                                                body = {
                                                              'itemid':
                                                                  itemsgrid[
                                                                          index]
                                                                      .itemid,
                                                            };

                                                            favourites.add(
                                                                itemsgrid[index]
                                                                    .itemid);
                                                            setState(() {
                                                              favourites =
                                                                  favourites;
                                                              itemsgrid[index]
                                                                      .likes =
                                                                  itemsgrid[index]
                                                                          .likes +
                                                                      1;
                                                            });
                                                            final response =
                                                                await http.post(
                                                                    url,
                                                                    body: body);

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                            } else {
                                                              print(response
                                                                  .statusCode);
                                                            }
                                                          } else {
                                                            print(
                                                                'Please Login to use Favourites');
                                                          }
                                                        },
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 18,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Icon(
                                                                    Feather
                                                                        .heart,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    size: 16,
                                                                  ),
                                                                ))))
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Feather.heart,
                                                            color:
                                                                Colors.blueGrey,
                                                            size: 16,
                                                          ),
                                                        ))),
                                      ],
                                    ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: snapshot.data.length,
                  ),
                )
              ],
              onLoad: () async {
                getmoreItemsSearch(query);
              },
            );
          } else {
            return Container();
          }
        });
  }

  var skip = 0;
  var limit = 20;

  List<Item> itemsgrid = List<Item>();

  Future<List<Item>> getItemsSearch(String text) async {
    itemsgrid.clear();
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    print(jsonbody.length);
    for (var i = 0; i < jsonbody.length; i++) {
      var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

      DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
      var dateuploaded = timeago.format(dateuploade);
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        date: dateuploaded,
        name: jsonbody[i]['name'],
        condition: jsonbody[i]['condition'] == null
            ? 'Like New'
            : jsonbody[i]['condition'],
        username: jsonbody[i]['username'],
        image: jsonbody[i]['image'],
        likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
        comments: jsonbody[i]['comments'] == null
            ? 0
            : jsonbody[i]['comments'].length,
        price: jsonbody[i]['price'].toString(),
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    print(itemsgrid);
//    responseJson.add(text);
    return itemsgrid;
  }

  Future<List> getmoreItemsSearch(String text) async {
    skip = skip + 20;
    limit = limit + 20;
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    List responseJson = json.decode(response.body.toString());
    print(responseJson);
//    responseJson.add(text);
    return responseJson;
  }

  List<String> itemsresult = const [];

  bool gridtoggle;
  final storage = new FlutterSecureStorage();

  getfavourites() async {
    if (favourites != null) {
      if (favourites.isNotEmpty) favourites.clear();
    }

    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<String> ites = List<String>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              if (profilemap[i] != null) {
                ites.add(profilemap[i]['_id']['\$oid']);
              }
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();

            favourites = jsoninreverse;
          } else {
            favourites = [];
          }
        }
      }
    } else {
      favourites = [];
    }
  }

  List<String> favourites;

  @override
  Widget buildSuggestions(BuildContext context) {
    getfavourites();
    return query.isNotEmpty
        ? FutureBuilder<List<Item>>(
            future: getItemsSearch(query),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return EasyRefresh.custom(
                  topBouncing: true,
                  footer: MaterialFooter(
                    enableInfiniteLoad: true,
                    enableHapticFeedback: true,
                  ),
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                        crossAxisCount: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index != 0 && index % 8 == 0) {
                            return Platform.isIOS == true
                                ? Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Container(
                                      height: 220,
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.2, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: NativeAdmob(
                                        adUnitID: _iosadUnitID,
                                        controller: _controller,
                                      ),
                                    ))
                                : Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Container(
                                      height: 220,
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.2, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: NativeAdmob(
                                        adUnitID: _androidadUnitID,
                                        controller: _controller,
                                      ),
                                    ));
                          }

                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return new Padding(
                                padding: EdgeInsets.all(7),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Details(
                                                itemid:
                                                    snapshot.data[index].itemid,
                                                sold: snapshot.data[index].sold,
                                              )),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.2, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        new Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 199,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      Duration(microseconds: 5),
                                                  imageUrl: snapshot.data[index]
                                                          .image.isEmpty
                                                      ? SpinKitChasingDots(
                                                          color:
                                                              Colors.deepOrange)
                                                      : snapshot
                                                          .data[index].image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitChasingDots(
                                                          color: Colors
                                                              .deepOrange),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            snapshot.data[index].sold == true
                                                ? Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .deepPurpleAccent
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Center(
                                                        child: Text(
                                                          'Sold',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ))
                                                : favourites != null
                                                    ? favourites.contains(
                                                            itemsgrid[index]
                                                                .itemid)
                                                        ? InkWell(
                                                            enableFeedback:
                                                                true,
                                                            onTap: () async {
                                                              var userid =
                                                                  await storage
                                                                      .read(
                                                                          key:
                                                                              'userid');

                                                              if (userid !=
                                                                  null) {
                                                                var url =
                                                                    'https://api.sellship.co/api/favourite/' +
                                                                        userid;

                                                                Map<String,
                                                                        String>
                                                                    body = {
                                                                  'itemid': itemsgrid[
                                                                          index]
                                                                      .itemid,
                                                                };

                                                                favourites.remove(
                                                                    itemsgrid[
                                                                            index]
                                                                        .itemid);
                                                                setState(() {
                                                                  favourites =
                                                                      favourites;
                                                                  itemsgrid[
                                                                          index]
                                                                      .likes = itemsgrid[
                                                                              index]
                                                                          .likes -
                                                                      1;
                                                                });
                                                                final response =
                                                                    await http.post(
                                                                        url,
                                                                        body:
                                                                            body);

                                                                if (response
                                                                        .statusCode ==
                                                                    200) {
                                                                } else {
                                                                  print(response
                                                                      .statusCode);
                                                                }
                                                              } else {
                                                                print(
                                                                    'Please Login to use Favourites');
                                                              }
                                                            },
                                                            child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          18,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .deepPurple,
                                                                      child:
                                                                          Icon(
                                                                        FontAwesome
                                                                            .heart,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            16,
                                                                      ),
                                                                    ))))
                                                        : InkWell(
                                                            enableFeedback:
                                                                true,
                                                            onTap: () async {
                                                              var userid =
                                                                  await storage
                                                                      .read(
                                                                          key:
                                                                              'userid');

                                                              if (userid !=
                                                                  null) {
                                                                var url =
                                                                    'https://api.sellship.co/api/favourite/' +
                                                                        userid;

                                                                Map<String,
                                                                        String>
                                                                    body = {
                                                                  'itemid': itemsgrid[
                                                                          index]
                                                                      .itemid,
                                                                };

                                                                favourites.add(
                                                                    itemsgrid[
                                                                            index]
                                                                        .itemid);
                                                                setState(() {
                                                                  favourites =
                                                                      favourites;
                                                                  itemsgrid[
                                                                          index]
                                                                      .likes = itemsgrid[
                                                                              index]
                                                                          .likes +
                                                                      1;
                                                                });
                                                                final response =
                                                                    await http.post(
                                                                        url,
                                                                        body:
                                                                            body);

                                                                if (response
                                                                        .statusCode ==
                                                                    200) {
                                                                } else {
                                                                  print(response
                                                                      .statusCode);
                                                                }
                                                              } else {
                                                                print(
                                                                    'Please Login to use Favourites');
                                                              }
                                                            },
                                                            child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          18,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      child:
                                                                          Icon(
                                                                        Feather
                                                                            .heart,
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        size:
                                                                            16,
                                                                      ),
                                                                    ))))
                                                    : Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                Feather.heart,
                                                                color: Colors
                                                                    .blueGrey,
                                                                size: 16,
                                                              ),
                                                            ))),
                                          ],
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: snapshot.data.length,
                      ),
                    )
                  ],
                  onLoad: () async {
                    getmoreItemsSearch(query);
                  },
                );
              } else {
                return Container();
              }
            })
        : ListView(
            children: <Widget>[
              ListTile(
                title: Text(''),
              )
            ],
          );
  }
}
