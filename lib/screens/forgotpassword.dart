import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController emailcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          'Forgot Password',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w800),
        ),
      ),
      // appBar: AppBar(
      //   leading: InkWell(
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => RootScreen(index: 4)),
      //         );
      //       },
      //       child: Icon(Icons.arrow_back_ios)),
      //   iconTheme: IconThemeData(color: Colors.deepPurple),
      //   elevation: 0,
      //   title: Text(
      //     'Forgot Password',
      //     style: TextStyle(
      //       fontWeight: FontWeight.w600,
      //       fontSize: 16,
      //       letterSpacing: 0.0,
      //       color: Colors.deepPurple,
      //       fontFamily: 'Helvetica',
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      // ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 30, top: 20, right: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 60,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: MediaQuery.of(context).size.width - 80,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(131, 146, 165, 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            onChanged: (text) {},
                            controller: emailcontroller,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  fontFamily: 'Helvetica', fontSize: 18),
                              hintText: "Email Address",
                              hintStyle: TextStyle(
                                  fontFamily: 'Helvetica', fontSize: 18),
                              icon: Icon(
                                FeatherIcons.mail,
                                color: Colors.blueGrey,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    var url = 'https://api.sellship.co/api/forgotpassword/' +
                        emailcontroller.text;

                    final response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              contentPadding: EdgeInsets.only(top: 10.0),
                              content: Container(
                                width: 300.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Center(
                                      child: Icon(
                                        FeatherIcons.mail,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'We have send a password reset email to the email address provided. Please reset your email using the link given in the email. ( Make sure to check your junk/spam too! )',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "SF",
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 20.0, bottom: 20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: "SF",
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Send Password Reset Email",
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
