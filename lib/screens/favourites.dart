import 'dart:convert';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sellship/screens/details.dart';
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
  List<String> Itemprice = List<String>();

  getfavourites() async {
    userid = await storage.read(key: 'userid');
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget favourites(BuildContext context) {
    return loading == false
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                "Favourites ❤️",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: Colors.amber,
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                // rounded corners ad.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: AdmobBanner(
                  adUnitId: getBannerAdUnitId(),
                  adSize: AdmobBannerSize.LEADERBOARD,
                ),
              ),
            ),
            body: Padding(
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
                                return new InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Details(itemid: Itemid[Index])),
                                      );
                                    },
                                    child: Card(
                                        child: ListTile(
                                      title: Text(Itemname[Index]),
                                      trailing: Text(Itemprice[Index] + ' AED'),
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
                              'assets/sss.jpg',
                              fit: BoxFit.cover,
                            ))
                          ],
                        )),
                ],
              ),
            ))
        : Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
          );
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
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Favourites ❤️",
                    style: Theme.of(context).textTheme.display1.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    'Login to see your favourite\'s here ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                    child: Image.asset(
                  'assets/sss.jpg',
                  fit: BoxFit.cover,
                ))
              ],
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                // rounded corners ad.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: AdmobBanner(
                  adUnitId: getBannerAdUnitId(),
                  adSize: AdmobBannerSize.LEADERBOARD,
                ),
              ),
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
                    Text('Loading'),
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
