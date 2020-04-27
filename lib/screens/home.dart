import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
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
        loading = false;
        itemsgrid = itemsgrid;
      });

      return itemsgrid;
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          (_scrollController.position.maxScrollExtent)) {
        print(_selectedFilter);
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

        getcity();
      });
    } on Exception catch (e) {
      print(e);
      location = null;
      _getLocation();
      setState(() {
        loading = false;
        itemsgrid = null;
      });
    }
  }

  int _selectedCat;

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
        currency = 'USD';
      });
    }

    setState(() {
      city = cit;
      country = countryy;
      fetchItems(skip, limit);
      //secure storage save it
    });
  }

  String city;

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var cit = await storage.read(key: 'city');
    var countr = await storage.read(key: 'country');

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

  TextEditingController searchcontroller = new TextEditingController();

  onSearch(String texte) async {
    if (texte.isEmpty) {
      setState(() {
        skip = 0;
        limit = 10;
        fetchItems(skip, limit);
      });
    } else {
      searchcontroller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search(text: texte)),
      );
    }
  }

  String _selectedFilter = 'Near me';

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: SpinKitChasingDots(color: Colors.deepOrange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Container(
                  height: 45,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(0.0, 1), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10),
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
                                  hintText: 'Search SellShip',
                                  hintStyle: GoogleFonts.lato(fontSize: 16),
                                  border: InputBorder.none),
                            ),
                          ),
                        ],
                      ))),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                'Filter',
                                style: GoogleFonts.lato(fontSize: 11),
                              )),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.filter_list,
                            size: 12,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Near me';
                                      skip = 0;
                                      limit = 10;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    fetchItems(skip, limit);
                                  },
                                  child: Padding(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedFilter == 'Near me'
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        border: Border.all(
                                            color: Colors.deepOrange),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 20,
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          'Near me',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color:
                                                  _selectedFilter == 'Near me'
                                                      ? Colors.deepOrange
                                                      : Colors.white),
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Recently Added';
                                      skip = 0;
                                      limit = 10;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    fetchRecentlyAdded(skip, limit);
                                  },
                                  child: Padding(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedFilter == 'Recently Added'
                                                ? Colors.white
                                                : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      height: 20,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Recently Added',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color: _selectedFilter ==
                                                      'Recently Added'
                                                  ? Colors.deepOrange
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Below 100';
                                      skip = 0;
                                      limit = 10;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    fetchbelowhundred(skip, limit);
                                  },
                                  child: Padding(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedFilter == 'Below 100'
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      height: 20,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Below 100',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color:
                                                  _selectedFilter == 'Below 100'
                                                      ? Colors.deepOrange
                                                      : Colors.white),
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Lowest Price';
                                      skip = 0;
                                      limit = 10;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    fetchLowestPrice(skip, limit);
                                  },
                                  child: Padding(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedFilter == 'Lowest Price'
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.deepOrange),
                                      ),
                                      height: 20,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Lowest Price',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color: _selectedFilter ==
                                                      'Lowest Price'
                                                  ? Colors.deepOrange
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'Highest Price';
                                      skip = 0;
                                      limit = 10;
                                      loading = true;
                                    });
                                    itemsgrid.clear();
                                    fetchHighestPrice(skip, limit);
                                  },
                                  child: Padding(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedFilter == 'Highest Price'
                                                ? Colors.white
                                                : Colors.deepOrange,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      height: 20,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Highest Price',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color: _selectedFilter ==
                                                      'Highest Price'
                                                  ? Colors.deepOrange
                                                  : Colors.white),
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    itemsgrid != null
                        ? Expanded(
                            child: StaggeredGridView.countBuilder(
                            controller: _scrollController,
                            crossAxisCount: 2,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            itemCount: itemsgrid.length + 1,
                            itemBuilder: (context, index) {
                              if (index == itemsgrid.length) {
                                return _buildProgressIndicator();
                              }
                              if (index == 0) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100,
                                  margin:
                                      const EdgeInsets.only(right: 8.0, top: 1),
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      itemBuilder: (ctx, i) {
                                        return Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedCat = i;
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CategoryScreen(
                                                              selectedcategory:
                                                                  _selectedCat)),
                                                );
                                              },
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 5.0),
                                                  width: 115.0,
                                                  constraints: BoxConstraints(
                                                      minHeight: 110),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11.0),
                                                  ),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        categories[i].icon,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        "${categories[i].title}",
                                                        style: GoogleFonts.lato(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                              if (index != 0 && index % 7 == 0) {
                                return Platform.isIOS == true
                                    ? Container(
                                        height: 330,
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.only(bottom: 20.0),
                                        child: NativeAdmob(
                                          adUnitID: _iosadUnitID,
                                          controller: _controller,
                                        ),
                                      )
                                    : Container(
                                        height: 330,
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.only(bottom: 20.0),
                                        child: NativeAdmob(
                                          adUnitID: _androidadUnitID,
                                          controller: _controller,
                                        ),
                                      );
                              }
                              return Padding(
                                  padding: EdgeInsets.all(7),
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Details(
                                                  itemid:
                                                      itemsgrid[index].itemid)),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: new Column(
                                          children: <Widget>[
                                            new Stack(
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        itemsgrid[index].image,
                                                    placeholder: (context,
                                                            url) =>
                                                        SpinKitChasingDots(
                                                            color: Colors
                                                                .deepOrange),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            new Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    itemsgrid[index].name,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  SizedBox(height: 3.0),
                                                  Container(
                                                    child: Text(
                                                      itemsgrid[index].category,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.0),
                                                  Container(
                                                    child: Text(
                                                      itemsgrid[index]
                                                              .price
                                                              .toString() +
                                                          ' ' +
                                                          currency,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )));
                            },
                            staggeredTileBuilder: (int index) {
                              if (index != 0 && index % 7 == 0) {
                                return StaggeredTile.count(2, 1);
                              } else if (index != 0 &&
                                  index == itemsgrid.length) {
                                return StaggeredTile.count(2, 0.5);
                              } else if (index == 0) {
                                return StaggeredTile.count(2, 0.6);
                              } else {
                                return StaggeredTile.fit(1);
                              }
                            },
                          ))
                        : Expanded(
                            child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                    'Looks like you\'re the first one here! \n Don\'t be shy add an Item!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(fontSize: 16)),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/little_theologians_4x.jpg',
                                fit: BoxFit.cover,
                              ))
                            ],
                          )),
                  ],
                )
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
