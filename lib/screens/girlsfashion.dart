import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/subcategory.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GirlsFashion extends StatefulWidget {
  GirlsFashion({Key key}) : super(key: key);
  @override
  _GirlsFashionState createState() => _GirlsFashionState();
}

class _GirlsFashionState extends State<GirlsFashion> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Girls Fashion',
          style: TextStyle(
              fontFamily: 'SF',
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GridView.count(
          physics: ScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Bags")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsbag.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Bags',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Bottoms")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsbottom.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Bottoms',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Dresses")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsdress.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Dresses',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Hats")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlshats.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Hats',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Accessories")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsjewlery.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Accessories',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Jumpsuits")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsjumpsuit.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Jumpsuits',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Nightwear & Loungewear")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsnightwear.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Nightwear & Loungewear',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Socks")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlssocks.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Socks',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Hoodies & Sweatshirts")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlssweatshirt.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Hoodies & Sweatshirts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Swimwear & Beachwear")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlsswim.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Swimwear & Beachwear',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategory(
                          sub: 'Girls',
                          category: 'Fashion & Accessories',
                          subcategory: "Tops and Tees")),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/girls/girlstop.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                              height: 40,
                              width: 120,
                              color: Colors.white,
                              child: Center(
                                child: Text('Tops and Tees',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black)),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
