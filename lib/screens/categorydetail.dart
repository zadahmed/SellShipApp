import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class CategoryDetail extends StatefulWidget {
  final String category;
  final String subcategory;

  CategoryDetail({Key key, this.category, this.subcategory}) : super(key: key);

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
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

  _getmoreData() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/categories/' +
        category +
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
          price: jsondata['price'],
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
        currency = 'USD';
        country = country;
      });
    }

    var url = 'https://sellship.co/api/categories/' +
        category +
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
          price: jsondata['price'],
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
    var url = 'https://sellship.co/api/categories/recent/' +
        category +
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
          price: jsondata['price'],
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
    var url = 'https://sellship.co/api/categories/belowhundred/' +
        category +
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
          price: jsondata['price'],
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
    var url = 'https://sellship.co/api/categories/highestprice/' +
        category +
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
          price: jsondata['price'],
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

  Future<List<Item>> fetchLowestPrice(int skip, int limit) async {
    var url = 'https://sellship.co/api/categories/lowestprice/' +
        category +
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
          price: jsondata['price'],
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

  _getmorehighestprice() async {
    setState(() {
      limit = limit + 10;
      skip = skip + 10;
    });

    var url = 'https://sellship.co/api/categories/highestprice/' +
        category +
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

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
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

    var url = 'https://sellship.co/api/categories/lowestprice/' +
        category +
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

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
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

    var url = 'https://sellship.co/api/categories/belowhundred/' +
        category +
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

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
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

    var url = 'https://sellship.co/api/categories/recent/' +
        category +
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

      for (var jsondata in jsonbody) {
        Item item = Item(
          itemid: jsondata['_id']['\$oid'],
          name: jsondata['name'],
          image: jsondata['image'],
          price: jsondata['price'],
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

  String category;
  String subcategory;

  @override
  void initState() {
    setState(() {
      skip = 0;
      limit = 10;
      category = widget.category;
      subcategory = widget.subcategory;
      loading = true;
    });

    fetchItems(skip, limit);
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
    super.initState();
  }

  bool loading;

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(child: SpinKitChasingDots(color: Colors.deepOrange)),
    );
  }

  ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'Near me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepOrange,
          title: Text(
            subcategory,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
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
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                'Filter',
                                style: GoogleFonts.lato(
                                    fontSize: 11, color: Colors.blueGrey),
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
                      height: 5,
                    ),
                    itemsgrid.isNotEmpty
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
                                                  const EdgeInsets.all(4.0),
                                              child: new Column(
                                                children: <Widget>[
                                                  Text(
                                                    itemsgrid[index].name,
                                                    overflow: TextOverflow.fade,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 3.0),
                                                  Container(
                                                    child: Text(
                                                      itemsgrid[index].category,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
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
                                                        fontSize: 16,
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
                                return StaggeredTile.count(2, 1);
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
                                  'Looks like you\'re the first here! \n Don\'t be shy add an Item!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
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
