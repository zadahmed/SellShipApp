import 'dart:io';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeral/numeral.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_icons/flutter_icons.dart';

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
    } else if (country.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
      });
    } else if (country.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\£';
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

          var productmap = itemmap['products'];

          if (productmap == null) {
            setState(() {
              itemsgrid = [];
              loading = false;
            });
          }

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
              loading = false;
            });
          } else {
            setState(() {
              itemsgrid = [];
              loading = false;
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
          if (followin <= 0) {
            followin = 0;
          } else {
            followin = profilemap['likes'];
          }
        } else {
          followin = 0;
        }

        var sol = profilemap['sold'];
        if (sol != null) {
        } else {
          sol = [];
        }

        var confirmedemai = profilemap['confirmedemail'];
        if (confirmedemai != null) {
        } else {
          confirmedemai = false;
        }

        var confirmedphon = profilemap['confirmedphone'];
        if (confirmedphon != null) {
        } else {
          confirmedphon = false;
        }

        var profilepic = profilemap['profilepicture'];
        if (profilepic != null) {
        } else {
          profilepic = null;
        }

        var confirmedf = profilemap['confirmedfb'];
        if (confirmedf != null) {
        } else {
          confirmedf = false;
        }

        var rating;
        if (profilemap['reviewrating'] == null) {
          rating = 0.0;
        } else {
          rating = profilemap['reviewrating'];
        }

        if (mounted) {
          setState(() {
            reviewrating = rating;
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
            confirmedfb = confirmedf;
            profilepicture = profilepic;
          });
        }
      } else {
        print('Error');
      }
    }
  }

  double reviewrating;
  bool confirmedfb;

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
      backgroundColor: Colors.deepPurple,
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
              if (profilemap[i] != null) {
                ites.add(profilemap[i]['_id']['\$oid']);
              }
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
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      var dropdownValue;

                                      List<String> reportvalues = [
                                        'Inappropriate',
                                        'Scam/Fraud'
                                      ];

                                      return StatefulBuilder(
                                          builder: (context, updateState) {
                                        return AlertDialog(
                                            title: Text('Report'),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                    'Would you like to report this user?',
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  DropdownButton(
                                                    hint: Text(
                                                      'Please choose a reason',
                                                      style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 16,
                                                      ),
                                                    ), // Not necessary for Option 1
                                                    value: dropdownValue,
                                                    onChanged: (newValue) {
                                                      updateState(() {
                                                        dropdownValue =
                                                            newValue;
                                                      });
                                                    },
                                                    items: reportvalues
                                                        .map((location) {
                                                      return DropdownMenuItem(
                                                        child: new Text(
                                                          location,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        value: location,
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: Text('Report'),
                                                onPressed: () async {
                                                  var url =
                                                      'https://api.sellship.co/api/report/user/' +
                                                          userid;

                                                  final response =
                                                      await http.get(url);
                                                  if (response.statusCode ==
                                                      200) {
                                                    Navigator.of(context).pop();
                                                    showInSnackBar(
                                                        'User has been reported! Thank you for making the SellShip community a safer place.');
                                                  }
                                                },
                                              ),
                                            ]);
                                      });
                                    });
                              },
                              child: Icon(
                                Icons.report_problem,
                                color: Color.fromRGBO(28, 45, 65, 1),
                                size: 24,
                              ),
                            ),
                          ),
                        ]),
                    SliverToBoxAdapter(
                        child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            child: Column(children: <Widget>[
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: profilepicture == null
                                      ? Image.asset(
                                          'assets/personplaceholder.png',
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.network(
                                          profilepicture,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      firstname != null
                                          ? firstname + ' ' + lastname
                                          : ' ',
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    reviewrating == null
                                        ? '0.0'
                                        : reviewrating.toStringAsFixed(1),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.deepPurple,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 20, right: 20, bottom: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              color: Colors.blueGrey),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          following == null
                                              ? '0'
                                              : following.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          'Likes',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Helvetica',
                                              color: Colors.blueGrey),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          followers == null
                                              ? '0'
                                              : followers.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Helvetica',
                                              color: Colors.blueGrey),
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
                                    borderRadius: BorderRadius.circular(5),
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
                            ? SliverStaggeredGrid(
                                gridDelegate:
                                    SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 1.0,
                                  crossAxisSpacing: 1.0,
                                  crossAxisCount: 2,
                                  staggeredTileCount: itemsgrid.length,
                                  staggeredTileBuilder: (index) =>
                                      new StaggeredTile.count(1, 1.6),
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
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
                                                      image: itemsgrid[index]
                                                          .image,
                                                      name:
                                                          itemsgrid[index].name,
                                                      source: 'my',
                                                    )),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.2, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                                    height: 220,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                      child: Image.network(
                                                        itemsgrid[index].image,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Container(
                                                          height: 35,
                                                          width: 145,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .black26
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                child: InkWell(
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Feather
                                                                              .heart,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          Numeral(itemsgrid[index].likes)
                                                                              .value(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    if (favourites
                                                                        .contains(
                                                                            itemsgrid[index].itemid)) {
                                                                      var userid =
                                                                          await storage.read(
                                                                              key: 'userid');

                                                                      if (userid !=
                                                                          null) {
                                                                        var url =
                                                                            'https://api.sellship.co/api/favourite/' +
                                                                                userid;

                                                                        Map<String,
                                                                                String>
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
                                                                            body:
                                                                                body);

                                                                        if (response.statusCode ==
                                                                            200) {
                                                                        } else {
                                                                          print(
                                                                              response.statusCode);
                                                                        }
                                                                      } else {
                                                                        showInSnackBar(
                                                                            'Please Login to use Favourites');
                                                                      }
                                                                    } else {
                                                                      var userid =
                                                                          await storage.read(
                                                                              key: 'userid');

                                                                      if (userid !=
                                                                          null) {
                                                                        var url =
                                                                            'https://api.sellship.co/api/favourite/' +
                                                                                userid;

                                                                        Map<String,
                                                                                String>
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
                                                                            body:
                                                                                body);

                                                                        if (response.statusCode ==
                                                                            200) {
                                                                        } else {
                                                                          print(
                                                                              response.statusCode);
                                                                        }
                                                                      } else {
                                                                        showInSnackBar(
                                                                            'Please Login to use Favourites');
                                                                      }
                                                                    }
                                                                  },
                                                                ),
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            5),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                child:
                                                                    VerticalDivider(),
                                                              ),
                                                              Padding(
                                                                child: InkWell(
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Feather
                                                                              .message_circle,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          Numeral(itemsgrid[index].comments)
                                                                              .value(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  enableFeedback:
                                                                      true,
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CommentsPage(itemid: itemsgrid[index].itemid)),
                                                                    );
                                                                  },
                                                                ),
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 5,
                                                                        right:
                                                                            10),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                          ),
                                                        ),
                                                      )),
                                                  itemsgrid[index].sold == true
                                                      ? Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .deepPurpleAccent
                                                                  .withOpacity(
                                                                      0.8),
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10)),
                                                            ),
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Center(
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
                                                            ),
                                                          ))
                                                      : favourites != null
                                                          ? favourites.contains(
                                                                  itemsgrid[index]
                                                                      .itemid)
                                                              ? InkWell(
                                                                  enableFeedback:
                                                                      true,
                                                                  onTap:
                                                                      () async {
                                                                    var userid =
                                                                        await storage.read(
                                                                            key:
                                                                                'userid');

                                                                    if (userid !=
                                                                        null) {
                                                                      var url =
                                                                          'https://api.sellship.co/api/favourite/' +
                                                                              userid;

                                                                      Map<String,
                                                                              String>
                                                                          body =
                                                                          {
                                                                        'itemid':
                                                                            itemsgrid[index].itemid,
                                                                      };

                                                                      favourites
                                                                          .remove(
                                                                              itemsgrid[index].itemid);
                                                                      setState(
                                                                          () {
                                                                        favourites =
                                                                            favourites;
                                                                        itemsgrid[index]
                                                                            .likes = itemsgrid[index]
                                                                                .likes -
                                                                            1;
                                                                      });
                                                                      final response = await http.post(
                                                                          url,
                                                                          body:
                                                                              body);

                                                                      if (response
                                                                              .statusCode ==
                                                                          200) {
                                                                      } else {
                                                                        print(response
                                                                            .statusCode);
                                                                      }
                                                                    } else {
                                                                      showInSnackBar(
                                                                          'Please Login to use Favourites');
                                                                    }
                                                                  },
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      child:
                                                                          Padding(
                                                                              padding: EdgeInsets.all(
                                                                                  10),
                                                                              child:
                                                                                  CircleAvatar(
                                                                                radius: 18,
                                                                                backgroundColor: Colors.deepPurple,
                                                                                child: Icon(
                                                                                  FontAwesome.heart,
                                                                                  color: Colors.white,
                                                                                  size: 16,
                                                                                ),
                                                                              ))))
                                                              : InkWell(
                                                                  enableFeedback:
                                                                      true,
                                                                  onTap:
                                                                      () async {
                                                                    var userid =
                                                                        await storage.read(
                                                                            key:
                                                                                'userid');

                                                                    if (userid !=
                                                                        null) {
                                                                      var url =
                                                                          'https://api.sellship.co/api/favourite/' +
                                                                              userid;

                                                                      Map<String,
                                                                              String>
                                                                          body =
                                                                          {
                                                                        'itemid':
                                                                            itemsgrid[index].itemid,
                                                                      };

                                                                      favourites.add(
                                                                          itemsgrid[index]
                                                                              .itemid);
                                                                      setState(
                                                                          () {
                                                                        favourites =
                                                                            favourites;
                                                                        itemsgrid[index]
                                                                            .likes = itemsgrid[index]
                                                                                .likes +
                                                                            1;
                                                                      });
                                                                      final response = await http.post(
                                                                          url,
                                                                          body:
                                                                              body);

                                                                      if (response
                                                                              .statusCode ==
                                                                          200) {
                                                                      } else {
                                                                        print(response
                                                                            .statusCode);
                                                                      }
                                                                    } else {
                                                                      showInSnackBar(
                                                                          'Please Login to use Favourites');
                                                                    }
                                                                  },
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      child:
                                                                          Padding(
                                                                              padding: EdgeInsets.all(
                                                                                  10),
                                                                              child:
                                                                                  CircleAvatar(
                                                                                radius: 18,
                                                                                backgroundColor: Colors.white,
                                                                                child: Icon(
                                                                                  Feather.heart,
                                                                                  color: Colors.blueGrey,
                                                                                  size: 16,
                                                                                ),
                                                                              ))))
                                                          : Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 18,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child: Icon(
                                                                      Feather
                                                                          .heart,
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      size: 16,
                                                                    ),
                                                                  ))),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                child: Container(
                                                  height: 20,
                                                  child: Text(
                                                    itemsgrid[index].name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color.fromRGBO(
                                                          28, 45, 65, 1),
                                                    ),
                                                  ),
                                                ),
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                              ),
                                              SizedBox(height: 4.0),
                                              currency != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Container(
                                                        child: Text(
                                                          currency +
                                                              ' ' +
                                                              itemsgrid[index]
                                                                  .price
                                                                  .toString(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            color: Colors
                                                                .deepOrange,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ))
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Container(
                                                        child: Text(
                                                          itemsgrid[index]
                                                              .price
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      )),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                          ),
                                        ),
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
                                      ),
                                    );
                                  },
                                  childCount: itemsgrid.length,
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Details(
                                                    itemid:
                                                        itemsgrid[index].itemid,
                                                    sold: itemsgrid[index].sold,
                                                    image:
                                                        itemsgrid[index].image,
                                                    name: itemsgrid[index].name,
                                                    source: 'my',
                                                  )),
                                        );
                                      },
                                      onDoubleTap: () async {
                                        if (favourites.contains(
                                            itemsgrid[index].itemid)) {
                                          var userid =
                                              await storage.read(key: 'userid');

                                          if (userid != null) {
                                            var url =
                                                'https://api.sellship.co/api/favourite/' +
                                                    userid;

                                            Map<String, String> body = {
                                              'itemid': itemsgrid[index].itemid,
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
                                                  width: 0.2,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                        child: Image.network(
                                                          itemsgrid[index]
                                                              .image,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    itemsgrid[index].sold ==
                                                            true
                                                        ? Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              height: 50,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color: Colors
                                                                  .deepPurpleAccent
                                                                  .withOpacity(
                                                                      0.8),
                                                              child: Center(
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
                                                            const EdgeInsets
                                                                    .only(
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
                                                                              onTap: () async {
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
                                                                              child: Icon(
                                                                                FontAwesome.heart,
                                                                                color: Colors.deepPurple,
                                                                              ),
                                                                            )
                                                                          : InkWell(
                                                                              onTap: () async {
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
                                                                              child: Icon(
                                                                                Feather.heart,
                                                                                color: Colors.black,
                                                                              ),
                                                                            )
                                                                      : Icon(
                                                                          Feather
                                                                              .heart,
                                                                          color:
                                                                              Colors.black,
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
                                                                            FontWeight.w600,
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
                                                                            FontWeight.w600,
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
                                                                            FontWeight.w700,
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
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Icon(
                                                                        Icons
                                                                            .access_time,
                                                                        size:
                                                                            12,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        'Uploaded ${itemsgrid[index].date}',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey,
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
                : Scaffold(
                    appBar: AppBar(
                        elevation: 0,
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
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.report_problem,
                                color: Color.fromRGBO(28, 45, 65, 1),
                                size: 24,
                              ),
                            ),
                          ),
                        ]),
                    body: Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2.0),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 8.0,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                  )));
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
