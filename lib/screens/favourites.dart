import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  var userid;
  final storage = new FlutterSecureStorage();

  List<String> Itemid = List<String>();
  List<String> Itemname = List<String>();
  List<String> Itemimage = List<String>();
  List<String> Itemcategory = List<String>();
  List<int> Itemprice = List<int>();

  var currency;
  getfavourites() async {
    userid = await storage.read(key: 'userid');
    var country = await storage.read(key: 'country');
    if (country.trim().toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (country.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = 'USD';
      });
    }
    print(userid);
    if (userid != null) {
      var url = 'https://sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          print(profilemap);
          for (var i = 0; i < profilemap.length; i++) {
            Itemid.add(profilemap[i]['_id']['\$oid']);
            Itemname.add(profilemap[i]['name']);
            Itemimage.add(profilemap[i]['image']);
            Itemprice.add(profilemap[i]['price']);
            Itemcategory.add(profilemap[i]['category']);
          }

          setState(() {
            Itemid = Itemid;
            Itemname = Itemname;
            Itemimage = Itemimage;
            Itemprice = Itemprice;
            Itemcategory = Itemcategory;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
            empty = true;
          });
        }
      } else {
        setState(() {
          empty = true;
          loading = false;
        });
      }
    } else {
      setState(() {
        empty = true;
        loading = false;
      });
    }
  }

  var loading;
  var empty;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      empty = false;
    });
    getfavourites();
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget favourites(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Favourites️",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepOrange,
        ),
        body: loading == false
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Itemname.isNotEmpty
                        ? Expanded(
                            child: new ListView.builder(
                                itemCount: Itemname.length,
                                itemBuilder: (BuildContext ctxt, int Index) {
                                  if (Index != 0 && Index % 4 == 0) {
                                    return Platform.isIOS == true
                                        ? Container(
                                            height: 200,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            child: NativeAdmob(
                                              adUnitID: _iosadUnitID,
                                              controller: _controller,
                                            ),
                                          )
                                        : Container(
                                            height: 200,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            child: NativeAdmob(
                                              adUnitID: _androidadUnitID,
                                              controller: _controller,
                                            ),
                                          );
                                  }
                                  return new InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Details(
                                                  itemid: Itemid[Index])),
                                        );
                                      },
                                      child: Card(
                                          child: ListTile(
                                        title: Text(Itemname[Index]),
                                        trailing: Text(
                                            Itemprice[Index].toString() +
                                                ' ' +
                                                currency),
                                        leading: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Image.network(
                                            Itemimage[Index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        subtitle: Text(Itemcategory[Index]),
                                      )));
                                }))
                        : Expanded(
                            child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'View your favourites here!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/favourites.png',
                                fit: BoxFit.cover,
                              ))
                            ],
                          )),
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Column(
                    children: [0, 1, 2, 3, 4, 5, 6]
                        .map((_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: 40.0,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ));
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  Widget emptyfavourites(BuildContext context) {
    return loading == false
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                "Favourites",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.deepOrange,
            ),
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text('View your favourite\'s here ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                      )),
                ),
                Expanded(
                    child: Image.asset(
                  'assets/favourites.png',
                  fit: BoxFit.fitWidth,
                ))
              ],
            ),
          )
        : Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 100,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return empty == false ? favourites(context) : emptyfavourites(context);
  }
}
