import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/models/withdrawals.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/useritems.dart';
import 'package:SellShip/screens/withdrawal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getBalance();
    getDetails();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:ViewUserBalance',
      screenClassOverride: 'AppViewUserBalance',
    );
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

    final response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);
    print(jsonbody);

    for (int i = 0; i < jsonbody.length; i++) {
      var date = jsonbody[i]['date']['\$date'];
      DateTime dates = new DateTime.fromMillisecondsSinceEpoch(date);
      final f = new DateFormat('yyyy-MM-dd hh:mm');
      var s = f.format(dates);

      Withdrawals withd = Withdrawals(
        withdrawalid: jsonbody[i]['withdrawalsid']['\$oid'],
        date: s.toString(),
        iban: jsonbody[i]['withdrawaliban'],
        amount: double.parse(jsonbody[i]['withdrawalamount'].toString()),
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
    var url = 'https://api.sellship.co/api/user/' + userid;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      var bal;
      if (jsonbody['balance'] == null) {
        bal = 0;
      } else {
        bal = jsonbody['balance'];
      }

      var pending;
      if (jsonbody['pendingbalance'] == null) {
        pending = 0;
      } else {
        pending = jsonbody['pendingbalance'];
      }
      setState(() {
        pendingbalance = pending;
        balance = bal;
        loading = false;
      });
    } else {
      print(response.statusCode);
    }
  }

  var pendingbalance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  TextEditingController paypalcontroller = TextEditingController();
  bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Balance',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: loading == false
            ? SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 10, right: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                currency + ' ' + balance.toStringAsFixed(2),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                    fontSize: 30.0,
                                    fontFamily: "Helvetica"),
                              ),
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
                            ],
                          )),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 15, bottom: 5, right: 15),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Pending Balance',
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    currency +
                                        ' ' +
                                        pendingbalance.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]))),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        if (double.parse(balance.toString()) != 0.00 &&
                            double.parse(balance.toString()) > 50) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Withdraw(userid: userid, balance: balance)),
                          );
                          if (result == null) {
                            withdrawllist.clear();
                            getBalance();
                            getDetails();
                          }
                          // withdraw();
                        } else {
                          showInSnackBar(
                              'You need a minimum balance of AED 50 to be able to request a withdrawal');
                        }
                      },
                      child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width - 30,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 115, 0, 1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Withdraw',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Withdrawal History',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 10, right: 15),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: ListView.builder(
                            itemCount: withdrawllist.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  '#ID: ${withdrawllist[index].withdrawalid}',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Text(
                                  currency +
                                      ' ' +
                                      withdrawllist[index]
                                          .amount
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                      color: Colors.deepOrangeAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  withdrawllist[index].date,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 12,
                                  ),
                                ),
//                              leading: withdrawllist[index].completed == true
//                                  ? Text(
//                                      'Completed',
//                                      style: TextStyle(
//                                        fontFamily: 'Helvetica',
//                                        fontSize: 16,
//                                      ),
//                                    )
//                                  : Text(
//                                      'Pending',
//                                      style: TextStyle(
//                                        fontFamily: 'Helvetica',
//                                        fontSize: 16,
//                                      ),
//                                    )
                              );
                            },
                          ),
                        ))
                  ]))
            : Container(
                child: Center(
                  child: SpinKitDoubleBounce(
                    color: Colors.deepOrange,
                  ),
                ),
              ));
  }
}
