import 'dart:convert';
import 'dart:io';
import 'package:SellShip/screens/additemlocation.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
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

class AddItemInfo extends StatefulWidget {
  final File image;
  final File image2;
  final File image3;
  final File image4;
  final File image5;
  final String userid;
  final String price;
  final File image6;
  final String itemname;

  AddItemInfo(
      {Key key,
      this.image,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.price,
      this.userid,
      this.itemname})
      : super(key: key);

  _AddItemInfoState createState() => _AddItemInfoState();
}

class _AddItemInfoState extends State<AddItemInfo> {
  final businessdescriptionController = TextEditingController();

  final businessbrandcontroller = TextEditingController();
  final businessizecontroller = TextEditingController();

  List<String> categories = [
    'Electronics',
    'Fashion & Accessories',
    'Beauty',
    'Home & Garden',
    'Baby & Child',
    'Sport & Leisure',
    'Books',
    'Motors',
    'Property',
    'Other'
  ];
  String _selectedCategory;

  List<String> conditions = [
    'New with tags',
    'New, but no tags',
    'Like new',
    'Very Good, a bit worn',
    'Good, some flaws visible in pictures'
  ];

  String _selectedCondition = 'Like new';

  String _selectedsubCategory;
  String _selectedsubsubCategory;
  String _selectedbrand;
  List<String> _subcategories;

  var price;
  var itemname;

  final storage = new FlutterSecureStorage();
  File _image;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  File _image6;

  @override
  void initState() {
    readstorage();
    setState(() {
      _image = widget.image;
      _image2 = widget.image2;
      _image3 = widget.image3;
      _image4 = widget.image4;
      _image5 = widget.image5;
      _image6 = widget.image6;
      price = widget.price;
      userid = widget.userid;
      itemname = widget.itemname;
    });
    super.initState();
  }

  var currency;

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
  }

  List<String> _subsubcategory;

  List<String> brands = List<String>();

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

  var brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Item Details",
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
          iconTheme: IconThemeData(color: Colors.deepOrange),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Product Detail',
                            style: TextStyle(
                                fontFamily: 'SF',
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
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
                        child: ListTile(
                          title: Text(
                            'Category',
                            style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                            width: 200,
                            padding: EdgeInsets.only(),
                            child: Center(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: DropdownButton(
                                  hint: Text(
                                    'Choose a category',
                                    style: TextStyle(
                                      fontFamily: 'SF',
                                      fontSize: 16,
                                    ),
                                  ), // Not necessary for Option 1
                                  value: _selectedCategory,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      _selectedCategory = newValue;
                                    });
                                    if (_selectedCategory == 'Electronics') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }
                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Phones & Accessories',
                                          'Gaming',
                                          'TV & Video',
                                          'Cameras & Photography',
                                          'Computers,PCs & Laptops',
                                          'Computer accessories',
                                          'Home Appliances',
                                          'Sound & Audio',
                                          'Tablets & eReaders',
                                          'Wearables',
                                          'Virtual Reality',
                                        ];
                                      });
                                    } else if (_selectedCategory ==
                                        'Fashion & Accessories') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Women',
                                          'Men',
                                          'Girls',
                                          'Boys',
                                          'Unisex',
                                        ];
                                      });
                                    } else if (_selectedCategory == 'Beauty') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Fragrance',
                                          'Perfume for men',
                                          'Perfume for women',
                                          'Makeup',
                                          'Haircare',
                                          'Skincare',
                                          'Tools and Accessories',
                                          'Mens grooming',
                                          'Gift sets',
                                        ];
                                      });
                                    } else if (_selectedCategory ==
                                        'Home & Garden') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Bedding',
                                          'Bath',
                                          'Home Decor',
                                          'Kitchen and Dining',
                                          'Home storage',
                                          'Furniture',
                                          'Garden & outdoor',
                                          'Lamps & Lighting',
                                          'Tools & Home improvement',
                                        ];
                                      });
                                    } else if (_selectedCategory ==
                                        'Baby & Child') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Kids toys',
                                          'Baby transport',
                                          'Nursing and feeding',
                                          'Bathing & Baby care',
                                          'Baby clothing & shoes',
                                          'Parenting Books',
                                        ];
                                      });
                                    } else if (_selectedCategory ==
                                        'Sport & Leisure') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Camping & Hiking',
                                          'Cycling',
                                          'Scooters & accessories',
                                          'Strength & weights',
                                          'Yoga',
                                          'Cardio equipment',
                                          'Water sports',
                                          'Raquet sports',
                                          'Boxing',
                                          'Other',
                                        ];
                                      });
                                    } else if (_selectedCategory == 'Books') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Childrens books',
                                          'Fiction books',
                                          'Comics',
                                          'Sports',
                                          'Science',
                                          'Diet, Health & Fitness',
                                          'Business & Finance',
                                          'Biogpraphy & Autobiography',
                                          'Crime & Mystery',
                                          'History',
                                          'Cook Books & Food',
                                          'Education',
                                          'Foreign Language Study',
                                          'Travel',
                                          'Magazine',
                                          'Other',
                                        ];
                                      });
                                    } else if (_selectedCategory == 'Motors') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'Used Cars',
                                          'Motorcycles & Scooters',
                                          'Heavy vehicles',
                                          'Boats',
                                          'Number plates',
                                          'Auto accessories',
                                          'Car Technology'
                                        ];
                                      });
                                    } else if (_selectedCategory ==
                                        'Property') {
                                      var categoryurl =
                                          'https://api.sellship.co/api/getbrands/' +
                                              _selectedCategory;
                                      final categoryresponse =
                                          await http.get(categoryurl);
                                      if (categoryresponse.statusCode == 200) {
                                        brands.clear();
                                        var categoryrespons =
                                            json.decode(categoryresponse.body);
                                        print(categoryrespons);
                                        for (int i = 0;
                                            i < categoryrespons.length;
                                            i++) {
                                          brands.add(categoryrespons[i]);
                                        }

                                        if (brands == null) {
                                          brands = [];
                                        }
                                        brands.add('Other');
                                        setState(() {
                                          brands = brands;
                                        });
                                      } else {
                                        print(categoryresponse.statusCode);
                                      }
                                      setState(() {
                                        _subcategories = [
                                          'For Sale \nHouses & Apartment',
                                          'For Rent \nHouses & Apartment',
                                          'For Rent \nShops & Offices',
                                          'Guest Houses',
                                        ];
                                      });
                                    } else {
                                      _subcategories = null;
                                    }
                                  },
                                  items: categories.map((location) {
                                    return DropdownMenuItem(
                                      child: new Text(
                                        location,
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ),
                                      value: location,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _subcategories == null
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Sub Category',
                                  style: TextStyle(
                                    fontFamily: 'SF',
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Container(
                                  width: 245,
                                  padding: EdgeInsets.only(),
                                  child: Center(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: DropdownButton(
                                        hint: Text(
                                          'Choose a sub category',
                                          style: TextStyle(
                                            fontFamily: 'SF',
                                            fontSize: 16,
                                          ),
                                        ), // Not necessary for Option 1
                                        value: _selectedsubCategory,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedsubCategory = newValue;
                                          });
                                          if (_selectedsubCategory == 'Women') {
                                            setState(() {
                                              _subsubcategory = [
                                                'Sneakers',
                                                'Flats',
                                                'Activewear & Sportswear',
                                                'Jewelry',
                                                'Dresses',
                                                'Tops',
                                                'Coats & Jackets',
                                                'Jumpers & Cardigans',
                                                'Bags',
                                                'Heels',
                                                'Sandals,slippers and flip-flops',
                                                'Boots',
                                                'Sports shoes',
                                                'Sunglasses',
                                                'Eye-wear',
                                                'Hair accessories',
                                                'Belts',
                                                'Watches',
                                                'Modest wear',
                                                'Jumpsuits & Playsuits',
                                                'Hoodies & Sweatshirts',
                                                'Jeans',
                                                'Suits & Blazers',
                                                'Swimwear & Beachwear',
                                                'Bottoms',
                                                'Skirts',
                                                'Other',
                                              ];
                                            });
                                          } else if (_selectedsubCategory ==
                                              'Men') {
                                            setState(() {
                                              _subsubcategory = [
                                                'Shoes & Boots',
                                                'Activewear & Sportswear',
                                                'Polo Shirts & T- Shirts',
                                                'Shirts',
                                                'Sneakers',
                                                'Loafers & slip-ons',
                                                'Formal shoes',
                                                'Sports shoes',
                                                'Coats & Jackets',
                                                'Jumpers & Cardigans',
                                                'Bags & Wallet',
                                                'Trousers',
                                                'Hair accessories',
                                                'Belts',
                                                'Eyewear',
                                                'Sunglasses',
                                                'Nightwear & Loungewear',
                                                'Hoodies & Sweatshirts',
                                                'Jeans',
                                                'Suits & Blazers',
                                                'Swimwear & Beachwear',
                                                'Shorts',
                                                'Other',
                                              ];
                                            });
                                          } else if (_selectedsubCategory ==
                                              'Girls') {
                                            setState(() {
                                              _subsubcategory = [
                                                'Bags',
                                                'Bottoms',
                                                'Dresses',
                                                'Tops and Tees',
                                                'Hats',
                                                'Accessories',
                                                'Jumpsuits',
                                                'Nightwear & Loungewear',
                                                'Socks',
                                                'Hoodies & Sweatshirts',
                                                'Swimwear & Beachwear'
                                              ];
                                            });
                                          } else if (_selectedsubCategory ==
                                              'Boys') {
                                            setState(() {
                                              _subsubcategory = [
                                                'Hats',
                                                'Hoodies & Sweatshirts',
                                                'Nightwear & Loungewear',
                                                'Bottoms',
                                                'Shirts & T-Shirts',
                                                'Socks',
                                                'Tops',
                                              ];
                                            });
                                          } else if (_selectedsubCategory ==
                                              'Unisex') {
                                            setState(() {
                                              _subsubcategory = [
                                                'Shoes & Boots',
                                                'Activewear & Sportswear',
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
                                            child: new Text(
                                              location,
                                              style: TextStyle(
                                                fontFamily: 'SF',
                                                fontSize: 16,
                                              ),
                                            ),
                                            value: location,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      _subsubcategory == null
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
//                                          boxShadow: [
//                                            BoxShadow(
//                                              color: Colors.grey.shade300,
//                                              offset: Offset(0.0, 1.0), //(x,y)
//                                              blurRadius: 6.0,
//                                            ),
//                                          ],
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(),
                                child: Center(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: DropdownButton(
                                      hint: Text(
                                        'Please choose a sub category',
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ), // Not necessary for Option 1
                                      value: _selectedsubsubCategory,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedsubsubCategory = newValue;
                                        });
                                      },
                                      items: _subsubcategory.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(
                                            location,
                                            style: TextStyle(
                                              fontFamily: 'SF',
                                              fontSize: 16,
                                            ),
                                          ),
                                          value: location,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
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
                        child: ListTile(
                          title: Text(
                            'Condition',
                            style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                              width: 200,
                              padding: EdgeInsets.only(),
                              child: Center(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: DropdownButton<String>(
                                        value: _selectedCondition,
                                        hint: Text(
                                            'Please choose the condition of your Item'), // No
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        iconSize: 20,
                                        elevation: 10,
                                        isExpanded: true,
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _selectedCondition = newValue;
                                          });
                                        },
                                        items: conditions
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'SF',
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                          );
                                        }).toList(),
                                      )))),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
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
                        child: TextField(
                          cursorColor: Color(0xFF979797),
                          controller: businessdescriptionController,
                          autocorrect: true,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 6,
//                                    maxLength: 1000,
                          decoration: InputDecoration(
                              labelText: "Description (optional)",
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(
                                fontFamily: 'SF',
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
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      brands.isNotEmpty || brands != null
                          ? Container(
                              height: 80,
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
                              child: Center(
                                  child: ListTile(
                                      title: Text(
                                        'Brand',
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: Container(
                                        width: 250,
                                        padding: EdgeInsets.only(),
                                        child: Center(
                                            child: InkWell(
                                          onTap: () {
                                            _scaffoldKey.currentState
                                                .showBottomSheet((context) {
                                              return Container(
                                                height: 500,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Feather.chevron_down),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          'Brand',
                                                          style: TextStyle(
                                                              fontFamily: 'SF',
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrange),
                                                        ),
                                                      ),
                                                      Flexible(
//                  height: 600,
                                                          child:
                                                              AlphabetListScrollView(
                                                        showPreview: true,
                                                        strList: brands,
                                                        indexedHeight: (i) {
                                                          return 40;
                                                        },
                                                        itemBuilder:
                                                            (context, index) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                brand = brands[
                                                                    index];
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: ListTile(
                                                              title: brands[
                                                                          index] !=
                                                                      null
                                                                  ? Text(brands[
                                                                      index])
                                                                  : Text('sd'),
                                                            ),
                                                          );
                                                        },
                                                      ))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                          child: brand != null
                                              ? Flex(
                                                  direction: Axis.horizontal,
                                                  children: [
                                                      Flexible(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(brand),
                                                          Icon(Icons
                                                              .arrow_drop_down)
                                                        ],
                                                      ))
                                                    ])
                                              : Container(
                                                  width: 120,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text('Choose Brand'),
                                                      Icon(
                                                          Icons.arrow_drop_down)
                                                    ],
                                                  )),
                                        )),
                                      ))))
                          : Container(),
                      brand == 'Other'
                          ? Container(
                              height: 80,
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
                              child: Center(
                                  child: ListTile(
                                      title: Text(
                                        'Other Brand Name',
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: Container(
                                          width: 200,
                                          padding: EdgeInsets.only(),
                                          child: Center(
                                            child: TextField(
                                              cursorColor: Color(0xFF979797),
                                              controller:
                                                  businessbrandcontroller,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              decoration: InputDecoration(
                                                  labelText: "Brand Name",
                                                  alignLabelWithHint: true,
                                                  labelStyle: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                  focusColor: Colors.black,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ))),
                                            ),
                                          )))))
                          : Container(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _selectedCategory == 'Fashion & Accessories'
                          ? Container(
                              height: 80,
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
                              child: Center(
                                  child: ListTile(
                                      title: Text(
                                        'Size',
                                        style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: Container(
                                          width: 200,
                                          padding: EdgeInsets.only(),
                                          child: Center(
                                            child: TextField(
                                              cursorColor: Color(0xFF979797),
                                              controller: businessizecontroller,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  labelText: "Size",
                                                  alignLabelWithHint: true,
                                                  labelStyle: TextStyle(
                                                    fontFamily: 'SF',
                                                    fontSize: 16,
                                                  ),
                                                  focusColor: Colors.black,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  )),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ))),
                                            ),
                                          )))))
                          : Container(),
                      SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
            )),
        bottomNavigationBar: userid != null
            ? Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () async {
                    if (businessdescriptionController.text.isEmpty) {
                      businessdescriptionController.text = '';
                    }

                    if (_selectedCategory == null) {
                      showInSnackBar('Please choose a category for your item!');
                    } else if (_selectedCondition == null) {
                      showInSnackBar(
                          'Please choose the condition of your item!');
                    } else if (brand == null) {
                      showInSnackBar('Please choose the brand for your item!');
                    } else {
                      String bran;
                      if (businessbrandcontroller != null) {
                        String brandcontrollertext =
                            businessbrandcontroller.text.trim();
                        if (brandcontrollertext.isNotEmpty) {
                          bran = businessbrandcontroller.text;
                        } else if (brand != null) {
                          bran = brand;
                        }
                      } else if (businessbrandcontroller == null) {
                        showInSnackBar('Please choose a brand for your item!');
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddItemLocation(
                                  image: _image,
                                  image2: _image2,
                                  image3: _image3,
                                  image4: _image4,
                                  image5: _image5,
                                  price: price,
                                  brand: bran,
                                  category: _selectedCategory,
                                  subcategory: _selectedsubCategory == null
                                      ? ''
                                      : _selectedsubCategory,
                                  subsubcategory:
                                      _selectedsubsubCategory == null
                                          ? ''
                                          : _selectedsubsubCategory,
                                  size: businessizecontroller.text == null
                                      ? ''
                                      : businessizecontroller.text,
                                  condition: _selectedCondition,
                                  description:
                                      businessdescriptionController.text,
                                  userid: userid,
                                  image6: _image6,
                                  itemname: itemname,
                                )),
                      );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.deepOrangeAccent,
                              Colors.deepOrange
                            ],
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
                        "Next ( Delivery Information )",
                        style: TextStyle(
                            fontFamily: 'SF',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ))
            : Text(''));
  }

  final Geolocator geolocator = Geolocator();

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
}
