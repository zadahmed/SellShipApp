import 'dart:math';

import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categorydetail.dart';

class CategoryScreen extends StatefulWidget {
  final int selectedcategory;
  CategoryScreen({Key key, this.selectedcategory}) : super(key: key);
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCat;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedCat = widget.selectedcategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
          title: Text(
            "Categories",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        margin: const EdgeInsets.only(right: 15.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (ctx, i) {
                            return Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCat = i;
                                    });
                                  },
                                  child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 25.0),
                                      width: 110.0,
                                      constraints:
                                          BoxConstraints(minHeight: 101),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _selectedCat == i
                                            ? Colors.transparent
                                            : Colors.amberAccent,
                                        borderRadius:
                                            BorderRadius.circular(11.0),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            categories[i].icon,
                                            color: _selectedCat == i
                                                ? Colors.amberAccent
                                                : Colors.white,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${categories[i].title}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .button
                                                .copyWith(
                                                    color: _selectedCat == i
                                                        ? Colors.amberAccent
                                                        : Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                      )),
                                ),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            );
                          },
                        ),
                      ),

//                  Content of categories
                      Expanded(
                        flex: 4,
                        child: ListView.builder(
                          itemCount: categories[_selectedCat].subCat.length,
                          itemBuilder: (ctx, i) {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryDetail(
                                            category:
                                                categories[_selectedCat].title,
                                            subcategory:
                                                categories[_selectedCat]
                                                    .subCat[i]
                                                    .title)),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(9.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${categories[_selectedCat].subCat[i].title}",
                                        ),
                                      ),
                                      Icon(Icons.chevron_right)
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
