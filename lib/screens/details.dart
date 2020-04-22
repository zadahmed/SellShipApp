import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/useritems.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {
  final String itemid;
  Details({Key key, this.itemid}) : super(key: key);
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

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      itemid = widget.itemid;
      heartColor = Colors.grey;
      heartIcon = FontAwesome5.heart;
    });
    fetchItem();
  }

  Set<Marker> _markers = Set();

  GoogleMapController controller;

  void mapCreated(GoogleMapController controlle) {
    setState(() {
      controller = controlle;
    });
  }

  var currency;

  List<String> images = [];
  fetchItem() async {
    var country = await storage.read(key: 'country');

    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
      });
    }

    var url = 'https://sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);
    print(jsonbody);
    newItem = Item(
        name: jsonbody[0]['name'],
        price: jsonbody[0]['price'],
        description: jsonbody[0]['description'],
        category: jsonbody[0]['category'],
        image: jsonbody[0]['image'],
        image1: jsonbody[0]['image1'],
        image2: jsonbody[0]['image2'],
        image3: jsonbody[0]['image3'],
        image4: jsonbody[0]['image4'],
        image5: jsonbody[0]['image5'],
        username: jsonbody[0]['username'],
        useremail: jsonbody[0]['useremail'],
        usernumber: jsonbody[0]['usernumber'],
        userid: jsonbody[0]['userid'],
        latitude: jsonbody[0]['latitude'],
        longitude: jsonbody[0]['longitude'],
        subsubcategory: jsonbody[0]['subsubcategory'],
        subcategory: jsonbody[0]['subcategory']);

    setState(() {
      position = LatLng(
          double.parse(newItem.latitude), double.parse(newItem.longitude));
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
          title: newItem.name,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
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
    print(images.length);
    return newItem;
  }

  final storage = new FlutterSecureStorage();
  var userid;

  void FavouriteItem() async {
    userid = await storage.read(key: 'userid');
    print(userid);
    if (userid != null) {
      var url = 'https://sellship.co/api/favourite/' + userid;

      Map<String, String> body = {
        'itemid': itemid,
      };

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print(jsondata);
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
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
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

  Color heartColor;
  IconData heartIcon;

  @override
  Widget build(BuildContext context) {
    return loading == false
        ? Scaffold(
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                new MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView(
//                  padding: EdgeInsets.symmetric(horizontal: 10),
                      children: <Widget>[
                        Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Stack(
                            children: <Widget>[
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (BuildContext ctxt, int Index) {
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
                                                        image: images[Index])));
                                      },
                                      child: Hero(
                                        tag: images[Index],
                                        child: Image.network(
                                          images[Index],
                                          height: 300,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    );
                                  }),
                              Positioned(
                                  right: 10.0,
                                  bottom: 5.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        images.length.toString() + '/6',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      newItem.name,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    width: 250,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    newItem.category,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    newItem.price.toString() + ' ' + currency,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    heartColor = Colors.deepOrange;
                                    heartIcon = FontAwesome.heart;
                                  });
                                  FavouriteItem();
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
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    heartIcon,
                                    color: heartColor,
                                    size: 17,
                                  ),
                                ),
                              ),
//                              RawMaterialButton(
//                                onPressed: () {
//
//                                },
//                                fillColor: Colors.white,
//                                shape: CircleBorder(),
//                                elevation: 4.0,
//                                child: Icon(
//                                  heartIcon,
//                                  color: heartColor,
//                                  size: 17,
//                                ),
//                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserItems(
                                      userid: newItem.userid,
                                      username: newItem.username)),
                            );
                          },
                          child: Container(
                            height: 70,
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
                            child: Center(
                              child: ListTile(
                                title: Text(
                                  newItem.username,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                leading: Icon(
                                  FontAwesome5.user_circle,
                                  color: Colors.deepOrange,
                                  size: 24,
                                ),
                                trailing: Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    Feather.arrow_right_circle,
                                    size: 20,
                                    color: Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
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
                        SizedBox(height: 5),
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
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Center(
                                  child: Text(
                                    'Description',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                flex: 1,
                                child: new SingleChildScrollView(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                      newItem.description,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                            padding: EdgeInsets.only(bottom: 15, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    final String telephone =
                                        'tel:' + newItem.usernumber;
                                    if (await canLaunch(telephone)) {
                                      await launch(telephone);
                                    } else {
                                      throw 'Could not launch $telephone';
                                    }
                                  },
                                  child: Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          20,
                                      height: 65,
                                      decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Feather.phone_call,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Center(
                                            child: Text(
                                              "Call",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                InkWell(
                                  onTap: () async {
                                    final String telephone =
                                        'sms:' + newItem.usernumber;
                                    if (await canLaunch(telephone)) {
                                      await launch(telephone);
                                    } else {
                                      throw 'Could not launch $telephone';
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    height: 65,
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Feather.smartphone,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "SMS",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ]),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 10),
                        Container(
                          height: 260,
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
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Center(
                                  child: Text(
                                    'Location of Item',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                      target: position,
                                      zoom: 18.0,
                                      bearing: 70),
                                  onMapCreated: mapCreated,
                                  markers: _markers,
                                  onTap: (LatLng) async {
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
                          height: 20,
                        ),
                        Platform.isIOS == true
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
                              ),
                        SizedBox(height: 10),
                      ],
                    ))
              ],
            ),
            bottomNavigationBar: Container(
              height: 60,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0)), //this right here
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child:
                                  SpinKitChasingDots(color: Colors.deepOrange),
                            ),
                          ),
                        );
                      });
                  userid = await storage.read(key: 'userid');
                  var senderid = newItem.userid;
                  if (senderid != userid) {
                    var userurl = 'https://sellship.co/api/username/' + userid;
                    final responseuser = await http.get(userurl);

                    if (responseuser.statusCode == 200) {
                      var username1 = responseuser.body;
                      var userurl2 =
                          'https://sellship.co/api/username/' + senderid;
                      final responseuser2 = await http.get(userurl2);
                      if (responseuser2.statusCode == 200) {
                        var username2 = responseuser2.body;

                        var checkurl =
                            'https://sellship.co/api/checkmessageexist/' +
                                userid +
                                '/' +
                                senderid;
                        final responsecheckurl = await http.get(checkurl);
                        if (responsecheckurl.statusCode == 200) {
                          var message = json.decode(responsecheckurl.body);
                          if (message['message'] != 'Empty') {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        ChatPageView(
                                            messageid: message['message'],
                                            recipentname: username2,
                                            senderid: userid,
                                            recipentid: senderid),
                              ),
                            );
                          } else {
                            var itemurl =
                                'https://sellship.co/api/createroom/' +
                                    userid +
                                    '/' +
                                    username1 +
                                    '/' +
                                    senderid +
                                    '/' +
                                    username2;
                            final itemresponse = await http.get(itemurl);
                            if (itemresponse.statusCode == 200) {
                              var messageid = itemresponse.body;
                              var url = 'https://sellship.co/api/sendmessage/' +
                                  userid +
                                  '/' +
                                  senderid +
                                  '/' +
                                  messageid;
                              await http.post(url, body: {
                                'message':
                                    'Hi there! I am quite interested in the item you\'ve put up for Sale! Could you tell me more about it please?',
                                'time': DateTime.now().toString()
                              });
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPageView(
                                      messageid: messageid,
                                      recipentname: username2,
                                      senderid: userid,
                                      recipentid: senderid),
                                ),
                              );
                            } else {
                              print(itemresponse.statusCode);
                            }
                          }
                        }
                      }
                    }
                  }
                  setState(() {
                    loading = false;
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 9, bottom: 9, left: 15, right: 15),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(25)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Feather.message_square,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Chat",
                            style: TextStyle(
                                color: Color(0xFFFBFBFB),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: Center(
                child: SpinKitChasingDots(color: Colors.deepOrangeAccent)));
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
        title: Text('Pictures'),
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
