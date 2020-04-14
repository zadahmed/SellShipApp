import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  fetchItem() async {
    var url = 'https://sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);
    print(jsonbody);
    newItem = Item(
        name: jsonbody[0]['name'],
        image: jsonbody[0]['image'],
        price: jsonbody[0]['price'],
        description: jsonbody[0]['description'],
        category: jsonbody[0]['category'],
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
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.amberAccent,
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
                new ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    SizedBox(height: 10),
                    Container(
                      height: 240,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context, _, __) =>
                                      ImageDisplay(image: newItem.image)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                newItem.image,
                                height: 240,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10.0,
                            bottom: 3.0,
                            child: RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  heartColor = Colors.amber;
                                  heartIcon = FontAwesome.heart;
                                });
                                FavouriteItem();
                              },
                              fillColor: Colors.white,
                              shape: CircleBorder(),
                              elevation: 4.0,
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  heartIcon,
                                  color: heartColor,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        newItem.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        newItem.category,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        newItem.price + ' AED',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 200,
                      color: Colors.white,
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
                                  fontSize: 20,
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
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  newItem.description,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                      child: Card(
                        color: Colors.amber,
                        child: ListTile(
                          title: Text(
                            newItem.username,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          leading: Icon(
                            Feather.user,
                            color: Colors.white,
                          ),
                          trailing: Text(
                            'View ${newItem.username}\'s items',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
                    Container(
                      height: 260,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Center(
                              child: Text(
                                'Location of Item',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final String googleMapsUrl =
                                  "comgooglemaps://?center=${position.latitude},${position.longitude}";
                              final String appleMapsUrl =
                                  "https://maps.apple.com/?q=${position.latitude},${position.longitude}";

                              if (await canLaunch(googleMapsUrl)) {
                                await launch(googleMapsUrl,
                                    forceSafariVC: true, forceWebView: true);
                              }
                              if (await canLaunch(appleMapsUrl)) {
                                await launch(appleMapsUrl,
                                    forceSafariVC: false);
                              } else {
                                throw "Couldn't launch URL";
                              }
                            },
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: position, zoom: 18.0, bearing: 70),
                                onMapCreated: mapCreated,
                                markers: _markers,
                              ),
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
                )
              ],
            ),
            bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        final String telephone = 'tel:' + newItem.usernumber;
                        if (await canLaunch(telephone)) {
                          await launch(telephone);
                        } else {
                          throw 'Could not launch $telephone';
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3 - 10,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Call",
                            style: TextStyle(
                                color: Color(0xFFFBFBFB),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        userid = await storage.read(key: 'userid');
                        var senderid = newItem.userid;

                        var userurl =
                            'https://sellship.co/api/username/' + userid;
                        final responseuser = await http.get(userurl);

                        if (responseuser.statusCode == 200) {
                          var username1 = responseuser.body;
                          var userurl2 =
                              'https://sellship.co/api/username/' + senderid;
                          final responseuser2 = await http.get(userurl2);
                          if (responseuser2.statusCode == 200) {
                            var username2 = responseuser2.body;

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
                              print(itemresponse.body);
                            } else {
                              print(itemresponse.statusCode);
                            }
                          }
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3 - 10,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Message",
                            style: TextStyle(
                                color: Color(0xFFFBFBFB),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final String telephone = 'sms:' + newItem.usernumber;
                        if (await canLaunch(telephone)) {
                          await launch(telephone);
                        } else {
                          throw 'Could not launch $telephone';
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3 - 10,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "SMS",
                            style: TextStyle(
                                color: Color(0xFFFBFBFB),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                )))
        : Scaffold(body: Center(child: CircularProgressIndicator()));
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
