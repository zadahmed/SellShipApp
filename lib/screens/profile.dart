import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sellship/screens/login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var loggedin = false;

  @override
  void initState() {
    super.initState();
    if (loggedin == false) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Text(
            'Profile',
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage('assets/avatar.png'),
                radius: 30.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('James Nardin'),
                  LikeDis(),
                ],
              ),
              RaisedButton(
                color: Colors.black,
                child: Text(
                  'Edit Profile',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
                onPressed: () {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
              )
            ],
          )
        ],
      ),
    );
  }
}

Widget LikeDis() {
  return Row(
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.thumb_up),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.thumb_down),
        onPressed: () {},
      ),
    ],
  );
}
