import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/filterpage.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SellShip/screens/details.dart';

import 'package:location/location.dart' as Location;
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Below100 extends StatefulWidget {
  @override
  Below100State createState() => Below100State();
}

class Below100State extends State<Below100> {
  String country;
  String currency;

  final scaffoldState = GlobalKey<ScaffoldState>();

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
    fetchbelowhundred(skip, limit);
  }

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
      await storage.write(key: 'city', value: cit);
      await storage.write(key: 'locationcountry', value: countr);
      setState(() {
        city = cit;
        locationcountry = countr;
        print(city);
      });
    } on Exception catch (e) {
      print(e);
      Location.Location().requestPermission();
      setState(() {
        loading = false;
      });
    }
  }

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

  String locationcountry;
  String city;
  LatLng position;

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

      final response = await http.get(Uri.parse(url));
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
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

  @override
  void initState() {
    super.initState();
    setState(() {
      skip = 0;
      limit = 40;
      loading = true;
    });
    itemsgrid.clear();
    getfavourites();
    readstorage();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  var showfloatingbutton = false;

  ScrollController _scrollController = ScrollController();

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
  final storage = new FlutterSecureStorage();

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

  var loading;

  String _FilterLoad = "Recently Added";
  String _selectedFilter = "Recently Added";

  static const _iosadUnitID = "ca-app-pub-9959700192389744/8038471619";

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
      floatingActionButton: InkWell(
        enableFeedback: true,
        onTap: () {
          Navigator.of(context).push(_createRoute());
        },
        child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 2.0), //(x,y)
                blurRadius: 4.0,
              ),
            ], color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.sliders,
                  size: 18,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Filter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Helvetica',
                    color: Colors.black,
                  ),
                ),
              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(28, 45, 65, 1),
          ),
        ),
        title: Text(
          'Deals under 100',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: loading == false
          ? EasyRefresh.custom(
              onRefresh: () {
                return fetchbelowhundred(0, 40);
              },
              onLoad: () {
                setState(() {
                  skip = skip + 40;
                  limit = limit + 40;
                });
                return fetchbelowhundred(skip, limit);
              },
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
              slivers: [
                SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 2,
                  itemCount: itemsgrid.length,
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
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
                                  height: 180,
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
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    itemsgrid[index].saleprice != null
                                        ? Text.rich(
                                            TextSpan(
                                              children: <TextSpan>[
                                                new TextSpan(
                                                  text: 'AED ' +
                                                      itemsgrid[index]
                                                          .saleprice,
                                                  style: new TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                new TextSpan(
                                                  text: '\nAED ' +
                                                      itemsgrid[index]
                                                          .price
                                                          .toString(),
                                                  style: new TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                                new TextSpan(
                                                  text: ' -' +
                                                      (((double.parse(itemsgrid[
                                                                              index]
                                                                          .price
                                                                          .toString()) -
                                                                      double.parse(itemsgrid[
                                                                              index]
                                                                          .saleprice
                                                                          .toString())) /
                                                                  double.parse(
                                                                      itemsgrid[
                                                                              index]
                                                                          .price
                                                                          .toString())) *
                                                              100)
                                                          .toStringAsFixed(0) +
                                                      '%',
                                                  style: new TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
                                            currency +
                                                ' ' +
                                                itemsgrid[index].price,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
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
                                                    .post(Uri.parse(url),
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
                                              radius: 16,
                                              backgroundColor:
                                                  Colors.deepOrange,
                                              child: Icon(
                                                FontAwesomeIcons.heart,
                                                color: Colors.white,
                                                size: 15,
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
                                                    .post(Uri.parse(url),
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
                                                radius: 16,
                                                backgroundColor:
                                                    Colors.blueGrey.shade50,
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.white,
                                                  child: Icon(
                                                    FeatherIcons.heart,
                                                    color: Colors.blueGrey,
                                                    size: 16,
                                                  ),
                                                )))
                                    : CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            Colors.blueGrey.shade50,
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            FeatherIcons.heart,
                                            color: Colors.blueGrey,
                                            size: 16,
                                          ),
                                        ))
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
                )
              ],
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
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            30,
                                    height: 150.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
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
            ),
    );
  }

  Widget loadingwidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                            width: MediaQuery.of(context).size.width / 2 - 30,
                            height: 150.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 30,
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

  List<Item> itemsgrid = [];

  var skip;
  var limit;

  String brand;
  String minprice;
  String maxprice;
  String condition;

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
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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

    final response = await http.get(Uri.parse(url));

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
        saleprice: jsonbody[i].containsKey('saleprice')
            ? jsonbody[i]['saleprice'].toString()
            : null,
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

    final response = await http.get(Uri.parse(url));

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
        saleprice: jsonbody[i].containsKey('saleprice')
            ? jsonbody[i]['saleprice'].toString()
            : null,
        category: jsonbody[i]['category'],
        sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
      );
      itemsgrid.add(item);
    }
    setState(() {
      itemsgrid = itemsgrid;
    });
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

    final response = await http.get(Uri.parse(url));
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
          saleprice: jsonbody[i].containsKey('saleprice')
              ? jsonbody[i]['saleprice'].toString()
              : null,
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
}
