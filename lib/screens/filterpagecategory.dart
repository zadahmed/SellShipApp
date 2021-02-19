import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class FilterPageCategory extends StatefulWidget {
  FilterPageCategory({Key key}) : super(key: key);
  @override
  FilterPageCategoryState createState() => FilterPageCategoryState();
}

class Subcategories {
  final String title;
  bool selected = false;

  Subcategories(this.title);
}

class FilterPageCategoryState extends State<FilterPageCategory> {
  List<String> categories = [
    'Electronics',
    'Women',
    'Men',
    'Beauty',
    'Home',
    'Toys',
    'Kids',
    'Sport & Leisure',
    'Handmade',
    'Books',
    'Other',
    'Garden',
    'Luxury',
    'Vintage',
  ];

  List<Subcategories> selectedsubcategory = List<Subcategories>();

  List<Subcategories> subcategorieselec = <Subcategories>[
    Subcategories('Phones & Accessories'),
    Subcategories('Gaming'),
    Subcategories('TV & Video'),
    Subcategories('Cameras & Photography'),
    Subcategories('Computers,PCs & Laptops'),
    Subcategories('Headphones & Mp3 Players'),
    Subcategories('Sound & Audio'),
    Subcategories('Tablets & eReaders'),
    Subcategories('Wearables'),
  ];

  List<Subcategories> subcategorieswome = <Subcategories>[
    Subcategories('Activewear & Sportswear'),
    Subcategories('Jewelry'),
    Subcategories('Dresses'),
    Subcategories('Tops & Blouses'),
    Subcategories('Coats & Jackets'),
    Subcategories('Sweaters'),
    Subcategories('Handbags'),
    Subcategories('Shoes'),
    Subcategories('Women\'s accessories'),
    Subcategories('Modest wear'),
    Subcategories('Jeans'),
    Subcategories('Suits & Blazers'),
    Subcategories('Swimwear & Beachwear'),
    Subcategories('Bottoms'),
  ];

  List<Subcategories> subcategoriesmen = <Subcategories>[
    Subcategories('Activewear & Sportswear'),
    Subcategories('Tops'),
    Subcategories('Shoes'),
    Subcategories('Coats & Jackets'),
    Subcategories('Men\'s accessories'),
    Subcategories('Bottoms'),
    Subcategories('Nightwear & Loungewear'),
    Subcategories('Hoodies & Sweatshirts'),
    Subcategories('Jeans'),
    Subcategories('Swimwear & Beachwear'),
  ];

  List<Subcategories> subcategoriesbeau = <Subcategories>[
    Subcategories('Fragrance'),
    Subcategories('Makeup'),
    Subcategories('Haircare'),
    Subcategories('Skincare'),
    Subcategories('Tools and Accessories'),
    Subcategories('Bath and Body'),
  ];

  List<Subcategories> subcategorieshome = <Subcategories>[
    Subcategories('Bath'),
    Subcategories('Home Decor'),
    Subcategories('Kitchen and Dining'),
    Subcategories('Storage and Organization'),
    Subcategories('Cleaning Supplies'),
    Subcategories('Furniture'),
    Subcategories('Artwork'),
    Subcategories('Home Appliances')
  ];

  List<Subcategories> subcategoriestoys = <Subcategories>[
    Subcategories('Collectibles & Hobbies'),
    Subcategories('Action Figures & Accessories'),
    Subcategories('Dolls & Accessories'),
    Subcategories('Vintage & Antique Toys'),
    Subcategories('Trading Cards'),
    Subcategories('Stuffed Animals'),
    Subcategories('Building Toys'),
    Subcategories('Arts & Crafts'),
    Subcategories('Games & Puzzles'),
    Subcategories('Remote Control Toys'),
  ];

  List<Subcategories> subcategorieskids = <Subcategories>[
    Subcategories('Girls Dresses'),
    Subcategories('Girls One-pieces'),
    Subcategories('Girls Tops & T-shirts'),
    Subcategories('Girls Bottoms'),
    Subcategories('Girls Shoes'),
    Subcategories('Girls Accessories'),
    Subcategories('Boys Tops & T-shirts'),
    Subcategories('Boys Bottoms'),
    Subcategories('Boys One-pieces'),
    Subcategories('Boys Accessories'),
    Subcategories('Boys Shoes'),
  ];

  List<Subcategories> subcategoriessports = <Subcategories>[
    Subcategories('Outdoors'),
    Subcategories('Exercise'),
    Subcategories('Fan Shop'),
    Subcategories('Team Sports'),
    Subcategories('Apparel'),
    Subcategories('Footwear')
  ];

  List<Subcategories> subcategorieshandmade = <Subcategories>[
    Subcategories('Accessories'),
    Subcategories('Paper Goods'),
    Subcategories('Clothing'),
    Subcategories('Bags & Purses'),
    Subcategories('Jewelry'),
    Subcategories('Music'),
    Subcategories('Art'),
    Subcategories('Weddings'),
    Subcategories('Children'),
    Subcategories('Gifts')
  ];

  List<Subcategories> subcategoriesbooks = <Subcategories>[
    Subcategories('Childrens Books'),
    Subcategories('Fiction Books'),
    Subcategories('Non Fiction Books'),
    Subcategories('Crime Books'),
    Subcategories('Sci-fi & Fantasy Books'),
    Subcategories('Comics'),
  ];

  List<Subcategories> subcategoriesother = <Subcategories>[
    Subcategories('Office Supplies'),
    Subcategories('Daily & Travel Items'),
    Subcategories('Musical Instruments'),
    Subcategories('Pet Supplies'),
  ];

  List<Subcategories> subcategoriesgarden = <Subcategories>[
    Subcategories('Garden Plants'),
    Subcategories('Pots and Garden Tools'),
    Subcategories('Artificial Plants'),
    Subcategories('Other'),
  ];

  List<Subcategories> subcategoriesluxury = <Subcategories>[
    Subcategories('Bags'),
    Subcategories('Clothing'),
    Subcategories('Home'),
    Subcategories('Accessories'),
    Subcategories('Shoes'),
  ];

  List<Subcategories> subcategoriesvintage = <Subcategories>[
    Subcategories('Bags & Purses'),
    Subcategories('Antiques'),
    Subcategories('Jewelry'),
    Subcategories('Books'),
    Subcategories('Electronics'),
    Subcategories('Accessories'),
    Subcategories('Serving Pieces'),
    Subcategories('Supplies'),
    Subcategories('Clothing'),
    Subcategories('Houseware')
  ];

  List<String> addedsubcategory = List<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Filter',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context, selectedsubcategory);
              }),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[0])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[0],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategorieselec.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategorieselec[index].selected,
                                  onTap: () {
                                    if (subcategorieselec[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategorieselec[index]);
                                        addedsubcategory.remove(categories[0]);
                                        subcategorieselec[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategorieselec[index]);
                                        addedsubcategory.add(categories[0]);
                                        subcategorieselec[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategorieselec[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategorieselec[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategorieselec[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[1])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[1],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategorieswome.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategorieswome[index].selected,
                                  onTap: () {
                                    if (subcategorieswome[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategorieswome[index]);
                                        addedsubcategory.remove(categories[1]);
                                        subcategorieswome[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategorieswome[index]);
                                        addedsubcategory.add(categories[1]);
                                        subcategorieswome[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategorieswome[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategorieswome[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategorieswome[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[2])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[2],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesmen.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesmen[index].selected,
                                  onTap: () {
                                    if (subcategoriesmen[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesmen[index]);
                                        addedsubcategory.remove(categories[2]);
                                        subcategoriesmen[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesmen[index]);
                                        addedsubcategory.add(categories[2]);
                                        subcategoriesmen[index].selected = true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategoriesmen[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategoriesmen[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesmen[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[3])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[3],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesbeau.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesbeau[index].selected,
                                  onTap: () {
                                    if (subcategoriesbeau[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesbeau[index]);
                                        addedsubcategory.remove(categories[3]);
                                        subcategoriesbeau[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesbeau[index]);
                                        addedsubcategory.add(categories[3]);
                                        subcategoriesbeau[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategoriesbeau[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategoriesbeau[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesbeau[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[4])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[4],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategorieshome.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategorieshome[index].selected,
                                  onTap: () {
                                    if (subcategorieshome[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategorieshome[index]);
                                        addedsubcategory.remove(categories[4]);
                                        subcategorieshome[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategorieshome[index]);
                                        addedsubcategory.add(categories[4]);
                                        subcategorieshome[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategorieshome[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategorieshome[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategorieshome[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[5])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[5],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriestoys.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriestoys[index].selected,
                                  onTap: () {
                                    if (subcategoriestoys[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriestoys[index]);
                                        addedsubcategory.remove(categories[5]);
                                        subcategoriestoys[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriestoys[index]);
                                        addedsubcategory.add(categories[5]);
                                        subcategoriestoys[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategoriestoys[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategoriestoys[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriestoys[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[6])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[6],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategorieskids.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategorieskids[index].selected,
                                  onTap: () {
                                    if (subcategorieskids[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategorieskids[index]);
                                        addedsubcategory.remove(categories[6]);
                                        subcategorieskids[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategorieskids[index]);
                                        addedsubcategory.add(categories[6]);
                                        subcategorieskids[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategorieskids[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategorieskids[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategorieskids[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[7])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[7],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriessports.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriessports[index].selected,
                                  onTap: () {
                                    if (subcategoriessports[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriessports[index]);
                                        addedsubcategory.remove(categories[7]);
                                        subcategoriessports[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriessports[index]);
                                        addedsubcategory.add(categories[7]);
                                        subcategoriessports[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing:
                                      (subcategoriessports[index].selected)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.deepOrange,
                                            )
                                          : Container(
                                              height: 5,
                                              width: 5,
                                            ),
                                  title: new Text(
                                    subcategoriessports[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriessports[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[8])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[8],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategorieshandmade.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected:
                                      subcategorieshandmade[index].selected,
                                  onTap: () {
                                    if (subcategorieshandmade[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory.remove(
                                            subcategorieshandmade[index]);
                                        addedsubcategory.remove(categories[8]);
                                        subcategorieshandmade[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategorieshandmade[index]);
                                        addedsubcategory.add(categories[8]);
                                        subcategorieshandmade[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing:
                                      (subcategorieshandmade[index].selected)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.deepOrange,
                                            )
                                          : Container(
                                              height: 5,
                                              width: 5,
                                            ),
                                  title: new Text(
                                    subcategorieshandmade[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategorieshandmade[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[9])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[9],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesbooks.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesbooks[index].selected,
                                  onTap: () {
                                    if (subcategoriesbooks[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesbooks[index]);
                                        addedsubcategory.remove(categories[9]);
                                        subcategoriesbooks[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesbooks[index]);
                                        addedsubcategory.add(categories[9]);
                                        subcategoriesbooks[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategoriesbooks[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategoriesbooks[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesbooks[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[10])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[10],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesother.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesother[index].selected,
                                  onTap: () {
                                    if (subcategoriesother[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesother[index]);
                                        addedsubcategory.remove(categories[10]);
                                        subcategoriesother[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesother[index]);
                                        addedsubcategory.add(categories[10]);
                                        subcategoriesother[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing: (subcategoriesother[index].selected)
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )
                                      : Container(
                                          height: 5,
                                          width: 5,
                                        ),
                                  title: new Text(
                                    subcategoriesother[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesother[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[11])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[11],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesgarden.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesgarden[index].selected,
                                  onTap: () {
                                    if (subcategoriesgarden[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesgarden[index]);
                                        addedsubcategory.remove(categories[11]);
                                        subcategoriesgarden[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesgarden[index]);
                                        addedsubcategory.add(categories[11]);
                                        subcategoriesgarden[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing:
                                      (subcategoriesgarden[index].selected)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.deepOrange,
                                            )
                                          : Container(
                                              height: 5,
                                              width: 5,
                                            ),
                                  title: new Text(
                                    subcategoriesgarden[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesgarden[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[12])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[12],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesluxury.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: subcategoriesluxury[index].selected,
                                  onTap: () {
                                    if (subcategoriesluxury[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory
                                            .remove(subcategoriesluxury[index]);
                                        addedsubcategory.remove(categories[12]);
                                        subcategoriesluxury[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesluxury[index]);
                                        addedsubcategory.add(categories[12]);
                                        subcategoriesluxury[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing:
                                      (subcategoriesluxury[index].selected)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.deepOrange,
                                            )
                                          : Container(
                                              height: 5,
                                              width: 5,
                                            ),
                                  title: new Text(
                                    subcategoriesluxury[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesluxury[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                  child: ExpansionTile(
                      maintainState: true,
                      trailing: addedsubcategory.contains(categories[13])
                          ? Icon(
                              Icons.circle,
                              size: 16,
                              color: Colors.deepOrange,
                            )
                          : Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        categories[13],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemCount: subcategoriesvintage.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected:
                                      subcategoriesvintage[index].selected,
                                  onTap: () {
                                    if (subcategoriesvintage[index].selected ==
                                        true) {
                                      setState(() {
                                        selectedsubcategory.remove(
                                            subcategoriesvintage[index]);
                                        addedsubcategory.remove(categories[13]);
                                        subcategoriesvintage[index].selected =
                                            false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedsubcategory
                                            .add(subcategoriesvintage[index]);
                                        addedsubcategory.add(categories[13]);
                                        subcategoriesvintage[index].selected =
                                            true;
                                      });
                                    }
                                  },
                                  dense: true,
                                  trailing:
                                      (subcategoriesvintage[index].selected)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.deepOrange,
                                            )
                                          : Container(
                                              height: 5,
                                              width: 5,
                                            ),
                                  title: new Text(
                                    subcategoriesvintage[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                          subcategoriesvintage[index].selected
                                              ? FontWeight.bold
                                              : FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ])),
            ]),
          ),
        ],
      ),
    );
  }
}
