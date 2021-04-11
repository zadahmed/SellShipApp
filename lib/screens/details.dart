import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/CommentsDetail.dart';
import 'package:SellShip/screens/brand.dart';
import 'package:SellShip/screens/categorydynamic.dart';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/checkout.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/condition.dart';
import 'package:SellShip/screens/onboardingbottom.dart';
import 'package:SellShip/screens/profile.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/size.dart';
import 'package:SellShip/screens/store/mystorepage.dart';
import 'package:SellShip/screens/storepage.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:SellShip/screens/subcategory.dart';
import 'package:SellShip/screens/subsubcategory.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:numeral/numeral.dart';
import 'package:SellShip/models/Items.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/useritems.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {
  final String itemid;
  final String image;
  final Item item;
  final String name;
  final String source;
  final bool sold;
  Details(
      {Key key,
      this.itemid,
      this.sold,
      this.image,
      this.name,
      this.source,
      this.item})
      : super(key: key);
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String itemid;
  LatLng position;
  Item newItem;

  var loading;

  final scaffoldState = GlobalKey<ScaffoldState>();
  bool sold;

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        if (respons != 'Empty') {
          print(respons);
          List<String> ites = List<String>();

          if (respons != null) {
            for (var i = 0; i < respons.length; i++) {
              if (respons[i] != null) {
                ites.add(respons[i]['_id']['\$oid']);
              }
            }

            if (ites.contains(widget.itemid)) {
              setState(() {
                favourited = true;
              });
            } else {
              setState(() {
                favourited = true;
              });
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            setState(() {
              favourites = jsoninreverse;
            });
          } else {
            setState(() {
              favourites = [];
            });
          }
        } else {
          setState(() {
            favourites = [];
          });
        }
      } else {
        setState(() {
          favourites = [];
        });
      }
      print(favourites);
    }
  }

  List<String> favourites;

  bool upDirection = true, flag = true;

  checkuser() async {
    var userid = await storage.read(key: 'userid');

    if (userid == null) {
      Navigator.pop(context);
      showModalBottomSheet(
          context: context,
          useRootNavigator: false,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0)),
                      ),
                      child: OnboardingBottomScreen());
                });
          });
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      itemid = widget.itemid;

      sold = widget.sold;
    });

    getsimilaritems();
    getfavourites();
    fetchItem();
  }

  getcategory() async {
    var url = "https://api.sellship.co/api/category/" + newItem.category;
    final response = await http.get(url);
    print(response.statusCode);

    var jsonbody = json.decode(response.body);

    setState(() {
      categoryimage = jsonbody[0]['categoryimage'];
      subcategory = jsonbody[0]['subcategories'].toList();
    });
  }

  var subcategory;
  var categoryimage;

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  List<Item> similaritems = List<Item>();

  getsimilaritems() async {
    var url = 'https://api.sellship.co/api/similar/products/' + widget.itemid;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var i = 0; i < jsonbody.length; i++) {
        var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);

        DateTime dateuploade = DateTime.fromMillisecondsSinceEpoch(q['\$date']);
        var dateuploaded = timeago.format(dateuploade);
        Item item = Item(
          approved: jsonbody[i]['approved'],
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
          category: jsonbody[i]['category'],
          sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
        );
        similaritems.add(item);
      }

      if (similaritems != null) {
        if (mounted)
          setState(() {
            similaritems = similaritems;
          });
      } else {
        if (mounted)
          setState(() {
            similaritems = [];
          });
      }
    }
  }

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
                                Expanded(
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
                                                'The offer is too low compared to the selling price. Minimum offer price is AED' +
                                                    minoffer.toString();
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
                                        child: SpinKitDoubleBounce(
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
                                showInSnackBar(
                                    'Awesome! You made an offer for ' +
                                        newItem.name +
                                        ' for ' +
                                        currency +
                                        offercontroller.text);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                print(response.statusCode);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  useRootNavigator: false,
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
                                          Navigator.pop(context);
                                          Navigator.pop(context);
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
                                  ? Colors.deepOrange
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
    super.dispose();
  }

  void mapCreated(GoogleMapController controlle) {
    setState(() {
      controller = controlle;
    });
  }

  var selectedSize;

  var currency;
  bool favourited;

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

    bool offers;
    if (jsonbody[0]['acceptoffers'] == 'false' ||
        jsonbody[0]['acceptoffers'] == null) {
      offers = false;
    } else {
      offers = true;
    }

    bool protection;
    if (jsonbody[0]['buyerprotection'] == 'false' ||
        jsonbody[0]['buyerprotection'] == null) {
      protection = false;
    } else {
      protection = true;
    }

    var sfs = jsonbody[0]['size'];

    if (sfs == null || sfs.isEmpty) {
      sfs = [];
    } else {
      sfs = jsonbody[0]['size'].substring(2, jsonbody[0]['size'].length - 2);
      sfs = sfs.split(',');
    }

    newItem = Item(
        name: jsonbody[0]['name'],
        buyerprotection: protection,
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
        makeoffers: offers,
        image3: jsonbody[0]['image3'],
        image4: jsonbody[0]['image4'],
        storetype:
            jsonbody[0]['storetype'] == null ? '' : jsonbody[0]['storetype'],
        image5: jsonbody[0]['image5'],
        sellerid: jsonbody[0]['selleruserid'],
        sellername: jsonbody[0]['sellerusername'],
        sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
        likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
        city: jsonbody[0]['city'],
        username: jsonbody[0]['username'],
        brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
        size: sfs,
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

    print(newItem.size);

    var q = Map<String, dynamic>.from(jsonbody[0]['dateuploaded']);

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

    getuserDetails(jsonbody[0]['userid']);
    getcategory();
    return newItem;
  }

  getuserDetails(user) async {
    var userurl = 'https://api.sellship.co/api/store/' + user;
    final userresponse = await http.get(userurl);

    var userjsonbody = json.decode(userresponse.body);

    var rating;
    if (userjsonbody['reviewrating'] == null) {
      rating = 0.0;
    } else {
      rating = double.parse(userjsonbody['reviewrating'].toString());
    }

    var revie;
    if (userjsonbody['reviewnumber'] == null) {
      revie = 0;
    } else {
      revie = int.parse(userjsonbody['reviewnumber'].toString());
    }

    if (mounted) {
      setState(() {
        review = revie;
        reviewrating = rating;
        profilepicture = userjsonbody['storelogo'];
      });
    }
  }

  int review;

  final storage = new FlutterSecureStorage();
  var userid = '';

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
      checkuser();
      showInSnackBar('Please Login to use Favourites');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      action: SnackBarAction(
        label: value.contains('added to Cart!') ? 'View Cart' : '',
        textColor: Colors.white,
        onPressed: () {
          if (value.contains('added to Cart!')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Checkout()),
            );
          }
        },
      ),
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
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

  ScrollController _scrollController = ScrollController();

  int inde = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            widget.name,
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
                    BranchUniversalObject buo = BranchUniversalObject(
                        canonicalIdentifier: widget.itemid,
                        title: widget.name,
                        imageUrl: widget.image,
                        contentDescription: newItem.description,
                        contentMetadata: BranchContentMetaData()
                          ..addCustomMetadata(
                            'itemname',
                            widget.name,
                          )
                          ..addCustomMetadata(
                            'source',
                            'item',
                          )
                          ..addCustomMetadata('itemimage', widget.itemid)
                          ..addCustomMetadata('itemsold', newItem.sold)
                          ..addCustomMetadata('itemid', widget.itemid),
                        publiclyIndex: true,
                        locallyIndex: true,
                        expirationDateInMilliSec: DateTime.now()
                            .add(Duration(days: 365))
                            .millisecondsSinceEpoch);

                    FlutterBranchSdk.registerView(buo: buo);

                    BranchLinkProperties lp = BranchLinkProperties(
                      channel: 'facebook',
                      feature: 'sharing',
                      stage: 'new share',
                    );
                    lp.addControlParam('\$uri_redirect_mode', '1');
                    BranchResponse response =
                        await FlutterBranchSdk.getShortUrl(
                            buo: buo, linkProperties: lp);
                    if (response.success) {
                      final RenderBox box = context.findRenderObject();
                      Share.share(
                          'Check out this listing on SellShip: \n' +
                              response.result,
                          subject: widget.name,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                      print('${response.result}');
                    }
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
            child: loading == false
                ? Column(
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
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              PageRouteBuilder(
                                                  opaque: false,
                                                  pageBuilder:
                                                      (BuildContext context, _,
                                                              __) =>
                                                          ImageDisplay(
                                                            image: images,
                                                            itemname:
                                                                widget.name,
                                                          )));
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: images[index],
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          placeholder: (context, url) =>
                                              SpinKitDoubleBounce(
                                                  color: Colors.deepOrange),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.cover,
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
                                  child: favourites != null
                                      ? favourites.contains(newItem.itemid)
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
                                                    'itemid': newItem.itemid,
                                                  };

                                                  favourites
                                                      .remove(newItem.itemid);
                                                  setState(() {
                                                    favourites = favourites;
                                                    newItem.likes =
                                                        newItem.likes - 1;
                                                  });
                                                  final response = await http
                                                      .post(url,
                                                          body: json
                                                              .encode(body));

                                                  if (response.statusCode ==
                                                      200) {
                                                  } else {
                                                    print(response.statusCode);
                                                  }
                                                } else {
                                                  checkuser();
                                                  showInSnackBar(
                                                      'Please Login to use Favourites');
                                                }
                                              },
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                child: Icon(
                                                  FontAwesome.heart,
                                                  color: Colors.white,
                                                  size: 20,
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
                                                    'itemid': newItem.itemid,
                                                  };

                                                  favourites
                                                      .add(newItem.itemid);
                                                  setState(() {
                                                    favourites = favourites;
                                                    newItem.likes =
                                                        newItem.likes + 1;
                                                  });
                                                  final response = await http
                                                      .post(url,
                                                          body: json
                                                              .encode(body));

                                                  if (response.statusCode ==
                                                      200) {
                                                  } else {
                                                    print(response.statusCode);
                                                  }
                                                } else {
                                                  checkuser();
                                                  showInSnackBar(
                                                      'Please Login to use Favourites');
                                                }
                                              },
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  Feather.heart,
                                                  color: Colors.blueGrey,
                                                  size: 20,
                                                ),
                                              ))
                                      : CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Feather.heart,
                                            color: Colors.blueGrey,
                                            size: 20,
                                          ),
                                        )),
                            ),
                          ],
                        ),
                        height: 400,
                      ),
                      Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(242, 244, 248, 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 15, bottom: 5, top: 2),
                                child: Text(
                                  currency + ' ' + newItem.price.toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 15, bottom: 5, top: 2),
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
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 2),
                                  child: Wrap(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryDetail(
                                                      category:
                                                          newItem.category,
                                                      categoryimage:
                                                          categoryimage,
                                                      subcategory: subcategory,
                                                    )),
                                          );
                                        },
                                        child: Text(
                                          newItem.category,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '/',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    SubCategory(
                                                      subcategory:
                                                          newItem.subcategory,
                                                      categoryimage:
                                                          newItem.image,
                                                    )),
                                          );
                                        },
                                        child: Text(
                                          newItem.subcategory,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '/',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    SubSubCategory(
                                                      subcategory: newItem
                                                          .subsubcategory,
                                                      categoryimage:
                                                          newItem.image,
                                                    )),
                                          );
                                        },
                                        child: Text(
                                          newItem.subsubcategory,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //       left: 15, bottom: 5, top: 2),
                              //   child: Text(
                              //     '$dateuploaded',
                              //     textAlign: TextAlign.left,
                              //     style: TextStyle(
                              //       fontFamily: 'Helvetica',
                              //       fontSize: 14,
                              //       color: Colors.grey,
                              //     ),
                              //   ),
                              // ),
                              newItem.size.isNotEmpty
                                  ? Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, top: 5),
                                      child: Text(
                                        'Size',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              newItem.size.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 10,
                                          top: 5,
                                          right: 15),
                                      child: Container(
                                          height: 40,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: newItem.size.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                  padding: EdgeInsets.all(2),
                                                  child: InkWell(
                                                      onTap: () {
                                                        if (selectedSize ==
                                                            newItem
                                                                .size[index]) {
                                                          setState(() {
                                                            selectedSize = null;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            selectedSize =
                                                                newItem.size[
                                                                    index];
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: selectedSize ==
                                                                          newItem.size[
                                                                              index]
                                                                      ? Colors
                                                                          .deepOrange
                                                                      : Colors
                                                                          .blueGrey
                                                                          .shade100),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Center(
                                                              child: Text(
                                                            newItem.size[index]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .deepOrange),
                                                          )))));
                                            },
                                          )),
                                    )
                                  : Container(),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              bottom: 5,
                                              top: 5,
                                              right: 15),
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
                                                    color: Color.fromRGBO(
                                                        60, 72, 88, 1),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CategoryDetail(
                                                              category: newItem
                                                                  .category,
                                                              categoryimage:
                                                                  categoryimage,
                                                              subcategory:
                                                                  subcategory,
                                                            )),
                                                  );
                                                },
                                                child: Container(
                                                  width: 200,
                                                  child: Text(
                                                    newItem.category,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.deepOrange,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      newItem.storetype == 'Secondhand Seller'
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  bottom: 5,
                                                  top: 5,
                                                  right: 15),
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          FontAwesome5
                                                              .smile_beam,
                                                          color: Color.fromRGBO(
                                                              60, 72, 88, 1),
                                                          size: 18,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Condition',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromRGBO(
                                                                    60,
                                                                    72,
                                                                    88,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Condition(
                                                                        condition:
                                                                            newItem.condition,
                                                                      )),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 200,
                                                        child: Text(
                                                          newItem.condition
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color: Colors
                                                                .deepOrange,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Padding(
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
                                              Row(
                                                children: [
                                                  Icon(
                                                    FontAwesome.tag,
                                                    color: Color.fromRGBO(
                                                        60, 72, 88, 1),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                            Brand(
                                                              brand:
                                                                  newItem.brand,
                                                            )),
                                                  );
                                                },
                                                child: Container(
                                                  width: 200,
                                                  child: Text(
                                                    newItem.brand.toString(),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      color: Colors.deepOrange,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              newItem.buyerprotection == true
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 5,
                                          top: 10,
                                          right: 15),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: ListTile(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Color(0xFF737373),
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder:
                                                          (context) =>
                                                              Container(
                                                                  height: MediaQuery.of(context)
                                                                          .size
                                                                          .height /
                                                                      2,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10,
                                                                          top:
                                                                              20),
                                                                  decoration: new BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: new BorderRadius
                                                                              .only(
                                                                          topLeft: const Radius.circular(
                                                                              20.0),
                                                                          topRight: const Radius.circular(
                                                                              20.0))),
                                                                  child:
                                                                      Scaffold(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    body:
                                                                        ListView(
                                                                      children: <
                                                                          Widget>[
                                                                        ListTile(
                                                                          title:
                                                                              Text(
                                                                            'Buyer Protection',
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 20,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        ListTile(
                                                                          title:
                                                                              Text(
                                                                            'Secure Payments',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            'All transcations within SellShip are secure and encrypted.',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 14,
                                                                              color: Colors.blueGrey,
                                                                            ),
                                                                          ),
                                                                          leading:
                                                                              Icon(
                                                                            Icons.lock,
                                                                            color: Color.fromRGBO(
                                                                                255,
                                                                                115,
                                                                                0,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        ListTile(
                                                                          title:
                                                                              Text(
                                                                            'Money Back Guarantee',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            'Product\'s that are not described as listed by the seller in the listing, that has undisclosed damage or if the seller has not shipped the item. The buyer can receive a refund for the item, as long as the refund request is made within 2 days of confirmed delivery or order',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 14,
                                                                              color: Colors.blueGrey,
                                                                            ),
                                                                          ),
                                                                          leading:
                                                                              Icon(
                                                                            FontAwesome.money,
                                                                            color: Color.fromRGBO(
                                                                                255,
                                                                                115,
                                                                                0,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        ListTile(
                                                                          title:
                                                                              Text(
                                                                            '24/7 Support',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            'The SellShip support team works 24/7 around the clock to deal with all support requests, queries and concerns.',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 14,
                                                                              color: Colors.blueGrey,
                                                                            ),
                                                                          ),
                                                                          leading:
                                                                              Icon(
                                                                            Icons.live_help,
                                                                            color: Color.fromRGBO(
                                                                                255,
                                                                                115,
                                                                                0,
                                                                                1),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    bottomNavigationBar:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              20),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              48,
                                                                          width:
                                                                              MediaQuery.of(context).size.width - 10,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                255,
                                                                                115,
                                                                                0,
                                                                                1),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(5.0),
                                                                            ),
                                                                            boxShadow: <BoxShadow>[
                                                                              BoxShadow(color: Color.fromRGBO(255, 115, 0, 0.4), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              'Done',
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
                                                          BorderRadius.circular(
                                                              15)),
                                                  child: Icon(
                                                    FontAwesome.lock,
                                                    size: 30,
                                                    color: Color.fromRGBO(
                                                        255, 115, 0, 1),
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    'Buyer Protection',
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                      ))
                                  : Container(),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 10, right: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StorePublic(
                                                          storeid:
                                                              newItem.userid,
                                                          storename:
                                                              newItem.username,
                                                        )),
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
                                                            BorderRadius
                                                                .circular(25),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 200,
                                                          width: 300,
                                                          imageUrl:
                                                              profilepicture,
                                                          fit: BoxFit.cover,
                                                        )),
                                                  )
                                                : CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        Colors.deepOrange,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0.0,
                                                    horizontal: 16.0),
                                          ),
                                          reviewrating != null
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15,
                                                      top: 10,
                                                      right: 15),
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          SmoothStarRating(
                                                              allowHalfRating:
                                                                  true,
                                                              starCount: 5,
                                                              isReadOnly: true,
                                                              rating:
                                                                  reviewrating,
                                                              size: 20.0,
                                                              color: Colors
                                                                  .deepOrange,
                                                              borderColor:
                                                                  Colors.grey,
                                                              spacing: 0.0),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            reviewrating
                                                                .toStringAsFixed(
                                                                    1),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        27,
                                                                        44,
                                                                        64,
                                                                        1)),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        review != null
                                                            ? '${review} Reviews'
                                                            : '0 Reviews',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    27,
                                                                    44,
                                                                    64,
                                                                    1)),
                                                      )
                                                    ],
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                  ),
                                                )
                                              : SpinKitDoubleBounce(
                                                  color: Colors.deepOrange),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ))),

                              Container(
                                height: 320,
                                child: DefaultTabController(
                                    length: 2,
                                    child: Scaffold(
                                      backgroundColor:
                                          Color.fromRGBO(242, 244, 248, 1),
                                      appBar: TabBar(
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicator: CircleTabIndicator(
                                            color: Colors.deepOrange,
                                            radius: 4),
                                        isScrollable: true,
                                        labelColor: Colors.black,
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Helvetica'),
                                        tabs: <Widget>[
                                          Tab(text: 'Description'),
                                          Tab(
                                              text:
                                                  newItem.comments.toString() +
                                                      ' Comments'),
                                        ],
                                      ),
                                      body: Container(
                                          height: 320,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: TabBarView(
                                            children: [
                                              Container(
                                                height: 300,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
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
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10),
                                                          child: Text(
                                                            newItem.description,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              CommentsDetail(
                                                  itemid: newItem.itemid)
                                            ],
                                          )),
                                    )),
                              ),
                            ],
                          )),
                      similaritems.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                bottom: 5,
                                top: 10,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Similar Items',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          : Container(),
                      similaritems.isNotEmpty
                          ? Container(
                              height: 280,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                itemCount: similaritems.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return new Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Container(
                                      height: 280,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          20,
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
                                                    builder: (context) =>
                                                        Details(
                                                            itemid:
                                                                similaritems[
                                                                        index]
                                                                    .itemid,
                                                            image: similaritems[
                                                                    index]
                                                                .image,
                                                            name: similaritems[
                                                                    index]
                                                                .name,
                                                            sold: similaritems[
                                                                    index]
                                                                .sold,
                                                            source: 'similar')),
                                              );
                                            },
                                            child: Stack(children: <Widget>[
                                              Container(
                                                height: 220,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Hero(
                                                    tag:
                                                        'similar${similaritems[index].itemid}',
                                                    child: CachedNetworkImage(
                                                      height: 200,
                                                      width: 300,
                                                      fadeInDuration: Duration(
                                                          microseconds: 5),
                                                      imageUrl: similaritems[
                                                                  index]
                                                              .image
                                                              .isEmpty
                                                          ? SpinKitDoubleBounce(
                                                              color: Colors
                                                                  .deepOrange)
                                                          : similaritems[index]
                                                              .image,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitDoubleBounce(
                                                              color: Colors
                                                                  .deepOrange),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              similaritems[index].sold == true
                                                  ? Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                        ),
                                                        width: 210,
                                                        child: Center(
                                                          child: Text(
                                                            'Sold',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              color:
                                                                  Colors.white,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    similaritems[index].name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    currency +
                                                        ' ' +
                                                        similaritems[index]
                                                            .price,
                                                  )
                                                ],
                                              )),
                                              favourites != null
                                                  ? favourites.contains(
                                                          similaritems[index]
                                                              .itemid)
                                                      ? InkWell(
                                                          enableFeedback: true,
                                                          onTap: () async {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    similaritems[
                                                                            index]
                                                                        .itemid,
                                                              };

                                                              favourites.remove(
                                                                  similaritems[
                                                                          index]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                similaritems[
                                                                        index]
                                                                    .likes = similaritems[
                                                                            index]
                                                                        .likes -
                                                                    1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body: json
                                                                          .encode(
                                                                              body));

                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                              } else {
                                                                print(response
                                                                    .statusCode);
                                                              }
                                                            } else {
                                                              checkuser();
                                                              showInSnackBar(
                                                                  'Please Login to use Favourites');
                                                            }
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            backgroundColor:
                                                                Colors
                                                                    .deepPurple,
                                                            child: Icon(
                                                              FontAwesome.heart,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ))
                                                      : InkWell(
                                                          enableFeedback: true,
                                                          onTap: () async {
                                                            var userid =
                                                                await storage.read(
                                                                    key:
                                                                        'userid');

                                                            if (userid !=
                                                                null) {
                                                              var url =
                                                                  'https://api.sellship.co/api/favourite/' +
                                                                      userid;

                                                              Map<String,
                                                                      String>
                                                                  body = {
                                                                'itemid':
                                                                    similaritems[
                                                                            index]
                                                                        .itemid,
                                                              };

                                                              favourites.add(
                                                                  similaritems[
                                                                          index]
                                                                      .itemid);
                                                              setState(() {
                                                                favourites =
                                                                    favourites;
                                                                similaritems[
                                                                        index]
                                                                    .likes = similaritems[
                                                                            index]
                                                                        .likes +
                                                                    1;
                                                              });
                                                              final response =
                                                                  await http.post(
                                                                      url,
                                                                      body: json
                                                                          .encode(
                                                                              body));

                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                              } else {
                                                                print(response
                                                                    .statusCode);
                                                              }
                                                            } else {
                                                              showInSnackBar(
                                                                  'Please Login to use Favourites');
                                                            }
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: Icon(
                                                              Feather.heart,
                                                              color: Colors
                                                                  .blueGrey,
                                                              size: 16,
                                                            ),
                                                          ))
                                                  : CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: Icon(
                                                        Feather.heart,
                                                        color: Colors.blueGrey,
                                                        size: 16,
                                                      ),
                                                    )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
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
                      SizedBox(height: 120),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                          height: 400,
                          width: MediaQuery.of(context).size.width,
                          child: Hero(
                            tag: widget.source + widget.itemid,
                            child: CachedNetworkImage(
                              imageUrl: widget.image,
                              height: MediaQuery.of(context).size.height,
                              placeholder: (context, url) =>
                                  SpinKitDoubleBounce(color: Colors.deepOrange),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          )),
                      Container(
                          height: 500,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(242, 244, 248, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, bottom: 5, top: 2),
                                  child: Text(
                                    capitalize(widget.name),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                    child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  highlightColor: Colors.grey[100],
                                  child: ListView.builder(
                                    itemBuilder: (_, __) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
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
                                    ),
                                    itemCount: 6,
                                  ),
                                ))
                              ]))
                    ],
                  )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: loading == false
            ? userid != newItem.sellerid
                ? newItem.sold == false
                    ? newItem.makeoffers == true
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white.withOpacity(0.7),
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, bottom: 10, right: 10, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (userid != null) {
                                        if (selectedSize == null &&
                                            newItem.size.isNotEmpty) {
                                          showInSnackBar(
                                              'Please Choose a Size');
                                        } else {
                                          showMe(context);
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
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                                    checkuser();
                                                  },
                                                ));
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          20,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
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
                                  InkWell(
                                    onTap: () async {
                                      if (userid != null) {
                                        if (selectedSize == null &&
                                            newItem.size.isNotEmpty) {
                                          showInSnackBar(
                                              'Please Choose a Size');
                                        } else {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          List cartitems =
                                              prefs.getStringList('cartitems');
                                          print(cartitems);

                                          if (cartitems == null) {
                                            newItem.quantity = 1;

                                            if (selectedSize != null) {
                                              newItem.selectedsize =
                                                  selectedSize.toString();
                                            } else {
                                              newItem.selectedsize = 'nosize';
                                            }

                                            String item = jsonEncode(newItem);

                                            prefs.setStringList(
                                                'cartitems', [item]);
                                            showInSnackBar(newItem.name +
                                                ' added to Cart!');
                                          } else {
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible:
                                                  false, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Oops',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  content: Text(
                                                    'You have an item in your cart already.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w200),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(
                                                        'Add to Cart',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      onPressed: () async {
                                                        newItem.quantity = 1;

                                                        if (selectedSize !=
                                                            null) {
                                                          newItem.selectedsize =
                                                              selectedSize
                                                                  .toString();
                                                        } else {
                                                          newItem.selectedsize =
                                                              'nosize';
                                                        }

                                                        String item =
                                                            jsonEncode(newItem);

                                                        prefs.setStringList(
                                                            'cartitems',
                                                            [item]);
                                                        showInSnackBar(newItem
                                                                .name +
                                                            ' added to Cart!');
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        'Close',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
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
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  description: Text(
                                                    'You need to login to add to cart!',
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
                                                    checkuser();
                                                  },
                                                ));
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              offset: const Offset(0.0, 0.8),
                                              blurRadius: 5.0),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Add to Cart',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Helvetica',
                                            letterSpacing: 0.0,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              if (userid != null) {
                                if (selectedSize == null &&
                                    newItem.size.isNotEmpty) {
                                  showInSnackBar('Please Choose a Size');
                                } else {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  List cartitems =
                                      prefs.getStringList('cartitems');
                                  print(cartitems);

                                  if (cartitems == null) {
                                    newItem.quantity = 1;

                                    if (selectedSize != null) {
                                      newItem.selectedsize =
                                          selectedSize.toString();
                                    } else {
                                      newItem.selectedsize = 'nosize';
                                    }

                                    String item = jsonEncode(newItem);

                                    prefs.setStringList('cartitems', [item]);
                                    showInSnackBar(
                                        newItem.name + ' added to Cart!');
                                  } else {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Oops',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          content: Text(
                                            'You have an item in your cart already.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w200),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                'Add to Cart',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              onPressed: () async {
                                                newItem.quantity = 1;

                                                if (selectedSize != null) {
                                                  newItem.selectedsize =
                                                      selectedSize.toString();
                                                } else {
                                                  newItem.selectedsize =
                                                      'nosize';
                                                }

                                                String item =
                                                    jsonEncode(newItem);

                                                prefs.setStringList(
                                                    'cartitems', [item]);
                                                showInSnackBar(newItem.name +
                                                    ' added to Cart!');
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                'Close',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
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
                                            'You need to login to add to cart!',
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
                                            checkuser();
                                          },
                                        ));
                              }
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width - 50,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        offset: const Offset(0.0, 0.8),
                                        blurRadius: 5.0),
                                  ],
                                ),
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10, right: 10, top: 10),
                                  child: Center(
                                    child: Text(
                                      'Add to Cart',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Helvetica',
                                        letterSpacing: 0.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )))
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
                                    color: Colors.black,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black12,
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
                      )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white.withOpacity(0.8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditItem(
                                    itemid: newItem.itemid,
                                    itemname: newItem.name,
                                  )),
                        );
                      },
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
                                  color: Colors.deepOrangeAccent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Edit Item',
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
            : Container());
  }
}

class ImageDisplay extends StatefulWidget {
  final List<String> image;
  final String itemname;
  ImageDisplay({Key key, this.image, this.itemname}) : super(key: key);
  @override
  ImageDisplayState createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
  var inde = 0;
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.itemname,
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
          child: Stack(children: [
            PageView.builder(
                itemCount: widget.image.length,
                onPageChanged: (index) {
                  print(index);
                  setState(() {
                    inde = index;
                  });
                },
                itemBuilder: (BuildContext ctxt, int index) {
                  return InteractiveViewer(
                      panEnabled: false,
                      boundaryMargin: EdgeInsets.all(10),
                      minScale: 0.5,
                      maxScale: 2,
                      child: CachedNetworkImage(
                        imageUrl: widget.image[index],
                        height: MediaQuery.of(context).size.height,
                        placeholder: (context, url) =>
                            SpinKitDoubleBounce(color: Colors.deepOrange),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                      ));
                }),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.image.map((url) {
                  _current = widget.image.indexOf(url);
                  return Padding(
                      padding: EdgeInsets.all(5),
                      child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.grey.withOpacity(0.3),
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
          ]),
        ));
  }
}
