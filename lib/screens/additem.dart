import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AddItem extends StatefulWidget {
  AddItem({Key key}) : super(key: key);

  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  GoogleMapController controller;
  LatLng _lastMapPosition;

  Set<Marker> _markers = Set();

  final businessnameController = TextEditingController();
  final businessdescriptionController = TextEditingController();
  final businesspricecontroller = TextEditingController();
  List<String> categories = [
    'Electronics',
    'Fashion & Accessories',
    'Home & Garden',
    'Baby & Child',
    'Sport & Leisure',
    'Movies, Books & Music',
    'Motors',
    'Property',
    'Services',
    'Other'
  ];
  String _selectedCategory;

  String _selectedsubCategory;
  String _selectedsubsubCategory;
  List<String> _subcategories = [];

  LatLng position;
  String city;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    readstorage();
    super.initState();
  }

  void readstorage() async {
    var latitude = await storage.read(key: 'latitude');
    var longitude = await storage.read(key: 'longitude');
    var cit = await storage.read(key: 'city');

    setState(() {
      position = LatLng(double.parse(latitude), double.parse(longitude));
      city = cit;
    });
  }

  File _image;
  List<String> _subsubcategory;

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      _image = image;
    });
  }

  @override
  void dispose() {
    businessdescriptionController.dispose();
    businessnameController.dispose();
    businesspricecontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Add an Item",
            style: TextStyle(
                color: Color(0xFF323643),
                fontSize: 20.0,
                fontWeight: FontWeight.w700),
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFFC5CCD6)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width - 40,
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10)),
                          height: 120,
                          width: 120,
                          child: _image == null
                              ? Icon(Icons.add)
                              : Image.file(
                                  _image,
                                  fit: BoxFit.cover,
                                )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton(
                    hint: Text(
                        'Please choose a category'), // Not necessary for Option 1
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        _selectedsubCategory = null;
                        _subcategories = [''];
                      });

                      if (_selectedCategory == 'Electronics') {
                        setState(() {
                          _subcategories = [
                            'Phones & Accessories',
                            'Gaming',
                            'Cameras & Photography',
                            'Car Technology',
                            'Computers,PCs & Laptops',
                            'Drones',
                            'Home Appliances',
                            'Smart Home & Security',
                            'Sound & Audio',
                            'Tablets & eReaders',
                            'TV & Video',
                            'Wearables',
                            'Virtual Reality',
                          ];
                        });
                      } else if (_selectedCategory == 'Fashion & Accessories') {
                        setState(() {
                          _subcategories = [
                            'Women',
                            'Men',
                            'Girls',
                            'Boys',
                          ];
                        });
                      } else if (_selectedCategory == 'Motors') {
                        setState(() {
                          _subcategories = ['Cars', 'Motorcycles & Scooters'];
                        });
                      } else if (_selectedCategory == 'Property') {
                        setState(() {
                          _subcategories = [
                            'Property for Sale',
                            'Property for Rent',
                          ];
                        });
                      }
                    },
                    items: categories.map((location) {
                      return DropdownMenuItem(
                        child: new Text(location),
                        value: location,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 2.0,
                ),
                _selectedCategory == null
                    ? Container()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton(
                          hint: Text(
                              'Please choose a sub category'), // Not necessary for Option 1
                          value: _selectedsubCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedsubCategory = newValue;
                            });
                            if (_selectedsubCategory == 'Women') {
                              setState(() {
                                _subsubcategory = [
                                  'Shoes & Boots',
                                  'Activewear & Sportswear',
                                  'Dresses',
                                  'Tops',
                                  'Coats & Jackets',
                                  'Jumpers & Cardigans',
                                  'Bags & Accessories',
                                  'Leggings',
                                  'Jumpsuits & Playsuits',
                                  'Lingerie',
                                  'Nightwear',
                                  'Loungewear',
                                  'Hoodies & Sweatshirts',
                                  'Jeans',
                                  'Suits & Blazers',
                                  'Swimwear & Beachwear',
                                  'Shorts',
                                  'Skirts',
                                  'Other',
                                ];
                              });
                            } else if (_selectedsubCategory == 'Men') {
                              setState(() {
                                _subsubcategory = [
                                  'Shoes & Boots',
                                  'Activewear & Sportswear',
                                  'Polo Shirts',
                                  'Shirts',
                                  'T- Shirts & Vests',
                                  'Coats & Jackets',
                                  'Jumpers & Cardigans',
                                  'Bags & Accessories',
                                  'Trousers',
                                  'Chinos',
                                  'Jumpsuits & Playsuits',
                                  'Nightwear',
                                  'Loungewear',
                                  'Hoodies & Sweatshirts',
                                  'Jeans',
                                  'Suits & Blazers',
                                  'Swimwear & Beachwear',
                                  'Shorts',
                                  'Other',
                                ];
                              });
                            } else if (_selectedsubCategory == 'Girls') {
                              setState(() {
                                _subsubcategory = [
                                  'Shoes & Boots',
                                  'Activewear & Sportswear',
                                  'Dresses',
                                  'Tops',
                                  'Coats & Jackets',
                                  'Jumpers & Cardigans',
                                  'Bags & Accessories',
                                  'Leggings',
                                  'Jumpsuits & Playsuits',
                                  'Lingerie',
                                  'Nightwear',
                                  'Loungewear',
                                  'Hoodies & Sweatshirts',
                                  'Jeans',
                                  'Suits & Blazers',
                                  'Swimwear & Beachwear',
                                  'Skirts',
                                  'Other',
                                ];
                              });
                            } else if (_selectedsubCategory == 'Boys') {
                              setState(() {
                                _subsubcategory = [
                                  'Shoes & Boots',
                                  'Activewear & Sportswear',
                                  'Polo Shirts',
                                  'Shirts',
                                  'T- Shirts & Vests',
                                  'Coats & Jackets',
                                  'Jumpers & Cardigans',
                                  'Bags & Accessories',
                                  'Trousers',
                                  'Chinos',
                                  'Jumpsuits & Playsuits',
                                  'Nightwear',
                                  'Loungewear',
                                  'Hoodies & Sweatshirts',
                                  'Jeans',
                                  'Suits & Blazers',
                                  'Swimwear & Beachwear',
                                  'Shorts',
                                  'Other',
                                ];
                              });
                            }
                          },
                          items: _subcategories.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
                            );
                          }).toList(),
                        ),
                      ),
                _subsubcategory == null
                    ? Container()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton(
                          hint: Text(
                              'Please choose a sub category'), // Not necessary for Option 1
                          value: _selectedsubsubCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedsubsubCategory = newValue;
                            });
                          },
                          items: _subsubcategory.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
                            );
                          }).toList(),
                        ),
                      ),
                TextField(
                  cursorColor: Color(0xFF979797),
                  controller: businessnameController,
                  decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      focusColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797)))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  cursorColor: Color(0xFF979797),
                  controller: businessdescriptionController,
                  maxLines: 5,
                  maxLength: 1000,
                  decoration: InputDecoration(
                      labelText: "Description",
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      focusColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797)))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextField(
                  cursorColor: Color(0xFF979797),
                  controller: businesspricecontroller,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      labelText: "Price AED",
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      focusColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF979797)))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text('Item Location'),
                SizedBox(
                  height: 10.0,
                ),
                position != null
                    ? Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: position, zoom: 18.0, bearing: 70),
                          onMapCreated: mapCreated,
                          onCameraMove: _onCameraMove,
                          onTap: _handleTap,
                          markers: _markers,
                          zoomGesturesEnabled: true,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          compassEnabled: true,
                          tiltGesturesEnabled: false,
                        ),
                      )
                    : Text('Oops! Something went wrong. \n Please try again'),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Thank you for helping us grow!",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          userid = await storage.read(key: 'userid');
          print(userid);
          if (userid != null) {
            var userurl = 'https://sellship.co/api/user/' + userid;
            final userresponse = await http.get(userurl);
            if (userresponse.statusCode == 200) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0)), //this right here
                      child: Container(
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Loading'),
                              SizedBox(
                                height: 10,
                              ),
                              CircularProgressIndicator()
                            ],
                          ),
                        ),
                      ),
                    );
                  });

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

            if (phonenumber == null || email == null) {
              showInSnackBar('Please update your Phone Number and Email');
            } else {
              String fileName = _image.path.split('/').last;
              var url = 'https://sellship.co/api/additem';

              Dio dio = new Dio();

              if (businessnameController.text.isNotEmpty) {
                FormData formData = FormData.fromMap({
                  'name': businessnameController.text,
                  'price': businesspricecontroller.text,
                  'category': _selectedCategory,
                  'subcategory':
                      _selectedsubCategory == null ? '' : _selectedsubCategory,
                  'subsubcategory': _selectedsubsubCategory == null
                      ? ''
                      : _selectedsubsubCategory,
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'description': businessdescriptionController.text,
                  'city': city,
                  'userid': userid,
                  'username': firstname,
                  'useremail': email,
                  'usernumber': phonenumber,
                  'date_uploaded': DateTime.now().toString(),
                  'image': await MultipartFile.fromFile(_image.path,
                      filename: fileName)
                });

                var response = await dio.post(url, data: formData);
                if (response.statusCode == 200) {
                  Navigator.pop(context);

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
                                  fontSize: 22.0, fontWeight: FontWeight.w600),
                            ),
                            description: Text(
                              'Your Item\'s Uploaded',
                              textAlign: TextAlign.center,
                              style: TextStyle(),
                            ),
                            onlyOkButton: true,
                            entryAnimation: EntryAnimation.DEFAULT,
                            onOkButtonPressed: () {
                              Navigator.pop(context);
                            },
                          ));
                } else {
                  print(response.statusCode);
                }
              }
            }
          } else {
            showInSnackBar('Please Login to use Favourites');
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 48,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.amberAccent, Colors.amber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(6.0),
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
                  color: Color(0xFFFBFBFB),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  _handleTap(LatLng point) {
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
        print(_lastMapPosition);
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
