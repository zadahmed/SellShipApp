import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;

class VerifyEmail extends StatefulWidget {
  final String userid;
  final String email;
  VerifyEmail({
    Key key,
    this.email,
    this.userid,
  }) : super(key: key);

  @override
  _VerifyEmailState createState() => new _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String userid;
  String email;

  @override
  void initState() {
    super.initState();
    setState(() {
      userid = widget.userid;
      email = widget.email;
      emailcontroller.text = email;
    });
  }

  TextEditingController emailcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RootScreen(index: 2)),
              );
            },
            child: Icon(Icons.arrow_back_ios)),
        iconTheme: IconThemeData(color: Colors.deepOrange),
        elevation: 0,
        title: Text(
          'Verify Email',
          style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF'),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FadeAnimation(
                1.2,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Email Address',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: "SF",
                          fontWeight: FontWeight.w400,
                          color: Colors.black87),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: emailcontroller,
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: "SF",
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Enter your Email Address",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400])),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400])),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        var url = 'https://api.sellship.co/verify/email/' +
                            userid +
                            '/' +
                            emailcontroller.text;

                        final response = await http.get(url);
                        if (response.statusCode == 200) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(32.0))),
                                  contentPadding: EdgeInsets.only(top: 10.0),
                                  content: Container(
                                    width: 300.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
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
                                            'We have send a verification email to the email address provided. Please confirm your email using the link given in the email. ( Make sure to check your junk/spam too! )',
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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RootScreen(index: 2)),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: 20.0, bottom: 20.0),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(32.0),
                                                  bottomRight:
                                                      Radius.circular(32.0)),
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
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.deepOrangeAccent,
                                  Colors.deepOrange
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFF9DA3B4).withOpacity(0.1),
                                  blurRadius: 65.0,
                                  offset: Offset(0.0, 15.0))
                            ]),
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
                              "Send Verification Email",
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
