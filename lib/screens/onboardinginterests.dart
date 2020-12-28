import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;

class OnboardingInterests extends StatefulWidget {
  final String userid;

  OnboardingInterests({
    Key key,
    this.userid,
  }) : super(key: key);

  @override
  _OnboardingInterestsState createState() => new _OnboardingInterestsState();
}

class _OnboardingInterestsState extends State<OnboardingInterests> {
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
  }

  List<String> categoryimages = [
    'assets/women/jumpsuit.jpeg',
    'assets/interests/men.jpg',
    'assets/interests/beauty.jpg',
    'assets/interests/electronics.jpg',
    'assets/interests/luxury.jpg',
    'assets/interests/home.jpg',
    'assets/interests/vintage.jpg',
    'assets/interests/handmade.jpg',
    'assets/interests/garden.jpg',
    'assets/interests/kids.jpg',
    'assets/interests/sports.jpg',
    'assets/interests/toys.jpg',
  ];

  List<String> categories = [
    'Women',
    'Men',
    'Beauty',
    'Electronics',
    'Luxury',
    'Home',
    'Vintage',
    'Handmade',
    'Garden',
    'Kids',
    'Sports',
    'Toys',
  ];

  List<String> selectedinterests = List<String>();
  TextEditingController usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Feather.arrow_left)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Choose Interests',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 16.0, bottom: 10, top: 30, right: 16),
            child: Text(
              "Let's get to know you better",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica'),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 16.0, bottom: 20, top: 10, right: 16),
            child: Text(
              "Please select atleast two categories that you are interested in.",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18.0, color: Colors.black, fontFamily: 'Helvetica'),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: categoryimages.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (BuildContext context, int index) {
                return new InkWell(
                    onTap: () {
                      if (selectedinterests.contains(categories[index])) {
                        selectedinterests.remove(categories[index]);
                      } else {
                        selectedinterests.add(categories[index]);
                      }
                      setState(() {
                        selectedinterests = selectedinterests;
                      });
                    },
                    child: Card(
                        child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset(
                            categoryimages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        selectedinterests.contains(categories[index])
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.black.withOpacity(0.6),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                ))
                            : Container(),
                      ],
                    )));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 36, top: 20, right: 36, bottom: 10),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      if (selectedinterests.length >= 2) {
                        var url = 'https://api.sellship.co/api/user/' +
                            userid; // change URL

                        final response = await http.get(url);
                        if (response.statusCode == 200) {
                          print(response.body);
                        }
                      }
                    },
                    child: Container(
                      height: 60,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: MediaQuery.of(context).size.width - 150,
                      decoration: BoxDecoration(
                        color: selectedinterests.length >= 2
                            ? Color.fromRGBO(255, 115, 0, 1)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                          child: Text(
                        'Start SellShipping',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      )),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
