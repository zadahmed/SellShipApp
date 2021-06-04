import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/filterpage.dart';
import 'package:SellShip/screens/home.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:SellShip/screens/notifications.dart';
import 'package:SellShip/screens/storepage.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:badges/badges.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:SellShip/screens/comments.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:SellShip/models/Items.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class AllStores extends StatefulWidget {
  AllStores({
    Key key,
  }) : super(key: key);

  @override
  _AllStoresState createState() => _AllStoresState();
}

class _AllStoresState extends State<AllStores> {
  @override
  void initState() {
    super.initState();
    getallstores();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:ViewAllStores',
      screenClassOverride: 'AppViewAllStores',
    );
  }

  getallstores() async {
    var url = "https://api.sellship.co/api/all/stores";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      for (var jsondata in jsonbody) {
        print(jsondata['approved']);
        var approved;
        if (jsondata['approved'] == null) {
          approved = false;
        } else {
          approved = jsondata['approved'];
        }
        if (approved == true) {
          Stores store = Stores(
              approved: approved,
              storename: jsondata['storename'],
              storeid: jsondata['_id']['\$oid'],
              storetype: jsondata['storetype'],
              storelogo: jsondata['storelogo'],
              storecategory: jsondata['storecategory']);
          storeList.add(store);
          stores.add(jsondata['storename']);
        }

        if (mounted) {
          setState(() {
            storeList = storeList.toSet().toList();
            stores = stores;
            loading = false;
          });
        }
      }
    }
  }

  bool loading = true;
  List<String> stores = new List<String>();
  List<Stores> storeList = new List<Stores>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                FeatherIcons.chevronLeft,
                color: Colors.black,
              ),
            ),
            title: Text(
              'All Stores',
              style: TextStyle(
                fontFamily: 'Helvetica',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )),
        body: loading == false
            ? ListView.builder(
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {},
                    child: Padding(
                        padding: EdgeInsets.all(1),
                        child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StorePublic(
                                            storename:
                                                storeList[index].storename,
                                            storeid: storeList[index].storeid,
                                          )),
                                );
                              },
                              leading: storeList[index].storelogo != null &&
                                      storeList[index].storelogo.isNotEmpty
                                  ? Container(
                                      height: 50,
                                      width: 50,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                            height: 200,
                                            width: 300,
                                            imageUrl:
                                                storeList[index].storelogo,
                                            fit: BoxFit.cover,
                                          )),
                                    )
                                  : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.deepOrangeAccent
                                          .withOpacity(0.3),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.asset(
                                          'assets/personplaceholder.png',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )),
                              title: Text(
                                storeList[index].storename.toUpperCase(),
                                style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                storeList[index].storecategory,
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Divider()
                          ],
                        )
//
                        ),
                  );
                })
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrangeAccent,
                ),
              ));
  }
}
