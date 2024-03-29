import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/expandabletext.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/followerspage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

class StorePublic extends StatefulWidget {
  final String storeid;
  final String storename;

  StorePublic({
    Key key,
    this.storeid,
    this.storename,
  }) : super(key: key);

  @override
  _StorePublicState createState() => new _StorePublicState();
}

class _StorePublicState extends State<StorePublic> {
  @override
  void initState() {
    super.initState();
    getuser();
    getItemData();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:' + widget.storename,
      screenClassOverride: 'App' + widget.storename,
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool loading;

  var profilepicture;
  var username;

  var itemssold;
  var following;
  var followers;
  var storename;
  var reviewrating;

  var follow = false;

  Color followcolor = Colors.white;
  final storage = new FlutterSecureStorage();

  getItemData() async {
    var itemurl = 'https://api.sellship.co/store/products/' + widget.storeid;

    final itemresponse = await http.get(Uri.parse(itemurl));
    if (itemresponse.statusCode == 200) {
      var itemrespons = json.decode(itemresponse.body);

      List<Item> ites = List<Item>();
      if (itemrespons != null) {
        for (var i = 0; i < itemrespons.length; i++) {
          Item ite = Item(
              approved: itemrespons[i]['approved'],
              itemid: itemrespons[i]['_id']['\$oid'],
              name: itemrespons[i]['name'],
              image: itemrespons[i]['image'],
              price: itemrespons[i]['price'].toString(),
              saleprice: itemrespons[i].containsKey('saleprice')
                  ? itemrespons[i]['saleprice'].toString()
                  : null,
              views:
                  itemrespons[i]['views'] == null ? 0 : itemrespons[i]['views'],
              likes:
                  itemrespons[i]['likes'] == null ? 0 : itemrespons[i]['likes'],
              comments: itemrespons[i]['comments'] == null
                  ? 0
                  : itemrespons[i]['comments'].length,
              sold: itemrespons[i]['sold'] == null
                  ? false
                  : itemrespons[i]['sold'],
              category: itemrespons[i]['category']);
          if (ite.approved == true) {
            ites.add(ite);
          }
        }
        if (mounted) {
          setState(() {
            item = new List.from(ites.reversed);

            profileloading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            item = [];
            profileloading = false;
          });
        }
      }
    } else {
      print(itemresponse.statusCode);
    }
  }

  Stores mystore;

  getuser() async {
    var url = 'https://api.sellship.co/api/store/' + widget.storeid;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      var follower = jsonbody['follower'];

      if (follower != null) {
        if (follower.length == 0) {
          if (mounted) {
            setState(() {
              followerslist = follower;
              followers = 0;
              follow = false;
            });
          }
        } else {
          for (int i = 0; i < follower.length; i++) {
            var meuser = await storage.read(key: 'userid');
            if (meuser == follower[i]['\$oid']) {
              if (mounted) {
                setState(() {
                  follow = true;

                  followcolor = Colors.deepOrange;
                });
              }
            }
          }
          if (mounted) {
            setState(() {
              followers = follower.length;
              followerslist = follower;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            followerslist = [];
            followers = 0;
            follow = false;
          });
        }
      }

      var reviewratin;
      if (jsonbody['reviewrating'] == null) {
        reviewratin = 0.0;
      } else {
        reviewratin = double.parse(jsonbody['reviewrating'].toString());
      }

      var s = jsonbody['storename'];

      var cover;
      if (jsonbody.containsKey('storecover')) {
        cover = jsonbody['storecover'];
      } else {
        cover = null;
      }

      mystore = Stores(
          storeusername: jsonbody['storeusername'] == null
              ? jsonbody['storename']
              : jsonbody['storeusername'],
          storeid: jsonbody['_id']['\$oid'],
          storecover: cover,
          reviews: jsonbody['reviewnumber'] == null
              ? '0'
              : jsonbody['reviewnumber'].toString(),
          sold: jsonbody['sold'] == null ? '0' : jsonbody['sold'].toString(),
          storecategory: jsonbody['storecategory'],
          storetype: jsonbody['storetype'],
          storelogo: jsonbody['storelogo'] == null ? '' : jsonbody['storelogo'],
          storebio: jsonbody['storebio'],
          storename: jsonbody['storename']);

      if (mounted) {
        setState(() {
          mystore = mystore;
          loading = false;
          reviewrating = reviewratin;
        });
      }
    }
  }

  List followerslist = List();

  bool profileloading;

  List<Item> item = List<Item>();

  Widget storeitems(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: item.isNotEmpty
                  ? EasyRefresh(
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
                      onRefresh: () {
                        return getItemData();
                      },
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Details(
                                          itemid: item[index].itemid,
                                          sold: item[index].sold,
                                          image: item[index].image,
                                          name: item[index].name,
                                          source: 'detail',
                                        )),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: 195,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Hero(
                                        tag: 'detail' + item[index].itemid,
                                        child: CachedNetworkImage(
                                          height: 200,
                                          width: 300,
                                          fadeInDuration:
                                              Duration(microseconds: 5),
                                          imageUrl: item[index].image,
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
                                  item[index].saleprice != null
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 30,
                                            width: 50,
                                            padding: EdgeInsets.only(
                                                left: 5, right: 5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'SALE',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ))
                                      : Container(),
                                  item[index].sold == true
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.only(
                                                left: 5, right: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrangeAccent
                                                  .withOpacity(0.8),
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                'Sold',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ))
                                      : Container(),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: item.length,
                      ))
                  : Container(
                      child: ListView(
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: MediaQuery.of(context).size.width - 100,
                            child: Image.asset(
                              'assets/little_theologians_4x.png',
                              fit: BoxFit.fitHeight,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Looks like its all empty here! ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                        ),
                      ],
                    ))),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                FeatherIcons.chevronLeft,
                color: Color.fromRGBO(28, 45, 65, 1),
              ),
              onTap: () {
                Navigator.pop(context);
              }),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10, bottom: 5),
            child: InkWell(
                onTap: () async {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      useRootNavigator: false,
                      builder: (_) => new AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            content: Builder(
                              builder: (context) {
                                return Container(
                                    height: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sharing Store..',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                            height: 50,
                                            width: 50,
                                            child: SpinKitDoubleBounce(
                                              color: Colors.deepOrange,
                                            )),
                                      ],
                                    ));
                              },
                            ),
                          ));
                  BranchUniversalObject buo = BranchUniversalObject(
                    canonicalIdentifier: widget.storeid,
                    title: widget.storename,
                    imageUrl: mystore.storelogo,
                    contentDescription: mystore.storebio,
                    contentMetadata: BranchContentMetaData()
                      ..addCustomMetadata(
                        'storename',
                        widget.storename,
                      )
                      ..addCustomMetadata(
                        'source',
                        'store',
                      )
                      ..addCustomMetadata('storeimage', mystore.storelogo)
                      ..addCustomMetadata('storeid', widget.storeid),
                    publiclyIndex: true,
                    locallyIndex: true,
                  );

                  FlutterBranchSdk.registerView(buo: buo);
                  BranchLinkProperties lp = BranchLinkProperties(
                    alias: mystore.storeusername,
                    channel: 'whatsapp',
                    feature: 'sharing',
                    stage: 'new share',
                  );
                  lp.addControlParam('\$uri_redirect_mode', '1');

                  BranchResponse response = await FlutterBranchSdk.getShortUrl(
                      buo: buo, linkProperties: lp);

                  Navigator.pop(context);
                  if (response.success) {
                    final RenderBox box = context.findRenderObject();
                    print(response.result);
                    var url =
                        "https://api.sellship.co/api/save/share/store/${mystore.storeid}";

                    FormData formData = FormData.fromMap({
                      'shareurl': response.result,
                    });

                    Dio dio = new Dio();
                    var respo = await dio.post(url, data: formData);

                    Share.share(response.result,
                        subject: widget.storename,
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                    print('${response.result}');
                  } else {
                    print('ss');
                    final RenderBox box = context.findRenderObject();
                    var url =
                        "https://api.sellship.co/api/share/store/${mystore.storeid}";
                    print(url);
                    var respo = await http.get(Uri.parse(url));
                    print(respo.body);

                    var jsonbody = json.decode(respo.body);
                    var urls = jsonbody['url'];
                    print(urls);
                    Share.share(urls,
                        subject: widget.storename,
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  }
                  FirebaseAnalytics analytics = FirebaseAnalytics();
                  await analytics.logShare(
                    contentType: widget.storename,
                    itemId: widget.storeid,
                  );
                },
                child: Icon(
                  FeatherIcons.share,
                  color: Color.fromRGBO(28, 45, 65, 1),
                )),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          mystore == null
              ? '@' + widget.storename
              : '@' + mystore.storeusername,
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      key: _scaffoldKey,
      body: loading == false
          ? NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                      delegate: new SliverChildListDelegate([
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                              height: 90,
                              width: MediaQuery.of(context).size.width,
                              child: mystore.storecover == null
                                  ? SvgPicture.asset(
                                      'assets/LoginBG.svg',
                                      semanticsLabel: 'SellShip BG',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: mystore.storecover,
                                      fit: BoxFit.cover,
                                    )),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                              padding:
                                  EdgeInsets.only(left: 15, top: 40, right: 20),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                            children: [
                                              Container(
                                                height: 110,
                                                width: 100,
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: GestureDetector(
                                                        child: Container(
                                                          height: 100,
                                                          width: 100,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  width: 5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: mystore.storelogo ==
                                                                        null ||
                                                                    mystore
                                                                        .storelogo
                                                                        .isEmpty
                                                                ? Image.asset(
                                                                    'assets/personplaceholder.png',
                                                                    fit: BoxFit
                                                                        .fitWidth,
                                                                  )
                                                                : Hero(
                                                                    tag: 'store' +
                                                                        mystore
                                                                            .storeid,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      height:
                                                                          200,
                                                                      width:
                                                                          300,
                                                                      imageUrl:
                                                                          mystore
                                                                              .storelogo,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          SpinKitDoubleBounce(
                                                                              color: Colors.deepOrange),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(Icons
                                                                              .error),
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, top: 35),
                                            child: Column(
                                                children: [
                                                  Text(
                                                    mystore.storename,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 24.0,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    mystore.storetype,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 18.0,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start))
                                      ]))),
                        )
                      ],
                    ),
                    widget.storename != null
                        ? Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      mystore.sold == null
                                                          ? '0'
                                                          : mystore.sold
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      'Sold',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Helvetica',
                                                          color:
                                                              Colors.blueGrey),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      mystore.reviews == null
                                                          ? '0'
                                                          : mystore.reviews
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      'Reviews',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Helvetica',
                                                          color:
                                                              Colors.blueGrey),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                FollowersPage(
                                                                  followers:
                                                                      followerslist,
                                                                )),
                                                      );
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          followers == null
                                                              ? '0'
                                                              : followers
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        Text(
                                                          'Followers',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Helvetica',
                                                              color: Colors
                                                                  .blueGrey),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          FeatherIcons.star,
                                                          color: Colors.black,
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          reviewrating != null
                                                              ? reviewrating
                                                                  .toStringAsFixed(
                                                                      1)
                                                              : '0.0',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      'Rating',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Helvetica',
                                                          color:
                                                              Colors.blueGrey),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start)))
                        : Container(
                            child: SpinKitDoubleBounce(
                                color: Colors.deepOrangeAccent),
                          ),
                    SizedBox(
                      height: 5,
                    ),
                    mystore.storebio.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 5.0),
                            child: ExpandableText(
                              mystore.storebio,
                              trimLines: 2,
                            ))
                        : Container(),
                    InkWell(
                      onTap: () async {
                        var user1 = await storage.read(key: 'userid');
                        if (follow == true) {
                          setState(() {
                            follow = false;
                            followcolor = Colors.white;
                            followers = followers - 1;
                          });
                          var followurl =
                              'https://api.sellship.co/api/follow/' +
                                  user1 +
                                  '/' +
                                  widget.storeid;

                          final followresponse =
                              await http.get(Uri.parse(followurl));
                          if (followresponse.statusCode == 200) {
                            print('UnFollowed');
                          }
                        } else {
                          var followurl =
                              'https://api.sellship.co/api/follow/' +
                                  user1 +
                                  '/' +
                                  widget.storeid;
                          setState(() {
                            follow = true;
                            followcolor = Colors.deepOrange;
                            followers = followers + 1;
                          });

                          final followresponse =
                              await http.get(Uri.parse(followurl));
                          if (followresponse.statusCode == 200) {
                            print('Followed');
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: 50,
                          width: 400,
                          decoration: BoxDecoration(
                              color: followcolor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: follow == true
                                      ? Colors.deepOrange
                                      : Colors.blueGrey.shade200
                                          .withOpacity(0.5))),
                          child: Center(
                            child: Text(
                              follow == true ? 'Following' : 'Follow',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: follow == true
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]))
                ];
              },
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: profileloading == false
                          ? storeitems(context)
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300],
                                highlightColor: Colors.grey[100],
                                child: ListView(
                                  children: [0, 1, 2, 3, 4, 5, 6]
                                      .map((_) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2 -
                                                      30,
                                                  height: 150.0,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                                                        BorderRadius.circular(
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
                    ),
                  ]))
          : Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  height: 150.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2 -
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
    );
  }
}
