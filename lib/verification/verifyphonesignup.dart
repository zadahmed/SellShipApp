import 'package:SellShip/screens/OTPScreen.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class VerifyPhoneSignUp extends StatefulWidget {
  final String userid;

  VerifyPhoneSignUp({Key key, this.userid}) : super(key: key);

  @override
  _VerifyPhoneSignUpState createState() => new _VerifyPhoneSignUpState();
}

class _VerifyPhoneSignUpState extends State<VerifyPhoneSignUp> {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Verify Phone',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: ListView(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              height: 310,
                              width: MediaQuery.of(context).size.width,
                              child: Image.asset(
                                'assets/184.png',
                                fit: BoxFit.fitHeight,
                              ))
                        ])),
                Padding(
                    padding: EdgeInsets.only(left: 30, top: 30, right: 30),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 85,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 2),
                            width: MediaQuery.of(context).size.width - 100,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(131, 146, 165, 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 0),
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
                                countries: ['AE'],
                                autoValidateMode:
                                    AutovalidateMode.onUserInteraction,
                                textFieldController: _phoneNumberController,
                                inputDecoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  hintText: "501234567",
                                ),
                              ),
                            ),
                          )
                        ])),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 36, top: 20, right: 36),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OTPScreen(
                                    phonenumber: numberphone,
                                    userid: widget.userid,
                                  ),
                                ));
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width - 250,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 115, 0, 1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                                child: Text(
                              'Verify Phone',
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
            )));
  }
}
