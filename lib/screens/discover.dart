import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/categorydetail.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/subcategory.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Discover extends StatefulWidget {
  Discover({Key key}) : super(key: key);
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mens Fashion',
          style: TextStyle(
              fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Shoes & Boots")),
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
                          'assets/men/shoes.jpeg',
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
                                child: Text('Shoes & Boots',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Activewear & Sportswear")),
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
                          'assets/men/active.jpeg',
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
                                child: Text('Activewear & Sportswear',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Polo Shirts & T- Shirts")),
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
                          'assets/men/polo.jpeg',
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
                                child: Text('Polo Shirts & T- Shirts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Shirts")),
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
                          'assets/men/shirt.jpeg',
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
                                child: Text('Shirts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Sneakers")),
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
                          'assets/men/shoes.jpeg',
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
                                child: Text('Sneakers',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Loafers & slip-ons")),
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
                          'assets/men/formalshoes.jpeg',
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
                                child: Text('Loafers & slip-ons',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Formal shoes")),
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
                          'assets/men/formsl.jpeg',
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
                                child: Text('Formal shoes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Sports shoes")),
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
                          'assets/men/sports.jpeg',
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
                                child: Text('Sports shoes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Bags & Wallet")),
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
                          'assets/men/wallet.jpeg',
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
                                child: Text('Bags & Wallet',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Coats & Jackets")),
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
                          'assets/men/jackets.jpeg',
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
                                child: Text('Coats & Jackets',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Jumpers & Cardigans")),
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
                          'assets/men/coats.jpeg',
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
                                child: Text('Jumpers & Cardigans',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Trousers")),
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
                          'assets/men/pants.jpeg',
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
                                child: Text('Trousers',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Hair accessories")),
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
                          'assets/men/hair.jpeg',
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
                                child: Text('Hair accessories',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Belts")),
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
                          'assets/men/belts.jpeg',
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
                                child: Text('Belts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Eyewear")),
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
                          'assets/men/eyewear.jpeg',
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
                                child: Text('Eyewear',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Sunglasses")),
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
                          'assets/men/sunglasses.jpeg',
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
                                child: Text('Sunglasses',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
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
                          'assets/men/nightwear.jpeg',
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
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
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
                          'assets/men/hoodie.jpeg',
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
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Jeans")),
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
                          'assets/men/jeans.jpeg',
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
                                child: Text('Jeans',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Suits & Blazers")),
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
                          'assets/men/suits.jpeg',
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
                                child: Text('Suits & Blazers',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
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
                          'assets/men/swimshorts.jpeg',
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
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Shorts")),
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
                          'assets/men/shorts.jpeg',
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
                                child: Text('Shorts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
                          sub: 'Men',
                          category: 'Fashion & Accessories',
                          subcategory: "Others")),
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
                          'assets/men/jackets.jpeg',
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
                                child: Text('Others',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
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
