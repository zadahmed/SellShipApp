import 'package:SellShip/screens/OTPScreen.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class VerifyPhone extends StatefulWidget {
  final String userid;

  VerifyPhone({Key key, this.userid}) : super(key: key);

  @override
  _VerifyPhoneState createState() => new _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isValid = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    setState(() {
      userid = widget.userid;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  Future<Null> validate(StateSetter updateState) async {
    print("in validate : ${_phoneNumberController.text.length}");
    if (_phoneNumberController.text.length == 10) {
      updateState(() {
        isValid = true;
      });
    }
  }

  var numberphone;
  var userid;

  final FocusNode myFocusNodePhone = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
              child: Icon(Icons.arrow_back_ios)),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Verify Phone',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body:
            StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5, top: 10, right: 15),
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: InternationalPhoneNumberInput(
                        isEnabled: true,
                        onInputChanged: (PhoneNumber number) async {
                          if (number != null) {
                            setState(() {
                              numberphone = number.toString();
                            });
                          }
                        },
                        focusNode: myFocusNodePhone,
                        autoValidate: true,
                        countries: ['AE'],
                        textFieldController: _phoneNumberController,
                        inputDecoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "501234567",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (numberphone != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPScreen(
                                  phonenumber: numberphone,
                                  userid: userid,
                                ),
                              ));
                        } else {
                          showInSnackBar('Please enter a valid number');
                        }
                      },
                      child: Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: MediaQuery.of(context).size.width - 200,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 115, 0, 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Verify Phone",
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
                      ),
                    ),
                  ],
                ),
              ));
        }));
  }
}
