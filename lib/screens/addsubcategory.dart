import 'dart:convert';

import 'package:SellShip/screens/addsubsubcategory.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddSubCategory extends StatefulWidget {
  final String category;
  AddSubCategory({Key key, this.category}) : super(key: key);

  _AddSubCategoryState createState() => _AddSubCategoryState();
}

class _AddSubCategoryState extends State<AddSubCategory> {
  String category;

  @override
  void initState() {
    super.initState();
    loadsubcategory(widget.category);
    setState(() {
      category = widget.category;
    });
  }

  String subcategory;

  List<String> subcategories = List<String>();

  loadsubcategory(String category) {
    if (category == 'Electronics') {
      setState(() {
        subcategories = [
          'Phones & Accessories',
          'Gaming',
          'TV & Video',
          'Cameras & Photography',
          'Computers,PCs & Laptops',
          'Headphones & Mp3 Players',
          'Sound & Audio',
          'Tablets & eReaders',
          'Wearables',
        ];
      });
    } else if (category == 'Women') {
      setState(() {
        subcategories = [
          'Activewear & Sportswear',
          'Jewelry',
          'Dresses',
          'Tops & Blouses',
          'Coats & Jackets',
          'Sweaters',
          'Handbags',
          'Shoes',
          'Women\'s accessories',
          'Modest wear',
          'Jeans',
          'Suits & Blazers',
          'Swimwear & Beachwear',
          'Bottoms',
        ];
      });
    } else if (category == 'Men') {
      setState(() {
        subcategories = [
          'Activewear & Sportswear',
          'Tops',
          'Shoes',
          'Coats & Jackets',
          'Men\'s accessories',
          'Bottoms',
          'Nightwear & Loungewear',
          'Hoodies & Sweatshirts',
          'Jeans',
          'Swimwear & Beachwear',
        ];
      });
    } else if (category == 'Beauty') {
      setState(() {
        subcategories = [
          'Fragrance',
          'Makeup',
          'Haircare',
          'Skincare',
          'Tools and Accessories',
          'Bath and Body',
        ];
      });
    } else if (category == 'Home') {
      setState(() {
        subcategories = [
          'Bath',
          'Home Decor',
          'Kitchen and Dining',
          'Storage and Organization',
          'Cleaning Supplies',
          'Furniture',
          'Artwork',
          'Home Appliances'
        ];
      });
    } else if (category == 'Toys') {
      setState(() {
        subcategories = [
          'Collectibles & Hobbies',
          'Action Figures & Accessories',
          'Dolls & Accessories',
          'Vintage & Antique Toys',
          'Trading Cards',
          'Stuffed Animals',
          'Building Toys',
          'Arts & Crafts',
          'Games & Puzzles',
          'Remote Control Toys',
        ];
      });
    } else if (category == 'Kids') {
      setState(() {
        subcategories = [
          'Girls Dresses',
          'Girls One-pieces',
          'Girls Tops & T-shirts',
          'Girls Bottoms',
          'Girls Shoes',
          'Girls Accessories',
          'Boys Tops & T-shirts',
          'Boys Bottoms',
          'Boys One-pieces',
          'Boys Accessories',
          'Boys Shoes',
        ];
      });
    } else if (category == 'Sport & Leisure') {
      setState(() {
        subcategories = [
          'Outdoors',
          'Exercise',
          'Fan Shop',
          'Team Sports',
          'Apparel',
          'Footwear'
        ];
      });
    } else if (category == 'Handmade') {
      setState(() {
        subcategories = [
          'Accessories',
          'Paper Goods',
          'Clothing',
          'Bags & Purses',
          'Jewelry',
          'Music',
          'Art',
          'Weddings',
          'Children',
          'Gifts'
        ];
      });
    } else if (category == 'Books') {
      setState(() {
        subcategories = [
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
        ];
      });
    } else if (category == 'Motors') {
      setState(() {
        subcategories = [
          'Used Cars',
          'Motorcycles & Scooters',
          'Heavy vehicles',
          'Boats',
          'Number plates',
          'Auto accessories',
          'Car Technology'
        ];
      });
    } else if (category == 'Property') {
      setState(() {
        subcategories = [
          'For Sale \nHouses & Apartment',
          'For Rent \nHouses & Apartment',
          'For Rent \nShops & Offices',
          'Guest Houses',
        ];
      });
    } else if (category == 'Other') {
      setState(() {
        subcategories = [
          'Office Supplies',
          'Daily & Travel Items',
          'Musical Instruments',
          'Pet Supplies',
        ];
      });
    } else if (category == 'Garden') {
      setState(() {
        subcategories = [
          'Office Supplies',
          'Daily & Travel Items',
          'Musical Instruments',
          'Pet Supplies',
        ];
      });
    } else if (category == 'Luxury') {
      setState(() {
        subcategories = [
          'Bags',
          'Clothing',
          'Home',
          'Accessories',
          'Shoes',
          'Jewelry'
        ];
      });
    } else if (category == 'Vintage') {
      setState(() {
        subcategories = [
          'Bags & Purses',
          'Antiques',
          'Jewelry',
          'Books',
          'Electronics',
          'Accessories',
          'Serving Pieces',
          'Supplies',
          'Clothing',
          'Houseware'
        ];
      });
    }
  }

  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Sub Category',
            style: TextStyle(
                fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
          ),
          leading: InkWell(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              margin:
                  EdgeInsets.only(top: 5.0, left: 10, right: 10, bottom: 10),
              child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Feather.search,
                          size: 24,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                bottom: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  category,
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
                child: AlphabetListScrollView(
              showPreview: true,
              strList: subcategories,
              indexedHeight: (i) {
                return 60;
              },
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          subcategory = subcategories[index];
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddSubSubCategory(
                                    category: category,
                                    subcategory: subcategory,
                                  )),
                        );
                      },
                      title: subcategories[index] != null
                          ? Text(
                              subcategories[index],
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                              ),
                            )
                          : Text(''),
                      trailing: Padding(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                        padding: EdgeInsets.only(right: 50),
                      ),
                    ));
              },
            ))
          ],
        ));
  }
}
