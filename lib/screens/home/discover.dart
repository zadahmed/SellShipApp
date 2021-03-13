import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/user.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/filter.dart';
import 'package:SellShip/screens/home/below100.dart';
import 'package:SellShip/screens/home/nearme.dart';
import 'package:SellShip/screens/home/toppicks.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/search.dart';
import 'package:SellShip/screens/subcategory.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Discover extends StatefulWidget {
  Discover({Key key}) : super(key: key);
  @override
  _DiscoverState createState() => _DiscoverState();
}

class Subcategory {
  final String name;
  final String image;

  Subcategory({this.name, this.image});
}

class _DiscoverState extends State<Discover>
    with AutomaticKeepAliveClientMixin {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  bool alive = false;

  @override
  bool get wantKeepAlive => alive;

  ScrollController _scrollController = ScrollController();

  var currency;

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        if (respons != 'Empty') {
          print(respons);
          List<String> ites = List<String>();

          if (respons != null) {
            for (var i = 0; i < respons.length; i++) {
              if (respons[i] != null) {
                ites.add(respons[i]['_id']['\$oid']);
              }
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            setState(() {
              favourites = jsoninreverse;
            });
          } else {
            setState(() {
              favourites = [];
            });
          }
        } else {
          setState(() {
            favourites = [];
          });
        }
      } else {
        setState(() {
          favourites = [];
        });
      }
      print(favourites);
    }
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

    if (mounted) {
      setState(() {
        skip = 0;
        limit = 50;
        loading = true;
      });
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));

    gettopdata();
    getsubcategoriesinterested();
    readstorage();
  }

  bool foryouloading = true;

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

  Color followcolor = Colors.deepOrange;

  var follow = false;

  var notifcount;
  var notifbadge;

  void readstorage() async {
    getnotification();
    getfavourites();
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      if (mounted)
        setState(() {
          currency = 'AED';
        });
    } else if (countr.trim().toLowerCase() == 'united states') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (countr.trim().toLowerCase() == 'canada') {
      if (mounted)
        setState(() {
          currency = '\$';
        });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      if (mounted)
        setState(() {
          currency = '\£';
        });
    }
    if (mounted)
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
    super.build(context);
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        body: homePage(context));
  }

  String view = 'home';

  List<User> followingusers = List<User>();

  followuser(user) async {
    User foluser = user;
    var userid = await storage.read(key: 'userid');
    if (followingusers.contains(user)) {
      setState(() {
        followingusers.remove(foluser);
      });
      var followurl =
          'https://api.sellship.co/api/follow/' + userid + '/' + foluser.userid;

      final followresponse = await http.get(followurl);
      if (followresponse.statusCode == 200) {
        print('UnFollowed');
      }
    } else {
      setState(() {
        followingusers.add(foluser);
      });
      var followurl =
          'https://api.sellship.co/api/follow/' + userid + '/' + foluser.userid;

      final followresponse = await http.get(followurl);
      if (followresponse.statusCode == 200) {
        print('Followed');
      }
    }
  }

  Widget foryouPage(BuildContext context) {
    return foryouloading == false
        ? foryoulist.isEmpty
            ? EasyRefresh.custom(
                footer: CustomFooter(
                    extent: 40.0,
                    enableHapticFeedback: true,
                    footerBuilder: (context,
                        loadState,
                        pulledExtent,
                        loadTriggerPullDistance,
                        loadIndicatorExtent,
                        axisDirection,
                        float,
                        completeDuration,
                        enableInfiniteLoad,
                        success,
                        noMore) {
                      return SpinKitFadingCircle(
                        color: Colors.deepOrange,
                        size: 30.0,
                      );
                    }),
                header: CustomHeader(
                    extent: 40.0,
                    enableHapticFeedback: true,
                    triggerDistance: 50.0,
                    headerBuilder: (context,
                        loadState,
                        pulledExtent,
                        loadTriggerPullDistance,
                        loadIndicatorExtent,
                        axisDirection,
                        float,
                        completeDuration,
                        enableInfiniteLoad,
                        success,
                        noMore) {
                      return SpinKitFadingCircle(
                        color: Colors.deepOrange,
                        size: 30.0,
                      );
                    }),
                onRefresh: () {
                  if (mounted) {
                    setState(() {
                      alive = false;
                      foryouloading = true;
                      foryou();

                      foryoupagescroll();
                    });
                  }

                  return getsellerrecommendation();
                },
                slivers: <Widget>[
                    SliverToBoxAdapter(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset('assets/024.png',
                              fit: BoxFit.fitHeight),
                        ),
                        Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Oops! Looks like you are not following any SellShipers. Here are a few recommendations.',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                              height: 270,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sellers you may like',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 20.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 215,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      itemCount: userList.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return new Padding(
                                          padding: EdgeInsets.only(
                                              right: 5, top: 10, bottom: 10),
                                          child: Container(
                                            height: 205,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                userList[index].profilepicture !=
                                                            null &&
                                                        userList[index]
                                                            .profilepicture
                                                            .isNotEmpty
                                                    ? Container(
                                                        height: 80,
                                                        width: 80,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child:
                                                                CachedNetworkImage(
                                                              height: 200,
                                                              width: 300,
                                                              imageUrl: userList[
                                                                      index]
                                                                  .profilepicture,
                                                              fit: BoxFit.cover,
                                                            )),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 40,
                                                        backgroundColor: Colors
                                                            .deepOrangeAccent
                                                            .withOpacity(0.3),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          child: Image.asset(
                                                            'assets/personplaceholder.png',
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          ),
                                                        )),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  '@' +
                                                      userList[index].username,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  userList[index]
                                                              .productsnumber !=
                                                          null
                                                      ? userList[index]
                                                              .productsnumber +
                                                          ' Listings'
                                                      : '0 Listings',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Container(
                                                    height: 30,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: followingusers
                                                              .contains(
                                                                  userList[
                                                                      index])
                                                          ? Colors.black
                                                          : Colors.deepOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        followuser(
                                                            userList[index]);
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          followingusers
                                                                  .contains(
                                                                      userList[
                                                                          index])
                                                              ? 'Following'
                                                              : 'Follow',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ))
                  ])
            : EasyRefresh.custom(
                footer: CustomFooter(
                    extent: 40.0,
                    enableHapticFeedback: true,
                    triggerDistance: 50.0,
                    footerBuilder: (context,
                        loadState,
                        pulledExtent,
                        loadTriggerPullDistance,
                        loadIndicatorExtent,
                        axisDirection,
                        float,
                        completeDuration,
                        enableInfiniteLoad,
                        success,
                        noMore) {
                      return SpinKitFadingCircle(
                        color: Colors.deepOrange,
                        size: 30.0,
                      );
                    }),
                header: CustomHeader(
                    extent: 40.0,
                    enableHapticFeedback: true,
                    triggerDistance: 50.0,
                    headerBuilder: (context,
                        loadState,
                        pulledExtent,
                        loadTriggerPullDistance,
                        loadIndicatorExtent,
                        axisDirection,
                        float,
                        completeDuration,
                        enableInfiniteLoad,
                        success,
                        noMore) {
                      return SpinKitFadingCircle(
                        color: Colors.deepOrange,
                        size: 30.0,
                      );
                    }),
                onRefresh: () {
                  if (mounted) {
                    setState(() {
                      foryouloading = true;
                      foryou();

                      foryoupagescroll();
                    });
                  }

                  return getsellerrecommendation();
                },
                slivers: <Widget>[
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 1),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Details(
                                      item: foryoulist[index],
                                      itemid: foryoulist[index].itemid,
                                      image: foryoulist[index].image,
                                      name: foryoulist[index].name,
                                      sold: foryoulist[index].sold,
                                      source: 'foryou')),
                            );
                          },
                          child: Stack(children: <Widget>[
                            Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                child: Hero(
                                  tag: 'foryou${foryoulist[index].itemid}',
                                  child: CachedNetworkImage(
                                    height: 200,
                                    width: 300,
                                    fadeInDuration: Duration(microseconds: 5),
                                    imageUrl: foryoulist[index].image.isEmpty
                                        ? SpinKitDoubleBounce(
                                            color: Colors.deepOrange)
                                        : foryoulist[index].image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        SpinKitDoubleBounce(
                                            color: Colors.deepOrange),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            foryoulist[index].sold == true
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                      width: 210,
                                      child: Center(
                                        child: Text(
                                          'Sold',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                                : Container(),
                          ]),
                        );
                      },
                      childCount: foryoulist.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                          height: 245,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sellers you may like',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 20.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 195,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemCount: userList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Padding(
                                      padding: EdgeInsets.only(
                                          right: 5, top: 10, bottom: 5),
                                      child: Container(
                                        height: 205,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            userList[index].profilepicture !=
                                                        null &&
                                                    userList[index]
                                                        .profilepicture
                                                        .isNotEmpty
                                                ? Container(
                                                    height: 80,
                                                    width: 80,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 200,
                                                          width: 300,
                                                          imageUrl: userList[
                                                                  index]
                                                              .profilepicture,
                                                          fit: BoxFit.cover,
                                                        )),
                                                  )
                                                : CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor: Colors
                                                        .deepOrangeAccent
                                                        .withOpacity(0.3),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: Image.asset(
                                                        'assets/personplaceholder.png',
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    )),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '@' + userList[index].username,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              userList[index].productsnumber !=
                                                      null
                                                  ? userList[index]
                                                          .productsnumber +
                                                      ' Listings'
                                                  : '0 Listings',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                height: 30,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color:
                                                      followingusers.contains(
                                                              userList[index])
                                                          ? Colors.black
                                                          : Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    followuser(userList[index]);
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      followingusers.contains(
                                                              userList[index])
                                                          ? 'Following'
                                                          : 'Follow',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 1),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Details(
                                      itemid: foryouscroll[index].itemid,
                                      image: foryouscroll[index].image,
                                      name: foryouscroll[index].name,
                                      sold: foryouscroll[index].sold,
                                      source: 'foryouscroll')),
                            );
                          },
                          child: Stack(children: <Widget>[
                            Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                child: Hero(
                                  tag:
                                      'foryouscroll${foryouscroll[index].itemid}',
                                  child: CachedNetworkImage(
                                    height: 200,
                                    width: 300,
                                    fadeInDuration: Duration(microseconds: 5),
                                    imageUrl: foryouscroll[index].image.isEmpty
                                        ? SpinKitDoubleBounce(
                                            color: Colors.deepOrange)
                                        : foryouscroll[index].image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        SpinKitDoubleBounce(
                                            color: Colors.deepOrange),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            foryouscroll[index].sold == true
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                      width: 210,
                                      child: Center(
                                        child: Text(
                                          'Sold',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                                : Container(),
                          ]),
                        );
                      },
                      childCount: foryouscroll.length,
                    ),
                  )
                ],
                enableControlFinishLoad: true,
                onLoad: () {
                  setState(() {
                    foryouskip = foryouskip + 30;
                    foryoulimit = foryoulimit + 30;
                  });
                  return foryoupagescroll();
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
            ));
  }

  foryou() async {
    var userid = await storage.read(key: 'userid');
    List<Item> testforoyou = List<Item>();
    var url = 'https://api.sellship.co/api/foryou/feed/' + userid + '/0/10';

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      if (jsonbody.isEmpty) {
        if (mounted)
          setState(() {
            testforoyou = [];
          });
      } else {
        var jsonbody = json.decode(response.body);

        for (var i = 0; i < jsonbody.length; i++) {
          Item item = Item(
            itemid: jsonbody[i]['_id']['\$oid'],
            image: jsonbody[i]['image'],
            name: jsonbody[i]['name'],
            sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
          );
          testforoyou.add(item);
        }
        if (mounted)
          setState(() {
            alive = true;
            foryoulist = testforoyou.toSet().toList();
            foryouloading = false;
          });
      }
    } else {
      print(response.statusCode);
    }
  }

  int foryouskip = 10;
  int foryoulimit = 40;

  foryoupagescroll() async {
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/foryou/feed/' +
        userid +
        '/' +
        foryouskip.toString() +
        '/' +
        foryoulimit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      if (jsonbody.isEmpty) {
        if (mounted)
          setState(() {
            foryouscroll = [];
          });
      } else {
        var jsonbody = json.decode(response.body);

        for (var i = 0; i < jsonbody.length; i++) {
          Item item = Item(
            itemid: jsonbody[i]['_id']['\$oid'],
            image: jsonbody[i]['image'],
            name: jsonbody[i]['name'],
            sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
          );
          foryouscroll.add(item);
        }

        if (mounted)
          setState(() {
            foryouscroll = foryouscroll;
            foryouloading = false;
          });
      }
    } else {
      print(response.statusCode);
    }
  }

  List<Item> foryoulist = List<Item>();
  List<Item> foryouscroll = List<Item>();

  getsellerrecommendation() async {
    userList.clear();
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/follower/recommendations/' +
        userid +
        '/' +
        country;

    List<User> testList = new List<User>();
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var lastname;
        var username;
        if (jsondata.containsKey('last_name')) {
          lastname = jsondata['last_name'];
        } else {
          lastname = '';
        }

        if (jsondata.containsKey('username')) {
          username = jsondata['username'];
        } else {
          username = jsondata['first_name'];
        }

        int products;
        if (jsondata.containsKey('products')) {
          products = jsondata['products'].length;
        } else {
          products = 0;
        }

        User user = new User(
            firstName: capitalize(jsondata['first_name']) + ' ' + lastname,
            username: username,
            userid: jsondata['_id']['\$oid'],
            productsnumber: products.toString(),
            profilepicture: jsondata['profilepicture']);

        if (!testList.contains(user)) {
          testList.add(user);
        }
      }

      testList.sort((a, b) {
        return a.compareTo(b);
      });

      if (mounted)
        setState(() {
          userList = testList;
          foryouloading = false;
        });
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  List<User> userList = new List<User>();

  Widget homePage(BuildContext context) {
    return loading == false
        ? EasyRefresh.custom(
            footer: CustomFooter(
                extent: 40.0,
                enableHapticFeedback: true,
                enableInfiniteLoad: true,
                footerBuilder: (context,
                    loadState,
                    pulledExtent,
                    loadTriggerPullDistance,
                    loadIndicatorExtent,
                    axisDirection,
                    float,
                    completeDuration,
                    enableInfiniteLoad,
                    success,
                    noMore) {
                  return SpinKitFadingCircle(
                    color: Colors.deepOrange,
                    size: 30.0,
                  );
                }),
            header: CustomHeader(
                extent: 160.0,
                enableHapticFeedback: true,
                triggerDistance: 160.0,
                headerBuilder: (context,
                    loadState,
                    pulledExtent,
                    loadTriggerPullDistance,
                    loadIndicatorExtent,
                    axisDirection,
                    float,
                    completeDuration,
                    enableInfiniteLoad,
                    success,
                    noMore) {
                  return SpinKitFadingCircle(
                    color: Colors.deepOrange,
                    size: 30.0,
                  );
                }),
            onRefresh: () {
              if (mounted) {
                setState(() {
                  alive = false;
                  skip = 0;
                  limit = 50;
                  loading = true;
                });
              }

              itemsgrid.clear();
              nearmeItems.clear();
              below100list.clear();
              subcategoryList.clear();
              subcategoryListsecond.clear();
              topitems.clear();
              getsubcategoriesinterested();
              gettopdata();
              readstorage();

              return getsubcategoriesinterested();
            },
            slivers: <Widget>[
              subcategoryList.isNotEmpty
                  ? SliverToBoxAdapter(
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
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RootScreen(
                                              index: 1,
                                            )),
                                  );
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )
                  : SliverToBoxAdapter(),
              subcategoryList.isNotEmpty
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          crossAxisCount: 3,
                          childAspectRatio: 0.70),
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => SubCategory(
                                        subcategory:
                                            subcategoryList[index].name,
                                        categoryimage:
                                            subcategoryList[index].image,
                                      )),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                                height: 200,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 180,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: subcategoryList[index].image !=
                                              null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Hero(
                                                  tag: 'subcat' +
                                                      subcategoryList[index]
                                                          .name,
                                                  child: CachedNetworkImage(
                                                    height: 200,
                                                    width: 300,
                                                    imageUrl:
                                                        subcategoryList[index]
                                                            .image,
                                                    fit: BoxFit.cover,
                                                  )))
                                          : Container(),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 50,
                                        width: 100,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: Text(
                                            subcategoryList[index].name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        );
                      }, childCount: 6))
                  : SliverToBoxAdapter(),
              topitems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16, top: 10, bottom: 10, right: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => TopPicks()),
                                  );
                                },
                                child: Text(
                                  'Top Picks',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => TopPicks()),
                                  );
                                },
                                enableFeedback: true,
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )
                  : SliverToBoxAdapter(),
              topitems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 280,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: 20,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 280,
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
                                        CupertinoPageRoute(
                                            builder: (context) => Details(
                                                itemid: topitems[index].itemid,
                                                image: topitems[index].image,
                                                name: topitems[index].name,
                                                sold: topitems[index].sold,
                                                source: 'top')),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 220,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          child: Hero(
                                            tag: 'top${topitems[index].itemid}',
                                            child: CachedNetworkImage(
                                              height: 200,
                                              width: 300,
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: topitems[index]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitDoubleBounce(
                                                      color: Colors.deepOrange)
                                                  : topitems[index].image,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SpinKitDoubleBounce(
                                                      color: Colors.deepOrange),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      topitems[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                ),
                                                width: 210,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      color: Colors.white,
                                                    ),
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
                                                              body: json.encode(
                                                                  body));
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
                                                              body: json.encode(
                                                                  body));

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
                        InkWell(
                          enableFeedback: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Below100()),
                            );
                          },
                          child: Text(
                            'Deals under 100',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Below100()),
                            );
                          },
                          enableFeedback: true,
                          child: Text(
                            'See All',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              below100list.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 230,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: below100list.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 210,
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
                                        CupertinoPageRoute(
                                            builder: (context) => Details(
                                                itemid:
                                                    below100list[index].itemid,
                                                image:
                                                    below100list[index].image,
                                                name: below100list[index].name,
                                                sold: below100list[index].sold,
                                                source: 'below100')),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 170,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          child: Hero(
                                            tag:
                                                'below100${below100list[index].itemid}',
                                            child: CachedNetworkImage(
                                              height: 200,
                                              width: 300,
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: below100list[index]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitDoubleBounce(
                                                      color: Colors.deepOrange)
                                                  : below100list[index].image,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SpinKitDoubleBounce(
                                                      color: Colors.deepOrange),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      below100list[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                ),
                                                width: 210,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      color: Colors.white,
                                                    ),
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
                                                              body: json.encode(
                                                                  body));

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
                                                              body: json.encode(
                                                                  body));

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
              nearmeItems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16, top: 10, bottom: 10, right: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => NearMe()),
                                  );
                                },
                                child: Text(
                                  'Near You',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => NearMe()),
                                  );
                                },
                                enableFeedback: true,
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )
                  : SliverToBoxAdapter(),
              nearmeItems.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                      height: 280,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: nearmeItems.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 280,
                              width: MediaQuery.of(context).size.width / 2 - 10,
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
                                        CupertinoPageRoute(
                                            builder: (context) => Details(
                                                itemid:
                                                    nearmeItems[index].itemid,
                                                image: nearmeItems[index].image,
                                                name: nearmeItems[index].name,
                                                sold: nearmeItems[index].sold,
                                                source: 'nearme')),
                                      );
                                    },
                                    child: Stack(children: <Widget>[
                                      Container(
                                        height: 220,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          child: Hero(
                                            tag:
                                                'nearme${nearmeItems[index].itemid}',
                                            child: CachedNetworkImage(
                                              height: 200,
                                              width: 300,
                                              fadeInDuration:
                                                  Duration(microseconds: 5),
                                              imageUrl: nearmeItems[index]
                                                      .image
                                                      .isEmpty
                                                  ? SpinKitDoubleBounce(
                                                      color: Colors.deepOrange)
                                                  : nearmeItems[index].image,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SpinKitDoubleBounce(
                                                      color: Colors.deepOrange),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      nearmeItems[index].sold == true
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                ),
                                                width: 210,
                                                child: Center(
                                                  child: Text(
                                                    'Sold',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      color: Colors.white,
                                                    ),
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
                                                              body: json.encode(
                                                                  body));

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
                                                              body: json.encode(
                                                                  body));

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
                  child: SizedBox(
                height: 4,
              )),
              subcategoryListsecond.isNotEmpty
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          crossAxisCount: 3,
                          childAspectRatio: 0.70),
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => SubCategory(
                                        subcategory:
                                            subcategoryListsecond[index].name,
                                        categoryimage:
                                            subcategoryListsecond[index].image,
                                      )),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                                height: 200,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 180,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child:
                                          subcategoryList[index].image != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Hero(
                                                      tag: 'cat' +
                                                          subcategoryListsecond[
                                                                  index]
                                                              .name,
                                                      child: CachedNetworkImage(
                                                        height: 200,
                                                        width: 300,
                                                        imageUrl:
                                                            subcategoryListsecond[
                                                                    index]
                                                                .image,
                                                        fit: BoxFit.cover,
                                                      )))
                                              : Container(),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 50,
                                        width: 100,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                          child: Text(
                                            subcategoryListsecond[index].name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        );
                      }, childCount: 4))
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
                    childAspectRatio: 0.75),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
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
                                  CupertinoPageRoute(
                                      builder: (context) => Details(
                                          itemid: itemsgrid[index].itemid,
                                          image: itemsgrid[index].image,
                                          name: itemsgrid[index].name,
                                          sold: itemsgrid[index].sold,
                                          source: 'newin')),
                                );
                              },
                              child: Stack(children: <Widget>[
                                Container(
                                  height: 195,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
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
                                    child: Hero(
                                      tag: 'newin${itemsgrid[index].itemid}',
                                      child: CachedNetworkImage(
                                        height: 200,
                                        width: 300,
                                        fadeInDuration:
                                            Duration(microseconds: 5),
                                        imageUrl: itemsgrid[index].image.isEmpty
                                            ? SpinKitDoubleBounce(
                                                color: Colors.deepOrange)
                                            : itemsgrid[index].image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            SpinKitDoubleBounce(
                                                color: Colors.deepOrange),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                itemsgrid[index].sold == true
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                          width: 210,
                                          child: Center(
                                            child: Text(
                                              'Sold',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                color: Colors.white,
                                              ),
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
                                                    .post(url,
                                                        body:
                                                            json.encode(body));

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
                                                    .post(url,
                                                        body:
                                                            json.encode(body));

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
        if (mounted)
          setState(() {
            topitems = topitems;
          });
      } else {
        if (mounted)
          setState(() {
            topitems = [];
          });
      }
    } else {
      print('error');
    }
  }

  List<Subcategory> subcategoryList = new List<Subcategory>();
  List<Subcategory> subcategoryListsecond = new List<Subcategory>();
  getsubcategoriesinterested() async {
    subcategoryList.clear();
    subcategoryListsecond.clear();
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/top/subcategories/' + userid;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        Subcategory cat = new Subcategory(
            name: jsonbody[i]['name'], image: jsonbody[i]['image']);
        subcategoryList.add(cat);
      }
      setState(() {
        subcategoryList = subcategoryList;
        subcategoryListsecond = subcategoryList.sublist(
          6,
        );
      });
    } else {
      print(response.statusCode);
    }
  }

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 50;
      skip = skip + 50;
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
    if (mounted)
      setState(() {
        loading = false;
        alive = true;
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
        20.toString() +
        '/' +
        position.longitude.toString() +
        '/' +
        position.latitude.toString();

    final response = await http.get(url);
    print(url);

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
