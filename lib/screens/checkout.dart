import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/addpayment.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

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
  var cardresult;
  @override
  void initState() {
    super.initState();
    getcurrency();
    StripeService.init();

    setState(() {
      messageid = widget.messageid;
      item = widget.item;
      offer = widget.offer;
    });
    calculatefees();
  }

  var totalpayable;

  calculatefees() {
    var rate;
    if (totalrate != null) {
      rate = totalrate;
    } else {
      rate = 0;
    }

    totalpayable = double.parse(offer) + double.parse(rate.toString());
  }

  GlobalKey _toolTipKey = GlobalKey();

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
    } else if (countr.trim().toLowerCase() == 'canada') {
      setState(() {
        currency = '\$';
        stripecurrency = 'CAD';
      });
    } else if (countr.trim().toLowerCase() == 'united kingdom') {
      setState(() {
        currency = '\$';
        stripecurrency = 'GBP';
      });
    }
  }

  var addressline1;
  var city;
  var state;
  var paymentby;
  var payment;
  var totalrate;
  var deliveryaddress;

  var zipcode;

  bool addressreturned = false;

  final scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.deepOrange),
          backgroundColor: Colors.white,
          title: Text(
            'CHECKOUT',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w800),
          ),
        ),
        bottomNavigationBar: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: 1,
          child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 15, bottom: 10, top: 5, right: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'On tapping \'Pay\', you hereby accept the terms and conditions of service from SellShip and our payment provider Stripe.',
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 10, right: 15),
                      child: Container(
                        child: InkWell(
                          onTap: () async {
                            if (deliveryaddress == null) {
                              //todo this is the same code as below refactor into widget.
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
                                          'Looks like your missing your delivery address!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                        onlyOkButton: true,
                                        entryAnimation: EntryAnimation.DEFAULT,
                                        onOkButtonPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        },
                                      ));
                            } else if (paymentby == null) {
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
                                          'Looks like your missing your Payment Method',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                        onlyOkButton: true,
                                        entryAnimation: EntryAnimation.DEFAULT,
                                        onOkButtonPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        },
                                      ));
                            } else {
                              if (paymentby != null) {
                                ProgressDialog dialog = new ProgressDialog(
                                  context,
                                );
                                dialog.style(message: 'Please wait...');
                                await dialog.show();
                                var userid = await storage.read(key: 'userid');

                                if (cardresult is Payments) {
                                  var messageurl =
                                      'https://api.sellship.co/api/stripe/pay/' +
                                          userid.toString() +
                                          '/' +
                                          cardresult.paymentid.toString() +
                                          '/' +
                                          offer.toString() +
                                          '/' +
                                          stripecurrency;
                                  final response = await http.get(messageurl);

                                  var paymentresponse =
                                      json.decode(response.body);

                                  if (paymentresponse['done'] == null) {
                                    if (paymentresponse['error']['code'] ==
                                        'card_declined') {
                                      await dialog.hide();
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                description: Text(
                                                  'Looks like your card has been declined! Please try another payment method',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(),
                                                ),
                                                onlyOkButton: true,
                                                entryAnimation:
                                                    EntryAnimation.DEFAULT,
                                                onOkButtonPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop('dialog');
                                                },
                                              ));
                                    } else if (paymentresponse['error']
                                            ['code'] ==
                                        'authentication_required') {
                                      var clientsecret =
                                          paymentresponse['error']
                                                  ['payment_intent']
                                              ['client_secret'];
                                      await dialog.hide();

                                      Stripe.init(
                                          "pk_live_CWGvDZru8fXBNVdXnhahkBoY00pzoyQfkz",
                                          returnUrlForSca:
                                              "stripesdk://3ds.stripesdk.io");

                                      final paymentIntent = await Stripe
                                          .instance
                                          .confirmPayment(clientsecret,
                                              paymentMethodId:
                                                  paymentresponse['error']
                                                              ['payment_intent']
                                                          ['charges']['data'][0]
                                                      ['payment_method']);

                                      if (paymentIntent['status'] ==
                                          'succeeded') {
                                        var messageurl =
                                            'https://api.sellship.co/api/payment/' +
                                                messageid +
                                                '/' +
                                                item.itemid +
                                                '/' +
                                                offer.toString() +
                                                '/' +
                                                totalrate.toString() +
                                                '/' +
                                                totalpayable.toString() +
                                                '/' +
                                                deliveryaddress +
                                                '/' +
                                                cardresult.paymentid.toString();

                                        final response =
                                            await http.get(messageurl);

                                        if (response.statusCode == 200) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentDone(
                                                      item: item,
                                                      messageid: messageid,
                                                    )),
                                          );
                                        }
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
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  description: Text(
                                                    'Looks like your card has been declined! Please try another payment method',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(),
                                                  ),
                                                  onlyOkButton: true,
                                                  entryAnimation:
                                                      EntryAnimation.DEFAULT,
                                                  onOkButtonPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop('dialog');
                                                  },
                                                ));
                                      }
                                    }
                                  } else {
                                    if (response.statusCode == 200) {
                                      var messageurl =
                                          'https://api.sellship.co/api/payment/' +
                                              messageid +
                                              '/' +
                                              item.itemid +
                                              '/' +
                                              offer.toString() +
                                              '/' +
                                              totalrate.toString() +
                                              '/' +
                                              totalpayable.toString() +
                                              '/' +
                                              deliveryaddress +
                                              '/' +
                                              cardresult.paymentid.toString();

                                      final response =
                                          await http.get(messageurl);

                                      if (response.statusCode == 200) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PaymentDone(
                                                    item: item,
                                                    messageid: messageid,
                                                  )),
                                        );

                                        await dialog.hide();
                                      }
                                    } else {
                                      await dialog.hide();
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                description: Text(
                                                  'The transaction failed! Try again!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(),
                                                ),
                                                onlyOkButton: true,
                                                entryAnimation:
                                                    EntryAnimation.DEFAULT,
                                                onOkButtonPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop('dialog');
                                                },
                                              ));
                                    }
                                  }
                                } else {
                                  var messageurl =
                                      'https://api.sellship.co/api/stripe/pay/' +
                                          userid.toString() +
                                          '/' +
                                          cardresult['id'].toString() +
                                          '/' +
                                          totalpayable.toString() +
                                          '/' +
                                          stripecurrency;
                                  final response = await http.get(messageurl);

                                  var paymentresponse =
                                      json.decode(response.body);

                                  if (paymentresponse['done'] == null) {
                                    if (paymentresponse['error']['code'] ==
                                        'card_declined') {
                                      await dialog.hide();
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                description: Text(
                                                  'Looks like your card has been declined! Please try another payment method',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(),
                                                ),
                                                onlyOkButton: true,
                                                entryAnimation:
                                                    EntryAnimation.DEFAULT,
                                                onOkButtonPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop('dialog');
                                                },
                                              ));
                                    } else if (paymentresponse['error']
                                            ['code'] ==
                                        'authentication_required') {
                                      var clientsecret =
                                          paymentresponse['error']
                                                  ['payment_intent']
                                              ['client_secret'];
                                      await dialog.hide();

                                      Stripe.init(
                                          "pk_live_CWGvDZru8fXBNVdXnhahkBoY00pzoyQfkz",
                                          returnUrlForSca:
                                              "stripesdk://3ds.stripesdk.io");

                                      final paymentIntent = await Stripe
                                          .instance
                                          .confirmPayment(clientsecret,
                                              paymentMethodId:
                                                  paymentresponse['error']
                                                              ['payment_intent']
                                                          ['charges']['data'][0]
                                                      ['payment_method']);

                                      if (paymentIntent['status'] ==
                                          'succeeded') {
                                        var messageurl =
                                            'https://api.sellship.co/api/payment/' +
                                                messageid +
                                                '/' +
                                                item.itemid +
                                                '/' +
                                                offer.toString() +
                                                '/' +
                                                totalrate.toString() +
                                                '/' +
                                                totalpayable.toString() +
                                                '/' +
                                                deliveryaddress +
                                                '/' +
                                                cardresult['id'].toString();

                                        final response =
                                            await http.get(messageurl);

                                        if (response.statusCode == 200) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentDone(
                                                      item: item,
                                                      messageid: messageid,
                                                    )),
                                          );
                                        }
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
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  description: Text(
                                                    'Looks like your card has been declined! Please try another payment method',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(),
                                                  ),
                                                  onlyOkButton: true,
                                                  entryAnimation:
                                                      EntryAnimation.DEFAULT,
                                                  onOkButtonPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop('dialog');
                                                  },
                                                ));
                                      }
                                    }
                                  } else {
                                    if (response.statusCode == 200) {
                                      var messageurl =
                                          'https://api.sellship.co/api/payment/' +
                                              messageid +
                                              '/' +
                                              item.itemid +
                                              '/' +
                                              offer.toString() +
                                              '/' +
                                              totalrate.toString() +
                                              '/' +
                                              totalpayable.toString() +
                                              '/' +
                                              deliveryaddress +
                                              '/' +
                                              cardresult['id'].toString();

                                      final response =
                                          await http.get(messageurl);

                                      if (response.statusCode == 200) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PaymentDone(
                                                    item: item,
                                                    messageid: messageid,
                                                  )),
                                        );

                                        await dialog.hide();
                                      }
                                    } else {
                                      await dialog.hide();
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                description: Text(
                                                  'The transaction failed! Try again!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(),
                                                ),
                                                onlyOkButton: true,
                                                entryAnimation:
                                                    EntryAnimation.DEFAULT,
                                                onOkButtonPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop('dialog');
                                                },
                                              ));
                                    }
                                  }
                                }
                              }
                            }
                          },
                          child: Container(
                            height: 48,
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
                ],
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
                                  fontFamily: 'Helvetica',
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
                                  fontFamily: 'Helvetica',
                                  fontSize: 14,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                          )))),
              Padding(
                padding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your seller will ship out the item once the payment has been completed. Don\'t worry, we will only release the payment to the seller, once you confirm that you have recieved the item as listed.',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 12,
                        color: Colors.blueGrey),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Amount',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
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
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Address()),
                      );

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Container(
                              height: 100,
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SpinKitChasingDots(
                                      color: Colors.deepOrangeAccent)),
                            );
                          });

                      setState(() {
                        addressline1 = result['addrLine1'];
                        city = result['city'];
                        state = result['state'];
                        zipcode = result['zip_code'];

                        deliveryaddress = result['addrLine1'] +
                            ' ,\n' +
                            result['city'] +
                            ' ,' +
                            result['state'] +
                            ' ,' +
                            result['zip_code'];
                        addressreturned = true;
                      });

                      var userid = await storage.read(key: 'userid');
                      var ratesurl = 'https://api.sellship.co/api/rates/' +
                          addressline1 +
                          '/' +
                          city +
                          '/' +
                          state +
                          '/' +
                          zipcode +
                          '/' +
                          item.itemid +
                          '/' +
                          userid;
                      final response = await http.get(ratesurl);
                      var jsonrates = json.decode(response.body);

                      print(jsonrates);
                      var totalrat = jsonrates['rates']
                              ['RatingServiceSelectionResponse']
                          ['RatedShipment']['TotalCharges']['MonetaryValue'];
                      setState(() {
                        totalrate = totalrat;
                      });
                      calculatefees();
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    title: Text(
                      'Deliver To',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    trailing: addressreturned == false
                        ? Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                          )
                        : Text(
                            deliveryaddress,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          )),
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
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddPayment()),
                      );

                      if (result is String) {
                        print(result);
                        if (result == 'applepay') {
                          setState(() {
                            paymentby = 'Apple Pay';
                          });
                        } else if (result == 'googlepay') {
                          setState(() {
                            paymentby = 'Google Pay';
                          });
                        }
                      } else if (result is Payments) {
                        setState(() {
                          paymentby = result.cardnumber;
                          cardresult = result;
                        });
                      } else if (result.containsKey("card")) {
                        var paymentmethod = result['card']['card']['last4'];
                        setState(() {
                          paymentby = paymentmethod;
                          cardresult = result['card'];
                        });
                      } else {
                        setState(() {
                          paymentby = null;
                        });
                      }
                    },
                    title: Text(
                      'Pay using',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    trailing: paymentby == null
                        ? Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                          )
                        : Text(paymentby.toString())),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: 10, bottom: 10, top: 20, right: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 250,
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ),
                          Text(
                            offer.toString() + ' ' + currency,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      totalrate != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Delivery',
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                Text(
                                  totalrate.toString() + ' ' + currency,
                                  style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black),
                                )
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          Text(
                            totalpayable.toStringAsFixed(2) + ' ' + currency,
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black),
                          )
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
