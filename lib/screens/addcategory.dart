import 'dart:convert';

import 'package:SellShip/screens/addsubcategory.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String category;

  @override
  void initState() {
    super.initState();
    setState(() {
      actualcategories = categories;
    });
  }

  List<String> brands = List<String>();

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

  List<String> actualcategories = List<String>();

  String selectedcategory;
  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Category',
            style: TextStyle(
                fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
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
                      Expanded(
                        child: TextField(
                          onChanged: (text) {
                            text = text.trim();
                            text = text.toLowerCase();

                            if (text.isEmpty) {
                              setState(() {
                                actualcategories = categories;
                              });
                            }
                            List<String> filtered = List<String>();
                            filtered.clear();
                            actualcategories.forEach((element) {
                              element = element.trim();
                              element = element.toLowerCase();
                              if (element.contains(text)) {
                                element = element[0].toUpperCase() +
                                    element.substring(1, element.length);
                                filtered.add(element);
                              } else {
                                setState(() {
                                  actualcategories = categories;
                                });
                              }
                            });

                            setState(() {
                              actualcategories = filtered;
                            });
                          },
                          controller: searchcontroller,
                          decoration: InputDecoration(
                              hintText: 'Search Categories',
                              hintStyle: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  )),
            ),
            Expanded(
                child: AlphabetListScrollView(
              showPreview: true,
              strList: actualcategories,
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
                          selectedcategory = actualcategories[index];
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddSubCategory(
                                    category: selectedcategory,
                                  )),
                        );
                      },
                      title: actualcategories[index] != null
                          ? Text(
                              actualcategories[index],
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
