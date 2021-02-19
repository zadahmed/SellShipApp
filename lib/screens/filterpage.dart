import 'dart:convert';
import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/filterpagecategory.dart';
import 'package:SellShip/screens/filterpagecondition.dart';
import 'package:SellShip/screens/filterpageprice.dart';
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

class FilterPage extends StatefulWidget {
  FilterPage({Key key}) : super(key: key);
  @override
  FilterPageState createState() => FilterPageState();
}

class FilterPageState extends State<FilterPage> {
  var selectedcategory = false;
  var selectedprice = false;
  var selectedcondition = false;
  String category = "";
  String _selectedsize = "";
  String condition = "";
  String price = "";
  int minprice = 0;
  int maxprice = 0;
  List<Subcategories> selectedsubcategory = List<Subcategories>();
  List<Conditions> selectedconditions = List<Conditions>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        child: InkWell(
          onTap: () async {},
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: MediaQuery.of(context).size.width - 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 115, 0, 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
                child: Text(
              'Filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
          ),
        ),
        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              delegate: SliverChildListDelegate([
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    enableFeedback: true,
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FilterPageCategory()));
                      if (result != null) {
                        setState(() {
                          selectedcategory = true;
                          category = '';
                          selectedsubcategory = result;
                          for (int i = 0; i < selectedsubcategory.length; i++) {
                            category += selectedsubcategory[i].title + ' ';
                          }
                        });
                      }
                    },
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            'Category',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          title: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    category,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ),
                              ]),
                          trailing: selectedcategory == true
                              ? Icon(
                                  Icons.circle,
                                  size: 16,
                                  color: Colors.deepOrange,
                                )
                              : Icon(Icons.chevron_right),
                        )))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FilterPagePrice()));
                      if (result != null) {
                        setState(() {
                          minprice = int.parse(result['minprice']);
                          maxprice = int.parse(result['maxprice']);
                          selectedprice = true;

                          price = 'AED ' +
                              minprice.toString() +
                              ' - ' +
                              maxprice.toString();
                        });
                      }
                    },
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              'Price',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            title: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    price,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.deepOrange),
                                  ),
                                ]),
                            trailing: selectedprice == true
                                ? Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Colors.deepOrange,
                                  )
                                : Icon(Icons.chevron_right))))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FilterPageCondition()));
                      if (result != null) {
                        setState(() {
                          selectedcondition = true;
                          selectedconditions = result;
                          condition = '';
                          for (int i = 0; i < selectedconditions.length; i++) {
                            condition += selectedconditions[i].title + ' ';
                          }
                        });
                      }
                    },
                    child: ListTile(
                        leading: Text(
                          'Condition',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        title: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                condition,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.deepOrange),
                              ),
                            ]),
                        trailing: selectedcondition == true
                            ? Icon(
                                Icons.circle,
                                size: 16,
                                color: Colors.deepOrange,
                              )
                            : Icon(Icons.chevron_right)))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () {
                      List<String> topsizes = [
                        'XXS',
                        'XS',
                        'S',
                        'M',
                        'L',
                        'XL',
                        'XXL'
                      ];

                      List<String> bottomsizes = [
                        '26',
                        '27',
                        '28',
                        '29',
                        '30',
                        '31',
                        '32',
                        '33',
                        '34',
                        '35',
                        '36',
                        '37',
                        '38',
                        '39',
                        '40',
                        '41',
                        '42',
                        '43',
                        '44'
                      ];

                      List<String> shoesizes = [
                        '5',
                        '5.5',
                        '6',
                        '6.5',
                        '7',
                        '7.5',
                        '8',
                        '8.5',
                        '9',
                        '9.5',
                        '10',
                        '10.5',
                        '11',
                        '11.5',
                        '12',
                        '12.5',
                        '13',
                        '14',
                        '15'
                      ];

                      List<String> selectedsize = List<String>();

                      showModalBottomSheet(
                          context: context,
                          useRootNavigator: false,
                          isScrollControlled: true,
                          builder: (_) {
                            return DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.7,
                                builder: (_, controller) {
                                  return StatefulBuilder(
                                      // You need this, notice the parameters below:
                                      builder: (BuildContext context,
                                          StateSetter updateState) {
                                    return Container(
                                        height: 350.0,
                                        color: Color(0xFF737373),
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: new BorderRadius
                                                        .only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            20.0),
                                                    topRight:
                                                        const Radius.circular(
                                                            20.0))),
                                            child: CustomScrollView(slivers: [
                                              SliverToBoxAdapter(
                                                child: Column(children: [
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            updateState(() {
                                                              _selectedsize =
                                                                  selectedsize[
                                                                      0];
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 15,
                                                                    top: 15,
                                                                    bottom: 5),
                                                            child: Text(
                                                              "Done",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
                                                          ))
                                                    ],
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15, bottom: 15),
                                                    child: Center(
                                                      child: Text(
                                                        'Choose your Size',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Clothing Sizes',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              SliverGrid(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        mainAxisSpacing: 5.0,
                                                        crossAxisSpacing: 5.0,
                                                        crossAxisCount: 4,
                                                        childAspectRatio: 1),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  (BuildContext context,
                                                      int i) {
                                                    return Padding(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: InkWell(
                                                            onTap: () {
                                                              selectedsize
                                                                  .clear();
                                                              updateState(() {
                                                                selectedsize.add(
                                                                    topsizes[
                                                                        i]);
                                                              });
                                                              print(
                                                                  topsizes[i]);
                                                            },
                                                            child: Container(
                                                                height: 100,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: selectedsize.contains(topsizes[i])
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .white,
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                child: Center(
                                                                    child: Text(
                                                                  topsizes[i],
                                                                  style: selectedsize.contains(
                                                                          topsizes[
                                                                              i])
                                                                      ? TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .white)
                                                                      : TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                )))));
                                                  },
                                                  childCount: topsizes.length,
                                                ),
                                              ),
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Shoe Sizes',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              SliverGrid(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        mainAxisSpacing: 5.0,
                                                        crossAxisSpacing: 5.0,
                                                        crossAxisCount: 4,
                                                        childAspectRatio: 1),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  (BuildContext context,
                                                      int i) {
                                                    return Padding(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: InkWell(
                                                            onTap: () {
                                                              selectedsize
                                                                  .clear();
                                                              updateState(() {
                                                                selectedsize.add(
                                                                    shoesizes[
                                                                        i]);
                                                              });
                                                              print(
                                                                  shoesizes[i]);
                                                            },
                                                            child: Container(
                                                                height: 100,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: selectedsize.contains(shoesizes[i])
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .white,
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                child: Center(
                                                                    child: Text(
                                                                  shoesizes[i],
                                                                  style: selectedsize.contains(
                                                                          shoesizes[
                                                                              i])
                                                                      ? TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .white)
                                                                      : TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                )))));
                                                  },
                                                  childCount: shoesizes.length,
                                                ),
                                              ),
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Bottoms Sizes',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              SliverGrid(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        mainAxisSpacing: 5.0,
                                                        crossAxisSpacing: 5.0,
                                                        crossAxisCount: 4,
                                                        childAspectRatio: 1),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  (BuildContext context,
                                                      int i) {
                                                    return Padding(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: InkWell(
                                                            onTap: () {
                                                              selectedsize
                                                                  .clear();
                                                              updateState(() {
                                                                selectedsize.add(
                                                                    bottomsizes[
                                                                        i]);
                                                              });
                                                              print(bottomsizes[
                                                                  i]);
                                                            },
                                                            child: Container(
                                                                height: 100,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: selectedsize.contains(bottomsizes[i])
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .white,
                                                                        border: Border
                                                                            .all(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                child: Center(
                                                                    child: Text(
                                                                  bottomsizes[
                                                                      i],
                                                                  style: selectedsize.contains(
                                                                          bottomsizes[
                                                                              i])
                                                                      ? TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color: Colors
                                                                              .white)
                                                                      : TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                )))));
                                                  },
                                                  childCount:
                                                      bottomsizes.length,
                                                ),
                                              ),
                                              SliverToBoxAdapter(
                                                  child: SizedBox(
                                                height: 10,
                                              )),
                                            ])));
                                  });
                                });
                          });
                    },
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Size',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [Icon(Icons.chevron_right)])
                          ],
                        )))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () {},
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Color',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [Icon(Icons.chevron_right)])
                          ],
                        )))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () {},
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [Icon(Icons.chevron_right)])
                          ],
                        )))),
            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () {},
                    child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sort',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [Icon(Icons.chevron_right)])
                          ],
                        )))),
          ]))
        ],
      ),
    );
  }
}
