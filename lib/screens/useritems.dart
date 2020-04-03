import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sellship/screens/details.dart';

class UserItems extends StatefulWidget {
  final String userid;
  UserItems({Key key, this.userid}) : super(key: key);

  @override
  _UserItemsState createState() => new _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  var loading;
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      userid = widget.userid;
    });
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profile(context),
    );
  }

  var firstname;
  var lastname;
  var email;
  var phonenumber;

  List<String> Itemid = List<String>();
  List<String> Itemname = List<String>();
  List<String> Itemimage = List<String>();
  List<String> Itemcategory = List<String>();
  List<String> Itemprice = List<String>();

  final storage = new FlutterSecureStorage();

  void getProfileData() async {
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
          backgroundColor: Colors.amber,
          title: Center(
            child: Text(
              '$firstname\'s Items',
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
                              if (Index % 4 == 0) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.only(bottom: 20.0),
                                  child: AdmobBanner(
                                    adUnitId: getBannerAdUnitId(),
                                    adSize: AdmobBannerSize.LARGE_BANNER,
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
                  ],
                ),
              ))
            : Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
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
              ));
  }
}
