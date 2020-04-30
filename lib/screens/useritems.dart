import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  var profilepicture;

  var followers;
  var itemssold;
  var following;
  var totalitems;

  ScrollController _scrollController = ScrollController();

  var follow;

  Widget profile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            '$username',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
          ),
        ),
      ),
      body: loading == false
          ? Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(100)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: profilepicture == null
                        ? Image.asset(
                            'assets/personplaceholder.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(''),
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  firstname + ' ' + lastname,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Padding(
                  padding:
                      EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            followers == null ? '0' : followers.toString(),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'FOLLOWERS',
                            style: TextStyle(
                                fontFamily: 'Montserrat', color: Colors.grey),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            itemssold == null ? '0' : itemssold.toString(),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'ITEMS SOLD',
                            style: TextStyle(
                                fontFamily: 'Montserrat', color: Colors.grey),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            following == null ? '0' : following.toString(),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'FOLLOWING',
                            style: TextStyle(
                                fontFamily: 'Montserrat', color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 400,
                    decoration: BoxDecoration(color: Colors.amber),
                    child: InkWell(
                      onTap: () {},
                      child: Center(
                        child: Text(
                          follow == true ? 'FOLLOWING' : 'FOLLOW',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Center(
                  child: Text(
                    'My Items',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Itemname.isNotEmpty
                    ? Expanded(
                        child: StaggeredGridView.countBuilder(
                        controller: _scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        itemCount: Itemname.length,
                        itemBuilder: (context, index) {
                          if (index != 0 && index % 4 == 0) {
                            return Platform.isIOS == true
                                ? Container(
                                    height: 330,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _iosadUnitID,
                                      controller: _controller,
                                    ),
                                  )
                                : Container(
                                    height: 330,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    child: NativeAdmob(
                                      adUnitID: _androidadUnitID,
                                      controller: _controller,
                                    ),
                                  );
                          }
                          return Padding(
                              padding: EdgeInsets.all(7),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Details(itemid: Itemid[index])),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: new Column(
                                      children: <Widget>[
                                        new Stack(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: CachedNetworkImage(
                                                imageUrl: Itemimage[index],
                                                placeholder: (context, url) =>
                                                    SpinKitChasingDots(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                Itemname[index],
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 3.0),
                                              Container(
                                                child: Text(
                                                  Itemcategory[index],
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              SizedBox(height: 3.0),
                                              Container(
                                                child: Text(
                                                  Itemprice[index].toString() +
                                                      ' ' +
                                                      currency,
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )));
                        },
                        staggeredTileBuilder: (int index) {
                          return StaggeredTile.fit(1);
                        },
                      ))
                    : Expanded(
                        child: Column(
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Go ahead Add an Item \n and start selling!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Image.asset(
                            'assets/items.png',
                            fit: BoxFit.fitWidth,
                          ))
                        ],
                      )),
              ],
            )
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
