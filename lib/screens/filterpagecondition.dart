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

class FilterPageCondition extends StatefulWidget {
  FilterPageCondition({Key key}) : super(key: key);
  @override
  FilterPageConditionState createState() => FilterPageConditionState();
}

class Conditions {
  final String title;
  bool selected = false;

  Conditions(this.title);

  Map<String, dynamic> toJson() => _$SubcategoriesToJson(this);

  Map<String, dynamic> _$SubcategoriesToJson(Conditions instance) =>
      <String, dynamic>{
        'title': instance.title,
      };
}

class FilterPageConditionState extends State<FilterPageCondition> {
  List<Conditions> conditions = [
    Conditions('New with tags'),
    Conditions('New, but no tags'),
    Conditions('Like new'),
    Conditions('Very Good, a bit worn'),
    Conditions('Good, some flaws visible')
  ];

  List<Conditions> selectedcondition = List<Conditions>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Condition',
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
                Navigator.pop(context, selectedcondition);
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
                    selected: conditions[index].selected,
                    dense: true,
                    onTap: () {
                      if (conditions[index].selected == true) {
                        setState(() {
                          selectedcondition.remove(conditions[index]);

                          conditions[index].selected = false;
                        });
                      } else {
                        setState(() {
                          selectedcondition.add(conditions[index]);

                          conditions[index].selected = true;
                        });
                      }
                    },
                    trailing: (conditions[index].selected)
                        ? Icon(
                            Icons.check,
                            color: Colors.deepOrange,
                          )
                        : Container(
                            height: 5,
                            width: 5,
                          ),
                    title: new Text(
                      conditions[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: conditions[index].selected
                            ? FontWeight.bold
                            : FontWeight.w700,
                      ),
                    ),
                  ));
            }, childCount: conditions.length),
          ),
        ],
      ),
    );
  }
}
