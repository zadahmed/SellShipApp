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
    'Toys',
    'Home',
    'Beauty',
    'Kids',
    'Vintage',
    'Luxury',
    'Garden',
    'Sport & Leisure',
    'Handmade',
    'Books',
    'Other'
  ];

  List<Subcategories> selectedsubcategory = List<Subcategories>();

  Widget subcategor(String category, BuildContext context) {
    if (category == 'Electronics') {
      List<Subcategories> subcategories = <Subcategories>[
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

      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Women') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: selectedsubcategory
                          .toSet()
                          .toList()
                          .contains(subcategories[index])
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : subcategories[index].selected
                          ? Icon(
                              Icons.check,
                              color: Colors.deepOrange,
                            )
                          : Container(
                              height: 5,
                              width: 5,
                            ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Men') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Beauty') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Fragrance'),
        Subcategories('Makeup'),
        Subcategories('Haircare'),
        Subcategories('Skincare'),
        Subcategories('Tools and Accessories'),
        Subcategories('Bath and Body'),
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Home') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Bath'),
        Subcategories('Home Decor'),
        Subcategories('Kitchen and Dining'),
        Subcategories('Storage and Organization'),
        Subcategories('Cleaning Supplies'),
        Subcategories('Furniture'),
        Subcategories('Artwork'),
        Subcategories('Home Appliances')
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Toys') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Kids') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Sport & Leisure') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Outdoors'),
        Subcategories('Exercise'),
        Subcategories('Fan Shop'),
        Subcategories('Team Sports'),
        Subcategories('Apparel'),
        Subcategories('Footwear')
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Handmade') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Books') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Childrens Books'),
        Subcategories('Fiction Books'),
        Subcategories('Non Fiction Books'),
        Subcategories('Crime Books'),
        Subcategories('Sci-fi & Fantasy Books'),
        Subcategories('Comics'),
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Motors') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Used Cars'),
        Subcategories('Motorcycles & Scooters'),
        Subcategories('Heavy vehicles'),
        Subcategories('Boats'),
        Subcategories('Other')
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Other') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Office Supplies'),
        Subcategories('Daily & Travel Items'),
        Subcategories('Musical Instruments'),
        Subcategories('Pet Supplies'),
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Garden') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Garden Plants'),
        Subcategories('Pots and Garden Tools'),
        Subcategories('Artificial Plants'),
        Subcategories('Other'),
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Luxury') {
      List<Subcategories> subcategories = <Subcategories>[
        Subcategories('Bags'),
        Subcategories('Clothing'),
        Subcategories('Home'),
        Subcategories('Accessories'),
        Subcategories('Shoes'),
      ];
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    } else if (category == 'Vintage') {
      List<Subcategories> subcategories = <Subcategories>[
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateState) {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: subcategories[index].selected,
                  onTap: () {
                    if (subcategories[index].selected == true) {
                      updateState(() {
                        selectedsubcategory.remove(subcategories[index]);
                        addedsubcategory.remove(category);
                        subcategories[index].selected = false;
                      });
                    } else {
                      updateState(() {
                        selectedsubcategory.add(subcategories[index]);
                        addedsubcategory.add(category);
                        subcategories[index].selected = true;
                      });
                    }
                  },
                  dense: true,
                  trailing: (subcategories[index].selected)
                      ? Icon(
                          Icons.check,
                          color: Colors.deepOrange,
                        )
                      : Container(
                          height: 5,
                          width: 5,
                        ),
                  title: new Text(
                    subcategories[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: subcategories[index].selected
                          ? FontWeight.bold
                          : FontWeight.w700,
                    ),
                  ),
                );
              },
            ));
      });
    }
  }

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
                Navigator.of(context).pop();
              }),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: ExpansionTile(
                  onExpansionChanged: (opened) {
                    if (!opened) {
                      setState(() {
                        addedsubcategory = addedsubcategory.toSet().toList();
                      });
                    }
                  },
                  maintainState: true,
                  trailing: addedsubcategory.contains(categories[index])
                      ? Icon(
                          Icons.circle,
                          size: 16,
                          color: Colors.deepOrange,
                        )
                      : Icon(Icons.keyboard_arrow_down),
                  title: Text(
                    categories[index],
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(addedsubcategory.length.toString()),
                  children: [subcategor(categories[index], context)],
                ));
          }, childCount: categories.length))
        ],
      ),
    );
  }
}
