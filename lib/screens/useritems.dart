import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_icons/flutter_icons.dart';
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
  final scaffoldState = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      userid = widget.userid;
      username = widget.username;
    });
    getProfileData();
    getfavourites();
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

  List<Item> itemsgrid = [];

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
      var url = 'https://api.sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;
        print(profilemap);

        var itemurl = 'https://api.sellship.co/api/useritems/' + userid;
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
                productmap[i]['sold'] == null ? false : productmap[i]['sold']);

            var q = Map<String, dynamic>.from(productmap[i]['dateuploaded']);

            DateTime dateuploade =
                DateTime.fromMillisecondsSinceEpoch(q['\$date']);
            var dateuploaded = timeago.format(dateuploade);
            Item item = Item(
              itemid: productmap[i]['_id']['\$oid'],
              date: dateuploaded,
              name: productmap[i]['name'],
              condition: productmap[i]['condition'] == null
                  ? 'Like New'
                  : productmap[i]['condition'],
              username: productmap[i]['username'],
              image: productmap[i]['image'],
              likes:
                  productmap[i]['likes'] == null ? 0 : productmap[i]['likes'],
              comments: productmap[i]['comments'] == null
                  ? 0
                  : productmap[i]['comments'].length,
              price: productmap[i]['price'].toString(),
              category: productmap[i]['category'],
              sold:
                  productmap[i]['sold'] == null ? false : productmap[i]['sold'],
            );
            itemsgrid.add(item);
          }

          if (itemsgrid != null) {
            setState(() {
              itemsgrid = itemsgrid;
            });
          } else {
            setState(() {
              itemsgrid = [];
            });
          }
        } else {
          print('No Items');
        }
        var follower = profilemap['follower'];

        if (follower != null) {
          for (int i = 0; i < follower.length; i++) {
            var meuser = await storage.read(key: 'userid');
            if (meuser == follower[i]['\$oid']) {
              setState(() {
                follow = true;
                followcolor = Colors.deepPurple;
              });
            }
          }
        } else {
          follower = [];
        }

        var followin = profilemap['likes'];
        if (followin != null) {
          print(followin);
        } else {
          followin = 0;
        }

        var sol = profilemap['sold'];
        if (sol != null) {
          print(sol);
        } else {
          sol = [];
        }

        var confirmedemai = profilemap['confirmedemail'];
        if (confirmedemai != null) {
          print(confirmedemai);
        } else {
          confirmedemai = false;
        }

        var confirmedphon = profilemap['confirmedphone'];
        if (confirmedphon != null) {
          print(confirmedphon);
        } else {
          confirmedphon = false;
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
            following = followin;
            confirmedemail = confirmedemai;
            confirmedphone = confirmedphon;
            loading = false;
            profilepicture = profilepic;
          });
        }
      } else {
        print('Error');
      }
    }
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldState.currentState?.removeCurrentSnackBar();
    scaffoldState.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  bool gridtoggle = true;
  List<String> favourites;

  getfavourites() async {
    var userid = await storage.read(key: 'userid');
    if (userid != null) {
      var url = 'https://api.sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body != 'Empty') {
          var respons = json.decode(response.body);
          var profilemap = respons;
          List<String> ites = List<String>();

          if (profilemap != null) {
            for (var i = 0; i < profilemap.length; i++) {
              ites.add(profilemap[i]['_id']['\$oid']);
            }

            Iterable inReverse = ites.reversed;
            List<String> jsoninreverse = inReverse.toList();
            setState(() {
              favourites = jsoninreverse;
            });
          } else {
            favourites = [];
          }
        }
      }
    } else {
      setState(() {
        favourites = [];
      });
    }
    print(favourites);
  }

  bool confirmedemail;
  bool confirmedphone;

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

  Color followcolor = Colors.deepOrange;
  var totalitems;

  ScrollController _scrollController = ScrollController();

  var follow = false;

  Widget profile(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? CustomScrollView(slivers: <Widget>[
                  SliverAppBar(
                    snap: false,
                    floating: true,
                    pinned: true,
                    iconTheme: IconThemeData(color: Colors.deepPurple),
                    backgroundColor: Colors.white,
                    title: Text(
                      '$username'.toUpperCase(),
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                          color: Colors.white,
                          width: double.infinity,
//                  height: MediaQuery.of(context).size.height,
                          child: Column(children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: profilepicture == null
                                            ? Image.asset(
                                                'assets/personplaceholder.png',
                                                fit: BoxFit.fill,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: profilepicture,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitChasingDots(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                      ),
                                    ),
                                    Container(
                                      width: 150,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          capitalize(firstname) +
                                              ' ' +
                                              capitalize(lastname),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 20, right: 30, bottom: 30),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            itemssold == null
                                                ? '0'
                                                : itemssold.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            'Sold',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Helvetica',
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            following == null
                                                ? '0'
                                                : following.toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            'Likes',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Helvetica',
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            followers == null
                                                ? '0'
                                                : followers.toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            'Followers',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Helvetica',
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.0),
                            SizedBox(height: 4.0),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      confirmedemail == true
                                          ? Badge(
                                              showBadge: true,
                                              badgeColor:
                                                  Colors.deepOrangeAccent,
                                              position:
                                                  BadgePosition.topRight(),
                                              animationType:
                                                  BadgeAnimationType.slide,
                                              badgeContent: Icon(
                                                Feather.check_circle,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 0.2,
                                                        color: Colors.grey),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: CircleAvatar(
                                                    child: Icon(
                                                      Feather.mail,
                                                      color: Colors.deepOrange,
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  )))
                                          : Badge(
                                              showBadge: true,
                                              badgeColor: Colors.grey,
                                              position:
                                                  BadgePosition.topRight(),
                                              animationType:
                                                  BadgeAnimationType.slide,
                                              badgeContent: Icon(
                                                FontAwesome.question,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Feather.mail,
                                                    color: Colors.deepOrange,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      confirmedphone == true
                                          ? Badge(
                                              showBadge: true,
                                              badgeColor:
                                                  Colors.deepOrangeAccent,
                                              position:
                                                  BadgePosition.topRight(),
                                              animationType:
                                                  BadgeAnimationType.slide,
                                              badgeContent: Icon(
                                                Feather.check_circle,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 0.2,
                                                        color: Colors.grey),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: CircleAvatar(
                                                    child: Icon(
                                                      Feather.phone,
                                                      color: Colors.deepOrange,
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  )))
                                          : Badge(
                                              showBadge: true,
                                              badgeColor: Colors.grey,
                                              position:
                                                  BadgePosition.topRight(),
                                              animationType:
                                                  BadgeAnimationType.slide,
                                              badgeContent: Icon(
                                                FontAwesome.question,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.grey),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Feather.phone,
                                                    color: Colors.deepOrange,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: Icon(
                                          Feather.facebook,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                height: 50,
                                width: 400,
                                decoration: BoxDecoration(
                                  color: followcolor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    if (follow == true) {
                                      var user1 =
                                          await storage.read(key: 'userid');
                                      var followurl =
                                          'https://api.sellship.co/api/follow/' +
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
                                        followcolor = Colors.deepOrange;
                                        followers = followers - 1;
                                      });
                                    } else {
                                      var user1 =
                                          await storage.read(key: 'userid');
                                      var followurl =
                                          'https://api.sellship.co/api/follow/' +
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
                                        followcolor = Colors.deepPurple;
                                        followers = followers + 1;
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      follow == true ? 'Following' : 'Follow',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 15, top: 10, bottom: 5),
                                    child: Text(
                                        '${capitalize(username)}\'s Items',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey)),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          right: 20, top: 10, bottom: 10),
                                      child: InkWell(
                                          onTap: () {
                                            if (gridtoggle == true) {
                                              setState(() {
                                                gridtoggle = false;
                                              });
                                            } else {
                                              setState(() {
                                                gridtoggle = true;
                                              });
                                            }
                                          },
                                          child: gridtoggle == true
                                              ? Icon(
                                                  Icons.list,
                                                  size: 20,
                                                  color: Colors.deepOrange,
                                                )
                                              : Icon(Icons.grid_on,
                                                  size: 20,
                                                  color: Colors.deepOrange))),
                                ]),
                          ]))),
                  itemsgrid.isNotEmpty
                      ? (gridtoggle == true
                          ? SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.63,
                                mainAxisSpacing: 1.0,
                                crossAxisSpacing: 1.0,
                                crossAxisCount: 2,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                if (index != 0 && index % 8 == 0) {
                                  return Platform.isIOS == true
                                      ? Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Container(
                                            height: 300,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: NativeAdmob(
                                              adUnitID: _iosadUnitID,
                                              controller: _controller,
                                            ),
                                          ))
                                      : Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Container(
                                            height: 300,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: NativeAdmob(
                                              adUnitID: _androidadUnitID,
                                              controller: _controller,
                                            ),
                                          ));
                                }
                                return new Padding(
                                    padding: EdgeInsets.all(10),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                      itemid: itemsgrid[index]
                                                          .itemid,
                                                      sold:
                                                          itemsgrid[index].sold,
                                                    )),
                                          );
                                        },
                                        onDoubleTap: () async {
                                          if (favourites.contains(
                                              itemsgrid[index].itemid)) {
                                            var userid = await storage.read(
                                                key: 'userid');

                                            if (userid != null) {
                                              var url =
                                                  'https://api.sellship.co/api/favourite/' +
                                                      userid;

                                              Map<String, String> body = {
                                                'itemid':
                                                    itemsgrid[index].itemid,
                                              };

                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                                var jsondata =
                                                    json.decode(response.body);

                                                favourites.clear();
                                                for (int i = 0;
                                                    i < jsondata.length;
                                                    i++) {
                                                  favourites.add(jsondata[i]
                                                      ['_id']['\$oid']);
                                                }
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes -
                                                          1;
                                                });
                                              } else {
                                                print(response.statusCode);
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Please Login to use Favourites');
                                            }
                                          } else {
                                            var userid = await storage.read(
                                                key: 'userid');

                                            if (userid != null) {
                                              var url =
                                                  'https://api.sellship.co/api/favourite/' +
                                                      userid;

                                              Map<String, String> body = {
                                                'itemid':
                                                    itemsgrid[index].itemid,
                                              };

                                              final response = await http
                                                  .post(url, body: body);

                                              if (response.statusCode == 200) {
                                                var jsondata =
                                                    json.decode(response.body);

                                                favourites.clear();
                                                for (int i = 0;
                                                    i < jsondata.length;
                                                    i++) {
                                                  favourites.add(jsondata[i]
                                                      ['_id']['\$oid']);
                                                }
                                                setState(() {
                                                  favourites = favourites;
                                                  itemsgrid[index].likes =
                                                      itemsgrid[index].likes +
                                                          1;
                                                });
                                              } else {
                                                print(response.statusCode);
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Please Login to use Favourites');
                                            }
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              new Stack(
                                                children: <Widget>[
                                                  Container(
                                                    height: 180,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            Duration(
                                                                microseconds:
                                                                    10),
                                                        imageUrl:
                                                            itemsgrid[index]
                                                                .image,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            SpinKitChasingDots(
                                                                color: Colors
                                                                    .deepOrange),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  itemsgrid[index].sold == true
                                                      ? Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Container(
                                                            height: 20,
                                                            width: 50,
                                                            color: Colors.amber,
                                                            child: Text(
                                                              'Sold',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ))
                                                      : Container(),
                                                ],
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          favourites != null
                                                              ? favourites.contains(
                                                                      itemsgrid[
                                                                              index]
                                                                          .itemid)
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        var userid =
                                                                            await storage.read(key: 'userid');

                                                                        if (userid !=
                                                                            null) {
                                                                          var url =
                                                                              'https://api.sellship.co/api/favourite/' + userid;

                                                                          Map<String, String>
                                                                              body =
                                                                              {
                                                                            'itemid':
                                                                                itemsgrid[index].itemid,
                                                                          };

                                                                          favourites
                                                                              .remove(itemsgrid[index].itemid);
                                                                          setState(
                                                                              () {
                                                                            favourites =
                                                                                favourites;
                                                                            itemsgrid[index].likes =
                                                                                itemsgrid[index].likes - 1;
                                                                          });
                                                                          final response = await http.post(
                                                                              url,
                                                                              body: body);

                                                                          if (response.statusCode ==
                                                                              200) {
                                                                          } else {
                                                                            print(response.statusCode);
                                                                          }
                                                                        } else {
                                                                          showInSnackBar(
                                                                              'Please Login to use Favourites');
                                                                        }
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        FontAwesome
                                                                            .heart,
                                                                        color: Colors
                                                                            .deepPurple,
                                                                      ),
                                                                    )
                                                                  : InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        var userid =
                                                                            await storage.read(key: 'userid');

                                                                        if (userid !=
                                                                            null) {
                                                                          var url =
                                                                              'https://api.sellship.co/api/favourite/' + userid;

                                                                          Map<String, String>
                                                                              body =
                                                                              {
                                                                            'itemid':
                                                                                itemsgrid[index].itemid,
                                                                          };

                                                                          favourites
                                                                              .add(itemsgrid[index].itemid);
                                                                          setState(
                                                                              () {
                                                                            favourites =
                                                                                favourites;
                                                                            itemsgrid[index].likes =
                                                                                itemsgrid[index].likes + 1;
                                                                          });
                                                                          final response = await http.post(
                                                                              url,
                                                                              body: body);

                                                                          if (response.statusCode ==
                                                                              200) {
                                                                          } else {
                                                                            print(response.statusCode);
                                                                          }
                                                                        } else {
                                                                          showInSnackBar(
                                                                              'Please Login to use Favourites');
                                                                        }
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Feather
                                                                            .heart,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    )
                                                              : Icon(
                                                                  Feather.heart,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            itemsgrid[index]
                                                                .likes
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        CommentsPage(
                                                                            itemid:
                                                                                itemsgrid[index].itemid)),
                                                              );
                                                            },
                                                            child: Icon(Feather
                                                                .message_circle),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        CommentsPage(
                                                                            itemid:
                                                                                itemsgrid[index].itemid)),
                                                              );
                                                            },
                                                            child: Text(
                                                              itemsgrid[index]
                                                                  .comments
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        child: Text(
                                                          itemsgrid[index].name,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0),
                                                      currency != null
                                                          ? Container(
                                                              child: Text(
                                                                currency +
                                                                    ' ' +
                                                                    itemsgrid[
                                                                            index]
                                                                        .price
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .deepOrange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text(
                                                                itemsgrid[index]
                                                                    .price
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )));
                              }, childCount: itemsgrid.length),
                            )
                          : SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                                if (index != 0 && index % 8 == 0) {
                                  return Platform.isIOS == true
                                      ? Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Container(
                                            height: 350,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: NativeAdmob(
                                              adUnitID: _iosadUnitID,
                                              controller: _controller,
                                            ),
                                          ))
                                      : Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Container(
                                            height: 350,
                                            padding: EdgeInsets.all(10),
                                            margin:
                                                EdgeInsets.only(bottom: 20.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: NativeAdmob(
                                              adUnitID: _androidadUnitID,
                                              controller: _controller,
                                            ),
                                          ));
                                }
                                return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  itemid:
                                                      itemsgrid[index].itemid,
                                                  sold: itemsgrid[index].sold,
                                                )),
                                      );
                                    },
                                    onDoubleTap: () async {
                                      if (favourites
                                          .contains(itemsgrid[index].itemid)) {
                                        var userid =
                                            await storage.read(key: 'userid');

                                        if (userid != null) {
                                          var url =
                                              'https://api.sellship.co/api/favourite/' +
                                                  userid;

                                          Map<String, String> body = {
                                            'itemid': itemsgrid[index].itemid,
                                          };

                                          final response =
                                              await http.post(url, body: body);

                                          if (response.statusCode == 200) {
                                            var jsondata =
                                                json.decode(response.body);

                                            favourites.clear();
                                            for (int i = 0;
                                                i < jsondata.length;
                                                i++) {
                                              favourites.add(
                                                  jsondata[i]['_id']['\$oid']);
                                            }
                                            setState(() {
                                              favourites = favourites;
                                              itemsgrid[index].likes =
                                                  itemsgrid[index].likes - 1;
                                            });
                                          } else {
                                            print(response.statusCode);
                                          }
                                        } else {
                                          showInSnackBar(
                                              'Please Login to use Favourites');
                                        }
                                      } else {
                                        var userid =
                                            await storage.read(key: 'userid');

                                        if (userid != null) {
                                          var url =
                                              'https://api.sellship.co/api/favourite/' +
                                                  userid;

                                          Map<String, String> body = {
                                            'itemid': itemsgrid[index].itemid,
                                          };

                                          final response =
                                              await http.post(url, body: body);

                                          if (response.statusCode == 200) {
                                            var jsondata =
                                                json.decode(response.body);

                                            favourites.clear();
                                            for (int i = 0;
                                                i < jsondata.length;
                                                i++) {
                                              favourites.add(
                                                  jsondata[i]['_id']['\$oid']);
                                            }
                                            setState(() {
                                              favourites = favourites;
                                              itemsgrid[index].likes =
                                                  itemsgrid[index].likes + 1;
                                            });
                                          } else {
                                            print(response.statusCode);
                                          }
                                        } else {
                                          showInSnackBar(
                                              'Please Login to use Favourites');
                                        }
                                      }
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              new Stack(
                                                children: <Widget>[
                                                  Container(
                                                    height: 400,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            Duration(
                                                                microseconds:
                                                                    10),
                                                        imageUrl:
                                                            itemsgrid[index]
                                                                .image,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            SpinKitChasingDots(
                                                                color: Colors
                                                                    .deepOrange),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  itemsgrid[index].sold == true
                                                      ? Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Container(
                                                            height: 20,
                                                            width: 50,
                                                            color: Colors.amber,
                                                            child: Text(
                                                              'Sold',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ))
                                                      : Container(),
                                                ],
                                              ),
                                              SizedBox(height: 2.0),
                                              new Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0,
                                                              right: 10.0,
                                                              bottom: 10.0,
                                                              top: 5),
                                                      child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                favourites !=
                                                                        null
                                                                    ? favourites
                                                                            .contains(itemsgrid[index].itemid)
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              var userid = await storage.read(key: 'userid');

                                                                              if (userid != null) {
                                                                                var url = 'https://api.sellship.co/api/favourite/' + userid;

                                                                                Map<String, String> body = {
                                                                                  'itemid': itemsgrid[index].itemid,
                                                                                };

                                                                                favourites.remove(itemsgrid[index].itemid);
                                                                                setState(() {
                                                                                  favourites = favourites;
                                                                                  itemsgrid[index].likes = itemsgrid[index].likes - 1;
                                                                                });
                                                                                final response = await http.post(url, body: body);

                                                                                if (response.statusCode == 200) {
                                                                                } else {
                                                                                  print(response.statusCode);
                                                                                }
                                                                              } else {
                                                                                showInSnackBar('Please Login to use Favourites');
                                                                              }
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              FontAwesome.heart,
                                                                              color: Colors.deepPurple,
                                                                            ),
                                                                          )
                                                                        : InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              var userid = await storage.read(key: 'userid');

                                                                              if (userid != null) {
                                                                                var url = 'https://api.sellship.co/api/favourite/' + userid;

                                                                                Map<String, String> body = {
                                                                                  'itemid': itemsgrid[index].itemid,
                                                                                };

                                                                                favourites.add(itemsgrid[index].itemid);
                                                                                setState(() {
                                                                                  favourites = favourites;
                                                                                  itemsgrid[index].likes = itemsgrid[index].likes + 1;
                                                                                });
                                                                                final response = await http.post(url, body: body);

                                                                                if (response.statusCode == 200) {
                                                                                } else {
                                                                                  print(response.statusCode);
                                                                                }
                                                                              } else {
                                                                                showInSnackBar('Please Login to use Favourites');
                                                                              }
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Feather.heart,
                                                                              color: Colors.black,
                                                                            ),
                                                                          )
                                                                    : Icon(
                                                                        Feather
                                                                            .heart,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  itemsgrid[index]
                                                                          .likes
                                                                          .toString() +
                                                                      ' likes',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                      Feather
                                                                          .message_circle),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    itemsgrid[index]
                                                                            .comments
                                                                            .toString() +
                                                                        ' comments',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Flexible(
                                                                  child: Text(
                                                                    itemsgrid[
                                                                            index]
                                                                        .name,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
//                                                            overflow:
//                                                                TextOverflow
//                                                                    .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  child: Text(
                                                                    currency +
                                                                        ' ' +
                                                                        itemsgrid[index]
                                                                            .price
                                                                            .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Helvetica',
                                                                      fontSize:
                                                                          17,
                                                                      color: Colors
                                                                          .deepOrange,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 2,
                                                            ),
                                                            Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      size: 12,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      'Uploaded ${itemsgrid[index].date}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Helvetica',
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ]))),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                        )));
                              }, childCount: itemsgrid.length),
                            ))
                      : SliverFillRemaining(
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Looks like there are no items here!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                  child: Image.asset(
                                'assets/little_theologians_4x.png',
                                fit: BoxFit.fitWidth,
                              ))
                            ],
                          ),
                        ),
                ])
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
                ),
        ));
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
