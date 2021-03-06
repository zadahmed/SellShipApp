import 'dart:async';
import 'dart:convert';

import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/username.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class VerifyEmailSignUp extends StatefulWidget {
  final String userid;
  final String email;
  VerifyEmailSignUp({
    Key key,
    this.email,
    this.userid,
  }) : super(key: key);

  @override
  _VerifyEmailSignUpState createState() => new _VerifyEmailSignUpState();
}

class _VerifyEmailSignUpState extends State<VerifyEmailSignUp> {
  String userid;
  String email;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
      email = widget.email;
      emailcontroller.text = email;
    });
  }

  bool disabled = true;

  Future<bool> checkemailverified() async {
    var url = 'https://api.sellship.co/api/user/' + userid.toString();

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var respons = json.decode(response.body);
      Map<String, dynamic> profilemap = respons;
      print(profilemap);

      var confirmedemai = profilemap['confirmedemail'];
      if (profilemap.containsKey('confirmedemail')) {
        disabled = false;
      } else {
        disabled = true;
      }
    } else {
      disabled = true;
    }
    print('yesss');
    print(disabled);
    return disabled;
  }

  TextEditingController emailcontroller = TextEditingController();

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
          'Verify Email',
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: 450,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/184.png',
                          fit: BoxFit.cover,
                        ))
                  ])),
          Padding(
            padding:
                EdgeInsets.only(left: 16.0, bottom: 10, top: 30, right: 16),
            child: Center(
              child: Text(
                "Verification email send to ${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
//                            fontWeight: FontWeight.bold,
                    fontFamily: 'Helvetica'),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 16.0, bottom: 10, top: 10, right: 16),
            child: Center(
              child: Text(
                "Verify your email to Create your Username to Start Buying and Selling on SellShip. Make sure to check your Spam and Junk too for our email, sometimes it tends to loose it\'s way",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                    fontFamily: 'Helvetica'),
              ),
            ),
          ),
          FutureBuilder<bool>(
              future: checkemailverified(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return Padding(
                  padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (snapshot.data == true) {
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Username(
                                      userid: userid,
                                    ),
                                  ));
                            }
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 150,
                            decoration: BoxDecoration(
                              color: snapshot.data == true
                                  ? Colors.grey
                                  : Color.fromRGBO(255, 115, 0, 1),
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
                );
              }),
          Padding(
              padding: EdgeInsets.only(left: 20, top: 40, right: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              useRootNavigator: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0)), //this right here
                                  child: Container(
                                    height: 100,
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SpinKitDoubleBounce(
                                            color: Colors.deepOrange)),
                                  ),
                                );
                              });
                          checkemailverified();
                        },
                        child: Text(
                          'I have verified my email',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )),
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              useRootNavigator: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32.0))),
                                    contentPadding: EdgeInsets.only(top: 10.0),
                                    content: Container(
                                        width: 300.0,
                                        height: 300,
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Enter Email Address',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: "Helvetica",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 10,
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Container(
                                                            height: 60,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        5),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                150,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      131,
                                                                      146,
                                                                      165,
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                            ),
                                                            child: TextField(
                                                              onChanged:
                                                                  (text) {},
                                                              controller:
                                                                  emailcontroller,
                                                              cursorColor:
                                                                  Colors.black,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    "Email Address",
                                                                hintStyle: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica'),
                                                                icon: Icon(
                                                                  Icons.email,
                                                                  color: Colors
                                                                      .blueGrey,
                                                                ),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 20,
                                                    ),
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              print(userid);
                                                              print(
                                                                  emailcontroller
                                                                      .text);
                                                              var url =
                                                                  'https://api.sellship.co/verify/email/' +
                                                                      userid +
                                                                      '/' +
                                                                      emailcontroller
                                                                          .text;

                                                              print(url);
                                                              final response =
                                                                  await http
                                                                      .get(url);
                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    useRootNavigator:
                                                                        false,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10.0))),
                                                                        contentPadding:
                                                                            EdgeInsets.only(top: 10.0),
                                                                        content:
                                                                            Container(
                                                                          width:
                                                                              300.0,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.stretch,
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Center(
                                                                                child: Icon(
                                                                                  Feather.mail,
                                                                                  color: Colors.deepOrange,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5.0,
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.all(10),
                                                                                child: Text(
                                                                                  'We have send a verification code to the email address. Please confirm your email using the link given in the email. Make sure to check your junk or spam too',
                                                                                  style: TextStyle(fontSize: 16, fontFamily: "Helvetica", fontWeight: FontWeight.w400, color: Colors.black),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5.0,
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.deepOrange,
//                                                                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.0), bottomRight: Radius.circular(32.0)),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Close",
                                                                                    style: TextStyle(fontSize: 15, fontFamily: "SF", fontWeight: FontWeight.w400, color: Colors.white),
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              } else {
                                                                print('error');
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          5),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  200,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        115,
                                                                        0,
                                                                        1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                              ),
                                                              child: Center(
                                                                  child: Text(
                                                                'Send Verification Email',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )),
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ]))));
                              });
                        },
                        child: Text(
                          'Resend Email',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ))
                  ])),
        ],
      ),
    );
  }
}
