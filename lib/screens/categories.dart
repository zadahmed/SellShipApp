import 'package:SellShip/screens/boysfashion.dart';
import 'package:SellShip/screens/girlsfashion.dart';
import 'package:SellShip/screens/menfashion.dart';
import 'package:SellShip/screens/womenfashion.dart';
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
    super.initState();
    setState(() {
      _selectedCat = widget.selectedcategory;
    });
  }

  final scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          title: Text(
            'CATEGORIES',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  key: Key('builder ${_selectedCat.toString()}'),
                  scrollDirection: Axis.vertical,
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        child: ExpansionTile(
                          key: Key(i.toString()),
                          initiallyExpanded: i == _selectedCat ? true : false,
                          leading: Icon(
                            categories[i].icon,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            categories[i].title,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          onExpansionChanged: (changed) {
                            if (changed == true) {
                              setState(() {
                                _selectedCat = i;
                              });
                            } else {
                              setState(() {
                                _selectedCat = -1;
                              });
                            }
                          },
                          children: <Widget>[
                            Container(
                              height: 300,
                              child: GridView.builder(
                                itemCount: categories[i].subCat.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.1,
                                ),
                                itemBuilder: (ctx, i) {
                                  return InkWell(
                                      onTap: () {
                                        if (categories[_selectedCat]
                                                .subCat[i]
                                                .title ==
                                            'Women') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WomenFashion()),
                                          );
                                        } else if (categories[_selectedCat]
                                                .subCat[i]
                                                .title ==
                                            'Men') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MensFashion()),
                                          );
                                        } else if (categories[_selectedCat]
                                                .subCat[i]
                                                .title ==
                                            'Boys') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BoysFashion()),
                                          );
                                        } else if (categories[_selectedCat]
                                                .subCat[i]
                                                .title ==
                                            'Girls') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GirlsFashion()),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryDetail(
                                                        category: categories[
                                                                _selectedCat]
                                                            .title,
                                                        subcategory: categories[
                                                                _selectedCat]
                                                            .subCat[i]
                                                            .title)),
                                          );
                                        }
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: 120,
                                            width: 150,
                                            color: Colors.white,
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Container(
                                                    height: 90,
                                                    width: 150,
                                                    child: Image.asset(
                                                      categories[_selectedCat]
                                                          .subCat[i]
                                                          .image,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    "${categories[_selectedCat].subCat[i].title}",
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )));
                                },
                              ),
                            )
                          ],
                        ));
                  },
                ),
              )
            ])));
  }
}
