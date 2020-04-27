import 'dart:math';

import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:google_fonts/google_fonts.dart';

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
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          title: Text(
            "Categories",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 5,
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
                                          const EdgeInsets.only(bottom: 10.0),
                                      width: 110.0,
                                      constraints:
                                          BoxConstraints(minHeight: 110),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _selectedCat == i
                                            ? Colors.white
                                            : Colors.deepOrange,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade200,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(11.0),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            categories[i].icon,
                                            color: _selectedCat == i
                                                ? Colors.deepOrange
                                                : Colors.white,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${categories[i].title}",
                                            style: GoogleFonts.lato(
                                                fontSize: 16,
                                                color: _selectedCat == i
                                                    ? Colors.deepOrange
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
                                          style: GoogleFonts.lato(fontSize: 16),
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
