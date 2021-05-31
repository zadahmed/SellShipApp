import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/expandabletext.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/followerspage.dart';
import 'package:SellShip/screens/store/discounts.dart';
import 'package:SellShip/screens/store/editstore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

class StorePage extends StatefulWidget {
  final String storeid;
  final String storename;

  StorePage({
    Key key,
    this.storeid,
    this.storename,
  }) : super(key: key);

  @override
  _StorePageState createState() => new _StorePageState();
}

class _StorePageState extends State<StorePage> {
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
      screenName: 'App:UserStorePage',
      screenClassOverride: 'AppUserStorePage',
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool loading;

  var profilepicture;
  var coverphoto;
  var username;

  var itemssold;
  var following;
  var followers;
  var storename;
  var reviewrating;

  final storage = new FlutterSecureStorage();

  getItemData() async {
    var itemurl = 'https://api.sellship.co/store/products/' + widget.storeid;

    final itemresponse = await http.get(Uri.parse(itemurl));
    if (itemresponse.statusCode == 200) {
      var itemrespons = json.decode(itemresponse.body);
      print(itemrespons);

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
              views: itemrespons[i]['views'] == null
                  ? 0
                  : int.parse(itemrespons[i]['views'].toString()),
              likes:
                  itemrespons[i]['likes'] == null ? 0 : itemrespons[i]['likes'],
              comments: itemrespons[i]['comments'] == null
                  ? 0
                  : itemrespons[i]['comments'].length,
              sold: itemrespons[i]['sold'] == null
                  ? false
                  : itemrespons[i]['sold'],
              category: itemrespons[i]['category']);
          ites.add(ite);
        }
        if (mounted)
          setState(() {
            item = new List.from(ites.reversed);
            profileloading = false;
          });
      } else {
        if (mounted)
          setState(() {
            item = [];
            profileloading = false;
          });
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
          setState(() {
            followerslist = follower;
            followers = 0;
          });
        } else {
          setState(() {
            followerslist = follower;
            followers = follower.length;
          });
        }
      } else {
        setState(() {
          followerslist = follower;
          followers = 0;
        });
      }

      if (jsonbody.containsKey('storecover')) {
        coverphoto = jsonbody['storecover'];
      } else {
        coverphoto = null;
      }
      Stores store = Stores(
          storetype: jsonbody['storetype'],
          storeid: jsonbody['_id']['\$oid'],
          reviews: jsonbody['reviewnumber'] == null
              ? '0'
              : jsonbody['reviewnumber'].toString(),
          sold: jsonbody['sold'] == null ? '0' : jsonbody['sold'].toString(),
          storecategory: jsonbody['storecategory'],
          storelogo: jsonbody['storelogo'],
          storebio: jsonbody['storebio'],
          storename: jsonbody['storename']);

      setState(() {
        mystore = store;

        loading = false;
      });
    }
  }

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
                        getuser();
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
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditItem(
                                                            itemid: item[index]
                                                                .itemid,
                                                            itemname:
                                                                item[index]
                                                                    .name,
                                                          )),
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 18,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  FeatherIcons.edit2,
                                                  color: Colors.blueGrey,
                                                  size: 16,
                                                ),
                                              )))),
                                  item[index].sold == true
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 50,
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
                                  Positioned(
                                    right: 0,
                                    bottom: 2,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(item[index].views.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 12,
                                                color: Colors.white)),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  item[index].approved == false
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10)),
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                'In Review',
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
                                  Positioned(
                                    right: 0,
                                    bottom: 2,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(item[index].views.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 12,
                                                color: Colors.white)),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: item.length,
                      ))
                  : Container(
                      child: Column(
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: MediaQuery.of(context).size.width - 100,
                            child: Image.asset(
                              'assets/little_theologians_4x.png',
                              fit: BoxFit.fill,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              'You have no items added to your store yet! Go ahead list your first listing now. Lets get selling! ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 5.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Sell an Item',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddItem()),
                            );
                          },
                        ),
                      ],
                    ))),
        ]);
  }

  List followerslist = List();

  Future getImageCamera() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    var url = 'https://api.sellship.co/api/store/imageupload/' + widget.storeid;
    Dio dio = new Dio();
    FormData formData;
    String fileName = image.path.split('/').last;
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: 50,
                      width: 50,
                      child: SpinKitDoubleBounce(
                        color: Colors.deepOrange,
                      ));
                },
              ),
            ));
    formData = FormData.fromMap({
      'profilepicture':
          await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        profilepicture = response.data;
      });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future getImageCameraCover() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, maxHeight: 400, maxWidth: 400);

    var url =
        'https://api.sellship.co/api/store/cover/imageupload/' + widget.storeid;
    Dio dio = new Dio();
    FormData formData;
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: 50,
                      width: 50,
                      child: SpinKitDoubleBounce(
                        color: Colors.deepOrange,
                      ));
                },
              ),
            ));
    String fileName = image.path.split('/').last;
    formData = FormData.fromMap({
      'storecover': await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        coverphoto = response.data;
      });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future getImageGalleryCover() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    var url =
        'https://api.sellship.co/api/store/cover/imageupload/' + widget.storeid;
    Dio dio = new Dio();
    FormData formData;
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: 50,
                      width: 50,
                      child: SpinKitDoubleBounce(
                        color: Colors.deepOrange,
                      ));
                },
              ),
            ));
    String fileName = image.path.split('/').last;
    formData = FormData.fromMap({
      'storecover': await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        coverphoto = response.data;
      });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future getImageGallery() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    var url = 'https://api.sellship.co/api/store/imageupload/' + widget.storeid;
    Dio dio = new Dio();
    FormData formData;
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: 50,
                      width: 50,
                      child: SpinKitDoubleBounce(
                        color: Colors.deepOrange,
                      ));
                },
              ),
            ));
    String fileName = image.path.split('/').last;
    formData = FormData.fromMap({
      'profilepicture':
          await MultipartFile.fromFile(image.path, filename: fileName)
    });
    var response = await dio.post(url, data: formData);

    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusCode);
    }

    if (mounted)
      setState(() {
        profilepicture = response.data;
      });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void showMe(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter updateState) {
              return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 20, right: 15),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Store Settings',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ])),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditStore(storeid: widget.storeid)),
                            );

                            if (result == null) {
                              getuser();
                            }
                          },
                          title: Text('Edit Store',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                              )),
                          trailing: Icon(
                            FeatherIcons.chevronRight,
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (_) => new AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                      height: 50,
                                                      width: 50,
                                                      child:
                                                          SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange,
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
                                ..addCustomMetadata(
                                    'storeimage', mystore.storelogo)
                                ..addCustomMetadata('storeid', widget.storeid),
                              publiclyIndex: true,
                              locallyIndex: true,
                            );

                            FlutterBranchSdk.registerView(buo: buo);

                            BranchLinkProperties lp = BranchLinkProperties(
                              alias: widget.storename,
                              channel: 'whatsapp',
                              feature: 'sharing',
                              stage: 'new share',
                            );
                            lp.addControlParam('\$uri_redirect_mode', '1');
                            BranchResponse response =
                                await FlutterBranchSdk.getShortUrl(
                                    buo: buo, linkProperties: lp);
                            if (response.success) {
                              Navigator.pop(context);
                              var url =
                                  "https://api.sellship.co/api/save/share/store/${mystore.storeid}";

                              FormData formData = FormData.fromMap({
                                'shareurl': response.result,
                              });

                              Dio dio = new Dio();
                              var respo = await dio.post(url, data: formData);
                              final RenderBox box = context.findRenderObject();
                              Share.share(response.result,
                                  subject: widget.storename,
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                              print('${response.result}');
                            } else {
                              print('ss');
                              final RenderBox box = context.findRenderObject();
                              var url =
                                  "https://api.sellship.co/api/share/store/${mystore.storeid}";

                              var respo = await http.get(Uri.parse(url));

                              var jsonbody = json.decode(respo.body);
                              Navigator.pop(context);
                              Share.share(jsonbody['url'],
                                  subject: widget.storename,
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            }
                            FirebaseAnalytics analytics = FirebaseAnalytics();
                            await analytics.logShare(
                              contentType: widget.storename,
                              itemId: widget.storeid,
                            );
                          },
                          title: Text('Share',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                              )),
                          trailing: Icon(
                            FeatherIcons.chevronRight,
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Discounts(storeid: widget.storeid)),
                            );
                          },
                          title: Row(
                            children: [
                              Text('Discounts',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 18,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                  width: 50,
                                  height: 22,
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: Text('NEW',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  )),
                            ],
                          ),
                          trailing: Icon(
                            FeatherIcons.chevronRight,
                            color: Colors.black,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            // final result = await Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           EditStore(storeid: widget.storeid)),
                            // );
                            //
                            // if (result == null) {
                            //   getuser();
                            // }
                          },
                          title: Text('Coming Soon - Promocodes 🤩',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18,
                                  color: Colors.grey)),
                          trailing: Icon(
                            FeatherIcons.chevronRight,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                      ]));
            }));
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '@' + widget.storename,
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10, bottom: 5),
            child: InkWell(
                onTap: () {
                  showMe(context);
                },
                child: Icon(
                  FeatherIcons.settings,
                  color: Color.fromRGBO(28, 45, 65, 1),
                )),
          ),
        ],
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
                                child: Stack(children: [
                                  Container(
                                      height: 90,
                                      width: MediaQuery.of(context).size.width,
                                      child: coverphoto == null
                                          ? SvgPicture.asset(
                                              'assets/LoginBG.svg',
                                              semanticsLabel: 'SellShip BG',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: coverphoto,
                                              fit: BoxFit.cover,
                                            )),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () {
                                        final action = CupertinoActionSheet(
                                          message: Text(
                                            "Upload an Image",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              child: Text("Upload from Camera",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              isDefaultAction: true,
                                              onPressed: () {
                                                getImageCameraCover();
                                              },
                                            ),
                                            CupertinoActionSheetAction(
                                              child: Text("Upload from Gallery",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              isDefaultAction: true,
                                              onPressed: () {
                                                getImageGalleryCover();
                                              },
                                            )
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            isDestructiveAction: true,
                                            onPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                            },
                                          ),
                                        );
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) => action);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 10, bottom: 10),
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              Color.fromRGBO(28, 45, 65, 1),
                                          child: Icon(
                                            FeatherIcons.camera,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]))),
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
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: InkWell(
                                                        onTap: () {
                                                          final action =
                                                              CupertinoActionSheet(
                                                            message: Text(
                                                              "Upload an Image",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            ),
                                                            actions: <Widget>[
                                                              CupertinoActionSheetAction(
                                                                child: Text(
                                                                    "Upload from Camera",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                                isDefaultAction:
                                                                    true,
                                                                onPressed: () {
                                                                  getImageCamera();
                                                                },
                                                              ),
                                                              CupertinoActionSheetAction(
                                                                child: Text(
                                                                    "Upload from Gallery",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                                isDefaultAction:
                                                                    true,
                                                                onPressed: () {
                                                                  getImageGallery();
                                                                },
                                                              )
                                                            ],
                                                            cancelButton:
                                                                CupertinoActionSheetAction(
                                                              child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal)),
                                                              isDestructiveAction:
                                                                  true,
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              },
                                                            ),
                                                          );
                                                          showCupertinoModalPopup(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      action);
                                                        },
                                                        child: CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor:
                                                              Color.fromRGBO(28,
                                                                  45, 65, 1),
                                                          child: Icon(
                                                            FeatherIcons.camera,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    )
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
                                padding: EdgeInsets.only(top: 10),
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
                      height: 10,
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 5.0),
                        child: ExpandableText(
                          mystore.storebio,
                          trimLines: 2,
                        )),
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
