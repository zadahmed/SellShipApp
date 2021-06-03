import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/custom_slider_thumb.dart';
import 'package:SellShip/controllers/customslider.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:SellShip/screens/details.dart';

import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class FilterPageSort extends StatefulWidget {
  FilterPageSort({Key key}) : super(key: key);
  @override
  FilterPageSortState createState() => FilterPageSortState();
}

class Sort {
  final String title;
  bool selected = false;

  Sort(this.title);
  Map<String, dynamic> toJson() => _$SubcategoriesToJson(this);

  Map<String, dynamic> _$SubcategoriesToJson(Sort instance) =>
      <String, dynamic>{
        'title': instance.title,
      };
}

class FilterPageSortState extends State<FilterPageSort> {
  List<Sort> sortoptions = [
    Sort('Recently Added'),
    Sort('Lowest Price'),
    Sort('Highest Price'),
  ];

  List<Sort> selectedsort = List<Sort>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Sort',
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
                Navigator.pop(context, selectedsort);
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
                  child: ListTile(
                    selected: sortoptions[index].selected,
                    dense: true,
                    onTap: () {
                      if (sortoptions[index].selected == true) {
                        setState(() {
                          selectedsort.remove(sortoptions[index]);

                          sortoptions[index].selected = false;
                        });
                      } else {
                        setState(() {
                          selectedsort.add(sortoptions[index]);

                          sortoptions[index].selected = true;
                        });
                      }
                    },
                    trailing: (sortoptions[index].selected)
                        ? Icon(
                            Icons.check,
                            color: Colors.deepOrange,
                          )
                        : Container(
                            height: 5,
                            width: 5,
                          ),
                    title: new Text(
                      sortoptions[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: sortoptions[index].selected
                            ? FontWeight.bold
                            : FontWeight.w700,
                      ),
                    ),
                  ));
            }, childCount: sortoptions.length),
          ),
        ],
      ),
    );
  }
}
