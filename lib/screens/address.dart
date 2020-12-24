import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/existingcard.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final addresslinecontroller = TextEditingController();
  final addressline2controller = TextEditingController();

  final citycontroller = TextEditingController();

  final zipcodecontroller = TextEditingController();

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

  var state_codes = {
    "Armed Forces America": "AA",
    "Armed Forces": "AE",
    "Alaska": "AK",
    "Alabama": "AL",
    "AP": "Armed Forces Pacific",
    "Arkansas": "AR",
    "American Samoa": "AS",
    "Arizona": "AZ",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Washington DC": "DC",
    "Delaware": "DE",
    "Florida": "FL",
    "Georgia": "GA",
    "Guam": "GU",
    "Hawaii": "HI",
    "Iowa": "IA",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Massachusetts": "MA",
    "Maryland": "MD",
    "Maine": "ME",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Missouri": "MO",
    "Mississippi": "MS",
    "Montana": "MT",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Nebraska": "NE",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "Nevada": "NV",
    "New York": "NY",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Puerto Rico": "PR",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Virginia": "VA",
    "Virgin Islands": "VI",
    "Vermont": "VT",
    "Washington": "WA",
    "Wisconsin": "WI",
    "West Virginia": "WV",
    "Wyoming": "WY"
  };

  String statecode;

  Widget newAddress(BuildContext context) {}

  List<String> addresses1list = List<String>();
  List<String> citylist = List<String>();
  List<String> statelist = List<String>();
  List<String> zipcodelist = List<String>();
  List<String> addresseslist = List<String>();

  loadaddresses() async {
    var user = await storage.read(key: 'userid');

    var url = "https://api.sellship.co/api/getaddresses/" + user;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);

      var addresses = jsonbody['addresses'];

      for (int i = 0; i < addresses.length; i++) {
        var address;
        if (addresses[i]['addrLine1'] is List) {
          address = addresses[i]['addrLine1'].join('') +
              ' \n' +
              addresses[i]['city'] +
              ' \n' +
              addresses[i]['zip_code'].toString();
          addresseslist.add(address);
          addresses1list.add(addresses[i]['addrLine1'].join(''));
          citylist.add(addresses[i]['city']);
          statelist.add(addresses[i]['state']);
          zipcodelist.add(addresses[i]['zip_code'].toString());
        } else {
          address = addresses[i]['addrLine1'] +
              ' \n' +
              addresses[i]['city'] +
              ' \n' +
              addresses[i]['zip_code'].toString();
          addresseslist.add(address);
          addresses1list.add(addresses[i]['addrLine1']);
          citylist.add(addresses[i]['city']);
          statelist.add(addresses[i]['state']);
          zipcodelist.add(addresses[i]['zip_code'].toString());
        }
      }

      setState(() {
        addresseslist = addresseslist;
        addresses1list = addresses1list;
        citylist = citylist;
        statelist = statelist;
        zipcodelist = zipcodelist;
      });
    } else {
      setState(() {
        addresseslist = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
        title: Text(
          'Add an Address',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.deepOrange,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          addresseslist.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    bottom: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Saved Addresses',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              : Container(),
          addresseslist.isNotEmpty
              ? Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          offset: const Offset(0.0, 0.5),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 150,
                          child: ListView.builder(
                            itemCount: addresseslist.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(FontAwesome.home),
                                onTap: () {
                                  Navigator.of(context).pop({
                                    'address': addresseslist[index],
                                    'addrLine1': addresses1list[index],
                                    'city': citylist[index],
                                    'state': statelist[index],
                                    'zip_code': zipcodelist[index]
                                  });
                                },
                                title: Text('${addresseslist[index]}'),
                              );
                            },
                          )),
                    ],
                  ))
              : Container(),
          ListTile(
            leading: Icon(Icons.add),
            onTap: () {
              setState(() {
                addaddress = true;
              });
            },
            title: Text('Add a New Address'),
          ),
          addaddress == true
              ? Column(
                  children: <Widget>[
                    Padding(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          cursorColor: Color(0xFF979797),
                          controller: addressline2controller,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              labelText:
                                  "Address 1 - Building Name/Apt/Suite No",
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
                      ),
                      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                    ),
                    Padding(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          cursorColor: Color(0xFF979797),
                          controller: addresslinecontroller,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              labelText: "Address 2 - Building No Street/Road",
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
                      ),
                      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                    ),
                    Padding(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          cursorColor: Color(0xFF979797),
                          controller: citycontroller,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              labelText: "City",
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
                      ),
                      padding: EdgeInsets.only(left: 10, top: 5, right: 10),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 5, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('State'),
                          trailing: Container(
                              child: DropdownButton<String>(
                            items: state_codes
                                .map((state, code) {
                                  return MapEntry(
                                      state,
                                      DropdownMenuItem<String>(
                                        value: code,
                                        child: Text(state),
                                      ));
                                })
                                .values
                                .toList(),
                            value: statecode,
                            onChanged: (newValue) {
                              setState(() {
                                statecode = newValue;
                              });
                            },
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          cursorColor: Color(0xFF979797),
                          controller: zipcodecontroller,
                          enableSuggestions: true,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              labelText: "Zip Code",
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
                      ),
                      padding: EdgeInsets.only(left: 10, top: 5, right: 10),
                    ),
                    Padding(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          enabled: false,
                          cursorColor: Color(0xFF979797),
                          controller: countrycontroller,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              labelText: "Country",
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
                      ),
                      padding: EdgeInsets.only(
                          left: 10, top: 5, right: 10, bottom: 10),
                    ),
                    InkWell(
                        onTap: () async {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0)), //this right here
                                  child: Container(
                                    height: 100,
                                    child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SpinKitChasingDots(
                                            color: Colors.deepPurpleAccent)),
                                  ),
                                );
                              });
                          String newStr = addresslinecontroller.text
                              .replaceAll("\'", " ")
                              .replaceAll("\-", " ")
                              .replaceAll("\,", " ");

                          String newStr2 = addressline2controller.text
                              .replaceAll("\'", " ")
                              .replaceAll("\-", " ")
                              .replaceAll("\,", " ");

                          var countrycode;

                          if (country == 'United States') {
                            countrycode = 'US';
                          } else if (country == 'United Arab Emirates') {
                            countrycode = 'UAE';
                          }

                          String address = newStr + ' ' + newStr2;
                          var url = 'https://api.sellship.co/api/addaddress/' +
                              userid +
                              '/' +
                              address +
                              '/' +
                              citycontroller.text.trim() +
                              '/' +
                              statecode +
                              '/' +
                              zipcodecontroller.text.trim() +
                              '/' +
                              countrycode;

                          final response = await http.get(url);

                          var jsonbody = json.decode(response.body);

                          var responsebody = jsonbody['response'];

                          if (responsebody == 'Address Not Added') {
                            showDialog(
                                context: context,
                                builder: (_) => AssetGiffyDialog(
                                      image: Image.asset(
                                        'assets/oops.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        'Oops!',
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'There seems to be an error with the address you entered!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                      onlyOkButton: true,
                                      entryAnimation: EntryAnimation.DEFAULT,
                                      onOkButtonPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      },
                                    ));
                          } else if (responsebody['code'] == 0.toString()) {
                            showDialog(
                                context: context,
                                builder: (_) => AssetGiffyDialog(
                                      image: Image.asset(
                                        'assets/oops.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        'Oops!',
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'There seems to be an error with the address you entered!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(),
                                      ),
                                      onlyOkButton: true,
                                      entryAnimation: EntryAnimation.DEFAULT,
                                      onOkButtonPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      },
                                    ));
                          } else {
                            var addressreturned = jsonbody['response'];
                            print('d');

                            showDialog(
                                context: context,
                                builder: (_) => AssetGiffyDialog(
                                      image: Image.asset(
                                        'assets/yay.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        'Address Added!',
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      onlyOkButton: true,
                                      entryAnimation: EntryAnimation.DEFAULT,
                                      onOkButtonPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');

                                        if (addressreturned['AddressLine']
                                            is List) {
                                          Navigator.of(context).pop({
                                            'address':
                                                addressreturned['AddressLine']
                                                        [0] +
                                                    ' ,\n' +
                                                    addressreturned[
                                                        'PoliticalDivision2'] +
                                                    ', ' +
                                                    addressreturned[
                                                        'PoliticalDivision1'] +
                                                    ', ' +
                                                    addressreturned[
                                                        'PostcodeExtendedLow'],
                                            'addrLine1':
                                                addressreturned['AddressLine'],
                                            'city': addressreturned[
                                                'PoliticalDivision2'],
                                            'state': addressreturned[
                                                'PoliticalDivision1'],
                                            'zip_code': addressreturned[
                                                'PostcodePrimaryLow']
                                          });
                                        } else {
                                          Navigator.of(context).pop({
                                            'address':
                                                addressreturned['AddressLine'] +
                                                    ' ,\n' +
                                                    addressreturned[
                                                        'PoliticalDivision2'] +
                                                    ', ' +
                                                    addressreturned[
                                                        'PoliticalDivision1'] +
                                                    ', ' +
                                                    addressreturned[
                                                        'PostcodeExtendedLow'],
                                            'addrLine1':
                                                addressreturned['AddressLine'],
                                            'city': addressreturned[
                                                'PoliticalDivision2'],
                                            'state': addressreturned[
                                                'PoliticalDivision1'],
                                            'zip_code': addressreturned[
                                                'PostcodePrimaryLow']
                                          });
                                        }
//                                          Navigator.of(context).pop({
//                                            'address':
//                                                addressreturned['addrLine1'] +
//                                                    ' ,\n' +
//                                                    addressreturned['city'] +
//                                                    ', ' +
//                                                    addressreturned['state'] +
//                                                    ', ' +
//                                                    addressreturned['zip_code'],
//                                            'addrLine1':
//                                                addressreturned['addrLine1'],
//                                            'city': addressreturned['city'],
//                                            'state': addressreturned['state'],
//                                            'zip_code':
//                                                addressreturned['zip_code']
//                                          });
                                      },
                                    ));
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.4),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Add Address',
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
                        )),
                  ],
                )
              : Container(),
        ],
      )),
    );
  }
}
