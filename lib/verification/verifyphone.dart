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
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
              child: Icon(Icons.arrow_back_ios)),
          iconTheme: IconThemeData(color: Colors.deepOrange),
          elevation: 0,
          title: Text(
            'Verify Phone',
            style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body:
            StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
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
                    autoValidateMode: AutovalidateMode.onUserInteraction,
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OTPScreen(
                            phonenumber: numberphone,
                            userid: userid,
                          ),
                        ));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(5),
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
          );
        }));
  }
}
