import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Filtered extends StatefulWidget {
  Map<String, dynamic> formdata;

  Filtered({
    Key key,
    this.formdata,
  }) : super(key: key);
  @override
  FilteredState createState() => FilteredState();
}

class FilteredState extends State<Filtered> {
  var skip;
  var limit;

  List<Item> itemsgrid = List<Item>();

  Future<List<Item>> fetchData() async {
    var addurl = 'https://api.sellship.co/api/filter/all/${skip}/${limit}';
    var response = await http.post(
      addurl,
      body: json.encode(widget.formdata),
    );
    print(response.body);
    print(response.statusCode);

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
      print(response.statusCode);
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
    fetchData();
    itemsgrid.clear();
//    getfavourites();
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

  String _FilterLoad;
  String _selectedFilter;

  static const _iosadUnitID = "ca-app-pub-9959700192389744/8038471619";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/4861643935";

  final _controller = NativeAdmobController();

  PersistentBottomSheetController _bottomsheetcontroller;
  final GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        floatingActionButton: InkWell(
          onTap: () {
            Navigator.of(context).pop();
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
              Feather.sliders,
              size: 18,
              color: Colors.deepOrange,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Filtered Results',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: EasyRefresh.custom(
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
          onLoad: () {
            setState(() {
              skip = skip + 40;
              limit = limit + 40;
            });
            return fetchData();
          },
          onRefresh: () {
            setState(() {
              itemsgrid.clear();
              skip = 0;
              limit = 40;
            });
            return fetchData();
          },
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  crossAxisCount: 2,
                  childAspectRatio: 0.75),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index != 0 && index % 8 == 0) {
                    return Platform.isIOS == true
                        ? Padding(
                            padding: EdgeInsets.all(7),
                            child: Container(
                              height: 200,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(bottom: 20.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
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
                                loading: Center(
                                    child: SpinKitDoubleBounce(
                                        color: Colors.deepOrange)),
                                type: NativeAdmobType.full,
                              ),
                            ))
                        : Padding(
                            padding: EdgeInsets.all(7),
                            child: Container(
                              height: 200,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(bottom: 20.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
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
                                loading: Center(
                                    child: SpinKitDoubleBounce(
                                        color: Colors.deepOrange)),
                                type: NativeAdmobType.full,
                              ),
                            ));
                  }

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
                                      fadeInDuration: Duration(microseconds: 5),
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
                                    'AED' + ' ' + itemsgrid[index].price,
                                  )
                                ],
                              )),
                              favourites != null
                                  ? favourites.contains(itemsgrid[index].itemid)
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
                                                    itemsgrid[index].likes - 1;
                                              });
                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
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
                                            backgroundColor: Colors.deepPurple,
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

                                              favourites
                                                  .add(itemsgrid[index].itemid);
                                              setState(() {
                                                favourites = favourites;
                                                itemsgrid[index].likes =
                                                    itemsgrid[index].likes + 1;
                                              });
                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
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
        ));
  }
}
