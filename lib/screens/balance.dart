import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/withdrawals.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBalance();
    getDetails();
  }

  List<Withdrawals> withdrawllist = List<Withdrawals>();

  getDetails() async {
    userid = await storage.read(key: 'userid');

    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }

    var url = 'https://api.sellship.co/api/withdrawalhistory/' + userid;

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    for (int i = 0; i < jsonbody.length; i++) {
      var date = jsonbody[i]['date']['\$date'];
      DateTime dates = new DateTime.fromMillisecondsSinceEpoch(date);
      final f = new DateFormat('yyyy-MM-dd hh:mm');
      var s = f.format(dates);

      Withdrawals withd = Withdrawals(
        withdrawalid: jsonbody[i]['_id']['\$oid'],
        date: s.toString(),
        amount: jsonbody[i]['withdrawrequested'],
        completed: jsonbody[i]['completed'],
      );
      withdrawllist.add(withd);
    }
    setState(() {
      withdrawllist = withdrawllist;
    });
  }

  var userid;
  final storage = new FlutterSecureStorage();
  var balance;
  var currency;

  getBalance() async {
    userid = await storage.read(key: 'userid');
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
      });
    }
    var url = 'https://api.sellship.co/api/getbalance/' + userid;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      setState(() {
        balance = jsonbody['balance'];
      });
    } else {
      print(response.statusCode);
    }
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
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  withdraw() async {
    userid = await storage.read(key: 'userid');
    var url = 'https://api.sellship.co/api/withdraw/' + userid;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      showInSnackBar('Withdraw Requested');
    } else {
      print(response.statusCode);
    }
  }

  TextEditingController paypalcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Balance',
            style: TextStyle(color: Colors.black, fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 100,
                  child: Card(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        currency + ' ' + balance.toString(),
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  withdraw();
                },
                child: Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width - 50,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.4),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Withdraw',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, bottom: 10, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Details',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(
                  'Paypal',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                  ),
                ),
                leading: Icon(FontAwesome5Brands.paypal),
                children: <Widget>[
                  ListTile(
                    title: Container(
                        width: 200,
                        padding: EdgeInsets.only(),
                        child: Center(
                          child: TextField(
                            cursorColor: Color(0xFF979797),
                            controller: paypalcontroller,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: "Paypal Email",
                                alignLabelWithHint: true,
                                labelStyle: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                ),
                                focusColor: Colors.black,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ))),
                          ),
                        )),
                    trailing: InkWell(
                      onTap: () async {
                        var url = 'https://api.sellship.co/api/paypalemail/' +
                            userid +
                            '/' +
                            paypalcontroller.text.trim().toLowerCase();

                        final response = await http.get(url);
                        print(response.body);
                      },
                      child: Container(
                        width: 100,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              'Save',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Helvetica',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, bottom: 10, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Withdrawal History',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: withdrawllist.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(
                          '${withdrawllist[index].withdrawalid}',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          currency +
                              ' ' +
                              withdrawllist[index].amount.toString(),
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          withdrawllist[index].date,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                          ),
                        ),
                        leading: withdrawllist[index].completed == true
                            ? Text(
                                'Completed',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                'Pending',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                ),
                              ));
                  },
                ),
              )
            ])));
  }
}
