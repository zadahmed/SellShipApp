import 'dart:convert';
import 'dart:io';

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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

class Payments {
  String paymentid;
  String cardnumber;
  String cardtype;

  Payments({
    this.paymentid,
    this.cardnumber,
    this.cardtype,
  });
}

class AddPayment extends StatefulWidget {
  @override
  _AddPaymentState createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  bool addaddress;

  List<Payments> paymentslist = List<Payments>();

  bool creditcardenabled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadpayments();
  }

  loadpayments() async {
    var user = await storage.read(key: 'userid');

    var url = "https://api.sellship.co/api/stripe/listmethods/" + user;

    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    print(jsonbody);
    var methods = jsonbody['methods'];

    for (int i = 0; i < methods.length; i++) {
      Payments payment = Payments(
          paymentid: methods[i]['id'],
          cardnumber: methods[i]['card']['last4'],
          cardtype: methods[i]['card']['brand']);
      paymentslist.add(payment);
    }

    setState(() {
      paymentslist = paymentslist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.deepPurple),
          backgroundColor: Colors.white,
          title: Text(
            'Choose a Payment Method',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          paymentslist.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    bottom: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Saved Payment Methods',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              : Container(),
          paymentslist.isNotEmpty
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
                      Expanded(
                          child: ListView.builder(
                        itemCount: paymentslist.length,
                        itemBuilder: (context, index) {
                          var icon;
                          if (paymentslist[index].cardtype == 'visa') {
                            icon = FontAwesome.cc_visa;
                          } else if (paymentslist[index].cardtype ==
                              'mastercard') {
                            icon = FontAwesome.cc_mastercard;
                          } else if (paymentslist[index].cardtype == 'amex') {
                            icon = FontAwesome.cc_amex;
                          } else if (paymentslist[index].cardtype ==
                              'discover') {
                            icon = FontAwesome.cc_discover;
                          } else if (paymentslist[index].cardtype == 'jcb') {
                            icon = FontAwesome.cc_jcb;
                          } else if (paymentslist[index].cardtype == 'diners') {
                            icon = FontAwesome.cc_diners_club;
                          }
                          return ListTile(
                            leading: Icon(
                              icon,
                              color: Colors.deepPurpleAccent,
                            ),
                            onTap: () {
                              Navigator.pop(context, paymentslist[index]);
                            },
                            title: Text('${paymentslist[index].cardnumber}'),
                          );
                        },
                      )),
                    ],
                  ))
              : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0.0, 0.6),
                    blurRadius: 5.0),
              ],
            ),
            child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.creditCard,
                  color: Colors.deepOrangeAccent,
                ),
                onTap: () async {
                  setState(() {
                    creditcardenabled = true;
                  });
                },
                title: Text(
                  'Add a new Credit/Debit Card',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.deepOrangeAccent,
                  size: 10,
                )),
          ),
          creditcardenabled == true
              ? CreditCardWidget(
                  cardBgColor: Colors.deepPurpleAccent,
                  textStyle: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                )
              : Container(),
          creditcardenabled == true
              ? CreditCardForm(
                  onCreditCardModelChange: onCreditCardModelChange,
                )
              : Container(),
          creditcardenabled == true
              ? Padding(
                  padding:
                      EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All payment information are stored securely and encrypted on our payment provider Stripe.',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          color: Colors.blueGrey),
                    ),
                  ),
                )
              : Container(),
          creditcardenabled == true
              ? InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Container(
                            height: 100,
                            child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SpinKitDoubleBounce(
                                    color: Colors.deepOrangeAccent)),
                          );
                        });
//                    addpaymentmethod();
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
                              color: Colors.deepPurpleAccent.withOpacity(0.4),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Add Card',
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
              : Container(),
          SizedBox(
            height: 10,
          ),
        ])));
  }

  final storage = new FlutterSecureStorage();

//  void addpaymentmethod() async {
//    var slash = expiryDate.indexOf('/');
//
//    CreditCard stripeCard = CreditCard(
//      number: cardNumber,
//      expMonth: int.parse(expiryDate.substring(0, slash)),
//      expYear: int.parse(expiryDate.substring(
//        slash + 1,
//      )),
//    );
//
//    var paymentMethod = await StripePayment.createPaymentMethod(
//        PaymentMethodRequest(card: stripeCard));
//    var userid = await storage.read(key: 'userid');
//
//    var url = 'https://api.sellship.co/api/addpaymentintent/' +
//        userid +
//        '/' +
//        paymentMethod.id;
//
//    final response = await http.get(url);
//
//    var jsonbody = json.decode(response.body);
//    showDialog(
//        context: context,
//        builder: (_) => AssetGiffyDialog(
//              image: Image.asset(
//                'assets/yay.gif',
//                fit: BoxFit.cover,
//              ),
//              title: Text(
//                'Card Added!',
//                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
//              ),
//              onlyOkButton: true,
//              entryAnimation: EntryAnimation.DEFAULT,
//              onOkButtonPressed: () {
//                Navigator.of(context, rootNavigator: true).pop('dialog');
//                Navigator.of(context, rootNavigator: true).pop('dialog');
//                Navigator.pop(context, jsonbody);
//              },
//            ));
//  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
