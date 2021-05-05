import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/store/createlayout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as Permission;
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChooseSaleProducts extends StatefulWidget {
  final String storeid;

  ChooseSaleProducts({
    Key key,
    this.storeid,
  }) : super(key: key);

  @override
  _ChooseSaleProductsState createState() => new _ChooseSaleProductsState();
}

class _ChooseSaleProductsState extends State<ChooseSaleProducts> {
  getItemData() async {
    var itemurl = 'https://api.sellship.co/store/products/' + widget.storeid;

    final itemresponse = await http.get(Uri.parse(itemurl));
    if (itemresponse.statusCode == 200) {
      var itemrespons = json.decode(itemresponse.body);
      print(itemrespons);

      List<Item> ites = List<Item>();
      if (itemrespons != null) {
        for (var i = 0; i < itemrespons.length; i++) {
          Item ite = Item(
              approved: itemrespons[i]['approved'],
              itemid: itemrespons[i]['_id']['\$oid'],
              name: itemrespons[i]['name'],
              image: itemrespons[i]['image'],
              price: itemrespons[i]['price'].toString(),
              views: itemrespons[i]['views'] == null
                  ? 0
                  : int.parse(itemrespons[i]['views'].toString()),
              likes:
                  itemrespons[i]['likes'] == null ? 0 : itemrespons[i]['likes'],
              comments: itemrespons[i]['comments'] == null
                  ? 0
                  : itemrespons[i]['comments'].length,
              sold: itemrespons[i]['sold'] == null
                  ? false
                  : itemrespons[i]['sold'],
              category: itemrespons[i]['category']);
          if (ite.approved == true && ite.sold == false) {
            ites.add(ite);
          }
        }
        if (mounted)
          setState(() {
            item = ites;
            loading = false;
          });
      } else {
        if (mounted)
          setState(() {
            item = [];
            loading = false;
          });
      }
    } else {
      print(itemresponse.statusCode);
    }
  }

  List<Item> item = List<Item>();

  bool loading = true;

  @override
  void initState() {
    super.initState();

    getItemData();
  }

  List<Item> choosenproducts = List<Item>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Choose Sale Products',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 20),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context, choosenproducts);
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    decoration: BoxDecoration(
                      color: choosenproducts.length >= 1
                          ? Color.fromRGBO(255, 115, 0, 1)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Text(
                      'Done',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ]),
        ),
        body: loading == false
            ? item.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (choosenproducts.contains(item[index])) {
                              choosenproducts.remove(item[index]);
                            } else {
                              choosenproducts.add(item[index]);
                            }
                            setState(() {
                              choosenproducts = choosenproducts;
                            });
                          },
                          child: Container(
                            height: 150,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(children: [
                                  Container(
                                    height: 128,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        height: 200,
                                        width: 300,
                                        fadeInDuration:
                                            Duration(microseconds: 5),
                                        imageUrl: item[index].image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            SpinKitDoubleBounce(
                                                color: Colors.deepOrange),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  choosenproducts.contains(item[index])
                                      ? Container(
                                          height: 128,
                                          width: 128,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 28,
                                          ))
                                      : Container(),
                                ]),
                                Text(
                                  item[index].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'AED ' + item[index].price,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: item.length,
                    ),
                  )
                : Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset('assets/051.png',
                              fit: BoxFit.fitHeight),
                        ),
                        Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Oops! Looks like you don\'t have any items to put on Sale.',
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 18.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            )),
                      ]))
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                ),
              ));
  }
}
