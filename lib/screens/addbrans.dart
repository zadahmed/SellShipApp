import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Brands extends StatefulWidget {
  final String category;
  final List<String> brands;
  Brands({Key key, this.category, this.brands}) : super(key: key);

  _BrandsState createState() => _BrandsState();
}

class _BrandsState extends State<Brands> {
  String category;

  @override
  void initState() {
    super.initState();
    setState(() {
      category = widget.category;
      brands = widget.brands;
      actbrands = widget.brands;
    });
  }

  List<String> brands = List<String>();
  List<String> actbrands = List<String>();

  String brand;
  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          pinned: true,
          title: Text(
            'Brands',
            style: TextStyle(color: Colors.black),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 5.0, left: 10, right: 10, bottom: 10),
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
                              brands = actbrands;
                            });
                          } else if (text.length >= 1) {
                            List<String> filtered = List<String>();
                            filtered.clear();

                            brands.forEach((element) {
                              element = element.trim();
                              element = element.toLowerCase();
                              if (element.contains(text)) {
                                element = element[0].toUpperCase() +
                                    element.substring(1, element.length);
                                filtered.add(element);
                              }
                            });

                            setState(() {
                              brands = filtered;
                            });
                          }
                        },
                        controller: searchcontroller,
                        decoration: InputDecoration(
                            hintText: 'Search Brands',
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
        ),
        SliverFillRemaining(
            child: AlphabetListScrollView(
          showPreview: true,
          strList: brands,
          indexedHeight: (i) {
            return 40;
          },
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                Navigator.pop(context, brands[index]);
              },
              child: ListTile(
                title: brands[index] != null ? Text(brands[index]) : Text(''),
              ),
            );
          },
        ))
      ],
    ));
  }
}
