import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/stores.dart';
import 'package:SellShip/screens/storepagepublic.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

    if (userid != null) {
      var url = 'https://api.sellship.co/api/user/' + userid;
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        Map<String, dynamic> profilemap = respons;
        var store;
        if (profilemap['stores'] != null) {
          store = profilemap['stores'];
        } else {
          store = [];
        }

        var rr;
        if (profilemap['reviewrating'] != null) {
          rr = double.parse(profilemap['reviewrating'].toString());
        } else {
          rr = 0.0;
        }

        var fl;
        if (profilemap['follower'] != null) {
          fl = profilemap['follower'];
        } else {
          fl = [];
        }

        var usess = await storage.read(key: 'userid');
        for (int i = 0; i < fl.length; i++) {
          if (fl[i]['\$oid'].contains(usess)) {
            setState(() {
              follow = true;
              followcolor = Colors.deepOrange;
            });
          } else {
            setState(() {
              follow = false;
              followcolor = Colors.white;
            });
          }
        }

        var fls;
        if (profilemap['follower'] != null) {
          fls = profilemap['follower'].length;
        } else {
          fls = 0;
        }

        setState(() {
          profilepicture = profilemap['profilepicture'];
          reviewrating = rr;
          following = fls;
          slist = store;
          getuser();
        });
      } else {
        print('Error');
      }
    }
  }

  List slist = new List();

  List<Stores> storelist = new List<Stores>();
  Stores mystore;

  getuser() async {
    for (int i = 0; i < slist.length; i++) {
      var url = 'https://api.sellship.co/api/user/store/' + slist[i]['\$oid'];
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonbody = json.decode(response.body);
        Stores store = Stores(
            storeid: jsonbody['_id']['\$oid'],
            reviews: jsonbody['reviewnumber'] == null
                ? '0'
                : jsonbody['reviewnumber'].toString(),
            sold: jsonbody['sold'] == null ? '0' : jsonbody['sold'].toString(),
            storecategory: jsonbody['storecategory'],
            storetype: jsonbody['storetype'],
            storelogo:
                jsonbody['storelogo'] == null ? '' : jsonbody['storelogo'],
            storebio: jsonbody['storebio'],
            storename: jsonbody['storename']);

        setState(() {
          storelist.add(store);
          loading = false;
        });
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

  var profilepicture;

  var followers;
  var itemssold;
  var following;

  Color followcolor = Colors.white;
  var totalitems;

  var follow = false;

  Widget profile(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '@$username',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.black,
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

                        return StatefulBuilder(builder: (context, updateState) {
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
                                          dropdownValue = newValue;
                                        });
                                      },
                                      items: reportvalues.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(
                                            location,
                                            style: TextStyle(
                                              fontFamily: 'Helvetica',
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

                                    final response = await http.get(url);
                                    if (response.statusCode == 200) {
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
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: loading == false
              ? CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: new SliverChildListDelegate([
                    Stack(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child: SvgPicture.asset(
                                  'assets/LoginBG.svg',
                                  semanticsLabel: 'SellShip BG',
                                  fit: BoxFit.cover,
                                ))),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                              padding:
                                  EdgeInsets.only(left: 15, top: 40, right: 20),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                            children: [
                                              Container(
                                                height: 110,
                                                width: 100,
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: GestureDetector(
                                                        child: Container(
                                                          height: 100,
                                                          width: 100,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  width: 5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: profilepicture ==
                                                                        null ||
                                                                    profilepicture
                                                                        .isEmpty
                                                                ? Image.asset(
                                                                    'assets/personplaceholder.png',
                                                                    fit: BoxFit
                                                                        .fitWidth,
                                                                  )
                                                                : CachedNetworkImage(
                                                                    height: 300,
                                                                    width: 300,
                                                                    imageUrl:
                                                                        profilepicture,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder: (context,
                                                                            url) =>
                                                                        SpinKitDoubleBounce(
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, top: 25),
                                          child: Row(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    '@' + username,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 24.0,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start),
                                        )
                                      ]))),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ])),
                  SliverToBoxAdapter(
                      child: Container(
                          width: double.infinity,
                          child: Column(children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        reviewrating == null
                                            ? '0'
                                            : reviewrating.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        'Reviews',
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        'Followers',
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
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: followcolor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: follow == true
                                                  ? Colors.deepOrange
                                                  : Colors.blueGrey.shade200
                                                      .withOpacity(0.5))),
                                      child: InkWell(
                                        onTap: () async {
                                          if (follow == true) {
                                            setState(() {
                                              follow = false;
                                              followcolor = Colors.white;
                                              following = following - 1;
                                            });
                                            var user1 = await storage.read(
                                                key: 'userid');
                                            var followurl =
                                                'https://api.sellship.co/api/follow/user/' +
                                                    user1 +
                                                    '/' +
                                                    userid;

                                            final followresponse =
                                                await http.get(followurl);
                                            if (followresponse.statusCode ==
                                                200) {
                                              print('UnFollowed');
                                            }
                                          } else {
                                            setState(() {
                                              follow = true;
                                              followcolor = Colors.deepOrange;
                                              following = following + 1;
                                            });
                                            var user1 = await storage.read(
                                                key: 'userid');
                                            var followurl =
                                                'https://api.sellship.co/api/follow/user/' +
                                                    user1 +
                                                    '/' +
                                                    userid;

                                            final followresponse =
                                                await http.get(followurl);
                                            if (followresponse.statusCode ==
                                                200) {
                                              print('Followed');
                                            }
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            follow == true
                                                ? 'Following'
                                                : 'Follow',
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                color: follow == true
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                        '${capitalize(username)}\'s Stores',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey)),
                                  ),
                                ]),
                          ]))),
                  storelist.isNotEmpty
                      ? SliverStaggeredGrid.countBuilder(
                          crossAxisCount: 3,
                          itemBuilder: (BuildContext context, index) {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StorePublic(
                                              storeid: storelist[index].storeid,
                                              storename:
                                                  storelist[index].storename,
                                            )),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Color.fromRGBO(
                                                  255, 115, 0, 0.7),
                                              width: 5),
                                          borderRadius:
                                              BorderRadius.circular(60)),
                                      child: storelist[index].storelogo != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                              child: CachedNetworkImage(
                                                height: 120,
                                                width: 120,
                                                imageUrl:
                                                    storelist[index].storelogo,
                                                fit: BoxFit.cover,
                                              ))
                                          : Container(),
                                    ),
                                    Container(
                                      width: 120,
                                      padding: EdgeInsets.all(5),
                                      child: Center(
                                        child: Text(
                                          storelist[index].storename,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 120,
                                      height: 45,
                                      padding: EdgeInsets.only(
                                          bottom: 10, left: 5, right: 5),
                                      child: Text(
                                        storelist[index].storetype,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                          },
                          itemCount: storelist.length,
                          staggeredTileBuilder: (int index) =>
                              new StaggeredTile.fit(1),
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                        )
                      : SliverToBoxAdapter(
                          child: SizedBox(
                          height: 10,
                        )),
                ])
              : SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                )),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
