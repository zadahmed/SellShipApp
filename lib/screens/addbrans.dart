import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 10.0, right: 10, left: 10, bottom: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: const Color(0x80e5e9f2),
              ),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Icon(
                      FeatherIcons.search,
                      size: 24,
                      color: Color.fromRGBO(115, 115, 125, 1),
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
        ),
        SliverFillRemaining(
            child: AlphabetListScrollView(
          showPreview: true,
          strList: brands,
          indexedHeight: (i) {
            return 50;
          },
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                Navigator.pop(context, brands[index]);
              },
              child: ListTile(
                title: brands[index] != null
                    ? Text(
                        brands[index],
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            color: Colors.black),
                      )
                    : Text(''),
              ),
            );
          },
        ))
      ],
    ));
  }
}
