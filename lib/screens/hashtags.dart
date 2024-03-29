import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/filterpage.dart';
import 'package:SellShip/screens/home.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:badges/badges.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:SellShip/screens/comments.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class Hashtags extends StatefulWidget {
  final String hashtag;

  Hashtags({
    Key key,
    this.hashtag,
  }) : super(key: key);

  @override
  _HashtagsState createState() => _HashtagsState();
}

class _HashtagsState extends State<Hashtags> {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  void dispose() {
    _scrollController.dispose();
    minpricecontroller.dispose();
    maxpricecontroller.dispose();
    super.dispose();
  }

  _getmoreData() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/subcategories/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  String country;

  Future<List<Item>> fetchItems(int skip, int limit) async {
    country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        country = country;
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        country = country;
      });
    } else if (country.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
        country = country;
      });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
        country = country;
      });
    }

    var url = 'https://api.sellship.co/api/searchhashtagsresults/' +
        widget.hashtag.trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/categories/recent/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      if (itemsgrid == null) {
        itemsgrid = [];
      }

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/categories/belowhundred/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/categories/highestprice/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  TextEditingController searchcontroller = new TextEditingController();

  Future<List<Item>> fetchbrands(String brand) async {
    var categoryurl = 'https://api.sellship.co/api/filter/category/brand/' +
        country +
        '/' +
        category +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> fetchCondition(String condition) async {
    var categoryurl = 'https://api.sellship.co/api/filter/category/condition/' +
        country +
        '/' +
        category +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> fetchPrice(String minprice, String maxprice) async {
    var categoryurl = 'https://api.sellship.co/api/filter/category/price/' +
        country +
        '/' +
        category +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> getmorecondition(String condition) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/category/condition/' +
        country +
        '/' +
        category +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> getmorePrice(String minprice, String maxprice) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/category/price/' +
        country +
        '/' +
        category +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> getmorebrands(String brand) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var categoryurl = 'https://api.sellship.co/api/filter/category/brand/' +
        country +
        '/' +
        category +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(categoryurl);
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
          likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
          comments: jsonbody[i]['comments'] == null
              ? 0
              : jsonbody[i]['comments'].length,
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'].toString(),
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/categories/lowestprice/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      print(itemsgrid);

      setState(() {
        itemsgrid = itemsgrid;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }

    return itemsgrid;
  }

  loadbrands() async {
    brands.clear();
    var categoryurl = 'https://api.sellship.co/api/getbrands/' + category;
    final categoryresponse = await http.get(Uri.parse(categoryurl));
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
              Icon(FeatherIcons.chevronDown),
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
            ],
          ),
        ),
      );
    });
  }

  List<String> brands = List<String>();
  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();

  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];
  String _selectedCondition;

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/categories/highestprice/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }
  }

  void getnotification() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/getnotification/' + userid;
      print(url);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var notificationinfo = json.decode(response.body);
        var notif = notificationinfo['notification'];
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
      } else {
        print(response.statusCode);
      }
    }
  }

  var notifcount;
  var notifbadge;

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/categories/lowestprice/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }
  }

  _getmorebelowhundred() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/categories/belowhundred/' +
        category +
        '/' +
        subcategory[0] +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }
  }

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(Uri.parse(url));
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

  getmorealldata() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/searchhashtagsresults/' +
        widget.hashtag.trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        var q = Map<String, dynamic>.from(jsondata['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          date: dateuploaded,
          likes: jsondata['likes'] == null ? 0 : jsondata['likes'],
          comments:
              jsondata['comments'] == null ? 0 : jsondata['comments'].length,
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          saleprice: jsondata.containsKey('saleprice')
              ? jsondata['saleprice'].toString()
              : null,
          category: jsondata['category'],
          sold: jsondata['sold'] == null ? false : jsondata['sold'],
        );
        itemsgrid.add(item);
      }

      setState(() {
        itemsgrid = itemsgrid;
      });
    } else {
      print(response.statusCode);
    }
  }

  final storage = new FlutterSecureStorage();

  var currency;
  String brand;
  String minprice;
  String maxprice;
  String condition;
  String category;
  String subcategory;

  @override
  void initState() {
    setState(() {
      skip = 0;
      limit = 40;
      subcategory = widget.hashtag;
      loading = true;
    });

    getfavourites();
    fetchItems(skip, limit);

    super.initState();
  }

  TabController _tabController;

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

  bool loading;
  bool gridtoggle = true;

  ScrollController _scrollController = ScrollController();
  final scaffoldState = GlobalKey<ScaffoldState>();

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        floatingActionButton: InkWell(
          onTap: () {
            Navigator.of(context).push(_createRoute());
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 2.0), //(x,y)
                blurRadius: 4.0,
              ),
            ], color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Icon(
              FeatherIcons.sliders,
              size: 18,
              color: Colors.deepOrange,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                      title: Text(
                        widget.hashtag,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      floating: false,
                      elevation: 0,
                      centerTitle: true,
                      pinned: true,
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                  ];
                },
                body: loading == false
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
                        slivers: <Widget>[
                          SliverStaggeredGrid.countBuilder(
                            crossAxisCount: 2,
                            itemCount: itemsgrid.length,
                            staggeredTileBuilder: (int index) =>
                                new StaggeredTile.fit(1),
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            itemBuilder: (BuildContext context, index) {
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
                                                      itemid: itemsgrid[index]
                                                          .itemid,
                                                      sold:
                                                          itemsgrid[index].sold,
                                                      source: 'catdetail',
                                                      image: itemsgrid[index]
                                                          .image,
                                                      name:
                                                          itemsgrid[index].name,
                                                    )),
                                          );
                                        },
                                        child: Stack(children: <Widget>[
                                          Container(
                                            height: 195,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
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
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Hero(
                                                tag:
                                                    'catdetail${itemsgrid[index].itemid}',
                                                child: CachedNetworkImage(
                                                  height: 200,
                                                  width: 300,
                                                  fadeInDuration:
                                                      Duration(microseconds: 5),
                                                  imageUrl: itemsgrid[index]
                                                          .image
                                                          .isEmpty
                                                      ? SpinKitDoubleBounce(
                                                          color:
                                                              Colors.deepOrange)
                                                      : itemsgrid[index].image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitDoubleBounce(
                                                          color: Colors
                                                              .deepOrange),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                    width: 210,
                                                    child: Center(
                                                      child: Text(
                                                        'Sold',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
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
                                                itemsgrid[index].name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1,
                                              ),
                                              Text(
                                                currency +
                                                    ' ' +
                                                    itemsgrid[index].price,
                                              )
                                            ],
                                          )),
                                          favourites != null
                                              ? favourites.contains(
                                                      itemsgrid[index].itemid)
                                                  ? InkWell(
                                                      enableFeedback: true,
                                                      onTap: () async {
                                                        var userid =
                                                            await storage.read(
                                                                key: 'userid');

                                                        if (userid != null) {
                                                          var url =
                                                              'https://api.sellship.co/api/favourite/' +
                                                                  userid;

                                                          Map<String, String>
                                                              body = {
                                                            'itemid':
                                                                itemsgrid[index]
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
                                                                  Uri.parse(
                                                                      url),
                                                                  body: json
                                                                      .encode(
                                                                          body));

                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                          } else {
                                                            print(response
                                                                .statusCode);
                                                          }
                                                        } else {
                                                          showInSnackBar(
                                                              'Please Login to use Wishlist');
                                                        }
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 16,
                                                        backgroundColor:
                                                            Colors.deepOrange,
                                                        child: Icon(
                                                          FontAwesomeIcons
                                                              .heart,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ))
                                                  : InkWell(
                                                      enableFeedback: true,
                                                      onTap: () async {
                                                        var userid =
                                                            await storage.read(
                                                                key: 'userid');

                                                        if (userid != null) {
                                                          var url =
                                                              'https://api.sellship.co/api/favourite/' +
                                                                  userid;

                                                          Map<String, String>
                                                              body = {
                                                            'itemid':
                                                                itemsgrid[index]
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
                                                                  Uri.parse(
                                                                      url),
                                                                  body: json
                                                                      .encode(
                                                                          body));

                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                          } else {
                                                            print(response
                                                                .statusCode);
                                                          }
                                                        } else {
                                                          showInSnackBar(
                                                              'Please Login to use Wishlist');
                                                        }
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Icon(
                                                          FeatherIcons.heart,
                                                          color:
                                                              Colors.blueGrey,
                                                          size: 16,
                                                        ),
                                                      ))
                                              : CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Colors.blueGrey.shade50,
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      FeatherIcons.heart,
                                                      color: Colors.blueGrey,
                                                      size: 16,
                                                    ),
                                                  ))
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                        onLoad: () async {
                          getmorealldata();
                        },
                      )
                    : Container(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                        )))));
  }
}
