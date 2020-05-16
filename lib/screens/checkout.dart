import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/existingcard.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderdetail.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class Checkout extends StatefulWidget {
  Item item;
  String offer;
  String messageid;
  Checkout({Key key, this.item, this.messageid, this.offer}) : super(key: key);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Item item;
  String messageid;
  String offer;
  @override
  void initState() {
    super.initState();

    StripeService.init();

    setState(() {
      messageid = widget.messageid;
      item = widget.item;
      offer = widget.offer;
    });
    calculatefees();
    getcurrency();
  }

  var fees;
  var totalpayable;

  calculatefees() {
    if (int.parse(offer) < 20) {
      fees = 2.0;
    } else {
      fees = 0.15 * int.parse(offer);
      if (fees > 200.0) {
        fees = 200;
      }
    }

    totalpayable = double.parse(offer) + fees;
  }

  var currency;
  var stripecurrency;
  final storage = new FlutterSecureStorage();

  getcurrency() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        stripecurrency = 'AED';
      });
    } else if (countr.trim().toLowerCase() == 'united states') {
      setState(() {
        currency = '\$';
        stripecurrency = 'USD';
      });
    }
  }

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepOrange,
          title: Text(
            'CHECKOUT',
            style: TextStyle(
                fontFamily: 'SF',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: 1,
          child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: Container(
                child: InkWell(
                  onTap: () async {
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Please wait...');
                    await dialog.show();

                    var slash = expiryDate.indexOf('/');

                    CreditCard stripeCard = CreditCard(
                      number: cardNumber,
                      expMonth: int.parse(expiryDate.substring(0, slash)),
                      expYear: int.parse(expiryDate.substring(
                        slash + 1,
                      )),
                    );

                    var response = await StripeService.payViaExistingCard(
                        amount: (totalpayable.toInt() * 100).toString(),
                        currency: stripecurrency,
                        card: stripeCard);
                    await dialog.hide();
                    if (response.success == true) {
                      var messageurl = 'https://sellship.co/api/payment/' +
                          messageid +
                          '/' +
                          item.itemid +
                          '/' +
                          offer.toString() +
                          '/' +
                          fees.toString() +
                          '/' +
                          totalpayable.toString();
                      final response = await http.get(messageurl);

                      if (response.statusCode == 200) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentDone(
                                    item: item,
                                    messageid: messageid,
                                  )),
                        );
                      }
                      await dialog.hide();
                    } else {
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
                                  'The transaction failed! Try again!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(),
                                ),
                                onlyOkButton: true,
                                entryAnimation: EntryAnimation.DEFAULT,
                                onOkButtonPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                },
                              ));
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16.0),
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
                        'Pay',
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
              )),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Details(itemid: item.itemid)),
                        );
                      },
                      child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800),
                            ),
                            leading: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: item.image,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              item.price.toString() + ' ' + currency,
                              style: TextStyle(
                                  fontFamily: 'SF',
                                  fontSize: 14,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                          )))),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Amount',
                    style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, bottom: 10, top: 20, right: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(item.name),
                          Text(offer.toString() + ' ' + currency)
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Platform Fees'),
                          Text(fees.toString() + ' ' + currency)
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total'),
                          Text(totalpayable.toString() + ' ' + currency)
                        ],
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment',
                    style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
              ),
              CreditCardForm(
                onCreditCardModelChange: onCreditCardModelChange,
              ),
              SizedBox(
                height: 80,
              )
            ],
          ),
        ));
  }

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
