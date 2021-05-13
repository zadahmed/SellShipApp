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

class FilterPageLocation extends StatefulWidget {
  FilterPageLocation({Key key}) : super(key: key);
  @override
  FilterPageLocationState createState() => FilterPageLocationState();
}

class Location {
  final String title;
  bool selected = false;

  Location(this.title);

  Map<String, dynamic> toJson() => _$SubcategoriesToJson(this);

  Map<String, dynamic> _$SubcategoriesToJson(Location instance) =>
      <String, dynamic>{
        'title': instance.title,
      };
}

class FilterPageLocationState extends State<FilterPageLocation> {
  List<Location> locations = [
    Location('Abu Dhabi'),
    Location('Dubai'),
    Location('Sharjah'),
    Location('Umm Al Quwain'),
    Location('Ajman'),
    Location('Ras Al Khaimah'),
    Location('Fujairah'),
    Location('Alain')
  ];

  List<Location> selectedlocation = List<Location>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Filter by City',
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
                Navigator.pop(context, selectedlocation);
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
                    selected: locations[index].selected,
                    dense: true,
                    onTap: () {
                      if (locations[index].selected == true) {
                        setState(() {
                          selectedlocation.remove(locations[index]);

                          locations[index].selected = false;
                        });
                      } else {
                        setState(() {
                          selectedlocation.add(locations[index]);

                          locations[index].selected = true;
                        });
                      }
                    },
                    trailing: (locations[index].selected)
                        ? Icon(
                            Icons.check,
                            color: Colors.deepOrange,
                          )
                        : Container(
                            height: 5,
                            width: 5,
                          ),
                    title: new Text(
                      locations[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: locations[index].selected
                            ? FontWeight.bold
                            : FontWeight.w700,
                      ),
                    ),
                  ));
            }, childCount: locations.length),
          ),
        ],
      ),
    );
  }
}
