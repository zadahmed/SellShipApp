import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FeatureItem extends StatefulWidget {
  @override
  _FeatureItemState createState() => _FeatureItemState();
}

class _FeatureItemState extends State<FeatureItem> {
  var currency;
  var stripecurrency;
  final storage = new FlutterSecureStorage();

  var onedayprice;
  var oneweekprice;
  var twoweekprice;
  var onemonthprice;

  getcurrency() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        stripecurrency = 'AED';
        onedayprice = 3.99;
        oneweekprice = 19.99;
        twoweekprice = 39.99;
        onemonthprice = 59.99;
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        stripecurrency = 'USD';
        onedayprice = 0.99;
        oneweekprice = 4.99;
        twoweekprice = 12.99;
        onemonthprice = 29.99;
      });
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
        stripecurrency = 'CAD';
        onedayprice = 0.99;
        oneweekprice = 4.99;
        twoweekprice = 12.99;
        onemonthprice = 29.99;
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\$';
        stripecurrency = 'GBP';
        onedayprice = 0.99;
        oneweekprice = 4.99;
        twoweekprice = 12.99;
        onemonthprice = 29.99;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getcurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boost'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
