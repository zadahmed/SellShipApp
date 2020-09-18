import 'package:SellShip/screens/boysfashion.dart';
import 'package:SellShip/screens/girlsfashion.dart';
import 'package:SellShip/screens/menfashion.dart';
import 'package:SellShip/screens/womenfashion.dart';
import 'package:flutter/material.dart';
import 'package:SellShip/global.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Categories',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Color.fromRGBO(28, 45, 65, 1),
                fontWeight: FontWeight.w800),
          ),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(28, 45, 65, 1),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: ListView.builder(
                  key: Key('builder ${_selectedCat.toString()}'),
                  scrollDirection: Axis.vertical,
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: 15, left: 5, right: 5),
                                child: Container(
                                  height: 40,
                                  width: 50,
                                  child: Image.asset(
                                    categories[i].image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  categories[i].title,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      color: Color.fromRGBO(28, 45, 65, 1),
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Divider()
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCat = i;
                            });
                          },
                        ));
                  },
                ),
              ),
              Container(
                color: Color.fromRGBO(229, 233, 242, 1),
                width: MediaQuery.of(context).size.width * 0.8,
                child: StaggeredGridView.builder(
                  itemCount: categories[_selectedCat].subCat.length,
                  gridDelegate:
                      SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    staggeredTileCount: categories[_selectedCat].subCat.length,
                    staggeredTileBuilder: (index) => new StaggeredTile.fit(1),
                  ),
                  itemBuilder: (ctx, i) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryDetail(
                                    category: categories[_selectedCat].title,
                                    subcategory: categories[_selectedCat]
                                        .subCat[i]
                                        .title)),
                          );
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
//                                  Padding(
//                                    padding: EdgeInsets.only(
//                                        bottom: 10, left: 5, right: 5),
//                                    child: Container(
//                                      height: 90,
//                                      width: 150,
//                                      child: Image.asset(
//                                        categories[_selectedCat]
//                                            .subCat[i]
//                                            .image,
//                                        fit: BoxFit.contain,
//                                      ),
//                                    ),
//                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      "${categories[_selectedCat].subCat[i].title}",
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Color.fromRGBO(28, 45, 65, 1),
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )));
                  },
                ),
              )
            ])));
  }
}
