import 'dart:convert';

import 'package:SellShip/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FollowersPage extends StatefulWidget {
  final List followers;

  FollowersPage({Key key, this.followers}) : super(key: key);

  @override
  _FollowersPageState createState() => new _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  void initState() {
    super.initState();
    getfollowing();
    setState(() {
      followers = widget.followers;
    });
    getusers();
  }

  List followers = List();

  List<User> followingusers = List<User>();

  followuser(user) async {
    User foluser = user;
    var userid = await storage.read(key: 'userid');
    if (followingusers.contains(user)) {
      setState(() {
        followingusers.remove(foluser);
      });
      var followurl = 'https://api.sellship.co/api/follow/user/' +
          userid +
          '/' +
          foluser.userid;

      final followresponse = await http.get(followurl);
      if (followresponse.statusCode == 200) {
        print('UnFollowed');
      }
    } else {
      setState(() {
        followingusers.add(foluser);
      });
      var followurl = 'https://api.sellship.co/api/follow/user/' +
          userid +
          '/' +
          foluser.userid;

      final followresponse = await http.get(followurl);
      if (followresponse.statusCode == 200) {
        print('Followed');
      }
    }
    setState(() {
      followingusers = followingusers;
    });
  }

  final storage = new FlutterSecureStorage();

  getfollowing() async {
    var userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/getfollowing/' + userid;
    var response = await http.get(url);
    var jsonbody = json.decode(response.body);
    for (int i = 0; i < jsonbody.length; i++) {
      User user = User(userid: jsonbody[i]['\$oid']);
      followingusers.add(user);
    }

    setState(() {
      followingusers = followingusers;
    });
  }

  getusers() async {
    var url = 'https://api.sellship.co/api/getuserfollowers';

    Map<String, dynamic> body = {
      'followers': followers,
    };
    Dio dio = new Dio();
    var response = await dio.post(url, data: body);
    var sbody = response.data;
    for (int i = 0; i < sbody.length; i++) {
      if (sbody[i] != null && sbody.isNotEmpty) {
        User user = new User(
          username: sbody[i].containsKey('username')
              ? sbody[i]['username']
              : sbody[i]['first_name'] + sbody[i]['last_name'],
          userid: sbody[i]['_id']['\$oid'],
          profilepicture: sbody[i].containsKey('profilepicture')
              ? sbody[i]['profilepicture']
              : '',
        );

        userList.add(user);
      } else {
        userList = [];
      }
    }
    setState(() {
      userList = userList;

      loading = false;
    });
  }

  bool loading = true;

  List<User> userList = List<User>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Followers',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                Feather.chevron_left,
                color: Color.fromRGBO(28, 45, 65, 1),
              ),
              onTap: () {
                Navigator.pop(context);
              }),
        ),
      ),
      body: loading == false
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Container(
                          height: 70,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(45),
                                        child: userList[index].profilepicture !=
                                                    null &&
                                                userList[index]
                                                    .profilepicture
                                                    .isNotEmpty
                                            ? CachedNetworkImage(
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                imageUrl: userList[index]
                                                    .profilepicture,
                                                fit: BoxFit.cover,
                                                width: 300,
                                                height: 200,
                                                placeholder: (context, url) =>
                                                    SpinKitDoubleBounce(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              )
                                            : Icon(
                                                FontAwesome.user_circle,
                                                color: Colors.blueGrey,
                                                size: 60,
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Container(
                                            height: 50,
                                            width: 150,
                                            child: Text(
                                              '@' + userList[index].username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: followingusers
                                                  .contains(userList[index])
                                              ? Border.all(color: Colors.white)
                                              : Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.2)),
                                          color: followingusers
                                                  .contains(userList[index])
                                              ? Colors.deepOrange
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            followuser(userList[index]);
                                          },
                                          child: Center(
                                            child: Text(
                                              followingusers
                                                      .contains(userList[index])
                                                  ? 'Following'
                                                  : 'Follow',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color:
                                                      followingusers.contains(
                                                              userList[index])
                                                          ? Colors.white
                                                          : Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ])
                            ],
                          )));
                },
              ),
            )
          : Center(
              child: SpinKitDoubleBounce(
                color: Colors.deepOrange,
              ),
            ),
    );
  }
}
