import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/user.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
//import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:numeral/numeral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:typed_data';
import 'package:SellShip/screens/comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:SellShip/models/Items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class Search extends StatefulWidget {
  final String text;
  Search({Key key, this.text}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class Category {
  final String categoryname;
  final List subcategories;
  final String categoryimage;

  Category({
    this.categoryname,
    this.categoryimage,
    this.subcategories,
  });
}

class _SearchState extends State<Search>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<Item> itemsgrid = [];

  var skip;
  var limit;

  @override
  bool get wantKeepAlive => true;

  var text;

  ScrollController _scrollController = ScrollController();

  LatLng position;
  String country;

  final storage = new FlutterSecureStorage();
  bool loading;

  bool gridtoggle;

  final scaffoldState = GlobalKey<ScaffoldState>();

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

  var currency;
  String brand;
  String minprice;
  String maxprice;
  String condition;
  String category;
  String subcategory;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );
    getCategories();
    readstorage();
    _getRecentSearches();
    setState(() {
      skip = 0;
      limit = 20;
    });
  }

  List<User> userList = new List<User>();

  List<Category> categoryList = new List<Category>();

  getCategories() async {
    var url = 'https://api.sellship.co/api/categories/view';

    final response = await http.get(url);
    var jsonbody = json.decode(response.body);

    for (int i = 0; i < jsonbody.length; i++) {
      if (jsonbody[i]['name'] != 'Other') {
        Category cat = new Category(
            categoryname: jsonbody[i]['name'],
            categoryimage: jsonbody[i]['categoryimage'],
            subcategories: jsonbody[i]['subcategories']);

        categoryList.add(cat);
      }
    }

    setState(() {
      categoryList = categoryList;
    });
  }

  _getmoreData(textsearch) async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        capitalize(textsearch).trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

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
        category: jsondata['category'],
        sold: jsondata['sold'] == null ? false : jsondata['sold'],
      );
      itemsgrid.add(item);
    }

    setState(() {
      itemsgrid = itemsgrid.toSet().toList();
      loading = false;
    });
  }

  onSearchUsers(textsearch) async {
    userList.clear();
    var url = 'https://api.sellship.co/api/searchusers/' +
        capitalize(textsearch).trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);

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

      print(jsondata);

      User user = new User(
          firstName: capitalize(jsondata['first_name']) + ' ' + lastname,
          username: username,
          userid: jsondata['_id']['\$oid'],
          profilepicture: jsondata['profilepicture']);
      userList.add(user);
    }

    setState(() {
      userList = userList.toSet().toList();
      loading = false;
    });
  }

  Future<List<String>> _getRecentSearchesLike(String query) async {
    final pref = await SharedPreferences.getInstance();
    final allSearches = pref.getStringList("recentSearches");

    return allSearches.where((search) => search.startsWith(query)).toList();
  }

  Future<List<String>> _getRecentSearches() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getStringList('recentSearches').isNotEmpty) {
      final allSearches = pref.getStringList("recentSearches").toSet().toList();
      setState(() {
        recentsearches = allSearches;
      });
      return allSearches;
    }
  }

  List<String> recentsearches = List<String>();

  Future<void> _saveToRecentSearches(String searchText) async {
    if (searchText == null) return; //Should not be null
    final pref = await SharedPreferences.getInstance();

    //Use `Set` to avoid duplication of recentSearches
    Set<String> allSearches =
        pref.getStringList("recentSearches")?.toSet() ?? {};

    //Place it at first in the set
    allSearches = {searchText, ...allSearches};
    pref.setStringList("recentSearches", allSearches.toList());
  }

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var countr = await storage.read(key: 'country');
    if (countr.trim().toLowerCase() == 'united arab emirates') {
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
      position = LatLng(double.parse(latitude), double.parse(longitude));
    });
  }

  TextEditingController searchcontroller = new TextEditingController();

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  onSearch(textsearch) async {
    itemsgrid.clear();
    var url = 'https://api.sellship.co/api/searchitems/' +
        country +
        '/' +
        capitalize(textsearch).trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
    print(response.body);

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
        category: jsondata['category'],
        sold: jsondata['sold'] == null ? false : jsondata['sold'],
      );
      itemsgrid.add(item);
    }

    setState(() {
      itemsgrid = itemsgrid;
      loading = false;
    });
  }

  Widget searchresults(BuildContext context) {
    return EasyRefresh.custom(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search Products',
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              crossAxisCount: 2,
              childAspectRatio: 0.9),
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
                            border: Border.all(width: 0.2, color: Colors.grey),
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
                            border: Border.all(width: 0.2, color: Colors.grey),
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
                padding: EdgeInsets.all(7),
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
                      border: Border.all(width: 0.2, color: Colors.grey),
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
                              height: 215,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 200,
                                  width: 300,
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
                                      width: MediaQuery.of(context).size.width,
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
                                : favourites != null
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
                                            child: Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor:
                                                          Colors.deepPurple,
                                                      child: Icon(
                                                        FontAwesome.heart,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ))))
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
                                            child: Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        Feather.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    ))))
                                    : Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Feather.heart,
                                                color: Colors.blueGrey,
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
            childCount: itemsgrid.length,
          ),
        )
      ],
      onLoad: () async {
//
        _getmoreData(searchcontroller.text);
      },
    );
  }

  TabController _tabController;
  bool searched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            margin: EdgeInsets.only(top: 10.0, right: 10, bottom: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: const Color(0x80e5e9f2),
              ),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Icon(
                      Feather.search,
                      size: 24,
                      color: Color.fromRGBO(115, 115, 125, 1),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (text) {
                        print(_tabController.index);
                        if (_tabController.index == 0 ||
                            _tabController.index == 1) {
                          print(text);
                          setState(() {
                            searched = false;
                            skip = 0;
                            limit = 20;
                            itemsgrid.clear();
                            loading = true;
                          });
                          onSearch(text);
                          _getRecentSearches();
                        } else if (_tabController.index == 2) {
                          setState(() {
                            searched = false;
                            skip = 0;
                            limit = 20;
                            userList.clear();
                            loading = true;
                          });
                          onSearchUsers(text);
                          _getRecentSearches();
                        }
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
          ),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(115, 115, 125, 1),
          ),
        ),
        body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        snap: true,
                        floating: true,
                        title: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            child: TabBar(
                              controller: _tabController,
                              labelStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Helvetica',
                              ),
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
                                  text: 'Top',
                                ),
                                new Tab(
                                  text: 'Products',
                                ),
                                new Tab(
                                  text: 'Users',
                                ),
                                new Tab(
                                  text: 'Hashtags',
                                ),
                              ],
                            ),
                          ),
                        ))
                  ];
                },
                body: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(229, 233, 242, 1).withOpacity(0.5),
//                      color: Colors.white,
                    ),
                    child: Container(
                        padding: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child:
                            TabBarView(controller: _tabController, children: [
                          searchcontroller.text.isNotEmpty
                              ? loading == false
                                  ? searched == false
                                      ? GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          },
                                          child: CustomScrollView(
                                              slivers: <Widget>[
                                                SliverToBoxAdapter(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15, top: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Search Results',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                itemsgrid.isNotEmpty
                                                    ? SliverList(
                                                        delegate:
                                                            new SliverChildBuilderDelegate(
                                                          (context, index) =>
                                                              ListTile(
                                                                  onTap:
                                                                      () async {
                                                                    await _saveToRecentSearches(
                                                                        itemsgrid[index]
                                                                            .name);
                                                                    setState(
                                                                        () {
                                                                      loading =
                                                                          true;
                                                                      onSearch(itemsgrid[
                                                                              index]
                                                                          .name);
                                                                      searched =
                                                                          true;
                                                                    });
                                                                  },
                                                                  leading: Icon(
                                                                      Feather
                                                                          .search),
                                                                  title:
                                                                      SubstringHighlight(
                                                                    text: itemsgrid[
                                                                            index]
                                                                        .name,
                                                                    term: searchcontroller
                                                                        .text,
                                                                    textStyle: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                    textStyleHighlight: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                  )

//
                                                                  ),
                                                          childCount: itemsgrid
                                                                      .length <=
                                                                  15
                                                              ? itemsgrid.length
                                                              : 15,
                                                        ),
                                                      )
                                                    : SliverToBoxAdapter(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15,
                                                                    top: 10),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                    height:
                                                                        MediaQuery.of(context).size.height /
                                                                                2 -
                                                                            200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        50,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/184.png',
                                                                      fit: BoxFit
                                                                          .fitHeight,
                                                                    )),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                searchcontroller
                                                                            .text
                                                                            .length >
                                                                        3
                                                                    ? Text(
                                                                        'Oops. Can\'t find any results for that search.',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                                    : Text(
                                                                        'Woah. That\'s way few letters to search for, Please ellaborate on what you are searching for, to get better results',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                              ],
                                                            )),
                                                      ),
                                              ]))
                                      : searchresults(context)
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    )
                              : CustomScrollView(
                                  slivers: [
                                    recentsearches.isNotEmpty
                                        ? SliverToBoxAdapter(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 10,
                                                    bottom: 10,
                                                    right: 36),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Recent Searches',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final pref =
                                                            await SharedPreferences
                                                                .getInstance();

                                                        pref.remove(
                                                            'recentSearches');
                                                        setState(() {
                                                          recentsearches = [];
                                                        });
                                                      },
                                                      child: Text(
                                                        'Clear All',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          )
                                        : SliverToBoxAdapter(),
                                    recentsearches.isNotEmpty
                                        ? SliverList(
                                            delegate:
                                                new SliverChildBuilderDelegate(
                                              (context, index) => ListTile(
                                                onTap: () async {
                                                  await _saveToRecentSearches(
                                                      recentsearches[index]);
                                                  setState(() {
                                                    loading = true;
                                                    onSearch(
                                                        recentsearches[index]);
                                                    searched = true;
                                                  });
                                                },
                                                leading: Icon(
                                                  Feather.clock,
                                                  size: 18,
                                                ),
                                                trailing: InkWell(
                                                  onTap: () async {
                                                    final pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    var allSearches = pref
                                                        .getStringList(
                                                            "recentSearches")
                                                        .toList();

                                                    allSearches.remove(
                                                        recentsearches[index]);

                                                    pref.setStringList(
                                                        "recentSearches",
                                                        allSearches.toList());

                                                    setState(() {
                                                      recentsearches =
                                                          allSearches.toList();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.cancel_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                                title: Text(
                                                  recentsearches[index],
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              childCount:
                                                  recentsearches.length <= 8
                                                      ? recentsearches.length
                                                      : 8,
                                            ),
                                          )
                                        : SliverToBoxAdapter(),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 15, top: 15, bottom: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Categories',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SliverStaggeredGrid.countBuilder(
                                      crossAxisCount: 3,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CategoryDetail(
                                                        categoryimage:
                                                            categoryList[index]
                                                                .categoryimage,
                                                        category:
                                                            categoryList[index]
                                                                .categoryname,
                                                        subcategory:
                                                            categoryList[index]
                                                                .subcategories,
                                                      )),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Container(
                                                height: 160,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 180,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: categoryList[index]
                                                                  .categoryimage !=
                                                              null
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Hero(
                                                                  tag: categoryList[
                                                                          index]
                                                                      .categoryname,
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    height: 200,
                                                                    width: 300,
                                                                    imageUrl: categoryList[
                                                                            index]
                                                                        .categoryimage,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )))
                                                          : Container(),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        height: 50,
                                                        width: 100,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Center(
                                                          child: Text(
                                                            categoryList[index]
                                                                .categoryname,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        );
                                      },
                                      itemCount: categoryList.length,
                                      staggeredTileBuilder: (int index) =>
                                          new StaggeredTile.fit(1),
                                      mainAxisSpacing: 4.0,
                                      crossAxisSpacing: 4.0,
                                    ),
                                    SliverToBoxAdapter(
                                        child: SizedBox(
                                      height: 100,
                                    )),
                                  ],
                                ),
                          searchcontroller.text.isNotEmpty
                              ? loading == false
                                  ? searched == false
                                      ? GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          },
                                          child: CustomScrollView(
                                              slivers: <Widget>[
                                                SliverToBoxAdapter(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15, top: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Search Results',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                itemsgrid.isNotEmpty
                                                    ? SliverList(
                                                        delegate:
                                                            new SliverChildBuilderDelegate(
                                                          (context, index) =>
                                                              ListTile(
                                                                  onTap:
                                                                      () async {
                                                                    await _saveToRecentSearches(
                                                                        itemsgrid[index]
                                                                            .name);
                                                                    setState(
                                                                        () {
                                                                      loading =
                                                                          true;
                                                                      onSearch(itemsgrid[
                                                                              index]
                                                                          .name);
                                                                      searched =
                                                                          true;
                                                                    });
                                                                  },
                                                                  leading: Icon(
                                                                      Feather
                                                                          .search),
                                                                  title:
                                                                      SubstringHighlight(
                                                                    text: itemsgrid[
                                                                            index]
                                                                        .name,
                                                                    term: searchcontroller
                                                                        .text,
                                                                    textStyle: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                    textStyleHighlight: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                  )

//
                                                                  ),
                                                          childCount: itemsgrid
                                                                      .length <=
                                                                  15
                                                              ? itemsgrid.length
                                                              : 15,
                                                        ),
                                                      )
                                                    : SliverToBoxAdapter(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15,
                                                                    top: 10),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                    height:
                                                                        MediaQuery.of(context).size.height /
                                                                                2 -
                                                                            200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        50,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/184.png',
                                                                      fit: BoxFit
                                                                          .fitHeight,
                                                                    )),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                searchcontroller
                                                                            .text
                                                                            .length >
                                                                        3
                                                                    ? Text(
                                                                        'Oops. Can\'t find any results for that search.',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                                    : Text(
                                                                        'Woah. That\'s way few letters to search for, Please ellaborate on what you are searching for, to get better results',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                              ],
                                                            )),
                                                      ),
                                              ]))
                                      : searchresults(context)
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    )
                              : CustomScrollView(
                                  slivers: [
                                    recentsearches.isNotEmpty
                                        ? SliverToBoxAdapter(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 10,
                                                    bottom: 10,
                                                    right: 36),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Recent Searches',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final pref =
                                                            await SharedPreferences
                                                                .getInstance();

                                                        pref.remove(
                                                            'recentSearches');
                                                        setState(() {
                                                          recentsearches = [];
                                                        });
                                                      },
                                                      child: Text(
                                                        'Clear All',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          )
                                        : SliverToBoxAdapter(),
                                    recentsearches.isNotEmpty
                                        ? SliverList(
                                            delegate:
                                                new SliverChildBuilderDelegate(
                                              (context, index) => ListTile(
                                                onTap: () async {
                                                  await _saveToRecentSearches(
                                                      recentsearches[index]);
                                                  setState(() {
                                                    loading = true;
                                                    onSearch(
                                                        recentsearches[index]);
                                                    searched = true;
                                                  });
                                                },
                                                leading: Icon(
                                                  Feather.clock,
                                                  size: 18,
                                                ),
                                                trailing: InkWell(
                                                  onTap: () async {
                                                    final pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    var allSearches = pref
                                                        .getStringList(
                                                            "recentSearches")
                                                        .toList();

                                                    allSearches.remove(
                                                        recentsearches[index]);

                                                    pref.setStringList(
                                                        "recentSearches",
                                                        allSearches.toList());

                                                    setState(() {
                                                      recentsearches =
                                                          allSearches.toList();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.cancel_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                                title: Text(
                                                  recentsearches[index],
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              childCount:
                                                  recentsearches.length <= 8
                                                      ? recentsearches.length
                                                      : 8,
                                            ),
                                          )
                                        : SliverToBoxAdapter(),
                                  ],
                                ),
                          searchcontroller.text.isNotEmpty
                              ? loading == false
                                  ? searched == false
                                      ? GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          },
                                          child: CustomScrollView(
                                              slivers: <Widget>[
                                                SliverToBoxAdapter(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15,
                                                        top: 10,
                                                        bottom: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Search Users',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                userList.isNotEmpty
                                                    ? SliverList(
                                                        delegate:
                                                            new SliverChildBuilderDelegate(
                                                          (context, index) =>
                                                              ListTile(
                                                            onTap: () async {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => UserItems(
                                                                        userid: userList[index]
                                                                            .userid,
                                                                        username:
                                                                            userList[index].username)),
                                                              );
                                                            },
                                                            leading: userList[index]
                                                                            .profilepicture !=
                                                                        null &&
                                                                    userList[index]
                                                                        .profilepicture
                                                                        .isNotEmpty
                                                                ? Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(25),
                                                                        child: CachedNetworkImage(
                                                                          height:
                                                                              200,
                                                                          width:
                                                                              300,
                                                                          imageUrl:
                                                                              userList[index].profilepicture,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )),
                                                                  )
                                                                : CircleAvatar(
                                                                    radius: 25,
                                                                    backgroundColor: Colors
                                                                        .deepOrangeAccent
                                                                        .withOpacity(
                                                                            0.3),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/personplaceholder.png',
                                                                        fit: BoxFit
                                                                            .fitWidth,
                                                                      ),
                                                                    )),
                                                            title:
                                                                SubstringHighlight(
                                                              text: userList[
                                                                      index]
                                                                  .firstName,
                                                              term:
                                                                  searchcontroller
                                                                      .text,
                                                              textStyle: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black),
                                                              textStyleHighlight: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            subtitle:
                                                                SubstringHighlight(
                                                              text: '@' +
                                                                  userList[
                                                                          index]
                                                                      .username,
                                                              term:
                                                                  searchcontroller
                                                                      .text,
                                                              textStyle: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .grey),
                                                              textStyleHighlight: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
//
                                                          ),
                                                          childCount: userList
                                                                      .length <=
                                                                  15
                                                              ? userList.length
                                                              : 15,
                                                        ),
                                                      )
                                                    : SliverToBoxAdapter(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15,
                                                                    top: 10),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                    height:
                                                                        MediaQuery.of(context).size.height /
                                                                                2 -
                                                                            200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        50,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/184.png',
                                                                      fit: BoxFit
                                                                          .fitHeight,
                                                                    )),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                searchcontroller
                                                                            .text
                                                                            .length >
                                                                        3
                                                                    ? Text(
                                                                        'Oops. Can\'t find any results for that search.',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                                    : Text(
                                                                        'Woah. That\'s way few letters to search for, Please ellaborate on what you are searching for, to get better results',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                              ],
                                                            )),
                                                      ),
                                              ]))
                                      : searchresults(context)
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    )
                              : CustomScrollView(
                                  slivers: [
                                    recentsearches.isNotEmpty
                                        ? SliverToBoxAdapter(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 10,
                                                    bottom: 10,
                                                    right: 36),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Recent Searches',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final pref =
                                                            await SharedPreferences
                                                                .getInstance();

                                                        pref.remove(
                                                            'recentSearches');
                                                        setState(() {
                                                          recentsearches = [];
                                                        });
                                                      },
                                                      child: Text(
                                                        'Clear All',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          )
                                        : SliverToBoxAdapter(),
                                    recentsearches.isNotEmpty
                                        ? SliverList(
                                            delegate:
                                                new SliverChildBuilderDelegate(
                                              (context, index) => ListTile(
                                                onTap: () async {
                                                  await _saveToRecentSearches(
                                                      recentsearches[index]);
                                                  setState(() {
                                                    loading = true;
                                                    onSearch(
                                                        recentsearches[index]);
                                                    searched = true;
                                                  });
                                                },
                                                leading: Icon(
                                                  Feather.clock,
                                                  size: 18,
                                                ),
                                                trailing: InkWell(
                                                  onTap: () async {
                                                    final pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    var allSearches = pref
                                                        .getStringList(
                                                            "recentSearches")
                                                        .toList();

                                                    allSearches.remove(
                                                        recentsearches[index]);

                                                    pref.setStringList(
                                                        "recentSearches",
                                                        allSearches.toList());

                                                    setState(() {
                                                      recentsearches =
                                                          allSearches.toList();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.cancel_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                                title: Text(
                                                  recentsearches[index],
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              childCount:
                                                  recentsearches.length <= 8
                                                      ? recentsearches.length
                                                      : 8,
                                            ),
                                          )
                                        : SliverToBoxAdapter(),
                                  ],
                                ),
                          searchcontroller.text.isNotEmpty
                              ? loading == false
                                  ? searched == false
                                      ? GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          },
                                          child: CustomScrollView(
                                              slivers: <Widget>[
                                                SliverToBoxAdapter(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15, top: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Search Results',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                itemsgrid.isNotEmpty
                                                    ? SliverList(
                                                        delegate:
                                                            new SliverChildBuilderDelegate(
                                                          (context, index) =>
                                                              ListTile(
                                                                  onTap:
                                                                      () async {
                                                                    await _saveToRecentSearches(
                                                                        itemsgrid[index]
                                                                            .name);
                                                                    setState(
                                                                        () {
                                                                      loading =
                                                                          true;
                                                                      onSearch(itemsgrid[
                                                                              index]
                                                                          .name);
                                                                      searched =
                                                                          true;
                                                                    });
                                                                  },
                                                                  leading: Icon(
                                                                      Feather
                                                                          .search),
                                                                  title:
                                                                      SubstringHighlight(
                                                                    text: itemsgrid[
                                                                            index]
                                                                        .name,
                                                                    term: searchcontroller
                                                                        .text,
                                                                    textStyle: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                    textStyleHighlight: TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black),
                                                                  )

//
                                                                  ),
                                                          childCount: itemsgrid
                                                                      .length <=
                                                                  15
                                                              ? itemsgrid.length
                                                              : 15,
                                                        ),
                                                      )
                                                    : SliverToBoxAdapter(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15,
                                                                    top: 10),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                    height:
                                                                        MediaQuery.of(context).size.height /
                                                                                2 -
                                                                            200,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        50,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/184.png',
                                                                      fit: BoxFit
                                                                          .fitHeight,
                                                                    )),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                searchcontroller
                                                                            .text
                                                                            .length >
                                                                        3
                                                                    ? Text(
                                                                        'Oops. Can\'t find any results for that search.',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                                    : Text(
                                                                        'Woah. That\'s way few letters to search for, Please ellaborate on what you are searching for, to get better results',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.grey.shade500),
                                                                      )
                                                              ],
                                                            )),
                                                      ),
                                              ]))
                                      : searchresults(context)
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                30,
                                                            height: 150.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    )
                              : CustomScrollView(
                                  slivers: [
                                    recentsearches.isNotEmpty
                                        ? SliverToBoxAdapter(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 10,
                                                    bottom: 10,
                                                    right: 36),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Recent Searches',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final pref =
                                                            await SharedPreferences
                                                                .getInstance();

                                                        pref.remove(
                                                            'recentSearches');
                                                        setState(() {
                                                          recentsearches = [];
                                                        });
                                                      },
                                                      child: Text(
                                                        'Clear All',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          )
                                        : SliverToBoxAdapter(),
                                    recentsearches.isNotEmpty
                                        ? SliverList(
                                            delegate:
                                                new SliverChildBuilderDelegate(
                                              (context, index) => ListTile(
                                                onTap: () async {
                                                  await _saveToRecentSearches(
                                                      recentsearches[index]);
                                                  setState(() {
                                                    loading = true;
                                                    onSearch(
                                                        recentsearches[index]);
                                                    searched = true;
                                                  });
                                                },
                                                leading: Icon(
                                                  Feather.clock,
                                                  size: 18,
                                                ),
                                                trailing: InkWell(
                                                  onTap: () async {
                                                    final pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    var allSearches = pref
                                                        .getStringList(
                                                            "recentSearches")
                                                        .toList();

                                                    allSearches.remove(
                                                        recentsearches[index]);

                                                    pref.setStringList(
                                                        "recentSearches",
                                                        allSearches.toList());

                                                    setState(() {
                                                      recentsearches =
                                                          allSearches.toList();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.cancel_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                                title: Text(
                                                  recentsearches[index],
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              childCount:
                                                  recentsearches.length <= 8
                                                      ? recentsearches.length
                                                      : 8,
                                            ),
                                          )
                                        : SliverToBoxAdapter(),
                                  ],
                                ),
                        ]))))));
  }

  String _FilterLoad = "Recently Added";
  String _selectedFilter = "Recently Added";

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  String getAppId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744~6783422976';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744~8862791402';
    }
    return null;
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/8038471619";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/4861643935";

  final _controller = NativeAdmobController();

  @override
  void dispose() {
    _scrollController.dispose();
    minpricecontroller.dispose();
    maxpricecontroller.dispose();
    super.dispose();
  }

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

    var url = 'https://api.sellship.co/api/searchnearby/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    });
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();
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

  Future<List<Item>> fetchbelowhundred(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/searchbelowhundred/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

  Future<List<Item>> fetchHighestPrice(int skip, int limit) async {
    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

  Future<List<Item>> fetchbrands(String brand) async {
    var url = 'https://api.sellship.co/api/searchbrand/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();
    print(url);
    final categoryresponse = await http.get(url);
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
    var url = 'https://api.sellship.co/api/searchcondition/' +
        text.toString().toLowerCase().trim() +
        '/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
    var url = 'https://api.sellship.co/api/searchprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
    var url = 'https://api.sellship.co/api/searchcondition/' +
        text.toString().toLowerCase().trim() +
        '/' +
        country +
        '/' +
        condition +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
    var url = 'https://api.sellship.co/api/searchprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        minprice +
        '/' +
        maxprice +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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

    var url = 'https://api.sellship.co/api/searchbrand/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        brand +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final categoryresponse = await http.get(url);
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
    var url = 'https://api.sellship.co/api/searchlowestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

  _getmorelowestprice() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

    var url = 'https://api.sellship.co/api/searchlowestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

    var url = 'https://api.sellship.co/api/searchhighestprice/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.get(url);
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

  _getmorenearme() async {
    setState(() {
      limit = limit + 20;
      skip = skip + 20;
    });

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

    var url = 'https://api.sellship.co/api/searchnearby/' +
        country +
        '/' +
        text.toString().toLowerCase().trim() +
        '/' +
        skip.toString() +
        '/' +
        limit.toString();

    final response = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    });
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      itemsgrid.clear();
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
