import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/CommentsDetail.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/checkoutuae.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/profile.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:badges/badges.dart';
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
import 'package:numeral/numeral.dart';
import 'package:photo_view/photo_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/useritems.dart';
import 'package:share/share.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  TextEditingController offercontroller = TextEditingController();

  String allowedoffer = '';
  bool disabled = true;
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Make an Offer',
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.deepOrangeAccent
                                          .withOpacity(0.2)),
                                  color:
                                      Colors.deepOrangeAccent.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text(
                                  'Current Price ' + currency + newItem.price,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
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
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: Container(
                        height: 84,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2)),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
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
                                            disabled = true;
                                          });
                                        } else {
                                          updateState(() {
                                            allowedoffer = '';
                                            disabled = false;
                                          });
                                        }
                                      } else {
                                        updateState(() {
                                          allowedoffer = '';
                                          disabled = true;
                                        });
                                      }
                                    },
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: '0',
//                                                alignLabelWithHint: true,
                                      hintStyle: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                      focusColor: Colors.black,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                  width: 100,
                                ),
                                Text(currency,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 22,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: InkWell(
                        onTap: () async {
                          if (disabled == false) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 100,
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SpinKitChasingDots(
                                            color: Colors.deepOrangeAccent)),
                                  );
                                });
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                                Navigator.pop(context);
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
                                          'You can\'t send an offer to yourself!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                        onlyOkButton: true,
                                        entryAnimation: EntryAnimation.DEFAULT,
                                        onOkButtonPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RootScreen(index: 0)),
                                          );
                                        },
                                      ));
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: allowedoffer.isEmpty
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
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
                    ),
                    SizedBox(height: 80),
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
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Report this Item?',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
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
                      width: MediaQuery.of(context).size.width - 50,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
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
                  SizedBox(
                    height: 40,
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
              if (profilemap[i] != null) {
                ites.add(profilemap[i]['_id']['\$oid']);
              }
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

  double reviewrating;
  bool verifiedfb;
  bool verifiedphone;
  bool verifiedemail;
  var profilepicture;

  var country;
  fetchItem() async {
    var countr = await storage.read(key: 'country');
    userid = await storage.read(key: 'userid');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
        country = countr;
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
        country = countr;
      });
    }

    var url = 'https://api.sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    var userurl = 'https://api.sellship.co/api/user/' + jsonbody[0]['userid'];
    final userresponse = await http.get(userurl);

    var userjsonbody = json.decode(userresponse.body);

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
        size: jsonbody[0]['size'] == null ? '' : jsonbody[0]['size'],
        useremail: jsonbody[0]['useremail'],
        usernumber: jsonbody[0]['usernumber'],
        userid: jsonbody[0]['userid'],
        latitude: jsonbody[0]['latitude'],
        comments: jsonbody[0]['comments'] == null
            ? 0
            : jsonbody[0]['comments'].length,
        longitude: jsonbody[0]['longitude'],
        subsubcategory: jsonbody[0]['subsubcategory'],
        subcategory: jsonbody[0]['subcategory']);

    var q = Map<String, dynamic>.from(jsonbody[0]['dateuploaded']);

    DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
    dateuploaded = timeago.format(dateuploade);

    var rating;
    if (userjsonbody['reviewrating'] == null) {
      rating = 0.0;
    } else {
      rating = userjsonbody['reviewrating'];
    }

    var revie;
    if (userjsonbody['reviewnumber'] == null) {
      review = 0;
    } else {
      review = userjsonbody['reviewnumber'];
    }

    setState(() {
      review = revie;
      reviewrating = rating;
      verifiedfb = userjsonbody['confirmedfb'];
      verifiedphone = userjsonbody['confirmedphone'];
      verifiedemail = userjsonbody['confirmedemail'];
      profilepicture = userjsonbody['profilepicture'];

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

  double review;

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

  int inde = 0;
  @override
  Widget build(BuildContext context) {
    return loading == false
        ? Scaffold(
            backgroundColor: Colors.white,
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
                newItem.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
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
                        color: Color.fromRGBO(28, 45, 65, 1),
                      )),
                ),
              ],
            ),
            key: _scaffoldKey,
            body: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                          height: 400,
                          child: PageView.builder(
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
                                    Navigator.of(context).push(PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder:
                                            (BuildContext context, _, __) =>
                                                ImageDisplay(
                                                    image: images[index])));
                                  },
                                  child: Hero(
                                    tag: widget.itemid,
                                    child: CachedNetworkImage(
                                      imageUrl: images[index],
                                      height:
                                          MediaQuery.of(context).size.height,
                                      placeholder: (context, url) =>
                                          SpinKitChasingDots(
                                              color: Colors.deepOrange),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              })),
                      Positioned(
                        bottom: 20,
                        left: MediaQuery.of(context).size.width / 2 - 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.map((url) {
                            _current = images.indexOf(url);
                            return Padding(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.3),
                                    child: Container(
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _current == inde
                                            ? Colors.deepOrange
                                            : Colors.white,
                                      ),
                                    )));
                          }).toList(),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(242, 244, 248, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                border: Border.all(
                                  width: 0.0,
                                  color: Color.fromRGBO(242, 244, 248, 1),
                                )),
                          )),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: favourited == true
                                    ? InkWell(
                                        onTap: () async {
                                          var userid =
                                              await storage.read(key: 'userid');

                                          if (userid != null) {
                                            var url =
                                                'https://api.sellship.co/api/favourite/' +
                                                    userid;

                                            Map<String, String> body = {
                                              'itemid': newItem.itemid,
                                            };

                                            final response = await http
                                                .post(url, body: body);

                                            if (response.statusCode == 200) {
                                              setState(() {
                                                newItem.likes =
                                                    newItem.likes - 1;
                                                favourited = false;
                                              });
                                            } else {
                                              print(response.statusCode);
                                            }
                                          } else {
                                            showInSnackBar(
                                                'Please Login to use Favourites');
                                          }
                                        },
                                        child: Icon(
                                          FontAwesome.heart,
                                          size: 22,
                                          color: Colors.deepPurple,
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          var userid =
                                              await storage.read(key: 'userid');

                                          if (userid != null) {
                                            var url =
                                                'https://api.sellship.co/api/favourite/' +
                                                    userid;

                                            Map<String, String> body = {
                                              'itemid': newItem.itemid,
                                            };

                                            final response = await http
                                                .post(url, body: body);

                                            if (response.statusCode == 200) {
                                              var jsondata =
                                                  json.decode(response.body);

                                              setState(() {
                                                newItem.likes =
                                                    newItem.likes + 1;
                                                favourited = true;
                                              });
                                            } else {
                                              print(response.statusCode);
                                            }
                                          } else {
                                            showInSnackBar(
                                                'Please Login to use Favourites');
                                          }
                                        },
                                        child: Icon(
                                          Feather.heart,
                                          size: 22,
                                          color: Colors.grey,
                                        ),
                                      ))),
                      ),
                    ],
                  ),
                  height: 400,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(242, 244, 248, 0.9),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15, bottom: 5, top: 2),
                          child: Text(
                            capitalize(newItem.brand),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, bottom: 5, top: 2),
                          child: Text(
                            capitalize(newItem.name),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 22,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, bottom: 5, top: 2),
                          child: Text(
                            '$dateuploaded',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15, bottom: 5, top: 10, right: 15),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 15, bottom: 5, top: 5, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.apps,
                                              color:
                                                  Color.fromRGBO(60, 72, 88, 1),
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Category',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                    60, 72, 88, 1),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 200,
                                          child: Text(
                                            newItem.category,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 5, right: 15),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Icon(
                                              FontAwesome5.smile_beam,
                                              color:
                                                  Color.fromRGBO(60, 72, 88, 1),
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Condition',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                    60, 72, 88, 1),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 200,
                                          child: Text(
                                            newItem.condition.toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 5, right: 15),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Icon(
                                              FontAwesome.tag,
                                              color:
                                                  Color.fromRGBO(60, 72, 88, 1),
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Brand',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                    60, 72, 88, 1),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 200,
                                          child: Text(
                                            newItem.brand.toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                newItem.size.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            bottom: 5,
                                            top: 5,
                                            right: 15),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Icon(
                                                Icons.signal_cellular_null,
                                                color: Color.fromRGBO(
                                                    60, 72, 88, 1),
                                                size: 18,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: 200,
                                                child: Text(
                                                  newItem.size.toString(),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ListTile(
                                      onTap: () {
                                        showModalBottomSheet(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            25.0))),
                                            backgroundColor: Colors.white,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) => Container(
                                                height: 700,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    20))),
                                                child: Scaffold(
                                                  body: ListView(
                                                    children: <Widget>[
                                                      Container(
                                                        height: 260,
                                                        decoration:
                                                            new BoxDecoration(
                                                          image:
                                                              new DecorationImage(
                                                            image: new ExactAssetImage(
                                                                'assets/secure.png'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Buyer Protection',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 20,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Secure Payments',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          'All transcations within SellShip are secured and encrypted and kept safe using our trusted payment provider Stripe. Payment information is not available to sellers nor stored by us.',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 14,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          Icons.lock,
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                            'Money Back Guarantee'),
                                                        subtitle: Text(
                                                          'Item\'s that are not described as listed by the seller, that has undisclosed damage or if the seller has not shipped the item. The buyer can receive a refund for the item, as long as the refund request is made within 3 days of confirmed delivery',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 14,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          FontAwesome.money,
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                            'SellShip Support'),
                                                        subtitle: Text(
                                                          'The SellShip support team works 24/7 around the clock to deal with all issues, queries and doubts.',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 14,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          Icons.live_help,
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  bottomNavigationBar: Padding(
                                                    padding: EdgeInsets.all(30),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                        height: 48,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            20,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.deepPurple,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                5.0),
                                                          ),
                                                          boxShadow: <
                                                              BoxShadow>[
                                                            BoxShadow(
                                                                color: Colors
                                                                    .deepPurple
                                                                    .withOpacity(
                                                                        0.4),
                                                                offset:
                                                                    const Offset(
                                                                        1.1,
                                                                        1.1),
                                                                blurRadius:
                                                                    10.0),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Done',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  0.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )));
                                      },
                                      leading: Container(
                                        height: 120,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                255, 115, 0, 0.1),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Icon(
                                          FontAwesome.lock,
                                          size: 30,
                                          color: Color.fromRGBO(255, 115, 0, 1),
                                        ),
                                      ),
                                      title: Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Buyer Protection',
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Items bought through SellShip are eligible for Buyer Protection and Money Back Guarantee.',
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Feather.info,
                                        size: 16,
                                      ))),
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Platform.isIOS == true
                                  ? Container(
                                      height: 300,
                                      padding: EdgeInsets.all(5),
                                      child: NativeAdmob(
                                        adUnitID: _iosadUnitID,
                                        controller: _controller,
                                      ),
                                    )
                                  : Container(
                                      height: 300,
                                      padding: EdgeInsets.all(5),
                                      child: NativeAdmob(
                                        adUnitID: _androidadUnitID,
                                        controller: _controller,
                                      ),
                                    ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  children: [
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
                                      leading: profilepicture != null &&
                                              profilepicture.isNotEmpty
                                          ? Container(
                                              height: 50,
                                              width: 50,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: CachedNetworkImage(
                                                    imageUrl: profilepicture,
                                                    fit: BoxFit.cover,
                                                  )),
                                            )
                                          : CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  Colors.deepOrange,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: Image.asset(
                                                  'assets/personplaceholder.png',
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              )),
                                      title: Text(
                                        newItem.username,
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      trailing: InkWell(
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
                                              final response =
                                                  await http.get(itemurl);
                                              var messageinfo =
                                                  json.decode(response.body);
                                              var messageid =
                                                  (messageinfo['messageid']);
                                              var recieverfcmtoken =
                                                  (messageinfo[
                                                      'recieverfcmtoken']);
                                              var sendername =
                                                  (messageinfo['sendername']);
                                              var recipentname =
                                                  (messageinfo['recievername']);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPageView(
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
                                                builder: (_) =>
                                                    AssetGiffyDialog(
                                                      image: Image.asset(
                                                        'assets/oops.gif',
                                                        fit: BoxFit.cover,
                                                      ),
                                                      title: Text(
                                                        'Oops!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      description: Text(
                                                        'You need to login to Chat!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(),
                                                      ),
                                                      onlyOkButton: true,
                                                      entryAnimation:
                                                          EntryAnimation
                                                              .DEFAULT,
                                                      onOkButtonPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RootScreen(
                                                                      index:
                                                                          4)),
                                                        );
                                                      },
                                                    ));
                                          }
                                        },
                                        child: Container(
                                          width: 90,
                                          height: 60,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  45, 202, 115, 1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 0.5), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Feather.message_circle,
                                                    color: Colors.white,
                                                    size: 16),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Chat',
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      subtitle: Column(children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              InkWell(
                                                child: verifiedemail == true
                                                    ? Badge(
                                                        showBadge: true,
                                                        badgeColor: Colors
                                                            .deepOrangeAccent,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        badgeContent: Icon(
                                                          FontAwesome
                                                              .check_circle,
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 0.2,
                                                                  color: Colors
                                                                      .grey),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: CircleAvatar(
                                                              radius: 13,
                                                              child: Icon(
                                                                Feather.mail,
                                                                size: 13,
                                                                color: Colors
                                                                    .deepOrange,
                                                              ),
                                                              backgroundColor:
                                                                  Colors.white,
                                                            )))
                                                    : Badge(
                                                        showBadge: false,
                                                        badgeColor: Colors.grey,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.2,
                                                                color: Colors
                                                                    .grey),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 13,
                                                            child: Icon(
                                                              Feather.mail,
                                                              size: 13,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              InkWell(
                                                child: verifiedphone == true
                                                    ? Badge(
                                                        showBadge: true,
                                                        badgeColor: Colors
                                                            .deepOrangeAccent,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        badgeContent: Icon(
                                                          FontAwesome
                                                              .check_circle,
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 0.2,
                                                                  color: Colors
                                                                      .grey),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: CircleAvatar(
                                                              radius: 13,
                                                              child: Icon(
                                                                Feather.phone,
                                                                size: 13,
                                                                color: Colors
                                                                    .deepOrange,
                                                              ),
                                                              backgroundColor:
                                                                  Colors.white,
                                                            )))
                                                    : Badge(
                                                        showBadge: false,
                                                        badgeColor: Colors.grey,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.2,
                                                                color: Colors
                                                                    .grey),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 13,
                                                            child: Icon(
                                                              Feather.phone,
                                                              size: 13,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              InkWell(
                                                child: verifiedfb == true
                                                    ? Badge(
                                                        showBadge: true,
                                                        badgeColor:
                                                            Colors.deepOrange,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        badgeContent: Icon(
                                                          FontAwesome
                                                              .check_circle,
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.2,
                                                                color: Colors
                                                                    .deepOrange),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 13,
                                                            child: Icon(
                                                              Feather.facebook,
                                                              size: 13,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .blueAccent,
                                                          ),
                                                        ),
                                                      )
                                                    : Badge(
                                                        showBadge: false,
                                                        badgeColor: Colors.grey,
                                                        position: BadgePosition
                                                            .bottomEnd(),
                                                        animationType:
                                                            BadgeAnimationType
                                                                .slide,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.2,
                                                                color: Colors
                                                                    .grey),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 13,
                                                            child: Icon(
                                                              Feather.facebook,
                                                              size: 13,
                                                              color: Colors
                                                                  .blueAccent,
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 16.0),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 15, top: 10, right: 15),
                                      child: Row(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              SmoothStarRating(
                                                  allowHalfRating: true,
                                                  starCount: 5,
                                                  isReadOnly: true,
                                                  rating: reviewrating,
                                                  size: 20.0,
                                                  color: Colors.deepOrange,
                                                  borderColor: Colors.grey,
                                                  spacing: 0.0),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                reviewrating.toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        27, 44, 64, 1)),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            review != null
                                                ? '${review} Reviews'
                                                : '0 Reviews',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    27, 44, 64, 1)),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ))),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 5, top: 10, right: 15),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10, bottom: 10, top: 5),
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
                                    height: 220,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 220,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: GoogleMap(
                                            myLocationEnabled: false,
                                            scrollGesturesEnabled: false,
                                            myLocationButtonEnabled: false,
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: position,
                                              zoom: 15.0,
                                            ),
                                            onMapCreated: mapCreated,
                                            circles: _circles,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 5, top: 10),
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
                                ],
                              ),
                            )),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            reportitem(context);
                          },
                          child: Center(
                            child: Text(
                              'Report this Item',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: 450,
                          child: DefaultTabController(
                              length: 2,
                              child: Scaffold(
                                backgroundColor:
                                    Color.fromRGBO(242, 244, 248, 1),
                                appBar: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: CircleTabIndicator(
                                      color: Colors.deepOrange, radius: 4),
                                  isScrollable: true,
                                  labelColor: Colors.black,
                                  tabs: <Widget>[
                                    Tab(text: 'Description'),
                                    Tab(
                                        text: newItem.comments.toString() +
                                            ' Comments'),
                                  ],
                                ),
                                body: Container(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: TabBarView(
                                      children: [
                                        Container(
                                          height: 300,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    new SingleChildScrollView(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10, right: 10),
                                                    child: Text(
                                                      newItem.description,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CommentsDetail(itemid: newItem.itemid)
                                      ],
                                    )),
                              )),
                        ),
                      ],
                    )),
                SizedBox(height: 80),
              ],
            )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: newItem.sold == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
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
                                                      RootScreen(index: 4)),
                                            );
                                          },
                                        ));
                              }
                            },
                            child: Container(
                              height: 48,
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      offset: const Offset(0.0, 0.8),
                                      blurRadius: 5.0),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Make an Offer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Helvetica',
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    offset: const Offset(0.0, 0.8),
                                    blurRadius: 5.0),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                currency + ' ' + newItem.price.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  fontFamily: 'Helvetica',
                                  letterSpacing: 1.0,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5.0),
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
