import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/existingcard.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderseller.dart';

import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';

class Payments {
  String paymentid;
  String cardnumber;
  String cardtype;
  String expirymonth;
  String expiryyear;

  Payments({
    this.paymentid,
    this.cardnumber,
    this.expirymonth,
    this.expiryyear,
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

  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadpayments();
  }

  loadpayments() async {
    paymentslist.clear();
    var user = await storage.read(key: 'userid');

    var url = "https://api.sellship.co/api/stripe/listmethods/" + user;

    final response = await http.get(Uri.parse(url));

    var jsonbody = json.decode(response.body);

    var methods = jsonbody['methods'];

    for (int i = 0; i < methods.length; i++) {
      Payments payment = Payments(
          paymentid: methods[i]['id'],
          cardnumber: methods[i]['card']['last4'],
          expirymonth: methods[i]['card']['exp_month'].toString(),
          expiryyear: methods[i]['card']['exp_year'].toString(),
          cardtype: methods[i]['card']['brand']);
      paymentslist.add(payment);
    }

    setState(() {
      loading = false;
      paymentslist = paymentslist;
    });
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
            'Choose Payment Method',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: loading == false
            ? SingleChildScrollView(
                child: Column(children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 15, bottom: 10, top: 10, right: 15),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    FontAwesomeIcons.creditCard,
                                    color: Colors.blueGrey,
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      creditcardenabled = true;
                                    });

                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        useRootNavigator: false,
                                        builder: (BuildContext context) {
                                          final _formKey =
                                              GlobalKey<FormState>();
                                          return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              backgroundColor: Colors.white,
                                              content: StatefulBuilder(
                                                  // You need this, notice the parameters below:
                                                  builder: (BuildContext
                                                          context,
                                                      StateSetter updateState) {
                                                return Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            10,
                                                    child: Scrollbar(
                                                        child:
                                                            SingleChildScrollView(
                                                                child: Form(
                                                                    key:
                                                                        _formKey,
                                                                    child: Column(
                                                                        children: <
                                                                            Widget>[
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                'Add a new Card',
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w800,
                                                                                  fontSize: 18,
                                                                                  letterSpacing: 0.0,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.close,
                                                                                    color: Colors.blueGrey,
                                                                                  )),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          // CreditCardWidget(
                                                                          //   cardBgColor:
                                                                          //       Colors.deepOrange,
                                                                          //   textStyle: TextStyle(
                                                                          //       fontFamily: 'Helvetica',
                                                                          //       fontSize: 16,
                                                                          //       color: Colors.white,
                                                                          //       fontWeight: FontWeight.w700),
                                                                          //   cardNumber:
                                                                          //       cardNumber,
                                                                          //   expiryDate:
                                                                          //       expiryDate,
                                                                          //   cardHolderName:
                                                                          //       cardHolderName,
                                                                          //   cvvCode:
                                                                          //       cvvCode,
                                                                          //   showBackView:
                                                                          //       isCvvFocused,
                                                                          // ),
                                                                          // CreditCardWidget(
                                                                          //   cardNumber:
                                                                          //       cardNumber,
                                                                          //   expiryDate:
                                                                          //       expiryDate,
                                                                          //   cardHolderName:
                                                                          //       cardHolderName,
                                                                          //   cvvCode:
                                                                          //       cvvCode,
                                                                          //   showBackView:
                                                                          //       isCvvFocused,
                                                                          //   cardBgColor:
                                                                          //       Colors.blueAccent,
                                                                          //   obscureCardNumber:
                                                                          //       true,
                                                                          //   obscureCardCvv:
                                                                          //       true,
                                                                          //   height:
                                                                          //       175,
                                                                          //   textStyle:
                                                                          //       TextStyle(color: Colors.yellowAccent),
                                                                          //   width:
                                                                          //       MediaQuery.of(context).size.width,
                                                                          //   animationDuration:
                                                                          //       Duration(milliseconds: 1000),
                                                                          // ),
                                                                          CreditCardForm(
                                                                            onCreditCardModelChange:
                                                                                (creditCardModel) {
                                                                              updateState(() {
                                                                                cardNumber = creditCardModel.cardNumber;
                                                                                expiryDate = creditCardModel.expiryDate;
                                                                                cardHolderName = creditCardModel.cardHolderName;
                                                                                cvvCode = creditCardModel.cvvCode;
                                                                                isCvvFocused = creditCardModel.isCvvFocused;
                                                                              });
                                                                            },
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(
                                                                                left: 15,
                                                                                bottom: 10,
                                                                                top: 10,
                                                                                right: 15),
                                                                            child:
                                                                                Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                'All payment information are stored securely and encrypted on our payment provider Stripe.',
                                                                                style: TextStyle(fontFamily: 'Helvetica', fontSize: 12, color: Colors.blueGrey),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                              onTap: () async {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    barrierDismissible: false,
                                                                                    useRootNavigator: false,
                                                                                    builder: (BuildContext context) {
                                                                                      return Container(
                                                                                        height: 100,
                                                                                        child: Padding(padding: const EdgeInsets.all(12.0), child: SpinKitDoubleBounce(color: Colors.deepOrangeAccent)),
                                                                                      );
                                                                                    });
                                                                                var slash = expiryDate.indexOf('/');

                                                                                CreditCard stripeCard = CreditCard(
                                                                                  number: cardNumber,
                                                                                  expMonth: int.parse(expiryDate.substring(0, slash)),
                                                                                  expYear: int.parse(expiryDate.substring(
                                                                                    slash + 1,
                                                                                  )),
                                                                                );

                                                                                StripePayment.setOptions(StripeOptions(
                                                                                    // publishableKey: "pk_live_CWGvDZru8fXBNVdXnhahkBoY00pzoyQfkz",
                                                                                    publishableKey: "pk_test_51IgtU3HQRQo46FowHQtM5WCo8AoLhvyjReZonLiYWa0Ihw31LIlPyO0Y3d0wKIqe8idUnesGGXxmYjkoezfAk2Q700dh5KkpVl",
                                                                                    // "pk_live_51IgtU3HQRQo46FowVzqt5d8VVYrjNyL66rnckL1DrzyEB6iz5I1mvLhjRxa9BOdAGDFpjvRMLKyO2PsGy3ywi8l300fChGmh9p",
                                                                                    merchantId: "merchant.com.zafra.sellship",
                                                                                    androidPayMode: 'production'));

                                                                                var paymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: stripeCard));

                                                                                print(paymentMethod);

                                                                                var userid = await storage.read(key: 'userid');

                                                                                var url = 'https://api.sellship.co/api/addpaymentintent/' + userid + '/' + paymentMethod.id;

                                                                                final response = await http.get(Uri.parse(url));
                                                                                print(response.statusCode);
                                                                                Navigator.pop(context);

                                                                                Navigator.of(context).pop('dialog');

                                                                                loadpayments();
                                                                              },
                                                                              child: Padding(
                                                                                padding: EdgeInsets.all(10),
                                                                                child: Container(
                                                                                  height: 48,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.deepOrange,
                                                                                    borderRadius: const BorderRadius.all(
                                                                                      Radius.circular(10.0),
                                                                                    ),
                                                                                    boxShadow: <BoxShadow>[
                                                                                      BoxShadow(color: Colors.deepOrange.withOpacity(0.4), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
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
                                                                        ])))));
                                              }));
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
                                    FeatherIcons.chevronRight,
                                    color: Colors.grey,
                                    size: 15,
                                  )),
                            ]))),
                SizedBox(
                  height: 5,
                ),
                paymentslist.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 10, top: 5, right: 15),
                        child: Container(
                            height: MediaQuery.of(context).size.height / 1.5,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Saved Payment Methods',
                                    style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: paymentslist.length,
                                  itemBuilder: (context, index) {
                                    var icon;
                                    if (paymentslist[index].cardtype ==
                                        'visa') {
                                      icon = FontAwesomeIcons.ccVisa;
                                    } else if (paymentslist[index].cardtype ==
                                        'mastercard') {
                                      icon = FontAwesomeIcons.ccMastercard;
                                    } else if (paymentslist[index].cardtype ==
                                        'amex') {
                                      icon = FontAwesomeIcons.ccAmex;
                                    } else if (paymentslist[index].cardtype ==
                                        'discover') {
                                      icon = FontAwesomeIcons.ccDiscover;
                                    } else if (paymentslist[index].cardtype ==
                                        'jcb') {
                                      icon = FontAwesomeIcons.ccJcb;
                                    } else if (paymentslist[index].cardtype ==
                                        'diners') {
                                      icon = FontAwesomeIcons.ccDinersClub;
                                    }
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        icon,
                                        color: Colors.blueGrey,
                                        size: 30,
                                      ),
                                      onTap: () {
                                        Navigator.pop(
                                            context, paymentslist[index]);
                                      },
                                      title: Text(
                                        '${capitalize(paymentslist[index].cardtype)} •••• •••• •••• ${paymentslist[index].cardnumber}',
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      subtitle: Text(
                                          'Expires  ${paymentslist[index].expirymonth}/${paymentslist[index].expiryyear}'),
                                    );
                                  },
                                )),
                              ],
                            )))
                    : Container(),
              ]))
            : Center(
                child: SpinKitDoubleBounce(
                  color: Colors.deepOrange,
                ),
              ));
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  final storage = new FlutterSecureStorage();
}
