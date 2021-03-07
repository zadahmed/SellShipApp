import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';

import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PaymentDone extends StatefulWidget {
  String messageid;
  Item item;

  PaymentDone({Key key, this.messageid, this.item}) : super(key: key);
  @override
  _PaymentDoneState createState() => _PaymentDoneState();
}

class _PaymentDoneState extends State<PaymentDone> {
  Item item;
  String messageid;

  @override
  void initState() {
    super.initState();
    setState(() {
      item = widget.item;
      messageid = widget.messageid;
    });
  }

  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Purchase Successful',
            style: TextStyle(
                color: Colors.deepOrange,
                fontFamily: 'Helvetica',
                fontSize: 16),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
              height: 300,
              width: MediaQuery.of(context).size.width - 20,
              child: Image.asset(
                'assets/143.png',
                fit: BoxFit.fitHeight,
              )),
          SizedBox(
            height: 10,
          ),
          Text(
            'Hooray! Your item is on its way!\nLook out for the Postman!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.deepPurple,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              var countr = await storage.read(key: 'country');

              if (countr.trim().toLowerCase() == 'united arab emirates') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderBuyerUAE(
                            item: item,
                            messageid: messageid,
                          )),
                );
              } else if (countr.trim().toLowerCase() == 'united states') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderBuyer(
                            itemid: item.itemid,
                            messageid: messageid,
                          )),
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.4),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Center(
                  child: Text(
                    'View Order',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RootScreen()),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.4),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Back Home',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ])));
  }
}
