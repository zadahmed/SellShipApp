import 'dart:convert';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/onboardinginterests.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Username extends StatefulWidget {
  final String userid;

  Username({
    Key key,
    this.userid,
  }) : super(key: key);

  @override
  _UsernameState createState() => new _UsernameState();
}

class _UsernameState extends State<Username> {
  String userid;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
    });
  }

  bool disabled = true;

  checkemailverified() async {
    var url = 'https://api.sellship.co/api/user/' + userid;

    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var respons = json.decode(response.body);
      Map<String, dynamic> profilemap = respons;
      print(profilemap);

      var confirmedemai = profilemap['confirmedemail'];
      if (confirmedemai != null) {
        print(confirmedemai);
        setState(() {
          disabled = false;
          confirmedemai = true;
        });
      } else {
        setState(() {
          disabled = true;
          confirmedemai = false;
        });
      }
    }
  }

  TextEditingController usernamecontroller = TextEditingController();

  var usernamemessage = '';
  var allgood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(FeatherIcons.arrowLeft)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Create Username',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width / 2 + 30,
                        child: Image.asset(
                          'assets/021.png',
                          fit: BoxFit.cover,
                        ))
                  ])),
          Padding(
            padding:
                EdgeInsets.only(left: 16.0, bottom: 10, top: 30, right: 16),
            child: Center(
              child: Text(
                "What should we call you?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Helvetica'),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width - 150,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(131, 146, 165, 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      onChanged: (text) async {
                        if (text.length >= 3) {
                        } else {
                          setState(() {
                            usernamemessage =
                                'Username needs to be atleast 3 characters';
                            allgood = false;
                          });
                        }
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,29}$'))
                      ],
                      controller: usernamecontroller,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(fontFamily: 'Helvetica'),
                        icon: Icon(
                          Icons.alternate_email,
                          color: Colors.blueGrey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              )),
          Padding(
            padding: EdgeInsets.only(left: 36, top: 20, right: 36),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          useRootNavigator: false,
                          builder: (_) => new AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                content: Builder(
                                  builder: (context) {
                                    return Container(
                                        height: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Loading..',
                                              style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                                height: 50,
                                                width: 50,
                                                child: SpinKitDoubleBounce(
                                                  color: Colors.deepOrange,
                                                )),
                                          ],
                                        ));
                                  },
                                ),
                              ));
                      var url = 'https://api.sellship.co/check/username/' +
                          userid +
                          '/' +
                          usernamecontroller.text;

                      final response = await http.get(Uri.parse(url));
                      if (response.statusCode == 200) {
                        var jsondeco = json.decode(response.body);
                        if (jsondeco['Status'] == 'Success') {
                          setState(() {
                            allgood = true;
                          });
                        } else {
                          setState(() {
                            allgood = false;
                          });
                        }
                      }
                      if (allgood) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OnboardingInterests()));
                      } else {
                        Navigator.of(context).pop();

                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            useRootNavigator: false,
                            builder: (_) => new AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  content: Builder(
                                    builder: (context) {
                                      return Container(
                                          height: 380,
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 250,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Image.asset(
                                                    'assets/oops.gif',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Looks like that Username is not available.',
                                                style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              InkWell(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          255, 115, 0, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color(
                                                                    0xFF9DA3B4)
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 65.0,
                                                            offset: Offset(
                                                                0.0, 15.0))
                                                      ]),
                                                  child: Center(
                                                    child: Text(
                                                      "Close",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ));
                                    },
                                  ),
                                ));
                      }
                    },
                    child: Container(
                      height: 60,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: MediaQuery.of(context).size.width - 150,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 115, 0, 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                          child: Text(
                        'Create Username',
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
