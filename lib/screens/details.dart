import 'dart:convert';
import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sellship/models/Items.dart';
import 'package:http/http.dart' as http;
import 'package:sellship/screens/useritems.dart';
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
              backgroundColor: Colors.white,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
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
                    Text(
                      newItem.name,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          newItem.category,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          newItem.price + ' AED',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      newItem.description,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        // rounded corners ad.
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: AdmobBanner(
                          adUnitId: getBannerAdUnitId(),
                          adSize: AdmobBannerSize.LARGE_BANNER,
                        ),
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
                            style: TextStyle(color: Colors.white),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        // rounded corners ad.
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: AdmobBanner(
                          adUnitId: getBannerAdUnitId(),
                          adSize: AdmobBannerSize.LARGE_BANNER,
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
                          await launch(appleMapsUrl, forceSafariVC: false);
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
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            ),
            bottomNavigationBar: Row(
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
                    width: MediaQuery.of(context).size.width / 2,
                    height: 80,
                    color: Colors.amber,
                    child: Center(
                      child: Text(
                        "Call",
                        style: TextStyle(
                            color: Color(0xFFFBFBFB),
                            fontSize: 14.0,
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
                    width: MediaQuery.of(context).size.width / 2,
                    height: 80,
                    color: Colors.amber,
                    child: Center(
                      child: Text(
                        "SMS",
                        style: TextStyle(
                            color: Color(0xFFFBFBFB),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ))
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
        title: Text('sd'),
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
