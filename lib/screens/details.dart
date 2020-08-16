import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:photo_view/photo_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/useritems.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {
  final String itemid;
  final bool sold;
  Details({Key key, this.itemid, this.sold}) : super(key: key);
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String itemid;
  LatLng position;
  Item newItem;

  var loading;

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();
  final scaffoldState = GlobalKey<ScaffoldState>();
  bool sold;

  bool upDirection = true, flag = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      itemid = widget.itemid;

      sold = widget.sold;
    });
    fetchItem();
  }

  TextEditingController offercontroller = TextEditingController();

  String allowedoffer = '';

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
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Make an Offer',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    allowedoffer.isNotEmpty
                        ? Padding(
                            padding:
                                EdgeInsets.only(left: 15, bottom: 5, top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                allowedoffer,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ListTile(
                          title: Container(
                              width: 200,
                              padding: EdgeInsets.only(),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xFF979797),
                                  controller: offercontroller,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {
                                      var offer = double.parse(text);
                                      var minoffer =
                                          double.parse(newItem.price) * 0.50;
                                      minoffer = double.parse(newItem.price) -
                                          minoffer;

                                      if (offer < minoffer) {
                                        updateState(() {
                                          allowedoffer =
                                              'The offer is too low compared to the selling price';
                                        });
                                      } else {
                                        updateState(() {
                                          allowedoffer = '';
                                        });
                                      }
                                    } else {
                                      updateState(() {
                                        allowedoffer = '';
                                      });
                                    }
                                  },
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      labelText: "Offer Price",
                                      alignLabelWithHint: true,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Helvetica',
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
                              )),
                          trailing: InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        content: Builder(
                                          builder: (context) {
                                            return Container(
                                                height: 50,
                                                width: 50,
                                                child: SpinKitChasingDots(
                                                  color: Colors.deepOrange,
                                                ));
                                          },
                                        ),
                                      ));
                              var recieverid = newItem.userid;
                              if (recieverid != userid) {
                                var itemurl =
                                    'https://api.sellship.co/api/createoffer/' +
                                        userid +
                                        '/' +
                                        recieverid +
                                        '/' +
                                        itemid +
                                        '/' +
                                        offercontroller.text.trim();

                                final response = await http.get(itemurl);

                                if (response.statusCode == 200) {
                                  var messageinfo = json.decode(response.body);
                                  var messageid = (messageinfo['messageid']);
                                  var recieverfcmtoken =
                                      (messageinfo['recieverfcmtoken']);
                                  var sendername = (messageinfo['sendername']);
                                  var recipentname =
                                      (messageinfo['recievername']);
                                  var offer = messageinfo['offer'];
                                  var offerstage = messageinfo['offerstage'];
                                  Navigator.pop(context);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPageView(
                                        messageid: messageid,
                                        recipentname: recipentname,
                                        senderid: userid,
                                        offer: offer,
                                        offerstage: offerstage,
                                        recipentid: recieverid,
                                        fcmToken: recieverfcmtoken,
                                        senderName: sendername,
                                        itemid: itemid,
                                      ),
                                    ),
                                  );
                                } else {}
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                          image: Image.asset(
                                            'assets/oops.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            'Oops!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          description: Text(
                                            'You can\'t send an offer to yourself!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(),
                                          ),
                                          onlyOkButton: true,
                                          entryAnimation:
                                              EntryAnimation.DEFAULT,
                                          onOkButtonPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 0)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: allowedoffer.isEmpty
                                      ? Colors.red
                                      : Colors.grey,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Make Offer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Helvetica',
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }));
  }

  void reportitem(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Report this Item?',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    trailing: InkWell(
                      onTap: () async {
                        var itemurl =
                            'https://api.sellship.co/api/report/' + itemid;
                        final response = await http.get(itemurl);
                        if (response.statusCode == 200) {
                          Navigator.of(context).pop();
                          showInSnackBar(
                              'Item has been reported! Thank you for making \nthe SellShip community a safer place!');
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              'Report Item',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Helvetica',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  Set<Circle> _circles = Set();

  GoogleMapController controller;

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void mapCreated(GoogleMapController controlle) {
    setState(() {
      controller = controlle;
    });
  }

  var currency;
  bool favourited;

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
              ites.add(profilemap[i]['_id']['\$oid']);
            }

            if (ites.contains(newItem.itemid)) {
              setState(() {
                favourited = true;
              });
            } else {
              favourited = false;
            }
          } else {
            favourited = false;
          }
        }
      }
    } else {
      setState(() {
        favourited = false;
      });
    }
  }

  List<String> images = [];
  String dateuploaded;

  fetchItem() async {
    var country = await storage.read(key: 'country');
    userid = await storage.read(key: 'userid');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }

    var url = 'https://api.sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);
    print(jsonbody);
    newItem = Item(
        name: jsonbody[0]['name'],
        itemid: jsonbody[0]['_id']['\$oid'].toString(),
        price: jsonbody[0]['price'].toString(),
        description: jsonbody[0]['description'],
        category: jsonbody[0]['category'],
        condition: jsonbody[0]['condition'] == null
            ? 'Like New'
            : jsonbody[0]['condition'],
        image: jsonbody[0]['image'],
        image1: jsonbody[0]['image1'],
        image2: jsonbody[0]['image2'],
        image3: jsonbody[0]['image3'],
        image4: jsonbody[0]['image4'],
        image5: jsonbody[0]['image5'],
        sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
        likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
        city: jsonbody[0]['city'],
        username: jsonbody[0]['username'],
        brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
        size: jsonbody[0]['size'] == null ? null : jsonbody[0]['size'],
        useremail: jsonbody[0]['useremail'],
        usernumber: jsonbody[0]['usernumber'],
        userid: jsonbody[0]['userid'],
        latitude: jsonbody[0]['latitude'],
        longitude: jsonbody[0]['longitude'],
        subsubcategory: jsonbody[0]['subsubcategory'],
        subcategory: jsonbody[0]['subcategory']);

    var q = Map<String, dynamic>.from(jsonbody[0]['dateuploaded']);
    print(q);
    DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
    dateuploaded = timeago.format(dateuploade);
    setState(() {
      dateuploaded = dateuploaded;

      position = LatLng(
          double.parse(newItem.latitude), double.parse(newItem.longitude));
      _circles.add(Circle(
          circleId: CircleId(itemid),
          center: LatLng(
              double.parse(newItem.latitude), double.parse(newItem.longitude)),
          radius: 250,
          fillColor: Colors.lightBlueAccent.withOpacity(0.5),
          strokeWidth: 3,
          strokeColor: Colors.lightBlueAccent));
      loading = false;
    });

    if (newItem.image != null) {
      images.add(newItem.image);
    }
    if (newItem.image1 != null) {
      images.add(newItem.image1);
    }
    if (newItem.image2 != null) {
      images.add(newItem.image2);
    }
    if (newItem.image3 != null) {
      images.add(newItem.image3);
    }
    if (newItem.image4 != null) {
      images.add(newItem.image4);
    }
    if (newItem.image5 != null) {
      images.add(newItem.image5);
    }

    getfavourites();

    return newItem;
  }

  final storage = new FlutterSecureStorage();
  var userid;

  void favouriteItem() async {
    var userid = await storage.read(key: 'userid');

    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourite/' + userid;

      Map<String, String> body = {
        'itemid': newItem.itemid,
      };

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);

        if (jsondata.contains(newItem.itemid)) {
          setState(() {
            newItem.likes = newItem.likes + 1;
            favourited = true;
          });
        } else {
          setState(() {
            newItem.likes = newItem.likes - 1;
            favourited = false;
          });
        }
      } else {
        print(response.statusCode);
      }
    } else {
      showInSnackBar('Please Login to use Favourites');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
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

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  int _current = 0;
  Future<String> createFirstPostLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://sellship.page.link',
      link: Uri.parse('https://api.sellship.co/items?id=$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.zad.sellship',
      ),
      iosParameters: IosParameters(
        bundleId: 'com.zad.sellship',
        appStoreId: '1506496966',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out what I found on SellShip!',
        description: 'Found this awesome ${newItem.name} on SellShip',
      ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl.toString();
  }

  ScrollController _scrollController = ScrollController();

  int inde;
  @override
  Widget build(BuildContext context) {
    return loading == false
        ? Scaffold(
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.deepOrange,
                ),
              ),
              title: Text(
                newItem.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: 'Helvetica', fontSize: 18, color: Colors.black),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 5),
                  child: InkWell(
                      onTap: () async {
                        var s = await createFirstPostLink(itemid);
                        Share.share('Check out what I found $s',
                            subject:
                                'Look at this awesome item I found on SellShip!');
                      },
                      child: Icon(
                        Feather.share,
                        color: Colors.deepOrange,
                      )),
                ),
              ],
            ),
            body: Stack(
              children: <Widget>[
                new MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView(
                      controller: _scrollController,
//                  padding: EdgeInsets.symmetric(horizontal: 10),
                      children: <Widget>[
                        Container(
                          height: 350,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Stack(
                            children: <Widget>[
                              PageView.builder(
                                  itemCount: images.length,
                                  onPageChanged: (index) {
                                    print(index);
                                    setState(() {
                                      inde = index;
                                    });
                                  },
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (BuildContext
                                                            context,
                                                        _,
                                                        __) =>
                                                    ImageDisplay(
                                                        image: images[index])));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: images[index],
                                        height:
                                            MediaQuery.of(context).size.height,
                                        placeholder: (context, url) =>
                                            SpinKitChasingDots(
                                                color: Colors.deepOrange),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: images.map((url) {
                                    _current = images.indexOf(url);
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _current == inde
                                            ? Colors.deepOrange
                                            : Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: <Widget>[
                            ListTile(
                              dense: true,
                              title: Text(
                                newItem.name,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 20,
                                ),
                              ),
                              trailing: Container(
                                height: 50,
                                width: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: favourited == true
                                            ? InkWell(
                                                onTap: () async {
                                                  var userid = await storage
                                                      .read(key: 'userid');

                                                  if (userid != null) {
                                                    var url =
                                                        'https://api.sellship.co/api/favourite/' +
                                                            userid;

                                                    Map<String, String> body = {
                                                      'itemid': newItem.itemid,
                                                    };

                                                    final response = await http
                                                        .post(url, body: body);

                                                    if (response.statusCode ==
                                                        200) {
                                                      setState(() {
                                                        newItem.likes =
                                                            newItem.likes - 1;
                                                        favourited = false;
                                                      });
                                                    } else {
                                                      print(
                                                          response.statusCode);
                                                    }
                                                  } else {
                                                    showInSnackBar(
                                                        'Please Login to use Favourites');
                                                  }
                                                },
                                                child: Icon(
                                                  FontAwesome.heart,
                                                  color: Colors.deepPurple,
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () async {
                                                  var userid = await storage
                                                      .read(key: 'userid');

                                                  if (userid != null) {
                                                    var url =
                                                        'https://api.sellship.co/api/favourite/' +
                                                            userid;

                                                    Map<String, String> body = {
                                                      'itemid': newItem.itemid,
                                                    };

                                                    final response = await http
                                                        .post(url, body: body);

                                                    if (response.statusCode ==
                                                        200) {
                                                      var jsondata =
                                                          json.decode(
                                                              response.body);

                                                      setState(() {
                                                        newItem.likes =
                                                            newItem.likes + 1;
                                                        favourited = true;
                                                      });
                                                    } else {
                                                      print(
                                                          response.statusCode);
                                                    }
                                                  } else {
                                                    showInSnackBar(
                                                        'Please Login to use Favourites');
                                                  }
                                                },
                                                child: Icon(
                                                  Feather.heart,
                                                  color: Colors.black,
                                                ),
                                              )),
                                    InkWell(
                                      onTap: () {
                                        reportitem(context);
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.warning,
                                          color: Colors.grey,
                                          size: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 15, bottom: 10, top: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currency + ' ' + newItem.price.toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 15, bottom: 10, top: 5),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Uploaded $dateuploaded',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserItems(
                                          userid: newItem.userid,
                                          username: newItem.username)),
                                );
                              },
                              dense: true,
                              leading: Icon(FontAwesome.user_circle),
                              title: Text(
                                newItem.username,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.black),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(FontAwesome.heart),
                              title: Text(
                                newItem.likes.toString() + ' Likes',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(Icons.category),
                              title: Text(
                                newItem.category,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(Icons.hourglass_full),
                              title: Text(
                                newItem.condition.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(FontAwesome.tag),
                              title: Text(
                                newItem.brand.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            newItem.size != null
                                ? ListTile(
                                    dense: true,
                                    leading: Icon(Icons.signal_cellular_null),
                                    title: Text(
                                      newItem.size.toString(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, bottom: 10, top: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width - 10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: new SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          newItem.description,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Platform.isIOS == true
                                ? Container(
                                    height: 200,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _iosadUnitID,
                                      controller: _controller,
                                    ),
                                  )
                                : Container(
                                    height: 200,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _androidadUnitID,
                                      controller: _controller,
                                    ),
                                  ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 10, bottom: 10, top: 5),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        newItem.city.toString(),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: position,
                                        zoom: 15.0,
                                      ),
                                      onMapCreated: mapCreated,
                                      circles: _circles,
                                      onTap: (latLng) async {
                                        final String googleMapsUrl =
                                            "comgooglemaps://?center=${position.latitude},${position.longitude}";
                                        final String appleMapsUrl =
                                            "https://maps.apple.com/?q=${position.latitude},${position.longitude}";

                                        if (await canLaunch(googleMapsUrl)) {
                                          await launch(googleMapsUrl,
                                              forceSafariVC: true,
                                              forceWebView: true);
                                        }
                                        if (await canLaunch(appleMapsUrl)) {
                                          await launch(appleMapsUrl,
                                              forceSafariVC: false);
                                        } else {
                                          throw "Couldn't launch URL";
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 10, bottom: 10, top: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Location is approximated to protect the user',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        )
                      ],
                    ))
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: newItem.sold == false
                ? AnimatedOpacity(
                    duration: const Duration(milliseconds: 5),
                    opacity: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, bottom: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              if (userid != null) {
                                var recieverid = newItem.userid;
                                if (recieverid != userid) {
                                  var itemurl =
                                      'https://api.sellship.co/api/createroom/' +
                                          userid +
                                          '/' +
                                          recieverid +
                                          '/' +
                                          itemid;
                                  final response = await http.get(itemurl);
                                  var messageinfo = json.decode(response.body);
                                  var messageid = (messageinfo['messageid']);
                                  var recieverfcmtoken =
                                      (messageinfo['recieverfcmtoken']);
                                  var sendername = (messageinfo['sendername']);
                                  var recipentname =
                                      (messageinfo['recievername']);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPageView(
                                        messageid: messageid,
                                        recipentname: recipentname,
                                        senderid: userid,
                                        recipentid: recieverid,
                                        fcmToken: recieverfcmtoken,
                                        senderName: sendername,
                                        itemid: itemid,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                          image: Image.asset(
                                            'assets/oops.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            'Oops!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          description: Text(
                                            'You need to login to Chat!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(),
                                          ),
                                          onlyOkButton: true,
                                          entryAnimation:
                                              EntryAnimation.DEFAULT,
                                          onOkButtonPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 2)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  border: Border.all(
                                      color:
                                          Colors.deepPurple.withOpacity(0.2)),
                                ),
                                child: Icon(
                                  Icons.chat_bubble,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (userid != null) {
                                showMe(context);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                          image: Image.asset(
                                            'assets/oops.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            'Oops!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          description: Text(
                                            'You need to login to create an offer!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(),
                                          ),
                                          onlyOkButton: true,
                                          entryAnimation:
                                              EntryAnimation.DEFAULT,
                                          onOkButtonPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 2)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              height: 48,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Make an Offer',
                                  textAlign: TextAlign.left,
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
                          InkWell(
                            onTap: () async {
                              if (userid != null) {
                                var recieverid = newItem.userid;
                                if (recieverid != userid) {
                                  var itemurl =
                                      'https://api.sellship.co/api/createroom/' +
                                          userid +
                                          '/' +
                                          recieverid +
                                          '/' +
                                          itemid;
                                  final response = await http.get(itemurl);
                                  var messageinfo = json.decode(response.body);
                                  var messageid = (messageinfo['messageid']);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Checkout(
                                        messageid: messageid,
                                        item: newItem,
                                        offer: newItem.price,
                                      ),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AssetGiffyDialog(
                                            image: Image.asset(
                                              'assets/oops.gif',
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(
                                              'Oops!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              'You can\'t send a message to yourself!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            onlyOkButton: true,
                                            entryAnimation:
                                                EntryAnimation.DEFAULT,
                                            onOkButtonPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop('dialog');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RootScreen(index: 2)),
                                              );
                                            },
                                          ));
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                          image: Image.asset(
                                            'assets/oops.gif',
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            'Oops!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          description: Text(
                                            'You need to login to create an offer!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(),
                                          ),
                                          onlyOkButton: true,
                                          entryAnimation:
                                              EntryAnimation.DEFAULT,
                                          onOkButtonPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 2)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              height: 48,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Buy Now',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : AnimatedOpacity(
                    duration: const Duration(milliseconds: 5),
                    opacity: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, bottom: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Item Sold',
                                  textAlign: TextAlign.left,
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
                        ],
                      ),
                    ),
                  ))
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.deepOrange,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 5),
                  child: InkWell(
                      onTap: () async {
                        var s = await createFirstPostLink(itemid);
                        Share.share('Check out what I found $s',
                            subject:
                                'Look at this awesome item I found on SellShip!');
                      },
                      child: Icon(
                        Feather.share,
                        color: Colors.deepOrange,
                      )),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: Center(
              child: SpinKitChasingDots(
                color: Colors.deepOrange,
              ),
            ));
  }
}

class ImageDisplay extends StatefulWidget {
  final String image;
  ImageDisplay({Key key, this.image}) : super(key: key);
  @override
  ImageDisplayState createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pictures',
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: PhotoView.customChild(
            child: Image.network(
              widget.image,
              fit: BoxFit.contain,
            ),
          )),
    );
  }
}
