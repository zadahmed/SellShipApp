import 'dart:convert';

import 'package:SellShip/screens/filter.dart';
import 'package:SellShip/screens/filterpagecategory.dart';
import 'package:SellShip/screens/filterpagecondition.dart';
import 'package:SellShip/screens/filterpagelocation.dart';
import 'package:SellShip/screens/filterpageprice.dart';
import 'package:SellShip/screens/filterpagesort.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  FilterPage({Key key}) : super(key: key);
  @override
  FilterPageState createState() => FilterPageState();
}

class FilterPageState extends State<FilterPage> {
  var selectedcategory = false;
  var selectedprice = false;
  var selectedcondition = false;
  var selectedsize = false;
  var selectedcolor = false;
  var selectedcity = false;
  var selectedsort = false;

  String category = "";
  String _selectedsize = "";
  String condition = "";
  String price = "";
  String city = "";
  String sort = "";

  int minprice = 0;
  int maxprice = 0;

  List<Subcategories> selectedsubcategory = List<Subcategories>();
  List<Conditions> selectedconditions = List<Conditions>();
  List<Location> selectedcities = List<Location>();
  List<Sort> selectedsorts = List<Sort>();

  List<Color> colorslist = [
    Colors.red,
    Colors.black,
    Colors.white,
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.tealAccent,
    Colors.teal,
    Colors.redAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.brown,
    Colors.indigo,
  ];

  List<Color> selectedColors = List<Color>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        child: InkWell(
          onTap: () async {
            Map<String, dynamic> body = {
              'category': jsonEncode(selectedsubcategory),
              'minprice': minprice.toString(),
              'maxprice': maxprice.toString(),
//              'colors': (selectedColors),
              'city': jsonEncode(selectedcities),
              'conditions': jsonEncode(selectedconditions),
              'sort': jsonEncode(selectedsorts),
//              'size': _selectedsize
            };

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Filtered(
                        formdata: body,
                      )),
            );
          },
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
                                  Expanded(
                                    child: Text(
                                      price,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
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
                              Expanded(
                                child: Text(
                                  condition,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.deepOrange),
                                ),
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
//            Padding(
//                padding:
//                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
//                child: InkWell(
//                    onTap: () {
//                      List<String> topsizes = [
//                        'XXS',
//                        'XS',
//                        'S',
//                        'M',
//                        'L',
//                        'XL',
//                        'XXL'
//                      ];
//
//                      List<String> bottomsizes = [
//                        '26',
//                        '27',
//                        '28',
//                        '29',
//                        '30',
//                        '31',
//                        '32',
//                        '33',
//                        '34',
//                        '35',
//                        '36',
//                        '37',
//                        '38',
//                        '39',
//                        '40',
//                        '41',
//                        '42',
//                        '43',
//                        '44'
//                      ];
//
//                      List<String> shoesizes = [
//                        '5',
//                        '5.5',
//                        '6',
//                        '6.5',
//                        '7',
//                        '7.5',
//                        '8',
//                        '8.5',
//                        '9',
//                        '9.5',
//                        '10',
//                        '10.5',
//                        '11',
//                        '11.5',
//                        '12',
//                        '12.5',
//                        '13',
//                        '14',
//                        '15'
//                      ];
//
//                      List<String> selectedsize = List<String>();
//
//                      showModalBottomSheet(
//                          context: context,
//                          useRootNavigator: false,
//                          isScrollControlled: true,
//                          builder: (_) {
//                            return DraggableScrollableSheet(
//                                expand: false,
//                                initialChildSize: 0.7,
//                                builder: (_, controller) {
//                                  return StatefulBuilder(
//                                      // You need this, notice the parameters below:
//                                      builder: (BuildContext context,
//                                          StateSetter updateState) {
//                                    return Container(
//                                        height: 350.0,
//                                        color: Color(0xFF737373),
//                                        child: Container(
//                                            padding: EdgeInsets.only(
//                                                left: 10, right: 10),
//                                            decoration: new BoxDecoration(
//                                                color: Colors.white,
//                                                borderRadius: new BorderRadius
//                                                        .only(
//                                                    topLeft:
//                                                        const Radius.circular(
//                                                            20.0),
//                                                    topRight:
//                                                        const Radius.circular(
//                                                            20.0))),
//                                            child: CustomScrollView(slivers: [
//                                              SliverToBoxAdapter(
//                                                child: Column(children: [
//                                                  Row(
//                                                    children: [
//                                                      InkWell(
//                                                          onTap: () {
//                                                            Navigator.pop(
//                                                                context);
//                                                            updateState(() {
//                                                              _selectedsize =
//                                                                  selectedsize[
//                                                                      0];
//                                                            });
//                                                          },
//                                                          child: Padding(
//                                                            padding:
//                                                                EdgeInsets.only(
//                                                                    right: 15,
//                                                                    top: 15,
//                                                                    bottom: 5),
//                                                            child: Text(
//                                                              "Done",
//                                                              style: TextStyle(
//                                                                  fontFamily:
//                                                                      'Helvetica',
//                                                                  fontSize: 18,
//                                                                  color: Colors
//                                                                      .black,
//                                                                  fontWeight:
//                                                                      FontWeight
//                                                                          .w300),
//                                                            ),
//                                                          ))
//                                                    ],
//                                                    mainAxisAlignment:
//                                                        MainAxisAlignment.end,
//                                                    crossAxisAlignment:
//                                                        CrossAxisAlignment.end,
//                                                  ),
//                                                  Padding(
//                                                    padding: EdgeInsets.only(
//                                                        left: 15, bottom: 15),
//                                                    child: Center(
//                                                      child: Text(
//                                                        'Choose your Size',
//                                                        textAlign:
//                                                            TextAlign.right,
//                                                        style: TextStyle(
//                                                            fontFamily:
//                                                                'Helvetica',
//                                                            fontSize: 18,
//                                                            color: Colors.black,
//                                                            fontWeight:
//                                                                FontWeight
//                                                                    .bold),
//                                                      ),
//                                                    ),
//                                                  ),
//                                                ]),
//                                              ),
//                                              SliverToBoxAdapter(
//                                                child: Padding(
//                                                  padding: EdgeInsets.all(10),
//                                                  child: Row(
//                                                      crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .start,
//                                                      mainAxisAlignment:
//                                                          MainAxisAlignment
//                                                              .start,
//                                                      children: [
//                                                        Text(
//                                                          'Clothing Sizes',
//                                                          textAlign:
//                                                              TextAlign.start,
//                                                          overflow: TextOverflow
//                                                              .ellipsis,
//                                                          style: TextStyle(
//                                                              fontFamily:
//                                                                  'Helvetica',
//                                                              fontSize: 16,
//                                                              fontWeight:
//                                                                  FontWeight
//                                                                      .bold,
//                                                              color:
//                                                                  Colors.black),
//                                                        ),
//                                                      ]),
//                                                ),
//                                              ),
//                                              SliverGrid(
//                                                gridDelegate:
//                                                    SliverGridDelegateWithFixedCrossAxisCount(
//                                                        mainAxisSpacing: 5.0,
//                                                        crossAxisSpacing: 5.0,
//                                                        crossAxisCount: 4,
//                                                        childAspectRatio: 1),
//                                                delegate:
//                                                    SliverChildBuilderDelegate(
//                                                  (BuildContext context,
//                                                      int i) {
//                                                    return Padding(
//                                                        padding:
//                                                            EdgeInsets.all(5),
//                                                        child: InkWell(
//                                                            onTap: () {
//                                                              selectedsize
//                                                                  .clear();
//                                                              updateState(() {
//                                                                selectedsize.add(
//                                                                    topsizes[
//                                                                        i]);
//                                                              });
//                                                              print(
//                                                                  topsizes[i]);
//                                                            },
//                                                            child: Container(
//                                                                height: 100,
//                                                                width: MediaQuery.of(
//                                                                        context)
//                                                                    .size
//                                                                    .width,
//                                                                decoration:
//                                                                    BoxDecoration(
//                                                                        color: selectedsize.contains(topsizes[i])
//                                                                            ? Colors
//                                                                                .black
//                                                                            : Colors
//                                                                                .white,
//                                                                        border: Border
//                                                                            .all(
//                                                                          color:
//                                                                              Colors.grey,
//                                                                        ),
//                                                                        borderRadius:
//                                                                            BorderRadius.circular(10)),
//                                                                child: Center(
//                                                                    child: Text(
//                                                                  topsizes[i],
//                                                                  style: selectedsize.contains(
//                                                                          topsizes[
//                                                                              i])
//                                                                      ? TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color: Colors
//                                                                              .white)
//                                                                      : TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color:
//                                                                              Colors.black),
//                                                                )))));
//                                                  },
//                                                  childCount: topsizes.length,
//                                                ),
//                                              ),
//                                              SliverToBoxAdapter(
//                                                child: Padding(
//                                                  padding: EdgeInsets.all(10),
//                                                  child: Row(
//                                                      crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .start,
//                                                      mainAxisAlignment:
//                                                          MainAxisAlignment
//                                                              .start,
//                                                      children: [
//                                                        Text(
//                                                          'Shoe Sizes',
//                                                          textAlign:
//                                                              TextAlign.start,
//                                                          overflow: TextOverflow
//                                                              .ellipsis,
//                                                          style: TextStyle(
//                                                              fontFamily:
//                                                                  'Helvetica',
//                                                              fontSize: 16,
//                                                              fontWeight:
//                                                                  FontWeight
//                                                                      .bold,
//                                                              color:
//                                                                  Colors.black),
//                                                        ),
//                                                      ]),
//                                                ),
//                                              ),
//                                              SliverGrid(
//                                                gridDelegate:
//                                                    SliverGridDelegateWithFixedCrossAxisCount(
//                                                        mainAxisSpacing: 5.0,
//                                                        crossAxisSpacing: 5.0,
//                                                        crossAxisCount: 4,
//                                                        childAspectRatio: 1),
//                                                delegate:
//                                                    SliverChildBuilderDelegate(
//                                                  (BuildContext context,
//                                                      int i) {
//                                                    return Padding(
//                                                        padding:
//                                                            EdgeInsets.all(5),
//                                                        child: InkWell(
//                                                            onTap: () {
//                                                              selectedsize
//                                                                  .clear();
//                                                              updateState(() {
//                                                                selectedsize.add(
//                                                                    shoesizes[
//                                                                        i]);
//                                                              });
//                                                              print(
//                                                                  shoesizes[i]);
//                                                            },
//                                                            child: Container(
//                                                                height: 100,
//                                                                width: MediaQuery.of(
//                                                                        context)
//                                                                    .size
//                                                                    .width,
//                                                                decoration:
//                                                                    BoxDecoration(
//                                                                        color: selectedsize.contains(shoesizes[i])
//                                                                            ? Colors
//                                                                                .black
//                                                                            : Colors
//                                                                                .white,
//                                                                        border: Border
//                                                                            .all(
//                                                                          color:
//                                                                              Colors.grey,
//                                                                        ),
//                                                                        borderRadius:
//                                                                            BorderRadius.circular(10)),
//                                                                child: Center(
//                                                                    child: Text(
//                                                                  shoesizes[i],
//                                                                  style: selectedsize.contains(
//                                                                          shoesizes[
//                                                                              i])
//                                                                      ? TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color: Colors
//                                                                              .white)
//                                                                      : TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color:
//                                                                              Colors.black),
//                                                                )))));
//                                                  },
//                                                  childCount: shoesizes.length,
//                                                ),
//                                              ),
//                                              SliverToBoxAdapter(
//                                                child: Padding(
//                                                  padding: EdgeInsets.all(10),
//                                                  child: Row(
//                                                      crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .start,
//                                                      mainAxisAlignment:
//                                                          MainAxisAlignment
//                                                              .start,
//                                                      children: [
//                                                        Text(
//                                                          'Bottoms Sizes',
//                                                          textAlign:
//                                                              TextAlign.start,
//                                                          overflow: TextOverflow
//                                                              .ellipsis,
//                                                          style: TextStyle(
//                                                              fontFamily:
//                                                                  'Helvetica',
//                                                              fontSize: 16,
//                                                              fontWeight:
//                                                                  FontWeight
//                                                                      .bold,
//                                                              color:
//                                                                  Colors.black),
//                                                        ),
//                                                      ]),
//                                                ),
//                                              ),
//                                              SliverGrid(
//                                                gridDelegate:
//                                                    SliverGridDelegateWithFixedCrossAxisCount(
//                                                        mainAxisSpacing: 5.0,
//                                                        crossAxisSpacing: 5.0,
//                                                        crossAxisCount: 4,
//                                                        childAspectRatio: 1),
//                                                delegate:
//                                                    SliverChildBuilderDelegate(
//                                                  (BuildContext context,
//                                                      int i) {
//                                                    return Padding(
//                                                        padding:
//                                                            EdgeInsets.all(5),
//                                                        child: InkWell(
//                                                            onTap: () {
//                                                              selectedsize
//                                                                  .clear();
//                                                              updateState(() {
//                                                                selectedsize.add(
//                                                                    bottomsizes[
//                                                                        i]);
//                                                              });
//                                                              print(bottomsizes[
//                                                                  i]);
//                                                            },
//                                                            child: Container(
//                                                                height: 100,
//                                                                width: MediaQuery.of(
//                                                                        context)
//                                                                    .size
//                                                                    .width,
//                                                                decoration:
//                                                                    BoxDecoration(
//                                                                        color: selectedsize.contains(bottomsizes[i])
//                                                                            ? Colors
//                                                                                .black
//                                                                            : Colors
//                                                                                .white,
//                                                                        border: Border
//                                                                            .all(
//                                                                          color:
//                                                                              Colors.grey,
//                                                                        ),
//                                                                        borderRadius:
//                                                                            BorderRadius.circular(10)),
//                                                                child: Center(
//                                                                    child: Text(
//                                                                  bottomsizes[
//                                                                      i],
//                                                                  style: selectedsize.contains(
//                                                                          bottomsizes[
//                                                                              i])
//                                                                      ? TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color: Colors
//                                                                              .white)
//                                                                      : TextStyle(
//                                                                          fontFamily:
//                                                                              'Helvetica',
//                                                                          fontSize:
//                                                                              16,
//                                                                          color:
//                                                                              Colors.black),
//                                                                )))));
//                                                  },
//                                                  childCount:
//                                                      bottomsizes.length,
//                                                ),
//                                              ),
//                                              SliverToBoxAdapter(
//                                                  child: SizedBox(
//                                                height: 10,
//                                              )),
//                                            ])));
//                                  });
//                                });
//                          });
//                    },
//                    child: Container(
//                        height: 50,
//                        padding:
//                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.circular(5)),
//                        child: ListTile(
//                            contentPadding: EdgeInsets.zero,
//                            leading: Text(
//                              'Size',
//                              style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                            title: Row(
//                                crossAxisAlignment: CrossAxisAlignment.end,
//                                mainAxisAlignment: MainAxisAlignment.end,
//                                children: [
//                                  Expanded(
//                                    child: Text(
//                                      _selectedsize,
//                                      textAlign: TextAlign.end,
//                                      overflow: TextOverflow.ellipsis,
//                                      style: TextStyle(
//                                          fontFamily: 'Helvetica',
//                                          fontSize: 16,
//                                          color: Colors.deepOrange),
//                                    ),
//                                  ),
//                                ]),
//                            trailing: _selectedsize != null
//                                ? Icon(
//                                    Icons.circle,
//                                    size: 16,
//                                    color: Colors.deepOrange,
//                                  )
//                                : Icon(Icons.chevron_right))))),
//            Divider(),
//            Padding(
//                padding:
//                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
//                child: InkWell(
//                    onTap: () {
//                      showModalBottomSheet(
//                          context: context,
//                          useRootNavigator: false,
//                          isScrollControlled: true,
//                          builder: (_) {
//                            return DraggableScrollableSheet(
//                                expand: false,
//                                initialChildSize: 0.7,
//                                builder: (_, controller) {
//                                  return StatefulBuilder(
//                                      // You need this, notice the parameters below:
//                                      builder: (BuildContext context,
//                                          StateSetter updateState) {
//                                    return Container(
//                                        height: 350.0,
//                                        color: Color(0xFF737373),
//                                        child: Container(
//                                            padding: EdgeInsets.only(
//                                                left: 10, right: 10),
//                                            decoration: new BoxDecoration(
//                                                color: Colors.white,
//                                                borderRadius: new BorderRadius
//                                                        .only(
//                                                    topLeft:
//                                                        const Radius.circular(
//                                                            20.0),
//                                                    topRight:
//                                                        const Radius.circular(
//                                                            20.0))),
//                                            child: Column(children: [
//                                              Row(
//                                                children: [
//                                                  InkWell(
//                                                      onTap: () {
//                                                        Navigator.pop(context);
//                                                      },
//                                                      child: Padding(
//                                                        padding:
//                                                            EdgeInsets.only(
//                                                                right: 15,
//                                                                top: 15,
//                                                                bottom: 5),
//                                                        child: Text(
//                                                          "Done",
//                                                          style: TextStyle(
//                                                              fontFamily:
//                                                                  'Helvetica',
//                                                              fontSize: 18,
//                                                              color:
//                                                                  Colors.black,
//                                                              fontWeight:
//                                                                  FontWeight
//                                                                      .w300),
//                                                        ),
//                                                      ))
//                                                ],
//                                                mainAxisAlignment:
//                                                    MainAxisAlignment.end,
//                                                crossAxisAlignment:
//                                                    CrossAxisAlignment.end,
//                                              ),
//                                              Padding(
//                                                padding: EdgeInsets.only(
//                                                    left: 15, bottom: 15),
//                                                child: Center(
//                                                  child: Text(
//                                                    'Choose your Color',
//                                                    textAlign: TextAlign.right,
//                                                    style: TextStyle(
//                                                        fontFamily: 'Helvetica',
//                                                        fontSize: 18,
//                                                        color: Colors.black,
//                                                        fontWeight:
//                                                            FontWeight.bold),
//                                                  ),
//                                                ),
//                                              ),
//                                              Expanded(
//                                                child: GridView.builder(
//                                                  gridDelegate:
//                                                      SliverGridDelegateWithFixedCrossAxisCount(
//                                                          mainAxisSpacing: 5.0,
//                                                          crossAxisSpacing: 5.0,
//                                                          crossAxisCount: 4,
//                                                          childAspectRatio:
//                                                              1.3),
//                                                  itemBuilder: (_, i) {
//                                                    return Padding(
//                                                        padding:
//                                                            EdgeInsets.all(5),
//                                                        child: InkWell(
//                                                          onTap: () {
//                                                            if (selectedColors
//                                                                    .length >
//                                                                3) {
//                                                              selectedColors
//                                                                  .removeAt(0);
//                                                              selectedColors.add(
//                                                                  colorslist[
//                                                                      i]);
//                                                            } else if (selectedColors
//                                                                .contains(
//                                                                    colorslist[
//                                                                        i])) {
//                                                              selectedColors
//                                                                  .remove(
//                                                                      colorslist[
//                                                                          i]);
//                                                            } else {
//                                                              selectedColors.add(
//                                                                  colorslist[
//                                                                      i]);
//                                                            }
//                                                            updateState(() {
//                                                              selectedColors =
//                                                                  selectedColors;
//                                                            });
//                                                            setState(() {
//                                                              selectedColors =
//                                                                  selectedColors;
//                                                            });
//                                                          },
//                                                          child: Container(
//                                                              height: 30,
//                                                              width: 30,
//                                                              decoration:
//                                                                  BoxDecoration(
//                                                                shape: BoxShape
//                                                                    .circle,
//                                                                border:
//                                                                    Border.all(
//                                                                  color: Colors
//                                                                      .grey
//                                                                      .shade300,
//                                                                ),
//                                                                color:
//                                                                    colorslist[
//                                                                        i],
//                                                              ),
//                                                              child: selectedColors
//                                                                      .contains(
//                                                                          colorslist[
//                                                                              i])
//                                                                  ? Icon(
//                                                                      Icons
//                                                                          .check,
//                                                                      color: Colors
//                                                                          .white,
//                                                                    )
//                                                                  : Container()),
//                                                        ));
//                                                  },
//                                                  itemCount: colorslist.length,
//                                                ),
//                                              )
//                                            ])));
//                                  });
//                                });
//                          });
//                    },
//                    child: Container(
//                        height: 50,
//                        padding:
//                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.circular(5)),
//                        child: ListTile(
//                            contentPadding: EdgeInsets.zero,
//                            leading: Text(
//                              'Color',
//                              style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                            title: Row(
//                                crossAxisAlignment: CrossAxisAlignment.end,
//                                mainAxisAlignment: MainAxisAlignment.end,
//                                children: [
//                                  Expanded(
//                                      child: ListView.builder(
//                                    scrollDirection: Axis.horizontal,
//                                    itemCount: selectedColors.length,
//                                    itemBuilder: (context, index) {
//                                      return Container(
//                                          height: 30,
//                                          width: 30,
//                                          decoration: BoxDecoration(
//                                            shape: BoxShape.circle,
//                                            border: Border.all(
//                                              color: Colors.grey.shade300,
//                                            ),
//                                            color: selectedColors[index],
//                                          ));
//                                    },
//                                  ))
//                                ]),
//                            trailing: selectedColors != null
//                                ? Icon(
//                                    Icons.circle,
//                                    size: 16,
//                                    color: Colors.deepOrange,
//                                  )
//                                : Icon(Icons.chevron_right))))),
//            Divider(),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FilterPageLocation()));
                      if (result != null) {
                        setState(() {
                          selectedcity = true;
                          city = '';
                          selectedcities = result;
                          for (int i = 0; i < selectedcities.length; i++) {
                            city += selectedcities[i].title + ' ';
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
                              'City',
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
                                      city,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                ]),
                            trailing: selectedcondition == true
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
                              builder: (context) => FilterPageSort()));
                      if (result != null) {
                        setState(() {
                          selectedsort = true;
                          sort = '';
                          selectedsorts = result;
                          for (int i = 0; i < selectedsorts.length; i++) {
                            sort += selectedsorts[i].title + ' ';
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
                              'Sort',
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
                                      sort,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                ]),
                            trailing: selectedcondition == true
                                ? Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Colors.deepOrange,
                                  )
                                : Icon(Icons.chevron_right))))),
          ]))
        ],
      ),
    );
  }
}
