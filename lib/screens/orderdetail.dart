import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OrderDetail extends StatefulWidget {
  String messageid;
  Item item;

  OrderDetail({Key key, this.messageid, this.item}) : super(key: key);
  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  Item item;
  String messageid;

  @override
  void initState() {
    super.initState();
    setState(() {
      item = widget.item;
      messageid = widget.messageid;
    });
    getDetails();
  }

  var userid;
  var currency;

  final storage = new FlutterSecureStorage();

  getDetails() async {
    userid = await storage.read(key: 'userid');

    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Order Detail',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Item Information',
                style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Details(
                                itemid: item.itemid,
                              )),
                    );
                  },
                  child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        leading: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          item.category,
                          style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 14,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          currency + ' ' + item.price.toString(),
                          style: TextStyle(
                              fontFamily: 'SF',
                              fontSize: 14,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                      )))),
          Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Seller Information',
                style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: InkWell(
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Center(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserItems(
                                userid: item.userid, username: item.username)),
                      );
                    },
                    dense: true,
                    leading: Icon(FontAwesome.user_circle),
                    title: Text(
                      item.username,
                      style: TextStyle(
                          fontFamily: 'SF', fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ])));
  }
}
