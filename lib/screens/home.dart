import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:SellShip/screens/nearme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
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

  bool loading;

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
      if (nearmeitemsgrid != null) {
        setState(() {
          nearmeitemsgrid = nearmeitemsgrid;
          loading = false;
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
    if (country == null) {
      _getLocation();
    } else {
      var url = 'https://sellship.co/api/recentitems/' +
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
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
    }
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
        loading = false;
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
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
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
        loading = false;
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
    if (itemsgrid == itemsgrid) {
      print('No New Items');
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

  LatLng position;
//  String city;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    setState(() {
      skip = 0;
      limit = 10;
      loading = true;
    });

    readstorage();

    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize = _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels == triggerFetchMoreSize) {
          if (_selectedFilter == 'Near me') {
            _getmoreData();
          } else if (_selectedFilter == 'Recently Added') {
            _getmoreRecentData();
          } else if (_selectedFilter == 'Below 100') {
            _getmorebelowhundred();
          } else if (_selectedFilter == 'Lowest Price') {
            _getmorelowestprice();
          } else if (_selectedFilter == 'Highest Price') {
            _getmorehighestprice();
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
      await storage.write(
          key: 'longitude', value: location.longitude.toString());
      setState(() {
        position =
            LatLng(location.latitude.toDouble(), location.longitude.toDouble());
        fetchRecentlyAdded(skip, limit);
        getcity();
      });
    } on Exception catch (e) {
      print(e);
      Location().requestPermission();
      _getLocation();
      setState(() {
        loading = false;
        itemsgrid = [];
      });
    }
  }

  String country;

  final Geolocator geolocator = Geolocator();

  void getcity() async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];
    var cit = place.administrativeArea;
    var countryy = place.country;
    await storage.write(key: 'city', value: cit);
    await storage.write(key: 'country', value: countryy);

    if (country.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
    fetchItems(skip, limit);
    setState(() {
      city = cit;
      country = countryy;
    });
  }

  String city;

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var cit = await storage.read(key: 'city');
    var countr = await storage.read(key: 'country');
    fetchRecentlyAdded(skip, limit);
    if (latitude == null || longitude == null) {
      _getLocation();
    } else {
      fetchItems(skip, limit);
      setState(() {
        position = LatLng(double.parse(latitude), double.parse(longitude));
        city = cit;
        country = countr;
      });
    }
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

  String _selectedFilter = 'Recently Added';

  ScrollController carouselController = ScrollController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 120),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300, spreadRadius: 5, blurRadius: 6)
              ]),
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 30,
                          width: 120,
                          child: Image.asset(
                            'assets/logotransparent.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 5, top: 5, left: 10),
                              child: Container(
                                  height: 45,
                                  width: 300,
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
                                      ))),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            CircleAvatar(
                              maxRadius: 17,
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              child: Icon(
                                Icons.favorite,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              maxRadius: 17,
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              child: Icon(
                                Icons.chat_bubble,
                                size: 16,
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ),
            )),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 75,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (ctx, i) {
                              return Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5.0),
                                        width:
                                            MediaQuery.of(context).size.width /
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
                                              alignment: Alignment.bottomCenter,
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
                        Container(
                            height: 300,
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
                        Row(children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                                        builder: (context) => NearMe()),
                                  );
                                },
                                child: Text('View All',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black)),
                              )),
                        ]),
                        SizedBox(
                          height: 5,
                        ),
                        nearmeitemsgrid.isNotEmpty
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 210,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 15,
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
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  5,
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
                        Row(children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 10, bottom: 5),
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
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 0.8),
                                      itemCount: itemsgrid.length,
                                      itemBuilder: (context, index) {
                                        if (index != 0 && index % 8 == 0) {
                                          return Platform.isIOS == true
                                              ? Container(
                                                  height: 330,
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.only(
                                                      bottom: 20.0),
                                                  child: NativeAdmob(
                                                    adUnitID: _iosadUnitID,
                                                    controller: _controller,
                                                  ),
                                                )
                                              : Container(
                                                  height: 330,
                                                  padding: EdgeInsets.all(10),
                                                  margin: EdgeInsets.only(
                                                      bottom: 20.0),
                                                  child: NativeAdmob(
                                                    adUnitID: _androidadUnitID,
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
                                                            height: 150,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  itemsgrid[
                                                                          index]
                                                                      .image,
                                                              fit: BoxFit.cover,
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
                                                                itemsgrid[index]
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 16,
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
                                                                itemsgrid[index]
                                                                    .category,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 5.0),
                                                            currency != null
                                                                ? Container(
                                                                    child: Text(
                                                                      itemsgrid[index]
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
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    child: Text(
                                                                      itemsgrid[
                                                                              index]
                                                                          .price
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )));
                                      },
                                    )))
                            : Expanded(
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
                      ]))
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Column(
                      children: [0, 1, 2, 3, 4, 5, 6]
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                          ),
                                          Container(
                                            width: 40.0,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        ));
  }
}
