import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:shimmer/shimmer.dart';

class UserItems extends StatefulWidget {
  final String userid;
  final String username;
  UserItems({Key key, this.userid, this.username}) : super(key: key);

  @override
  _UserItemsState createState() => new _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  var loading;
  String userid;
  String username;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      userid = widget.userid;
      username = widget.username;
    });
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profile(context),
    );
  }

  static const _iosadUnitID = "ca-app-pub-9959700192389744/1316209960";

  static const _androidadUnitID = "ca-app-pub-9959700192389744/5957969037";

  final _controller = NativeAdmobController();

  var firstname;
  var lastname;
  var email;
  var phonenumber;

  List<String> Itemid = List<String>();
  List<String> Itemname = List<String>();
  List<String> Itemimage = List<String>();
  List<String> Itemcategory = List<String>();
  List<int> Itemprice = List<int>();

  final storage = new FlutterSecureStorage();
  var currency;
  void getProfileData() async {
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
      var url = 'https://sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;
        print(profilemap);

        var itemurl = 'https://sellship.co/api/useritems/' + userid;
        print(itemurl);
        final itemresponse = await http.get(itemurl);
        if (itemresponse.statusCode == 200) {
          var itemrespons = json.decode(itemresponse.body);
          Map<String, dynamic> itemmap = itemrespons;
          print(itemmap);

          var productmap = itemmap['products'];

          for (var i = 0; i < productmap.length; i++) {
            Itemid.add(productmap[i]['_id']['\$oid']);
            Itemname.add(productmap[i]['name']);
            Itemimage.add(productmap[i]['image']);
            Itemprice.add(productmap[i]['price']);
            Itemcategory.add(productmap[i]['category']);
          }
          setState(() {
            Itemid = Itemid;
            Itemname = Itemname;
            Itemimage = Itemimage;
            Itemprice = Itemprice;
            Itemcategory = Itemcategory;
          });
        } else {
          print('No Items');
        }

        if (mounted) {
          setState(() {
            firstname = profilemap['first_name'];
            lastname = profilemap['last_name'];
            phonenumber = profilemap['phonenumber'];
            email = profilemap['email'];
            loading = false;
          });
        }
      } else {
        print('Error');
      }
    }
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-9959700192389744/1339524606';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9959700192389744/3087720541';
    }
    return null;
  }

  Widget profile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            '$username\'s Items',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
      body: loading == false
          ? SafeArea(
              child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Divider(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                      child: new ListView.builder(
                          itemCount: Itemname.length,
                          itemBuilder: (BuildContext ctxt, int Index) {
                            if (Index != 0 && Index % 4 == 0) {
                              return Platform.isIOS == true
                                  ? Container(
                                      height: 200,
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      child: NativeAdmob(
                                        adUnitID: _iosadUnitID,
                                        controller: _controller,
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(bottom: 20.0),
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
                                        builder: (context) =>
                                            Details(itemid: Itemid[Index])),
                                  );
                                },
                                child: Card(
                                    child: ListTile(
                                  title: Text(Itemname[Index]),
                                  trailing: Text(Itemprice[Index].toString() +
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
            ),
    );
  }
}
