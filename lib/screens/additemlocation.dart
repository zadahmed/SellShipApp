import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:location/location.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:shimmer/shimmer.dart';

class AddItemLocation extends StatefulWidget {
  final File image;
  final File image2;
  final File image3;
  final File image4;
  final File image5;
  final String userid;
  final String price;
  final File image6;
  final String itemname;
  final String brand;
  final String category;
  final String subcategory;
  final String subsubcategory;
  final String description;
  final String condition;
  final String size;

  AddItemLocation(
      {Key key,
      this.image,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.price,
      this.brand,
      this.userid,
      this.description,
      this.size,
      this.condition,
      this.category,
      this.subcategory,
      this.subsubcategory,
      this.itemname})
      : super(key: key);

  _AddItemLocationState createState() => _AddItemLocationState();
}

class _AddItemLocationState extends State<AddItemLocation> {
  GoogleMapController controller;
  LatLng _lastMapPosition;

  Set<Marker> _markers = Set();

  String _selectedCategory;

  String _selectedCondition;

  String _selectedsubCategory;
  String _selectedsubsubCategory;
  String _selectedbrand;

  LatLng position;
  String city;
  String country;
  String price;
  String itemname;
  String description;
  String size;

  final storage = new FlutterSecureStorage();

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
            fontFamily: 'SF',
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RootScreen()),
        );
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continue",
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Cancel Item Upload?",
        style: TextStyle(
            fontFamily: 'SF',
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Would you like to cancel uploading your item?",
        style: TextStyle(
          fontFamily: 'SF',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    readstorage();
    setState(() {
      loading = true;
      _image = widget.image;
      _image2 = widget.image2;
      _image3 = widget.image3;
      _image4 = widget.image4;
      _image5 = widget.image5;
      _image6 = widget.image6;
      price = widget.price;
      userid = widget.userid;
      itemname = widget.itemname;
      _selectedbrand = widget.brand;
      _selectedCategory = widget.category;
      _selectedsubCategory = widget.subcategory;
      _selectedsubsubCategory = widget.subsubcategory;
      _selectedCondition = widget.condition;
      description = widget.description;
      size = widget.size;
    });
    super.initState();
  }

  var currency;
  bool loading;

  bool meetupcheckbox = false;
  bool shippingcheckbox = false;

  void readstorage() async {
    var countr = await storage.read(key: 'country');

    if (countr.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
      });
    }

    userid = await storage.read(key: 'userid');

    Location _location = new Location();

    var location = await _location.getLocation();
    if (location == null) {
      _location.requestPermission();
      readstorage();
    } else {
      var positio =
          LatLng(location.latitude.toDouble(), location.longitude.toDouble());

      setState(() {
        loading = false;
        position = positio;
      });
    }
  }

  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Delivery Information",
              style: TextStyle(
                fontFamily: 'SF',
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.deepOrange),
          actions: <Widget>[
            InkWell(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'X',
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              onTap: () {
                showAlertDialog(context);
              },
            ),
          ],
        ),
        body: loading == false
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, bottom: 10, top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Delivery Method',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Column(children: <Widget>[
                                CheckboxListTile(
                                  title: const Text('Meetup'),
                                  value: meetupcheckbox,
                                  onChanged: (bool value) {
                                    setState(() {
                                      meetupcheckbox = value;
                                    });
                                  },
                                  secondary:
                                      const Icon(FontAwesome.handshake_o),
                                ),
                                CheckboxListTile(
                                  title: const Text('Shipping Included'),
                                  value: shippingcheckbox,
                                  onChanged: (bool value) {
                                    setState(() {
                                      shippingcheckbox = value;
                                    });
                                  },
                                  secondary: const Icon(Icons.local_shipping),
                                ),
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              bottom: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Item Location',
                                style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                            height: 390,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  'Press on the map to choose the Item\'s location',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Stack(
                                  children: <Widget>[
                                    position != null
                                        ? Container(
                                            height: 355,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target: position,
                                                      zoom: 18.0,
                                                      bearing: 70),
                                              onMapCreated: mapCreated,
                                              onCameraMove: _onCameraMove,
                                              onTap: _handleTap,
                                              markers: _markers,
                                              zoomGesturesEnabled: true,
                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: true,
                                              compassEnabled: true,
                                              gestureRecognizers: Set()
                                                ..add(Factory<
                                                        EagerGestureRecognizer>(
                                                    () =>
                                                        EagerGestureRecognizer())),
                                            ),
                                          )
                                        : Text(
                                            'Oops! Something went wrong. \n Please try again',
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 16,
                                            ),
                                          ),
                                    Positioned(
                                      top: 10,
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                      child: SearchMapPlaceWidget(
                                        apiKey:
                                            'AIzaSyAL0gczX37-cNVHC_4aV6lWE3RSNqeamf4',
                                        // The language of the autocompletion
                                        language: 'en',
                                        location: position,
                                        radius: 10000,
                                        onSelected: (Place place) async {
                                          final geolocation =
                                              await place.geolocation;

                                          controller.animateCamera(
                                              CameraUpdate.newLatLng(
                                                  geolocation.coordinates));
                                          controller.animateCamera(
                                              CameraUpdate.newLatLngBounds(
                                                  geolocation.bounds, 0));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Thank you for helping us grow!",
                            style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Column(
                    children: [0, 1, 2, 3, 4, 5, 6]
                        .map((_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
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
                            ))
                        .toList(),
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: () async {
                var userurl = 'https://api.sellship.co/api/user/' + userid;
                final userresponse = await http.get(userurl);
                if (userresponse.statusCode == 200) {
                  var userrespons = json.decode(userresponse.body);
                  var profilemap = userrespons;
                  print(profilemap);
                  if (mounted) {
                    setState(() {
                      firstname = profilemap['first_name'];
                      phonenumber = profilemap['phonenumber'];
                      email = profilemap['email'];
                    });
                  }
                }

                if (meetupcheckbox == false && shippingcheckbox == false) {
                  showInSnackBar(
                      'Please choose a checkbox for delivery method!');
                } else if (city == null) {
                  showInSnackBar('Please choose the location of your item!');
                } else {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0)), //this right here
                          child: Container(
                            height: 100,
                            child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SpinKitChasingDots(
                                    color: Colors.deepOrange)),
                          ),
                        );
                      });

                  var url = 'https://api.sellship.co/api/additem';

                  Dio dio = new Dio();
                  FormData formData;
                  if (_image != null) {
                    String fileName = _image.path.split('/').last;
                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'originalprice': '',
                      'category': _selectedCategory,
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'description': description,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'city': city.trim(),
                      'country': country.trim(),
                      'condition': _selectedCondition,
                      'brand': _selectedbrand,
                      'size': size,
                      'userid': userid,
                      'username': firstname,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName)
                    });
                  }
                  if (_image != null && _image2 != null) {
                    String fileName = _image.path.split('/').last;
                    String fileName2 = _image2.path.split('/').last;
                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'originalprice': '',
                      'category': _selectedCategory,
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'description': description,
                      'city': city.trim(),
                      'condition': _selectedCondition,
                      'userid': userid,
                      'brand': _selectedbrand,
                      'size': size,
                      'country': country.trim(),
                      'username': firstname,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName),
                      'image2': await MultipartFile.fromFile(_image2.path,
                          filename: fileName2),
                    });
                  }
                  if (_image != null && _image2 != null && _image3 != null) {
                    String fileName = _image.path.split('/').last;
                    String fileName2 = _image2.path.split('/').last;
                    String fileName3 = _image3.path.split('/').last;

                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'category': _selectedCategory,
                      'originalprice': '',
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'description': description,
                      'city': city.trim(),
                      'condition': _selectedCondition,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'brand': _selectedbrand,
                      'size': size,
                      'userid': userid,
                      'country': country.trim(),
                      'username': firstname,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName),
                      'image2': await MultipartFile.fromFile(_image2.path,
                          filename: fileName2),
                      'image3': await MultipartFile.fromFile(_image3.path,
                          filename: fileName3),
                    });
                  }
                  if (_image != null &&
                      _image2 != null &&
                      _image3 != null &&
                      _image4 != null) {
                    String fileName = _image.path.split('/').last;
                    String fileName2 = _image2.path.split('/').last;
                    String fileName3 = _image3.path.split('/').last;
                    String fileName4 = _image4.path.split('/').last;

                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'category': _selectedCategory,
                      'originalprice': '',
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'description': description,
                      'city': city.trim(),
                      'userid': userid,
                      'condition': _selectedCondition,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'brand': _selectedbrand,
                      'size': size,
                      'country': country.trim(),
                      'username': firstname,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName),
                      'image2': await MultipartFile.fromFile(_image2.path,
                          filename: fileName2),
                      'image3': await MultipartFile.fromFile(_image3.path,
                          filename: fileName3),
                      'image4': await MultipartFile.fromFile(_image4.path,
                          filename: fileName4),
                    });
                  }
                  if (_image != null &&
                      _image2 != null &&
                      _image3 != null &&
                      _image4 != null &&
                      _image5 != null) {
                    String fileName = _image.path.split('/').last;
                    String fileName2 = _image2.path.split('/').last;
                    String fileName3 = _image3.path.split('/').last;
                    String fileName4 = _image4.path.split('/').last;
                    String fileName5 = _image5.path.split('/').last;

                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'category': _selectedCategory,
                      'originalprice': '',
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'description': description,
                      'city': city.trim(),
                      'country': country.trim(),
                      'brand': _selectedbrand,
                      'size': size,
                      'condition': _selectedCondition,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'userid': userid,
                      'username': firstname,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName),
                      'image2': await MultipartFile.fromFile(_image2.path,
                          filename: fileName2),
                      'image3': await MultipartFile.fromFile(_image3.path,
                          filename: fileName3),
                      'image4': await MultipartFile.fromFile(_image4.path,
                          filename: fileName4),
                      'image5': await MultipartFile.fromFile(_image5.path,
                          filename: fileName5),
                    });
                  }
                  if (_image != null &&
                      _image2 != null &&
                      _image3 != null &&
                      _image4 != null &&
                      _image5 != null &&
                      _image6 != null) {
                    String fileName = _image.path.split('/').last;
                    String fileName2 = _image2.path.split('/').last;
                    String fileName3 = _image3.path.split('/').last;
                    String fileName4 = _image4.path.split('/').last;
                    String fileName5 = _image5.path.split('/').last;
                    String fileName6 = _image6.path.split('/').last;
                    formData = FormData.fromMap({
                      'name': itemname,
                      'price': price,
                      'category': _selectedCategory,
                      'originalprice': '',
                      'subcategory': _selectedsubCategory,
                      'subsubcategory': _selectedsubsubCategory,
                      'latitude': _lastMapPosition.latitude,
                      'longitude': _lastMapPosition.longitude,
                      'description': description,
                      'city': city.trim(),
                      'userid': userid,
                      'country': country.trim(),
                      'username': firstname,
                      'meetup': meetupcheckbox,
                      'shipping': shippingcheckbox,
                      'brand': _selectedbrand,
                      'size': size,
                      'condition': _selectedCondition,
                      'useremail': email,
                      'usernumber': phonenumber,
                      'date_uploaded': DateTime.now().toString(),
                      'image': await MultipartFile.fromFile(_image.path,
                          filename: fileName),
                      'image2': await MultipartFile.fromFile(_image2.path,
                          filename: fileName2),
                      'image3': await MultipartFile.fromFile(_image3.path,
                          filename: fileName3),
                      'image4': await MultipartFile.fromFile(_image4.path,
                          filename: fileName4),
                      'image5': await MultipartFile.fromFile(_image5.path,
                          filename: fileName5),
                      'image6': await MultipartFile.fromFile(_image6.path,
                          filename: fileName6),
                    });
                  }

                  var response = await dio.post(url, data: formData);

                  if (response.statusCode == 200) {
                    showDialog(
                        context: context,
                        builder: (_) => AssetGiffyDialog(
                              image: Image.asset(
                                'assets/yay.gif',
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                'Hooray!',
                                style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600),
                              ),
                              description: Text(
                                'Your Item\'s Uploaded',
                                textAlign: TextAlign.center,
                                style: TextStyle(),
                              ),
                              onlyOkButton: true,
                              entryAnimation: EntryAnimation.DEFAULT,
                              onOkButtonPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RootScreen()),
                                );
                              },
                            ));
                  } else {
                    showInSnackBar('Looks like something went wrong!');
                  }
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 48,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.deepOrangeAccent, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF9DA3B4).withOpacity(0.1),
                          blurRadius: 65.0,
                          offset: Offset(0.0, 15.0))
                    ]),
                child: Center(
                  child: Text(
                    "Add an Item",
                    style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )));
  }

  final Geolocator geolocator = Geolocator();

  _handleTap(LatLng point) async {
    if (_markers.isNotEmpty) {
      _markers.remove(_markers.last);
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Location of Item',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        _lastMapPosition = point;
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _lastMapPosition.latitude, _lastMapPosition.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      setState(() {
        city = cit;
        country = countr;
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Location of Item',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        _lastMapPosition = point;
        print(_lastMapPosition);
      });
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _lastMapPosition.latitude, _lastMapPosition.longitude);
      Placemark place = p[0];
      var cit = place.administrativeArea;
      var countr = place.country;
      setState(() {
        city = cit;
        country = countr;
      });
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
          fontFamily: 'SF',
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  String userid;

  var firstname;
  var email;
  var phonenumber;

  void mapCreated(GoogleMapController controlle) {
    setState(() {
      controller = controlle;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastMapPosition = position.target;
    });
  }
}
