
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
            "Categories",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
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
                        height: 155,
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0,
                                          right: 5.0,
                                          top: 8.0,
                                          bottom: 5.0),
                                      child: Container(
                                          height: 155.0,
                                          width: 170.0,
                                          child: Column(children: <Widget>[
                                            Container(
                                              height: 100,
                                              width: 150,
                                              child: Image.asset(
                                                categories[i].image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                categories[i].title,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16.0,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ])),
                                    )),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: GridView.builder(
                          itemCount: categories[_selectedCat].subCat.length,
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
                                        builder: (context) => CategoryDetail(
                                            category:
                                                categories[_selectedCat].title,
                                            subcategory:
                                                categories[_selectedCat]
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
                                            MainAxisAlignment.spaceBetween,
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
                  ),
                ),
              ],
            )));
  }
}
