import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/existingcard.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class AddressModel {
  String addresstype;
  String address;
  String phonenumber;

  AddressModel({this.addresstype, this.address, this.phonenumber});
}

class _AddressState extends State<Address> {
  final addresslinecontroller = TextEditingController();
  final addressline2controller = TextEditingController();

  final citycontroller = TextEditingController();

  final phonenumbercontroller = TextEditingController();

  var phonenumber;

  final countrycontroller = TextEditingController();

  bool addaddress = false;

  final storage = new FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    readData();
    loadaddresses();
  }

  var userid;
  var country;
  readData() async {
    var ctry = await storage.read(key: 'country');
    var user = await storage.read(key: 'userid');
    setState(() {
      countrycontroller.text = ctry;
      userid = user;
      country = ctry;
    });
  }

  String statecode;

  var selectedCity;

  var selectedaddress;

  Widget newAddress(BuildContext context) {}

  List<AddressModel> addresseslist = List<AddressModel>();

  loadaddresses() async {
    var user = await storage.read(key: 'userid');

    var url = "https://api.sellship.co/api/getaddresses/" + user;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        addresseslist.add(AddressModel(
            addresstype: jsonbody[i]['addresstype'],
            address: jsonbody[i]['addressline1'] +
                '\n' +
                jsonbody[i]['addressline2'] +
                '\n' +
                jsonbody[i]['city'] +
                '\n' +
                jsonbody[i]['country'],
            phonenumber: jsonbody[i]['phonenumber']));
      }

      setState(() {
        addresseslist = addresseslist;
      });
    } else {
      print(response.statusCode);
      setState(() {
        addresseslist = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(242, 244, 248, 1),
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Address',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 10, right: 15),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Address',
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
                                              100,
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
                                                  'Add Address',
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
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
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
                                                    child: Center(
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          autofocus: true,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          icon: Icon(Icons
                                                              .keyboard_arrow_down),
                                                          hint: Center(
                                                            child: Text(
                                                              'Address Type',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          value:
                                                              selectedaddress,
                                                          onChanged: (value) {
                                                            updateState(() {
                                                              selectedaddress =
                                                                  value;
                                                            });
                                                          },
                                                          items: <String>[
                                                            'Home',
                                                            'Work',
                                                            'Other',
                                                          ].map((String value) {
                                                            return new DropdownMenuItem<
                                                                    String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      200,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        value),
                                                                  ),
                                                                ));
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
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
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          addressline2controller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Apartment/Villa Number",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
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
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          addresslinecontroller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Street Name/Area",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
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
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
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
                                                    child: Center(
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          autofocus: true,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          icon: Icon(Icons
                                                              .keyboard_arrow_down),
                                                          hint: Center(
                                                            child: Text(
                                                              'City',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          value: selectedCity,
                                                          onChanged: (value) {
                                                            updateState(() {
                                                              selectedCity =
                                                                  value;
                                                            });
                                                          },
                                                          items: <String>[
                                                            'Abu Dhabi',
                                                            'Alain',
                                                            'Dubai',
                                                            'Sharjah',
                                                            'Ajman',
                                                            'Umm Al Quwain',
                                                            'Ras Al Khaimah',
                                                            'Fujairah'
                                                          ].map((String value) {
                                                            return new DropdownMenuItem<
                                                                    String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      200,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        value),
                                                                  ),
                                                                ));
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        bottom: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
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
                                                    child:
                                                        InternationalPhoneNumberInput(
                                                      isEnabled: true,
                                                      onInputChanged:
                                                          (PhoneNumber
                                                              number) async {
                                                        if (number != null) {
                                                          setState(() {
                                                            phonenumber = number
                                                                .toString();
                                                          });
                                                        }
                                                      },
                                                      autoValidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      countries: ['AE'],
                                                      textFieldController:
                                                          phonenumbercontroller,
                                                      inputDecoration:
                                                          InputDecoration(
                                                        border:
                                                            UnderlineInputBorder(),
                                                        hintText: "501234567",
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
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
                                                    child: TextField(
                                                      enabled: false,
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          countrycontroller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Country",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
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
                                                      top: 5,
                                                      right: 10,
                                                      bottom: 10),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () async {
                                                      if (addresslinecontroller
                                                              .text.isEmpty ||
                                                          addressline2controller
                                                              .text.isEmpty ||
                                                          selectedCity ==
                                                              null ||
                                                          selectedaddress ==
                                                              null ||
                                                          phonenumbercontroller
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
                                                                            20.0)),
                                                                //this right here
                                                                child:
                                                                    Container(
                                                                  height: 100,
                                                                  child: Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          12.0),
                                                                      child: SpinKitChasingDots(
                                                                          color:
                                                                              Colors.deepPurpleAccent)),
                                                                ),
                                                              );
                                                            });

                                                        var url = 'https://api.sellship.co/api/addaddress/' +
                                                            userid +
                                                            '/' +
                                                            selectedaddress +
                                                            '/' +
                                                            addresslinecontroller
                                                                .text
                                                                .trim() +
                                                            '/' +
                                                            addressline2controller
                                                                .text
                                                                .trim() +
                                                            '/' +
                                                            selectedCity +
                                                            '/' +
                                                            phonenumber +
                                                            '/' +
                                                            country;

                                                        final response =
                                                            await http.get(url);

                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          var jsonbody = json
                                                              .decode(response
                                                                  .body);

                                                          print(jsonbody);

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
                                                                      'Address Added!',
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
                                                              .deepPurpleAccent,
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
                                                                    .deepPurpleAccent
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
                                                            'Add Address',
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
                          backgroundColor: Colors.deepPurpleAccent,
                        )),
                  ],
                )),
          ),
          addresseslist.isNotEmpty
              ? Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width / 2,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: addresseslist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            height: 300,
                            width: MediaQuery.of(context).size.width / 2,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: RadioListTile(
                                            value: index,
                                            groupValue: index,
                                            title: Text(addresseslist[index]
                                                .addresstype),
                                            onChanged: (intvalue) {})),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    top: 15,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      addresseslist[index].address,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueGrey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    top: 15,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      addresseslist[index].phonenumber,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.deepOrangeAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                  ))
              : Container()
        ]));
  }
}
