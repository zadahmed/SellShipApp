import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:SellShip/screens/favourites.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/nearme.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/search.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> itemsgrid = [];

  List<Item> nearmeitemsgrid = [];
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
      nearmeitemsgrid.clear();
      var url = 'https://sellship.co/api/getitems/' +
          country +
          '/' +
          0.toString() +
          '/' +
          15.toString();

      final response = await http.post(url, body: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString()
      });
      if (response.statusCode == 200) {
        var jsonbody = json.decode(response.body);

        for (var i = 0; i < jsonbody.length; i++) {
          Item item = Item(
            itemid: jsonbody[i]['_id']['\$oid'],
            name: jsonbody[i]['name'],
            image: jsonbody[i]['image'],
            price: jsonbody[i]['price'],
            category: jsonbody[i]['category'],
          );
          nearmeitemsgrid.add(item);
        }
      }
      if (nearmeitemsgrid != null) {
        setState(() {
          nearmeitemsgrid = nearmeitemsgrid;
        });
      } else {
        setState(() {
          nearmeitemsgrid = [];
        });
      }

      return nearmeitemsgrid;
    }
  }

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
      );
      itemsgrid.add(item);
    }
    print(itemsgrid);
    setState(() {
      itemsgrid = itemsgrid;
    });

    return itemsgrid;
  }

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/belowhundred/' +
          country +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();

      final response = await http.get(url);

      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    }
  }

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/highestprice/' +
          country +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();

      final response = await http.get(url);

      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    }
  }

  Future<List<Item>> fetchbrands(String brand) async {
    var categoryurl = 'https://sellship.co/api/filter/brand/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchCondition(String condition) async {
    var categoryurl = 'https://sellship.co/api/filter/condition/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchPrice(String minprice, String maxprice) async {
    var categoryurl = 'https://sellship.co/api/filter/price/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorecondition(String condition) async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/condition/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorePrice(String minprice, String maxprice) async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/price/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> getmorebrands(String brand) async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/brand/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    } else {
      print(categoryresponse.statusCode);
    }
  }

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/lowestprice/' +
          country +
          '/' +
          skip.toString() +
          '/' +
          limit.toString();

      final response = await http.get(url);

      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    }
  }

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/highestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/lowestprice/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  _getmorebelowhundred() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/belowhundred/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
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

  _getNearMeData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/getitems/' +
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
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  Future<List<Item>> fetchItemsNearMe(int skip, int limit) async {
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/getitems/' +
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
        Item item = Item(
          itemid: jsonbody[i]['_id']['\$oid'],
          name: jsonbody[i]['name'],
          image: jsonbody[i]['image'],
          price: jsonbody[i]['price'],
          category: jsonbody[i]['category'],
        );
        itemsgrid.add(item);
      }
      setState(() {
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    }
  }

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/recentitems/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    var jsonbody = json.decode(response.body);

    for (var i = 0; i < jsonbody.length; i++) {
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
  }

  LatLng position;
//  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 10;
    });

    readstorage();

    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize = _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels == triggerFetchMoreSize) {
          if (_selectedFilter == 'Near me') {
            _getNearMeData();
          } else if (_selectedFilter == 'Recently Added') {
            _getmoreRecentData();
          } else if (_selectedFilter == 'Below 100') {
            _getmorebelowhundred();
          } else if (_selectedFilter == 'Lowest Price') {
            _getmorelowestprice();
          } else if (_selectedFilter == 'Highest Price') {
            _getmorehighestprice();
          } else if (_selectedFilter == 'Brands') {
            getmorebrands(brand);
          } else if (_selectedFilter == 'Price') {
            getmorePrice(minprice, maxprice);
          } else if (_selectedFilter == 'Condition') {
            getmorecondition(condition);
          }
        }
      });
  }

  _getmoreData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });
    var url = 'https://sellship.co/api/getitems/' +
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
      Item item = Item(
        itemid: jsonbody[i]['_id']['\$oid'],
        name: jsonbody[i]['name'],
        image: jsonbody[i]['image'],
        price: jsonbody[i]['price'],
        category: jsonbody[i]['category'],
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
      var userid = await storage.read(key: 'userid');

      var token = await FirebaseNotifications().getNotifications();
      if (userid != null) {
        print(token + "\n Token was recieved from firebase");
        var url =
            'https://sellship.co/api/checktokenfcm/' + userid + '/' + token;
        print(url);
        final response = await http.get(url);
        if (response.statusCode == 200) {
          print(response.body);
        } else {
          print(response.statusCode);
        }
      }

      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());
        getcity();
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'locationcountry', value: countr);
      setState(() {
        city = cit;
        locationcountry = countr;
        print(city);
      });
      fetchItems(skip, limit);
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
      setState(() {
        nearmeitemsgrid = [];
      });
    }
  }

  String locationcountry;
  String country;

  String brand;
  String minprice;
  String maxprice;
  String condition;

  final scaffoldState = GlobalKey<ScaffoldState>();

  final Geolocator geolocator = Geolocator();

  void getcity() async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];
    var cit = place.administrativeArea;
    var countryy = place.country;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'locationcountry', value: countryy);

    fetchItems(skip, limit);
    setState(() {
      city = cit;
      locationcountry = countryy;
    });
  }

  String city;

  void readstorage() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
    setState(() {
      country = countr;
    });
    fetchRecentlyAdded(skip, limit);

    _getLocation();
    loadbrands();
  }

  var images = [
    'assets/fashion.png',
    'assets/laptop.png',
    'assets/sports.png',
  ];

  TextEditingController searchcontroller = new TextEditingController();

  onSearch(String texte) async {
    if (texte.isEmpty) {
      setState(() {
        skip = 0;
        limit = 10;
        fetchRecentlyAdded(skip, limit);
      });
    } else {
      searchcontroller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search(text: texte)),
      );
    }
  }

  List<String> brands = List<String>();
  loadbrands() async {
    var categoryurl = 'https://sellship.co/api/getallbrands';
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
  }

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
  String _selectedFilter = 'Recently Added';

  ScrollController carouselController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 115),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: 120,
                        child: Image.asset(
                          'assets/logotransparent.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
//                                  height: 45,
//                                  width: 300,

                              child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Row(
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
                                              controller: searchcontroller,
                                              onSubmitted: onSearch,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'What are you looking for today?',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                  ),
                                                  border: InputBorder.none),
                                            ),
                                          ),
                                        ],
                                      )))),
                          SizedBox(
                            width: 5,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Messages()),
                                );
                              },
                              child: Icon(
                                Feather.message_square,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                        ],
                      )
                    ],
                  )),
            )),
        body: GestureDetector(onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        }, child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, top: 10, bottom: 10),
                              child: Text('Categories',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
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
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.black)),
                                )),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 75,
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
                                          margin: const EdgeInsets.only(
                                              bottom: 5.0),
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3 -
                                              20,
                                          height: 75,
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 30,
                                                width: 120,
                                                child: Icon(
                                                  categories[i].icon,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  "${categories[i].title}",
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                carouselController: carouselController,
                                autoPlay: true,
                                autoPlayAnimationDuration: Duration(seconds: 1),
                                aspectRatio: 2.0,
                                enlargeCenterPage: true,
                              ),
                              items: images
                                  .map((item) => InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryScreen()),
                                        );
                                      },
                                      child: Hero(
                                          tag: item,
                                          child: Image.asset(
                                            item,
                                            fit: BoxFit.fitWidth,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ))))
                                  .toList(),
                            )),
                        nearmeitemsgrid.isNotEmpty
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, top: 10, bottom: 10),
                                      child: Text('Near me',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
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
                                                  builder: (context) =>
                                                      NearMe()),
                                            );
                                          },
                                          child: Text('View All',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black)),
                                        )),
                                  ])
                            : Container(),
                        nearmeitemsgrid.isNotEmpty
                            ? SizedBox(
                                height: 5,
                              )
                            : Container(),
                        nearmeitemsgrid.isNotEmpty
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 230,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 15,
                                    shrinkWrap: true,
                                    itemBuilder: (ctx, i) {
                                      return Row(
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => Details(
                                                              itemid:
                                                                  nearmeitemsgrid[
                                                                          i]
                                                                      .itemid)),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                      color: Colors.white,
                                                    ),
                                                    child: new Column(
                                                      children: <Widget>[
                                                        new Stack(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 120,
                                                              width: 150,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    nearmeitemsgrid[
                                                                            i]
                                                                        .image,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitChasingDots(
                                                                        color: Colors
                                                                            .deepOrange),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        new Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: new Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                height: 20,
                                                                child: Text(
                                                                  nearmeitemsgrid[
                                                                          i]
                                                                      .name,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5.0),
                                                              Container(
                                                                child: Text(
                                                                  nearmeitemsgrid[
                                                                          i]
                                                                      .category,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5.0),
                                                              Container(
                                                                child: Text(
                                                                  nearmeitemsgrid[
                                                                              i]
                                                                          .price
                                                                          .toString() +
                                                                      ' ' +
                                                                      currency,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ))),
                                        ],
                                      );
                                    }))
                            : Container(),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 600,
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryScreen()),
                                  );
                                },
                                child: Container(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.asset(
                                          'assets/homeshow/clothes.jpeg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Container(
                                              height: 40,
                                              width: 180,
                                              color: Colors.white,
                                              child: Center(
                                                child: Text('#PRELOVEDFASHION',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black)),
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 500,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: new ExactAssetImage(
                                      'assets/homeshow/bgimage.jpeg'),
                                  fit: BoxFit.cover,
                                )),
                                child: GridView.count(
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.4,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Women")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/ladies.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Women',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Men")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/men.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Men',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Boys")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/boy.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Boys',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Girls")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/girls.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Girls',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Women")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/bag.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Bags',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryDetail(
                                                      category:
                                                          'Fashion & Accessories',
                                                      subcategory: "Women")),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.asset(
                                                  'assets/homeshow/watch.jpeg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                      height: 30,
                                                      width: 100,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text('Watches',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black)),
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Text('Recently Added',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black)),
                          ),
                        ]),
                        itemsgrid.isNotEmpty
                            ? Flexible(
                                child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: StickyHeader(
                                        header: Container(
                                          height: 40.0,
                                          color: Colors.white,
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                InkWell(
                                                  child: Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            10,
                                                    child: Center(
                                                      child: Text(
                                                        'SORT',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    scaffoldState.currentState
                                                        .showBottomSheet(
                                                            (context) {
                                                      return Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ListTile(
                                                                title: Text(
                                                                  'Sort',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                child: ListTile(
                                                                  title: Text(
                                                                    'New',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Recently Added';
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchRecentlyAdded(
                                                                      skip,
                                                                      limit);
                                                                },
                                                              ),
                                                              InkWell(
                                                                child: ListTile(
                                                                  title: Text(
                                                                    'Near me',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Near me';
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchItemsNearMe(
                                                                      skip,
                                                                      limit);
                                                                },
                                                              ),
                                                              InkWell(
                                                                child: ListTile(
                                                                  title: Text(
                                                                    'Below 100',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Below 100';
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchbelowhundred(
                                                                      skip,
                                                                      limit);
                                                                },
                                                              ),
                                                              InkWell(
                                                                child: ListTile(
                                                                  title: Text(
                                                                    'Price Low to High',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Lowest Price';
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchLowestPrice(
                                                                      skip,
                                                                      limit);
                                                                },
                                                              ),
                                                              InkWell(
                                                                child: ListTile(
                                                                  title: Text(
                                                                    'Price High to Low',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Highest Price';
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchHighestPrice(
                                                                      skip,
                                                                      limit);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                ),
                                                Container(
                                                    height: 40,
                                                    child: VerticalDivider(
                                                        color: Colors.black)),
                                                InkWell(
                                                  onTap: () {
                                                    scaffoldState.currentState
                                                        .showBottomSheet(
                                                            (context) {
                                                      return Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                ListTile(
                                                                  title: Text(
                                                                    'Filter',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w800,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                ExpansionTile(
                                                                  title: Text(
                                                                    'Brand',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                        height:
                                                                            500,
                                                                        child:
                                                                            AlphabetListScrollView(
                                                                          strList:
                                                                              brands,
                                                                          indexedHeight:
                                                                              (i) {
                                                                            return 40;
                                                                          },
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return InkWell(
                                                                              onTap: () async {
                                                                                setState(() {
                                                                                  _selectedFilter = 'Brands';
                                                                                  brand = brands[index];
                                                                                  skip = 0;
                                                                                  limit = 10;
                                                                                });
                                                                                itemsgrid.clear();
                                                                                Navigator.of(context).pop();

                                                                                fetchbrands(brands[index]);
                                                                              },
                                                                              child: ListTile(
                                                                                title: Text(brands[index]),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ))
                                                                  ],
                                                                ),
                                                                ExpansionTile(
                                                                  title: Text(
                                                                    'Condition',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              30,
                                                                          right:
                                                                              30),
                                                                      child: Container(
                                                                          width: MediaQuery.of(context).size.width,
                                                                          child: Center(
                                                                              child: Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: DropdownButton<String>(
                                                                                    value: _selectedCondition,
                                                                                    hint: Text('Please choose the condition of your Item'), // No
                                                                                    icon: Icon(Icons.keyboard_arrow_down),
                                                                                    iconSize: 20,
                                                                                    elevation: 1,
                                                                                    isExpanded: true,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Montserrat',
                                                                                      fontSize: 16,
                                                                                    ),
                                                                                    onChanged: (String newValue) {
                                                                                      setState(() {
                                                                                        _selectedCondition = newValue;
                                                                                      });

                                                                                      setState(() {
                                                                                        _selectedFilter = 'Condition';
                                                                                        condition = _selectedCondition;
                                                                                        skip = 0;
                                                                                        limit = 10;
                                                                                      });
                                                                                      itemsgrid.clear();
                                                                                      Navigator.of(context).pop();

                                                                                      fetchCondition(_selectedCondition);
                                                                                    },
                                                                                    items: conditions.map<DropdownMenuItem<String>>((String value) {
                                                                                      return DropdownMenuItem<String>(
                                                                                        value: value,
                                                                                        child: Text(
                                                                                          value,
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.black),
                                                                                        ),
                                                                                      );
                                                                                    }).toList(),
                                                                                  )))),
                                                                    ),
                                                                  ],
                                                                ),
                                                                ExpansionTile(
                                                                  title: Text(
                                                                    'Price',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                        height:
                                                                            130,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.shade300,
                                                                              offset: Offset(0.0, 1.0), //(x,y)
                                                                              blurRadius: 6.0,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: <
                                                                              Widget>[
                                                                            Center(
                                                                                child: ListTile(
                                                                                    title: Text(
                                                                                      'Minimum Price',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Montserrat',
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
                                                                                            keyboardType: TextInputType.numberWithOptions(),
                                                                                            decoration: InputDecoration(
                                                                                                labelText: "Price " + currency,
                                                                                                alignLabelWithHint: true,
                                                                                                labelStyle: TextStyle(
                                                                                                  fontFamily: 'Montserrat',
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
                                                                            Center(
                                                                                child: ListTile(
                                                                                    title: Text(
                                                                                      'Maximum Price',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Montserrat',
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
                                                                                            keyboardType: TextInputType.numberWithOptions(),
                                                                                            decoration: InputDecoration(
                                                                                                labelText: "Price " + currency,
                                                                                                alignLabelWithHint: true,
                                                                                                labelStyle: TextStyle(
                                                                                                  fontFamily: 'Montserrat',
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
                                                                                        ))))
                                                                          ],
                                                                        )),
                                                                    InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            _selectedFilter =
                                                                                'Price';
                                                                            minprice =
                                                                                minpricecontroller.text;
                                                                            maxprice =
                                                                                maxpricecontroller.text;
                                                                            skip =
                                                                                0;
                                                                            limit =
                                                                                10;
                                                                          });
                                                                          itemsgrid
                                                                              .clear();
                                                                          Navigator.of(context)
                                                                              .pop();

                                                                          fetchPrice(
                                                                              minpricecontroller.text,
                                                                              maxpricecontroller.text);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              50,
                                                                          color:
                                                                              Colors.deepOrange,
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              'Filter',
                                                                              style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ))
                                                                  ],
                                                                ),
//
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            10,
                                                    child: Center(
                                                      child: Text(
                                                        'FILTER',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        content: GridView.builder(
                                          cacheExtent: double.parse(
                                              itemsgrid.length.toString()),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.80),
                                          itemCount: itemsgrid.length,
                                          itemBuilder: (context, index) {
                                            if (index != 0 && index % 8 == 0) {
                                              return Platform.isIOS == true
                                                  ? Container(
                                                      height: 330,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      margin: EdgeInsets.only(
                                                          bottom: 20.0),
                                                      child: NativeAdmob(
                                                        adUnitID: _iosadUnitID,
                                                        controller: _controller,
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 330,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      margin: EdgeInsets.only(
                                                          bottom: 20.0),
                                                      child: NativeAdmob(
                                                        adUnitID:
                                                            _androidadUnitID,
                                                        controller: _controller,
                                                      ),
                                                    );
                                            }

                                            return Padding(
                                                padding: EdgeInsets.all(4),
                                                child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Details(
                                                                    itemid: itemsgrid[
                                                                            index]
                                                                        .itemid)),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .grey.shade300,
                                                            offset: Offset(0.0,
                                                                1.0), //(x,y)
                                                            blurRadius: 6.0,
                                                          ),
                                                        ],
                                                        color: Colors.white,
                                                      ),
                                                      child: new Column(
                                                        children: <Widget>[
                                                          new Stack(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 150,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      itemsgrid[
                                                                              index]
                                                                          .image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    height: 20,
                                                                    child: Text(
                                                                      itemsgrid[
                                                                              index]
                                                                          .name,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5.0),
                                                                  Container(
                                                                    child: Text(
                                                                      itemsgrid[
                                                                              index]
                                                                          .category,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5.0),
                                                                  currency !=
                                                                          null
                                                                      ? Container(
                                                                          child:
                                                                              Text(
                                                                            itemsgrid[index].price.toString() +
                                                                                ' ' +
                                                                                currency,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Montserrat',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          child:
                                                                              Text(
                                                                            itemsgrid[index].price.toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Montserrat',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                          ),
                                                                        )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )));
                                          },
                                        ))))
                            : StickyHeader(
                                header: Container(
                                  height: 40.0,
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        InkWell(
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                10,
                                            child: Center(
                                              child: Text(
                                                'SORT',
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            scaffoldState.currentState
                                                .showBottomSheet((context) {
                                              return Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          'Sort',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            'New',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Recently Added';
                                                            skip = 0;
                                                            limit = 10;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchRecentlyAdded(
                                                              skip, limit);
                                                        },
                                                      ),
                                                      InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            'Near me',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Near me';
                                                            skip = 0;
                                                            limit = 10;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchItems(
                                                              skip, limit);
                                                        },
                                                      ),
                                                      InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            'Below 100',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Below 100';
                                                            skip = 0;
                                                            limit = 10;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchbelowhundred(
                                                              skip, limit);
                                                        },
                                                      ),
                                                      InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            'Price Low to High',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Lowest Price';
                                                            skip = 0;
                                                            limit = 10;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchLowestPrice(
                                                              skip, limit);
                                                        },
                                                      ),
                                                      InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            'Price High to Low',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Highest Price';
                                                            skip = 0;
                                                            limit = 10;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchHighestPrice(
                                                              skip, limit);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                        Container(
                                            height: 40,
                                            child: VerticalDivider(
                                                color: Colors.black)),
                                        InkWell(
                                          onTap: () {
                                            scaffoldState.currentState
                                                .showBottomSheet((context) {
                                              return Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ListTile(
                                                          title: Text(
                                                            'Filter',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        ExpansionTile(
                                                          title: Text(
                                                            'Brand',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          children: <Widget>[
                                                            Container(
                                                                height: 500,
                                                                child:
                                                                    AlphabetListScrollView(
                                                                  strList:
                                                                      brands,
                                                                  indexedHeight:
                                                                      (i) {
                                                                    return 40;
                                                                  },
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          _selectedFilter =
                                                                              'Brands';
                                                                          brand =
                                                                              brands[index];
                                                                          skip =
                                                                              0;
                                                                          limit =
                                                                              10;
                                                                        });
                                                                        itemsgrid
                                                                            .clear();
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        fetchbrands(
                                                                            brands[index]);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            brands[index]),
                                                                      ),
                                                                    );
                                                                  },
                                                                ))
                                                          ],
                                                        ),
                                                        ExpansionTile(
                                                          title: Text(
                                                            'Condition',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 30,
                                                                      right:
                                                                          30),
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child: Center(
                                                                      child: Align(
                                                                          alignment: Alignment.center,
                                                                          child: DropdownButton<String>(
                                                                            value:
                                                                                _selectedCondition,
                                                                            hint:
                                                                                Text('Please choose the condition of your Item'), // No
                                                                            icon:
                                                                                Icon(Icons.keyboard_arrow_down),
                                                                            iconSize:
                                                                                20,
                                                                            elevation:
                                                                                1,
                                                                            isExpanded:
                                                                                true,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Montserrat',
                                                                              fontSize: 16,
                                                                            ),
                                                                            onChanged:
                                                                                (String newValue) {
                                                                              setState(() {
                                                                                _selectedCondition = newValue;
                                                                              });

                                                                              setState(() {
                                                                                _selectedFilter = 'Condition';
                                                                                condition = _selectedCondition;
                                                                                skip = 0;
                                                                                limit = 10;
                                                                              });
                                                                              itemsgrid.clear();
                                                                              Navigator.of(context).pop();

                                                                              fetchCondition(_selectedCondition);
                                                                            },
                                                                            items:
                                                                                conditions.map<DropdownMenuItem<String>>((String value) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: value,
                                                                                child: Text(
                                                                                  value,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.black),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          )))),
                                                            ),
                                                          ],
                                                        ),
                                                        ExpansionTile(
                                                          title: Text(
                                                            'Price',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          children: <Widget>[
                                                            Container(
                                                                height: 130,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0), //(x,y)
                                                                      blurRadius:
                                                                          6.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: <
                                                                      Widget>[
                                                                    Center(
                                                                        child: ListTile(
                                                                            title: Text(
                                                                              'Minimum Price',
                                                                              style: TextStyle(
                                                                                fontFamily: 'Montserrat',
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
                                                                                    keyboardType: TextInputType.numberWithOptions(),
                                                                                    decoration: InputDecoration(
                                                                                        labelText: "Price " + currency,
                                                                                        alignLabelWithHint: true,
                                                                                        labelStyle: TextStyle(
                                                                                          fontFamily: 'Montserrat',
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
                                                                    Center(
                                                                        child: ListTile(
                                                                            title: Text(
                                                                              'Maximum Price',
                                                                              style: TextStyle(
                                                                                fontFamily: 'Montserrat',
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
                                                                                    keyboardType: TextInputType.numberWithOptions(),
                                                                                    decoration: InputDecoration(
                                                                                        labelText: "Price " + currency,
                                                                                        alignLabelWithHint: true,
                                                                                        labelStyle: TextStyle(
                                                                                          fontFamily: 'Montserrat',
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
                                                                                ))))
                                                                  ],
                                                                )),
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    _selectedFilter =
                                                                        'Price';
                                                                    minprice =
                                                                        minpricecontroller
                                                                            .text;
                                                                    maxprice =
                                                                        maxpricecontroller
                                                                            .text;
                                                                    skip = 0;
                                                                    limit = 10;
                                                                  });
                                                                  itemsgrid
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  fetchPrice(
                                                                      minpricecontroller
                                                                          .text,
                                                                      maxpricecontroller
                                                                          .text);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  color: Colors
                                                                      .deepOrange,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Filter',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
//
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                10,
                                            child: Center(
                                              child: Text(
                                                'FILTER',
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                content: Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                              'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 16,
                                              )),
                                        ),
                                        Expanded(
                                            child: Image.asset(
                                          'assets/little_theologians_4x.jpg',
                                          fit: BoxFit.cover,
                                        ))
                                      ],
                                    )),
                              ),
                      ])));
        })));
  }
}
