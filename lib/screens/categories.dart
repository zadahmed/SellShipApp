
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          title: Text(
            'CATEGORIES',
            style: TextStyle(
                fontFamily: 'Montserrat',
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
                  scrollDirection: Axis.vertical,
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        child: ExpansionTile(
                          leading: Icon(
                            categories[i].icon,
                            color: Colors.deepOrange,
                          ),
                          title: Text(
                            categories[i].title,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          onExpansionChanged: (changed) {
                            if (changed == true) {
                              _selectedCat = i;
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
                                  childAspectRatio: (140 / 80),
                                ),
                                itemBuilder: (ctx, i) {
                                  return InkWell(
                                      onTap: () {
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
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: 80,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    "${categories[_selectedCat].subCat[i].title}",
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.chevron_right)
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
