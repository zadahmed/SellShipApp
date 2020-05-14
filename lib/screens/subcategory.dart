import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class SubCategory extends StatefulWidget {
  final String subcategory;
  final String sub;
  final String category;

  SubCategory({Key key, this.subcategory, this.sub, this.category})
      : super(key: key);

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<Item> itemsgrid = [];

  var skip;
  var limit;
  String category;

  @override
  void dispose() {
    _scrollController.dispose();
    minpricecontroller.dispose();
    maxpricecontroller.dispose();
    super.dispose();
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  var sub;

  _getmoreData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/subcategories/' +
        sub +
        '/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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
    }

    var url = 'https://sellship.co/api/subcategories/' +
        sub +
        '/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  Future<List<Item>> fetchRecentlyAdded(int skip, int limit) async {
    var url = 'https://sellship.co/api/subcategories/recent/' +
        sub +
        '/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    var url = 'https://sellship.co/api/subcategories/belowhundred/' +
        sub +
        '/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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
    var url = 'https://sellship.co/api/subcategories/highestprice/' +
        sub +
        '/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  Future<List<Item>> fetchbrands(String brand) async {
    var categoryurl = 'https://sellship.co/api/filter/subcategory/brand/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
    var categoryurl = 'https://sellship.co/api/filter/subcategory/condition/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
    var categoryurl = 'https://sellship.co/api/filter/subcategory/price/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/subcategory/condition/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/subcategory/price/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
      limit = limit + 10;
      skip = skip + 10;
    });
    var categoryurl = 'https://sellship.co/api/filter/subcategory/brand/' +
        country +
        '/' +
        subcategory +
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
          price: jsonbody[i]['price'].toString(),
          category: jsonbody[i]['category'],
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
    var url = 'https://sellship.co/api/subcategories/lowestprice/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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
    var categoryurl = 'https://sellship.co/api/getbrands/' + category;
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
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/subcategories/highestprice/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/subcategories/lowestprice/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/subcategories/belowhundred/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  _getmoreRecentData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/subcategories/recent/' +
        subcategory +
        '/' +
        country +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'].toString(),
          category: jsondata['category'],
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

  String subcategory;

  @override
  void initState() {
    setState(() {
      skip = 0;
      limit = 10;
      subcategory = widget.subcategory;
      category = widget.category;
      sub = widget.sub;
      loading = true;
    });
    loadbrands();
    fetchItems(skip, limit);
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
          } else if (_selectedFilter == 'Brands') {
            getmorebrands(brand);
          } else if (_selectedFilter == 'Price') {
            getmorePrice(minprice, maxprice);
          } else if (_selectedFilter == 'Condition') {
            getmorecondition(condition);
          }
        }
      });
    super.initState();
  }

  bool loading;

  ScrollController _scrollController = ScrollController();
  final scaffoldState = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'Near me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepOrange,
          title: Text(
            subcategory.toUpperCase(),
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? SafeArea(
                  child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width / 2 - 10,
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
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'Sort',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black),
                                          ),
                                        ),
                                        InkWell(
                                          child: ListTile(
                                            title: Text(
                                              'New',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedFilter =
                                                  'Recently Added';
                                              skip = 0;
                                              limit = 10;
                                              loading = true;
                                            });
                                            itemsgrid.clear();
                                            Navigator.of(context).pop();

                                            fetchRecentlyAdded(skip, limit);
                                          },
                                        ),
                                        InkWell(
                                          child: ListTile(
                                            title: Text(
                                              'Near me',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedFilter = 'Near me';
                                              skip = 0;
                                              limit = 10;
                                              loading = true;
                                            });
                                            itemsgrid.clear();
                                            Navigator.of(context).pop();

                                            fetchItems(skip, limit);
                                          },
                                        ),
                                        InkWell(
                                          child: ListTile(
                                            title: Text(
                                              'Below 100',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedFilter = 'Below 100';
                                              skip = 0;
                                              limit = 10;
                                              loading = true;
                                            });
                                            itemsgrid.clear();
                                            Navigator.of(context).pop();

                                            fetchbelowhundred(skip, limit);
                                          },
                                        ),
                                        InkWell(
                                          child: ListTile(
                                            title: Text(
                                              'Price Low to High',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedFilter = 'Lowest Price';
                                              skip = 0;
                                              limit = 10;
                                              loading = true;
                                            });
                                            itemsgrid.clear();
                                            Navigator.of(context).pop();

                                            fetchLowestPrice(skip, limit);
                                          },
                                        ),
                                        InkWell(
                                          child: ListTile(
                                            title: Text(
                                              'Price High to Low',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedFilter = 'Highest Price';
                                              skip = 0;
                                              limit = 10;
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
                            },
                          ),
                          Container(
                              height: 40,
                              child: VerticalDivider(color: Colors.black)),
                          InkWell(
                            onTap: () {
                              scaffoldState.currentState
                                  .showBottomSheet((context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              'Filter',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          ExpansionTile(
                                            title: Text(
                                              'Brand',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            children: <Widget>[
                                              Container(
                                                  height: 500,
                                                  child: AlphabetListScrollView(
                                                    strList: brands,
                                                    indexedHeight: (i) {
                                                      return 40;
                                                    },
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            _selectedFilter =
                                                                'Brands';
                                                            brand =
                                                                brands[index];
                                                            skip = 0;
                                                            limit = 10;
                                                            loading = true;
                                                          });
                                                          itemsgrid.clear();
                                                          Navigator.of(context)
                                                              .pop();

                                                          fetchbrands(
                                                              brands[index]);
                                                        },
                                                        child: ListTile(
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
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30, right: 30),
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Center(
                                                        child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              value:
                                                                  _selectedCondition,
                                                              hint: Text(
                                                                  'Please choose the condition of your Item'), // No
                                                              icon: Icon(Icons
                                                                  .keyboard_arrow_down),
                                                              iconSize: 20,
                                                              elevation: 1,
                                                              isExpanded: true,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 16,
                                                              ),
                                                              onChanged: (String
                                                                  newValue) {
                                                                setState(() {
                                                                  _selectedCondition =
                                                                      newValue;
                                                                });

                                                                setState(() {
                                                                  _selectedFilter =
                                                                      'Condition';
                                                                  condition =
                                                                      _selectedCondition;
                                                                  skip = 0;
                                                                  limit = 10;
                                                                  loading =
                                                                      true;
                                                                });
                                                                itemsgrid
                                                                    .clear();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                fetchCondition(
                                                                    _selectedCondition);
                                                              },
                                                              items: conditions.map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                    value,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black),
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
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            children: <Widget>[
                                              Container(
                                                  height: 130,
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
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      Center(
                                                          child: ListTile(
                                                              title: Text(
                                                                'Minimum Price',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  Container(
                                                                      width:
                                                                          200,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            TextField(
                                                                          cursorColor:
                                                                              Color(0xFF979797),
                                                                          controller:
                                                                              minpricecontroller,
                                                                          keyboardType:
                                                                              TextInputType.numberWithOptions(),
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
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  Container(
                                                                      width:
                                                                          200,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            TextField(
                                                                          cursorColor:
                                                                              Color(0xFF979797),
                                                                          controller:
                                                                              maxpricecontroller,
                                                                          keyboardType:
                                                                              TextInputType.numberWithOptions(),
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
                                                  onTap: () async {
                                                    setState(() {
                                                      _selectedFilter = 'Price';
                                                      minprice =
                                                          minpricecontroller
                                                              .text;
                                                      maxprice =
                                                          maxpricecontroller
                                                              .text;
                                                      skip = 0;
                                                      limit = 10;
                                                      loading = true;
                                                    });
                                                    itemsgrid.clear();
                                                    Navigator.of(context).pop();

                                                    fetchPrice(
                                                        minpricecontroller.text,
                                                        maxpricecontroller
                                                            .text);
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    color: Colors.deepOrange,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Center(
                                                      child: Text(
                                                        'Filter',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ),
//                                          ExpansionTile(
//                                            title: Text(
//                                              'Delivery',
//                                              style: TextStyle(
//                                                  fontFamily: 'Montserrat',
//                                                  fontSize: 16,
//                                                  fontWeight: FontWeight.w400,
//                                                  color: Colors.black),
//                                            ),
//                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width / 2 - 10,
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
                    SizedBox(
                      height: 5,
                    ),
                    itemsgrid.isNotEmpty
                        ? Flexible(
                            child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GridView.builder(
                                  cacheExtent:
                                      double.parse(itemsgrid.length.toString()),
                                  shrinkWrap: true,
                                  controller: _scrollController,
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
                                              padding: EdgeInsets.all(10),
                                              margin:
                                                  EdgeInsets.only(bottom: 20.0),
                                              child: NativeAdmob(
                                                adUnitID: _iosadUnitID,
                                                controller: _controller,
                                              ),
                                            )
                                          : Container(
                                              height: 330,
                                              padding: EdgeInsets.all(10),
                                              margin:
                                                  EdgeInsets.only(bottom: 20.0),
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
                                                            itemid:
                                                                itemsgrid[index]
                                                                    .itemid)),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
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
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              itemsgrid[index]
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
                                                    ],
                                                  ),
                                                  new Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
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
                                                      )),
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
                  ],
                ))
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
