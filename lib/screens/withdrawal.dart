import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Withdraw extends StatefulWidget {
  final String userid;
  final double balance;

  Withdraw({Key key, this.userid, this.balance}) : super(key: key);

  @override
  _WithdrawState createState() => _WithdrawState();
}

class BankAccounts {
  String beneficiaryname;
  String bankname;
  String bankbranch;
  String iban;
  String confrimiban;

  BankAccounts({
    this.beneficiaryname,
    this.bankname,
    this.bankbranch,
    this.confrimiban,
    this.iban,
  });
}

class _WithdrawState extends State<Withdraw> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      balance = widget.balance;
      currentvalue = balance / 2;
    });
    loadaddresses();
  }

  List<BankAccounts> bankaccountslist = List<BankAccounts>();

  loadaddresses() async {
    bankaccountslist.clear();

    var url = "https://api.sellship.co/api/get/bank/" + widget.userid;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        bankaccountslist.add(BankAccounts(
          bankbranch: jsonbody[i]['bankbranch'],
          bankname: jsonbody[i]['bankname'],
          beneficiaryname: jsonbody[i]['beneficiaryname'],
          iban: jsonbody[i]['iban'],
          confrimiban: jsonbody[i]['confirmiban'],
        ));
      }

      if (bankaccountslist != null) {
        setState(() {
          loading = false;
          selectedBank = bankaccountslist[0];
          bankaccountslist = bankaccountslist;
        });
      } else {
        setState(() {
          loading = false;
          bankaccountslist = bankaccountslist;
        });
      }
    } else {
      setState(() {
        loading = false;
        bankaccountslist = [];
      });
    }
  }

  int selected = 0;

  BankAccounts selectedBank;

  bool loading = true;

  final banknamecontroller = TextEditingController();
  final bankbranchcontroller = TextEditingController();
  final bankibancountroller = TextEditingController();
  final bankibanconfirmcountroller = TextEditingController();
  final firstnamelastnameuser = TextEditingController();

  final citycontroller = TextEditingController();

  final phonenumbercontroller = TextEditingController();

  double balance = 0;
  double currentvalue = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Withdraw to Bank Account',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18.0,
              fontFamily: "Helvetica"),
        ),
        iconTheme: IconThemeData(
          color: Color.fromRGBO(10, 17, 65, 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5, top: 10, right: 15),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Withdraw',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontFamily: "Helvetica"),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'AED ' + currentvalue.roundToDouble().toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                  fontSize: 30.0,
                                  fontFamily: "Helvetica"),
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      Slider(
                        value: currentvalue,
                        min: 0,
                        max: balance,
                        activeColor: Colors.deepOrange,
                        label: currentvalue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            currentvalue = value;
                          });
                        },
                      )
                    ],
                  ))),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 10, right: 15),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Bank Account',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    backgroundColor: Colors.white,
                                    content: StatefulBuilder(
                                        // You need this, notice the parameters below:
                                        builder: (BuildContext context,
                                            StateSetter updateState) {
                                      return Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2 +
                                              20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          child: Scrollbar(
                                              child: SingleChildScrollView(
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Add Bank Account',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                    letterSpacing: 0.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Enter your IBAN";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          bankibancountroller,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "IBAN (AE)",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Confirm your IBAN";
                                                        } else if (value !=
                                                            bankibancountroller
                                                                .text) {
                                                          return "IBAN must be the same";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          bankibanconfirmcountroller,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Confirm IBAN (AE)",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Enter your Bank Name";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          banknamecontroller,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Bank Name",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Enter your Bank Branch";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          bankbranchcontroller,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Bank Branch",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Please Enter the Beneficiary name";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          firstnamelastnameuser,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Beneficiary Name",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () async {
                                                      if (bankbranchcontroller.text.isEmpty ||
                                                          bankibancountroller
                                                              .text.isEmpty ||
                                                          bankibanconfirmcountroller
                                                              .text.isEmpty ||
                                                          banknamecontroller
                                                              .text.isEmpty ||
                                                          firstnamelastnameuser
                                                              .text.isEmpty) {
                                                        showDialog(
                                                            context: context,
                                                            useRootNavigator:
                                                                false,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title:
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      content: Text(
                                                                          "Oops looks like something is missing."),
                                                                      actions: [
                                                                        InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(10),
                                                                              child: Container(
                                                                                height: 48,
                                                                                width: 100,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.black,
                                                                                  borderRadius: const BorderRadius.all(
                                                                                    Radius.circular(10.0),
                                                                                  ),
                                                                                  boxShadow: <BoxShadow>[
                                                                                    BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
                                                                                  ],
                                                                                ),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Close',
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
                                                                            ))
                                                                      ],
                                                                    ));
                                                      } else {
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            useRootNavigator:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0)), //this right here
                                                                  child: Container(
                                                                      height: 170,
                                                                      padding: EdgeInsets.all(15),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            'Adding New Bank Account..',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                              height: 50,
                                                                              width: 50,
                                                                              child: SpinKitDoubleBounce(
                                                                                color: Colors.deepOrange,
                                                                              )),
                                                                        ],
                                                                      )));
                                                            });

                                                        var url =
                                                            'https://api.sellship.co/api/add/bank/' +
                                                                widget.userid;

                                                        Dio dio = new Dio();
                                                        FormData formData;

                                                        formData =
                                                            FormData.fromMap({
                                                          'beneficiaryname':
                                                              firstnamelastnameuser
                                                                  .text,
                                                          'bankname':
                                                              banknamecontroller
                                                                  .text,
                                                          'bankbranch':
                                                              bankbranchcontroller
                                                                  .text,
                                                          'iban':
                                                              bankibancountroller
                                                                  .text,
                                                          'confirmiban':
                                                              bankibanconfirmcountroller
                                                                  .text,
                                                        });

                                                        var response =
                                                            await dio.post(url,
                                                                data: formData);
                                                        //
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          showDialog(
                                                              context: context,
                                                              useRootNavigator:
                                                                  false,
                                                              builder: (_) =>
                                                                  AssetGiffyDialog(
                                                                    image: Image
                                                                        .asset(
                                                                      'assets/yay.gif',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    title: Text(
                                                                      'Bank Account Added!',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              22.0,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    onlyOkButton:
                                                                        true,
                                                                    entryAnimation:
                                                                        EntryAnimation
                                                                            .DEFAULT,
                                                                    onOkButtonPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        loading =
                                                                            true;
                                                                      });
                                                                      loadaddresses();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');
                                                                    },
                                                                  ));
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop('dialog');

                                                          print(response
                                                              .statusCode);
                                                        }
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Container(
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                10.0),
                                                          ),
                                                          boxShadow: <
                                                              BoxShadow>[
                                                            BoxShadow(
                                                                color: Colors
                                                                    .deepOrangeAccent
                                                                    .withOpacity(
                                                                        0.4),
                                                                offset:
                                                                    const Offset(
                                                                        1.1,
                                                                        1.1),
                                                                blurRadius:
                                                                    10.0),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Add Bank Account',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  0.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          )));
                                    }));
                              });
                        },
                        child: CircleAvatar(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.deepOrangeAccent)),
                  ],
                )),
          ),
          loading == false
              ? bankaccountslist.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: bankaccountslist.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  setState(() {
                                    selected = index;
                                    selectedBank = bankaccountslist[index];
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: selected == index
                                          ? Border.all(
                                              color: Colors.deepOrangeAccent,
                                              width: 3)
                                          : Border.all(color: Colors.white),
                                      color: Colors.white),
                                  height: 130,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            top: 5,
                                            bottom: 5,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              bankaccountslist[index].iban,
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black),
                                            ),
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            bankaccountslist[index]
                                                .beneficiaryname,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blueGrey),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          top: 5,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            bankaccountslist[index].bankname,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.deepOrangeAccent),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          bottom: 5,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            bankaccountslist[index].bankbranch,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.deepOrangeAccent),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ))
                  : Container()
              : Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: ListView(
                      children: [0]
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 300.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 280.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                )
        ],
      ),
      floatingActionButton: Padding(
        child: InkWell(
            child: Container(
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: MediaQuery.of(context).size.width - 20,
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: currentvalue >= 50.0 ? Colors.deepOrange : Colors.grey,
                ),
                child: Center(
                  child: Text(
                    'Withdraw ' +
                        'AED ' +
                        currentvalue.roundToDouble().toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Helvetica',
                        color: Colors.white),
                  ),
                )),
            onTap: () async {
              Widget cancelButton = FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'Helvetica', color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = FlatButton(
                child: Text(
                  'Withdraw',
                  style:
                      TextStyle(fontFamily: 'Helvetica', color: Colors.black),
                ),
                onPressed: () async {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      useRootNavigator: false,
                      builder: (_) => new AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            content: Builder(
                              builder: (context) {
                                return Container(
                                    height: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Requesting Withdrawal',
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
                  Dio dio = new Dio();
                  FormData formData;

                  var url =
                      'https://api.sellship.co/api/withdraw/' + widget.userid;

                  formData = FormData.fromMap({
                    'amount': currentvalue.toString(),
                    'beneficiaryname': selectedBank.beneficiaryname,
                    'bankname': selectedBank.bankname,
                    'bankbranch': selectedBank.bankbranch,
                    'iban': selectedBank.iban,
                    'confirmiban': selectedBank.confrimiban,
                  });

                  var response = await dio.post(url, data: formData);

                  if (response.statusCode == 200) {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.pop(context);
                    showInSnackBar('Withdraw Requested');
                  } else {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.pop(context);
                    print(response.statusCode);
                  }
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text(
                  'Withdraw ' +
                      'AED ' +
                      currentvalue.roundToDouble().toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica',
                      color: Colors.black),
                ),
                content: Text("Confirm withdrawal to " +
                    selectedBank.bankname +
                    ' with IBAN ' +
                    selectedBank.iban),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            }),
        padding: EdgeInsets.only(left: 20, right: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

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
}
