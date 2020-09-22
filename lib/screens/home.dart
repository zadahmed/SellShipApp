import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/details.dart';
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
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<List<Item>> fetchItems(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://api.sellship.co/api/getitems/' +
          locationcountry +
          '/' +
          0.toString() +
          '/' +
          20.toString();

      final response = await http.post(url, body: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString()
      });
      if (response.statusCode == 200) {
        var jsonbody = json.decode(response.body);
        itemsgrid.clear();
        for (var i = 0; i < jsonbody.length; i++) {
          var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

          DateTime dateuploade =
              DateTime.fromMillisecondsSinceEpoch(q['\$date']);
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
            userid: jsonbody[i]['userid'],
            price: jsonbody[i]['price'].toString(),
            category: jsonbody[i]['category'],
            sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
          );
          itemsgrid.add(item);
        }
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

  refresh() async {
    setState(() {
      itemsgrid.clear();
      skip = 0;
      limit = 20;
    });
    getfavourites();
    getnotification();

    fetchRecentlyAdded(skip, limit);
  }

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

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

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
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

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    print(url);

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
    print(itemsgrid);
    setState(() {
      itemsgrid = itemsgrid;
    });

    return itemsgrid;
  }

  LatLng position;
  bool loading;

//  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 20;
      loading = true;
      notifbadge = false;
      notbadge = false;
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));

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

  _getmoreData() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/getitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

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

  _getLocation() async {
    Location _location = new Location();
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

      var token = await FirebaseNotifications().getNotifications(context);
      if (userid != null) {
        print(token + "\n Token was recieved from firebase");
        var url =
            'https://api.sellship.co/api/checktokenfcm/' + userid + '/' + token;
        print(url);
        final response = await http.get(url);
        if (response.statusCode == 200) {
          print(response.body);
        } else {
          print(response.statusCode);
        }
      }

      Coordinates coordinates =
          Coordinates(position.latitude, position.longitude);
      List<Address> p =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      Address place = p[0];
      var cit = place.adminArea;
      var countr = place
          .countryName; //todo check with zahid was this country code or country name?
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'locationcountry', value: countr);
      setState(() {
        city = cit;
        locationcountry = countr;
        print(city);
      });
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
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
    Coordinates coordinates =
        Coordinates(position.latitude, position.longitude);
    List<Address> p =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    Address place = p[0];
    var cit = place.adminArea;
    var countryy = place.countryName;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'locationcountry', value: countryy);

    setState(() {
      city = cit;
      locationcountry = countryy;
    });
//    fetchItems(skip, limit);
  }

  String city;
  var notcount;

  PersistentBottomSheetController bottomsheetcontroller;

  bool notbadge;

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/getnotification/' + userid;
      print(url);
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SafeArea(
              child: EasyRefresh.custom(
            header: BezierCircleHeader(
                color: Colors.deepOrangeAccent,
                backgroundColor: Colors.deepPurple,
                enableHapticFeedback: true),
            footer: BallPulseFooter(
                color: Colors.deepPurpleAccent, enableInfiniteLoad: true),
            slivers: <Widget>[
              SliverAppBar(
                pinned: false,
                snap: false,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.white,
                leading: Badge(
                  showBadge: notbadge,
                  position: BadgePosition.topRight(top: 2, right: 3),
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
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                  ),
                ),
                title: Container(
                  height: 30,
                  width: 120,
                  child: Image.asset(
                    'assets/logotransparent.png',
                    fit: BoxFit.cover,
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Badge(
                      showBadge: notifbadge,
                      position: BadgePosition.topRight(top: 2),
                      animationType: BadgeAnimationType.slide,
                      badgeContent: Text(
                        '',
                        style: TextStyle(color: Colors.white),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Messages()),
                          );
                        },
                        child: Icon(
                          Feather.message_square,
                          color: Colors.deepOrange,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
                expandedHeight: 150.0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: 40.0, left: 15, right: 15, bottom: 10),
                        child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Feather.search,
                                    size: 24,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    onTap: () {
                                      showSearch(
                                          context: context,
                                          delegate:
                                              UserSearchDelegate(country));
                                    },
                                    controller: searchcontroller,
                                    decoration: InputDecoration(
                                        hintText: 'Search SellShip',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Container(child: filtersort(context)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(5.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Text('Categories',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black)),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  right: 20, top: 10, bottom: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryScreen(
                                            selectedcategory: 0)),
                                  );
                                },
                                child: Text('View All',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.deepOrange)),
                              )),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 85,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: categories.length,
                            itemBuilder: (ctx, i) {
                              return Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryScreen(
                                                    selectedcategory: i)),
                                      );
                                    },
                                    child: Container(
                                        width: 80,
                                        height: 80,
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              width: 80,
                                              child: Image.asset(
                                                categories[i].image,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                "${categories[i].title}",
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                    color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        )),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 10, top: 10, bottom: 5),
                              child: Text(_FilterLoad,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black)),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    right: 20, top: 10, bottom: 10),
                                child: InkWell(
                                    onTap: () {
                                      if (gridtoggle == true) {
                                        setState(() {
                                          gridtoggle = false;
                                        });
                                      } else {
                                        setState(() {
                                          gridtoggle = true;
                                        });
                                      }
                                    },
                                    child: gridtoggle == true
                                        ? Icon(
                                            Icons.list,
                                            size: 20,
                                            color: Colors.deepOrange,
                                          )
                                        : Icon(Icons.grid_on,
                                            size: 20,
                                            color: Colors.deepOrange))),
                          ]),
                    ],
                  ),
                ),
              ),
              itemsgrid.isNotEmpty
                  ? (gridtoggle == true
                      ? SliverStaggeredGrid(
                          gridDelegate:
                              SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            crossAxisCount: 2,
                            staggeredTileCount: itemsgrid.length,
                            staggeredTileBuilder: (index) =>
                                new StaggeredTile.fit(1),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (index != 0 && index % 8 == 0) {
                                return Platform.isIOS == true
                                    ? Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: 300,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: 300,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                                child: InkWell(
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
                                              height: 220,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      Duration(microseconds: 5),
                                                  imageUrl:
                                                      itemsgrid[index].image,
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
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Container(
                                                    height: 35,
                                                    width: 145,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          child: InkWell(
                                                            child: Container(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Feather
                                                                        .heart,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    Numeral(itemsgrid[index]
                                                                            .likes)
                                                                        .value(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ],
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              if (favourites.contains(
                                                                  itemsgrid[
                                                                          index]
                                                                      .itemid)) {
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
                                                                        .likes = itemsgrid[index]
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
                                                                  showInSnackBar(
                                                                      'Please Login to use Favourites');
                                                                }
                                                              } else {
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
                                                                        .likes = itemsgrid[index]
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
                                                                  showInSnackBar(
                                                                      'Please Login to use Favourites');
                                                                }
                                                              }
                                                            },
                                                          ),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 5),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5,
                                                                  bottom: 5),
                                                          child:
                                                              VerticalDivider(),
                                                        ),
                                                        Padding(
                                                          child: InkWell(
                                                            child: Container(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Feather
                                                                        .message_circle,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    Numeral(itemsgrid[index]
                                                                            .comments)
                                                                        .value(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ],
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                              ),
                                                            ),
                                                            enableFeedback:
                                                                true,
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        CommentsPage(
                                                                            itemid:
                                                                                itemsgrid[index].itemid)),
                                                              );
                                                            },
                                                          ),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 10),
                                                        ),
                                                      ],
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                    ),
                                                  ),
                                                )),
                                            itemsgrid[index].sold == true
                                                ? Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height: 50,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      color: Colors
                                                          .deepPurpleAccent
                                                          .withOpacity(0.8),
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
                                                                showInSnackBar(
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
                                                                showInSnackBar(
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
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          child: Text(
                                            itemsgrid[index].name,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  Color.fromRGBO(28, 45, 65, 1),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(left: 10),
                                        ),
                                        SizedBox(height: 4.0),
                                        currency != null
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Container(
                                                  child: Text(
                                                    currency +
                                                        ' ' +
                                                        itemsgrid[index]
                                                            .price
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.deepOrange,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Container(
                                                  child: Text(
                                                    itemsgrid[index]
                                                        .price
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                )),
                                        SizedBox(
                                          height: 10,
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
//
//
//                                  Container(
//                                    decoration: BoxDecoration(
//                                      border: Border.all(
//                                          width: 0.2, color: Colors.grey),
//                                      borderRadius: BorderRadius.circular(5),
//                                      color: Colors.white,
//                                      boxShadow: [
//                                        BoxShadow(
//                                          color: Colors.grey.shade300,
//                                          offset: Offset(0.0, 1.0), //(x,y)
//                                          blurRadius: 6.0,
//                                        ),
//                                      ],
//                                    ),
//                                    child: Column(
//                                      children: <Widget>[
//                                        new Stack(
//                                          children: <Widget>[
//                                            Container(
//                                              height: 180,
//                                              width: MediaQuery.of(context)
//                                                  .size
//                                                  .width,
//                                              child: ClipRRect(
//                                                borderRadius: BorderRadius.only(
//                                                  topLeft: Radius.circular(5),
//                                                  topRight: Radius.circular(5),
//                                                ),
//                                                child: CachedNetworkImage(
//                                                  fadeInDuration: Duration(
//                                                      microseconds: 10),
//                                                  imageUrl:
//                                                      itemsgrid[index].image,
//                                                  fit: BoxFit.cover,
//                                                  placeholder: (context, url) =>
//                                                      SpinKitChasingDots(
//                                                          color: Colors
//                                                              .deepOrange),
//                                                  errorWidget:
//                                                      (context, url, error) =>
//                                                          Icon(Icons.error),
//                                                ),
//                                              ),
//                                            ),
//                                            itemsgrid[index].sold == true
//                                                ? Align(
//                                                    alignment: Alignment.center,
//                                                    child: Container(
//                                                      height: 50,
//                                                      width:
//                                                          MediaQuery.of(context)
//                                                              .size
//                                                              .width,
//                                                      color: Colors
//                                                          .deepPurpleAccent
//                                                          .withOpacity(0.8),
//                                                      child: Center(
//                                                        child: Text(
//                                                          'Sold',
//                                                          textAlign:
//                                                              TextAlign.center,
//                                                          style: TextStyle(
//                                                              fontFamily:
//                                                                  'Helvetica',
//                                                              color:
//                                                                  Colors.white,
//                                                              fontWeight:
//                                                                  FontWeight
//                                                                      .bold),
//                                                        ),
//                                                      ),
//                                                    ))
//                                                : Container(),
//                                          ],
//                                        ),
//                                        Align(
//                                          alignment: Alignment.centerLeft,
//                                          child: Padding(
//                                            padding: EdgeInsets.all(10),
//                                            child: Column(
//                                              mainAxisAlignment:
//                                                  MainAxisAlignment.start,
//                                              crossAxisAlignment:
//                                                  CrossAxisAlignment.start,
//                                              children: <Widget>[
//                                                Row(
//                                                  mainAxisAlignment:
//                                                      MainAxisAlignment.start,
//                                                  crossAxisAlignment:
//                                                      CrossAxisAlignment.center,
//                                                  children: <Widget>[

//                                                    SizedBox(
//                                                      width: 5,
//                                                    ),
//                                                    Text(
//                                                      itemsgrid[index]
//                                                          .likes
//                                                          .toString(),
//                                                      style: TextStyle(
//                                                        fontFamily: 'Helvetica',
//                                                        fontSize: 16,
//                                                        fontWeight:
//                                                            FontWeight.w600,
//                                                      ),
//                                                    ),
//                                                    SizedBox(
//                                                      width: 10,
//                                                    ),
//                                                    InkWell(
//                                                      enableFeedback: true,
//                                                      onTap: () {
//                                                        Navigator.push(
//                                                          context,
//                                                          MaterialPageRoute(
//                                                              builder: (context) =>
//                                                                  CommentsPage(
//                                                                      itemid: itemsgrid[
//                                                                              index]
//                                                                          .itemid)),
//                                                        );
//                                                      },
//                                                      child: Icon(Feather
//                                                          .message_circle),
//                                                    ),
//                                                    SizedBox(
//                                                      width: 5,
//                                                    ),
//                                                    InkWell(
//                                                      onTap: () {
//                                                        Navigator.push(
//                                                          context,
//                                                          MaterialPageRoute(
//                                                              builder: (context) =>
//                                                                  CommentsPage(
//                                                                      itemid: itemsgrid[
//                                                                              index]
//                                                                          .itemid)),
//                                                        );
//                                                      },
//                                                      child: Text(
//                                                        itemsgrid[index]
//                                                            .comments
//                                                            .toString(),
//                                                        style: TextStyle(
//                                                          fontFamily:
//                                                              'Helvetica',
//                                                          fontSize: 16,
//                                                          fontWeight:
//                                                              FontWeight.w600,
//                                                        ),
//                                                      ),
//                                                    ),
//                                                  ],
//                                                ),
//                                        ),
//                                      ],
//                                    ),
//                                  ),
                                  ),
                                  onDoubleTap: () async {
                                    if (favourites
                                        .contains(itemsgrid[index].itemid)) {
                                      var userid =
                                          await storage.read(key: 'userid');

                                      if (userid != null) {
                                        var url =
                                            'https://api.sellship.co/api/favourite/' +
                                                userid;

                                        Map<String, String> body = {
                                          'itemid': itemsgrid[index].itemid,
                                        };

                                        final response =
                                            await http.post(url, body: body);

                                        if (response.statusCode == 200) {
                                          var jsondata =
                                              json.decode(response.body);

                                          favourites.clear();
                                          for (int i = 0;
                                              i < jsondata.length;
                                              i++) {
                                            favourites.add(
                                                jsondata[i]['_id']['\$oid']);
                                          }
                                          setState(() {
                                            favourites = favourites;
                                            itemsgrid[index].likes =
                                                itemsgrid[index].likes - 1;
                                          });
                                        } else {
                                          print(response.statusCode);
                                        }
                                      } else {
                                        showInSnackBar(
                                            'Please Login to use Favourites');
                                      }
                                    } else {
                                      var userid =
                                          await storage.read(key: 'userid');

                                      if (userid != null) {
                                        var url =
                                            'https://api.sellship.co/api/favourite/' +
                                                userid;

                                        Map<String, String> body = {
                                          'itemid': itemsgrid[index].itemid,
                                        };

                                        final response =
                                            await http.post(url, body: body);

                                        if (response.statusCode == 200) {
                                          var jsondata =
                                              json.decode(response.body);

                                          favourites.clear();
                                          for (int i = 0;
                                              i < jsondata.length;
                                              i++) {
                                            favourites.add(
                                                jsondata[i]['_id']['\$oid']);
                                          }
                                          setState(() {
                                            favourites = favourites;
                                            itemsgrid[index].likes =
                                                itemsgrid[index].likes + 1;
                                          });
                                        } else {
                                          print(response.statusCode);
                                        }
                                      } else {
                                        showInSnackBar(
                                            'Please Login to use Favourites');
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: itemsgrid.length,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index != 0 && index % 8 == 0) {
                                return Platform.isIOS == true
                                    ? Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Container(
                                          height: 350,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                                        padding: EdgeInsets.all(15),
                                        child: Container(
                                          height: 350,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                              return InkWell(
                                  enableFeedback: true,
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
                                  onDoubleTap: () async {
                                    if (favourites
                                        .contains(itemsgrid[index].itemid)) {
                                      var userid =
                                          await storage.read(key: 'userid');

                                      if (userid != null) {
                                        var url =
                                            'https://api.sellship.co/api/favourite/' +
                                                userid;

                                        Map<String, String> body = {
                                          'itemid': itemsgrid[index].itemid,
                                        };

                                        final response =
                                            await http.post(url, body: body);

                                        if (response.statusCode == 200) {
                                          var jsondata =
                                              json.decode(response.body);

                                          favourites.clear();
                                          for (int i = 0;
                                              i < jsondata.length;
                                              i++) {
                                            favourites.add(
                                                jsondata[i]['_id']['\$oid']);
                                          }
                                          setState(() {
                                            favourites = favourites;
                                            itemsgrid[index].likes =
                                                itemsgrid[index].likes - 1;
                                          });
                                        } else {
                                          print(response.statusCode);
                                        }
                                      } else {
                                        showInSnackBar(
                                            'Please Login to use Favourites');
                                      }
                                    } else {
                                      var userid =
                                          await storage.read(key: 'userid');

                                      if (userid != null) {
                                        var url =
                                            'https://api.sellship.co/api/favourite/' +
                                                userid;

                                        Map<String, String> body = {
                                          'itemid': itemsgrid[index].itemid,
                                        };

                                        final response =
                                            await http.post(url, body: body);

                                        if (response.statusCode == 200) {
                                          var jsondata =
                                              json.decode(response.body);

                                          favourites.clear();
                                          for (int i = 0;
                                              i < jsondata.length;
                                              i++) {
                                            favourites.add(
                                                jsondata[i]['_id']['\$oid']);
                                          }
                                          setState(() {
                                            favourites = favourites;
                                            itemsgrid[index].likes =
                                                itemsgrid[index].likes + 1;
                                          });
                                        } else {
                                          print(response.statusCode);
                                        }
                                      } else {
                                        showInSnackBar(
                                            'Please Login to use Favourites');
                                      }
                                    }
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.2, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                                  height: 400,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      topRight:
                                                          Radius.circular(5),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      fadeInDuration: Duration(
                                                          microseconds: 10),
                                                      imageUrl: itemsgrid[index]
                                                          .image,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitChasingDots(
                                                              color: Colors
                                                                  .deepOrange),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                                itemsgrid[index].sold == true
                                                    ? Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          height: 50,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          color: Colors
                                                              .deepPurpleAccent
                                                              .withOpacity(0.8),
                                                          child: Center(
                                                            child: Text(
                                                              'Sold',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ))
                                                    : Container(),
                                              ],
                                            ),
                                            SizedBox(height: 2.0),
                                            new Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10.0,
                                                            bottom: 10.0,
                                                            top: 5),
                                                    child: new Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              favourites != null
                                                                  ? favourites.contains(
                                                                          itemsgrid[index]
                                                                              .itemid)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            var userid =
                                                                                await storage.read(key: 'userid');

                                                                            if (userid !=
                                                                                null) {
                                                                              var url = 'https://api.sellship.co/api/favourite/' + userid;

                                                                              Map<String, String> body = {
                                                                                'itemid': itemsgrid[index].itemid,
                                                                              };

                                                                              favourites.remove(itemsgrid[index].itemid);
                                                                              setState(() {
                                                                                favourites = favourites;
                                                                                itemsgrid[index].likes = itemsgrid[index].likes - 1;
                                                                              });
                                                                              final response = await http.post(url, body: body);

                                                                              if (response.statusCode == 200) {
                                                                              } else {
                                                                                print(response.statusCode);
                                                                              }
                                                                            } else {
                                                                              showInSnackBar('Please Login to use Favourites');
                                                                            }
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            FontAwesome.heart,
                                                                            color:
                                                                                Colors.deepPurple,
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            var userid =
                                                                                await storage.read(key: 'userid');

                                                                            if (userid !=
                                                                                null) {
                                                                              var url = 'https://api.sellship.co/api/favourite/' + userid;

                                                                              Map<String, String> body = {
                                                                                'itemid': itemsgrid[index].itemid,
                                                                              };

                                                                              favourites.add(itemsgrid[index].itemid);
                                                                              setState(() {
                                                                                favourites = favourites;
                                                                                itemsgrid[index].likes = itemsgrid[index].likes + 1;
                                                                              });
                                                                              final response = await http.post(url, body: body);

                                                                              if (response.statusCode == 200) {
                                                                              } else {
                                                                                print(response.statusCode);
                                                                              }
                                                                            } else {
                                                                              showInSnackBar('Please Login to use Favourites');
                                                                            }
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Feather.heart,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        )
                                                                  : Icon(
                                                                      Feather
                                                                          .heart,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                itemsgrid[index]
                                                                        .likes
                                                                        .toString() +
                                                                    ' likes',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              InkWell(
                                                                enableFeedback:
                                                                    true,
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                  );
                                                                },
                                                                child: Icon(Feather
                                                                    .message_circle),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              InkWell(
                                                                enableFeedback:
                                                                    true,
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  itemsgrid[index]
                                                                          .comments
                                                                          .toString() +
                                                                      ' comments',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Flexible(
                                                                child: Text(
                                                                  itemsgrid[
                                                                          index]
                                                                      .name,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
//                                                            overflow:
//                                                                TextOverflow
//                                                                    .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  currency +
                                                                      ' ' +
                                                                      itemsgrid[
                                                                              index]
                                                                          .price
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .deepOrange,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .access_time,
                                                                    size: 12,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    'Uploaded ${itemsgrid[index].date}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        ]))),
                                            SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                            childCount: itemsgrid.length,
                          ),
                        ))
                  : SliverToBoxAdapter(
                      child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: ListView(
                            children: [0, 1, 2, 3, 4, 5, 6]
                                .map((_) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                30,
                                            height: 150.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                30,
                                            height: 150.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ))
            ],
            onRefresh: () async {
              refresh();
            },
            onLoad: () async {
              if (_FilterLoad == 'Near me') {
                _getmoreData();
              } else if (_FilterLoad == 'Recently Added') {
                _getmoreRecentData();
              } else if (_FilterLoad == 'Below 100') {
                _getmorebelowhundred();
              } else if (_FilterLoad == 'Lowest Price') {
                _getmorelowestprice();
              } else if (_FilterLoad == 'Highest Price') {
                _getmorehighestprice();
              } else if (_FilterLoad == 'Brand') {
                getmorebrands(brand);
              } else if (_FilterLoad == 'Price') {
                getmorePrice(minprice, maxprice);
              } else if (_FilterLoad == 'Condition') {
                getmorecondition(condition);
              }
            },
          )),
        ));
  }

  String _FilterLoad = "Recently Added";
  String _selectedFilter = "Recently Added";

  Widget filtersort(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Container(
          height: 30,
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Recently Added";
                        _FilterLoad = "Recently Added";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      fetchRecentlyAdded(skip, limit);
                    },
                    child: _selectedFilter == "Recently Added"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'New',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'New',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Near Me";
                        _FilterLoad = "Near Me";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      fetchItems(skip, limit);
                    },
                    child: _selectedFilter == "Near Me"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 70,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 70,
                            child: Center(
                              child: Text(
                                'Near Me',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = "Below 100";
                        _FilterLoad = "Below 100";
                        skip = 0;
                        limit = 20;
                        loading = true;
                      });
                      itemsgrid.clear();

                      fetchbelowhundred(skip, limit);
                    },
                    child: _selectedFilter == "Below 100"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Below 100',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    child: _selectedFilter == "Sort"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Sort',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Sort',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          ),
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.2, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          height: 200,
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
                                    'Sort',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                ListTile(
                                  title: Text(
                                    'Price Low to High',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Sort';
                                      _FilterLoad = "Lowest Price";
                                      skip = 0;
                                      limit = 20;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    Navigator.of(context).pop();

                                    fetchLowestPrice(skip, limit);
                                  },
                                ),
                                ListTile(
                                  title: Text(
                                    'Price High to Low',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Sort';
                                      _FilterLoad = "Highest Price";
                                      skip = 0;
                                      limit = 20;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    Navigator.of(context).pop();

                                    fetchHighestPrice(skip, limit);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      loadbrands();
                    },
                    child: _selectedFilter == "Brand"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Brand',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Brand',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                          height: 500,
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: SingleChildScrollView(
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
                                      'Conditions',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
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
                                              setState(() {
                                                _selectedCondition =
                                                    conditions[index];
                                              });

                                              setState(() {
                                                _selectedFilter = 'Condition';
                                                _FilterLoad = "Condition";
                                                condition = _selectedCondition;
                                                skip = 0;
                                                limit = 20;
                                                loading = true;
                                              });
                                              itemsgrid.clear();
                                              Navigator.of(context).pop();

                                              fetchCondition(
                                                  _selectedCondition);
                                            },
                                            child: ListTile(
                                              title: conditions[index] != null
                                                  ? Text(conditions[index])
                                                  : Text('sd'),
                                            ),
                                          );
                                        },
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                    child: _selectedFilter == "Condition"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 80,
                            child: Center(
                              child: Text(
                                'Condition',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      scaffoldState.currentState.showBottomSheet((context) {
                        return Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Feather.chevron_down),
                                SizedBox(
                                  height: 2,
                                ),
                                Center(
                                  child: Text(
                                    'Price',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ),
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
                                            width: 200,
                                            padding: EdgeInsets.only(),
                                            child: Center(
                                              child: TextField(
                                                cursorColor: Color(0xFF979797),
                                                controller: minpricecontroller,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Price " + currency,
                                                    alignLabelWithHint: true,
                                                    labelStyle: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                    focusColor: Colors.black,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
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
                                            width: 200,
                                            padding: EdgeInsets.only(),
                                            child: Center(
                                              child: TextField(
                                                cursorColor: Color(0xFF979797),
                                                controller: maxpricecontroller,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Price " + currency,
                                                    alignLabelWithHint: true,
                                                    labelStyle: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                    focusColor: Colors.black,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ))),
                                              ),
                                            )))),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _selectedFilter = 'Price';
                                        _FilterLoad = "Price";
                                        minprice = minpricecontroller.text;
                                        maxprice = maxpricecontroller.text;
                                        skip = 0;
                                        limit = 20;
                                        loading = true;
                                      });
                                      itemsgrid.clear();
                                      Navigator.of(context).pop();

                                      fetchPrice(minpricecontroller.text,
                                          maxpricecontroller.text);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                    ))
                              ],
                            ));
                      });
                    },
                    child: _selectedFilter == "Price"
                        ? Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.deepOrangeAccent),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Price',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            width: 60,
                            child: Center(
                              child: Text(
                                'Price',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.deepOrange),
                              ),
                            ),
                          )),
              ],
            ),
          ),
        ));
  }

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
        height: 500,
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

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List>(
        stream: getItemsSearch(query).asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.restore),
                  title: Text(snapshot.data[index]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Search(text: snapshot.data[index])),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        });
  }

  Future<List> getItemsSearch(String text) async {
    var url =
        'https://api.sellship.co/api/searchresults/' + country + '/' + text;

    final response = await http.get(url);

    List responseJson = json.decode(response.body.toString());
    responseJson.add(text);
    return responseJson;
  }

  List<String> itemsresult = const [];

  bool gridtoggle;

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isNotEmpty
        ? FutureBuilder<List>(
            future: getItemsSearch(query),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.length);
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.restore),
                      title: Text(snapshot.data[index]),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Search(text: snapshot.data[index])),
                      ),
                    );
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
