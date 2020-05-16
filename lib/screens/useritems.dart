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
  List<String> Itemprice = List<String>();
  List<bool> Itemsold = List<bool>();

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
        currency = '\$';
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
            Itemprice.add(productmap[i]['price'].toString());
            Itemcategory.add(productmap[i]['category']);
            Itemsold.add(
                profilemap[i]['sold'] == null ? false : profilemap[i]['sold']);
          }
          setState(() {
            Itemid = Itemid;
            Itemname = Itemname;
            Itemimage = Itemimage;
            Itemprice = Itemprice;
            Itemcategory = Itemcategory;
            Itemsold = Itemsold;
          });
        } else {
          print('No Items');
        }
        var follower = profilemap['follower'];
        print(follower);
        if (follower != null) {
          for (int i = 0; i < follower.length; i++) {
            var meuser = await storage.read(key: 'userid');
            if (meuser == follower[i]['\$oid']) {
              setState(() {
                follow = true;
              });
            }
          }
        } else {
          follower = [];
        }

        var followin = profilemap['following'];
        if (followin != null) {
          print(followin);
        } else {
          followin = [];
        }

        var sol = profilemap['sold'];
        if (sol != null) {
          print(sol);
        } else {
          sol = [];
        }

        var profilepic = profilemap['profilepicture'];
        if (profilepic != null) {
          print(profilepic);
        } else {
          profilepic = null;
        }

        if (mounted) {
          setState(() {
            firstname = profilemap['first_name'];
            lastname = profilemap['last_name'];
            phonenumber = profilemap['phonenumber'];
            email = profilemap['email'];
            followers = follower.length;
            itemssold = sol.length;
            following = followin.length;
            loading = false;
            profilepicture = profilepic;
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
        title: Text(
          '$username'.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'SF', fontSize: 16),
        ),
      ),
      body: loading == false
          ? LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                  controller: _scrollController,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: profilepicture == null
                                  ? Image.asset(
                                      'assets/personplaceholder.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      profilepicture,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(height: 25.0),
                          Text(
                            firstname + ' ' + lastname,
                            style: TextStyle(
                                fontFamily: 'SF',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10, left: 30, right: 30, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      followers == null
                                          ? '0'
                                          : followers.toString(),
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'FOLLOWERS',
                                      style: TextStyle(
                                          fontFamily: 'SF', color: Colors.grey),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      itemssold == null
                                          ? '0'
                                          : itemssold.toString(),
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'ITEMS SOLD',
                                      style: TextStyle(
                                          fontFamily: 'SF', color: Colors.grey),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      following == null
                                          ? '0'
                                          : following.toString(),
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'FOLLOWING',
                                      style: TextStyle(
                                          fontFamily: 'SF', color: Colors.grey),
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
                                onTap: () async {
                                  if (follow == true) {
                                    var user1 =
                                        await storage.read(key: 'userid');
                                    var followurl =
                                        'https://sellship.co/api/follow/' +
                                            user1 +
                                            '/' +
                                            userid;

                                    final followresponse =
                                        await http.get(followurl);
                                    if (followresponse.statusCode == 200) {
                                      print('UnFollowed');
                                    }
                                    setState(() {
                                      follow = false;
                                      followers = followers - 1;
                                    });
                                  } else {
                                    var user1 =
                                        await storage.read(key: 'userid');
                                    var followurl =
                                        'https://sellship.co/api/follow/' +
                                            user1 +
                                            '/' +
                                            userid;

                                    final followresponse =
                                        await http.get(followurl);
                                    if (followresponse.statusCode == 200) {
                                      print('Followed');
                                    }

                                    setState(() {
                                      follow = true;
                                      followers = followers + 1;
                                    });
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    follow == true ? 'FOLLOWING' : 'FOLLOW',
                                    style: TextStyle(
                                        fontFamily: 'SF',
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
                              '$firstname\'s Items',
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Itemname.isNotEmpty
                              ? Flexible(
                                  child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: GridView.builder(
                                        cacheExtent: double.parse(
                                            Itemname.length.toString()),
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 0.65),
                                        itemCount: Itemname.length,
                                        itemBuilder: (context, index) {
                                          if (index != 0 && index % 4 == 0) {
                                            return Platform.isIOS == true
                                                ? Container(
                                                    height: 330,
                                                    padding: EdgeInsets.all(10),
                                                    margin: EdgeInsets.only(
                                                        bottom: 20.0),
                                                    child: NativeAdmob(
                                                      adUnitID: _iosadUnitID,
                                                      controller: _controller,
                                                    ),
                                                  )
                                                : Container(
                                                    height: 330,
                                                    padding: EdgeInsets.all(10),
                                                    margin: EdgeInsets.only(
                                                        bottom: 20.0),
                                                    child: NativeAdmob(
                                                      adUnitID:
                                                          _androidadUnitID,
                                                      controller: _controller,
                                                    ),
                                                  );
                                          }
                                          return Padding(
                                              padding: EdgeInsets.all(4),
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Details(
                                                                  itemid: Itemid[
                                                                      index])),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        new Stack(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 150,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      Itemimage[
                                                                          index],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepOrange),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ),
                                                            Itemsold[index] ==
                                                                    true
                                                                ? Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          20,
                                                                      width: 50,
                                                                      color: Colors
                                                                          .amber,
                                                                      child:
                                                                          Text(
                                                                        'Sold',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'SF',
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ))
                                                                : Container(),
                                                          ],
                                                        ),
                                                        new Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        5.0),
                                                                child: new Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            Itemname[index],
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'SF',
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 3.0),
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              Itemcategory[index],
                                                                              style: TextStyle(
                                                                                fontFamily: 'SF',
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w300,
                                                                              ),
                                                                              textAlign: TextAlign.left,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 3.0),
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              currency + ' ' + Itemprice[index].toString(),
                                                                              style: TextStyle(
                                                                                fontFamily: 'SF',
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                              textAlign: TextAlign.left,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ])))
                                                      ],
                                                    ),
                                                  )));
                                        },
                                      )))
                              : Expanded(
                                  child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        'Go ahead Add an Item \n and start selling!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'SF',
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
                      )));
            })
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
