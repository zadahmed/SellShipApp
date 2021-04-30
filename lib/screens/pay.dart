import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/addpayment.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/onboardingbottom.dart';

import 'package:SellShip/screens/paymentweb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class Pay extends StatefulWidget {
  String itemid;
  String messageid;
  AddressModel address;
  String phonenumber;
  double price;

  Pay({
    Key key,
    this.itemid,
    this.messageid,
    this.price,
    this.phonenumber,
    this.address,
  }) : super(key: key);
  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  var cardresult;
  double total;
  double subtotal = 0.0;
  checkuser() async {
    var userid = await storage.read(key: 'userid');

    if (userid == null) {
      Navigator.pop(context);
      showModalBottomSheet(
          context: context,
          useRootNavigator: false,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 1,
                builder: (_, controller) {
                  return Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0)),
                      ),
                      child: OnboardingScreen());
                });
          });
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedaddress = widget.address;
      phonenumber = widget.phonenumber;
    });
    checkuser();
    getcurrency();

    setState(() {});
  }

  GlobalKey _toolTipKey = GlobalKey();

  var currency;
  var stripecurrency;

  final storage = new FlutterSecureStorage();

  AddressModel selectedaddress;

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldState.currentState?.removeCurrentSnackBar();
    scaffoldState.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.deepOrange,
      duration: Duration(seconds: 3),
    ));
  }

  List<Item> listitems = List<Item>();

  var phonenumber;
  getcurrency() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        stripecurrency = 'AED';
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List cartitems = prefs.getStringList('cartitems');

    var deliverycharges;
    if (cartitems != null) {
      for (int i = 0; i < cartitems.length; i++) {
        var decodeditem = json.decode(cartitems[i]);

        print(decodeditem);
        Item newItem = Item(
            name: decodeditem['name'],
            selectedsize: decodeditem['selectedsize'],
            quantity: decodeditem['quantity'],
            itemid: decodeditem['itemid'],
            weight: decodeditem['weight'],
            freedelivery: decodeditem['freedelivery'],
            price: decodeditem['price'].toString(),
            image: decodeditem['image'],
            userid: decodeditem['sellerid'] == null
                ? decodeditem['userid']
                : decodeditem['sellerid'],
            username: decodeditem['sellername'] == null
                ? decodeditem['username']
                : decodeditem['sellername']);

        if (newItem.freedelivery == false) {
          var weightfees;
          if (newItem.weight == '5') {
            weightfees = 10;
          } else if (newItem.weight == '10') {
            weightfees = 30;
          } else if (newItem.weight == '20') {
            weightfees = 50;
          } else if (newItem.weight == '50') {
            weightfees = 110;
          }

          setState(() {
            deliveryamount = 'AED ' + weightfees.toString();
            deliverycharges = double.parse(weightfees.toString());
          });
        } else {
          setState(() {
            deliveryamount = 'FREE';
            deliverycharges = 0.0;
          });
        }

        subtotal = subtotal + double.parse(widget.price.toString());

        listitems.add(newItem);
      }
    }

    setState(() {
      subtotal = subtotal;
      total = subtotal + deliverycharges;
      listitems = listitems;
    });
  }

  var deliveryamount;
  Item newItem;
  var addressline1;
  var city;
  var state;
  var paymentby;

  var totalrate;
  var deliveryaddress;

  var zipcode;

  bool addressreturned = false;
  Payments payment;
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  final scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      backgroundColor: Color.fromRGBO(242, 244, 248, 1),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          'Pay',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        children: [
          Padding(
              padding:
                  EdgeInsets.only(left: 15, bottom: 10, top: 15, right: 15),
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddPayment()),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        payment = result;
                                      });
                                    }
                                  },
                                  child: payment == null
                                      ? Text(
                                          'Choose your payment method',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 15,
                                            color: Colors.blueGrey,
                                          ),
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              '${capitalize(payment.cardtype)} •••• •••• •••• ${payment.cardnumber}',
                                              style: TextStyle(
                                                  fontFamily: 'Helvetica',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            subtitle: Text(
                                                'Expires  ${payment.expirymonth}/${payment.expiryyear}'),
                                          ))),
                              InkWell(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddPayment()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Colors.blueGrey,
                                      )
                                    ],
                                  )),
                            ])
                      ]))),
          Padding(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listitems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Details(
                                                        itemid: listitems[index]
                                                            .itemid,
                                                        name: listitems[index]
                                                            .name,
                                                        sold: listitems[index]
                                                            .sold,
                                                        source: 'activity',
                                                        image: listitems[index]
                                                            .image,
                                                      )),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 80,
                                                width: 80,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: listitems[index]
                                                            .image
                                                            .isNotEmpty
                                                        ? Hero(
                                                            tag:
                                                                'activity${listitems[index].itemid}',
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  listitems[
                                                                          index]
                                                                      .image,
                                                              height: 200,
                                                              width: 300,
                                                              fadeInDuration:
                                                                  Duration(
                                                                      microseconds:
                                                                          5),
                                                              fit: BoxFit.cover,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitDoubleBounce(
                                                                      color: Colors
                                                                          .deepOrange),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(Icons
                                                                      .error),
                                                            ),
                                                          )
                                                        : SpinKitFadingCircle(
                                                            color: Colors
                                                                .deepOrange,
                                                          )),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 25,
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            10,
                                                    child: Text(
                                                      listitems[index].name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  Text(
                                                    '@' +
                                                        listitems[index]
                                                            .username,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    currency +
                                                        ' ' +
                                                        listitems[index].price,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Helvetica',
                                                        fontSize: 14.0,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          listitems[index].selectedsize !=
                                                      'nosize' &&
                                                  listitems[index]
                                                          .selectedsize !=
                                                      null
                                              ? Text(
                                                  'Size: ' +
                                                      listitems[index]
                                                          .selectedsize
                                                          .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Helvetica',
                                                      fontSize: 14.0,
                                                      color: Colors.grey),
                                                )
                                              : Container(),
                                          // Container(
                                          //     decoration: BoxDecoration(
                                          //       color: Colors.white,
                                          //       border: Border.all(
                                          //           color: Colors
                                          //               .grey.shade300),
                                          //       borderRadius:
                                          //           BorderRadius.all(
                                          //               Radius.circular(
                                          //                   15)),
                                          //     ),
                                          //     child: Container(
                                          //         height: 30,
                                          //         width: 130,
                                          //         child: Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .end,
                                          //           children: [
                                          //             IconButton(
                                          //               icon: Icon(
                                          //                   Icons.remove),
                                          //               iconSize: 16,
                                          //               color: Colors
                                          //                   .deepOrange,
                                          //               onPressed: () {
                                          //                 setState(() {
                                          //                   if (listitems[
                                          //                               index]
                                          //                           .quantity >
                                          //                       0) {
                                          //                     listitems[
                                          //                             index]
                                          //                         .quantity = listitems[
                                          //                                 index]
                                          //                             .quantity -
                                          //                         1;
                                          //                   }
                                          //                   subtotal = double.parse(
                                          //                           listitems[index]
                                          //                               .price) *
                                          //                       listitems[
                                          //                               index]
                                          //                           .quantity;
                                          //                 });
                                          //               },
                                          //             ),
                                          //             Container(
                                          //               width: 25,
                                          //               child: Text(
                                          //                 listitems[index]
                                          //                     .quantity
                                          //                     .toString(),
                                          //                 style: TextStyle(
                                          //                     fontSize: 18),
                                          //                 textAlign:
                                          //                     TextAlign
                                          //                         .center,
                                          //               ),
                                          //             ),
                                          //             IconButton(
                                          //               icon:
                                          //                   Icon(Icons.add),
                                          //               iconSize: 16,
                                          //               color: Colors
                                          //                   .deepOrange,
                                          //               onPressed: () {
                                          //                 setState(() {
                                          //                   if (listitems[
                                          //                               index]
                                          //                           .quantity >=
                                          //                       0 ) {
                                          //                     listitems[
                                          //                             index]
                                          //                         .quantity = listitems[
                                          //                                 index]
                                          //                             .quantity +
                                          //                         1;
                                          //                   }
                                          //                   subtotal = double.parse(
                                          //                           listitems[index]
                                          //                               .price) *
                                          //                       listitems[
                                          //                               index]
                                          //                           .quantity;
                                          //                 });
                                          //               },
                                          //             ),
                                          //           ],
                                          //         )))
                                        ],
                                      )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ));
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              subtotal != 0.0
                                  ? currency + ' ' + subtotal.toStringAsFixed(2)
                                  : 'AED 0',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              deliveryamount,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ]))),
          Padding(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Shipping Information',
                        style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deliver To',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          InkWell(
                              onTap: () async {
                                final addressresult = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Address()),
                                );
                                if (addressresult != null) {
                                  setState(() {
                                    selectedaddress = addressresult['address'];
                                    phonenumber = addressresult['phonenumber'];
                                  });
                                } else {
                                  setState(() {
                                    selectedaddress = null;
                                    phonenumber = null;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      selectedaddress == null
                                          ? 'Choose Address'
                                          : selectedaddress.address +
                                              '\n' +
                                              phonenumber,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.blueGrey,
                                  )
                                ],
                              )),
                        ],
                      )
                    ],
                  ))),
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.deepOrangeAccent.withOpacity(0.2)),
                  child: Center(
                    child: Icon(
                      Icons.warning,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ),
                title: Text(
                  'On tapping \'Pay\', you hereby accept the terms and conditions ',
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      color: Colors.blueGrey),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: listitems.isNotEmpty
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: 1,
              child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 15, bottom: 10, top: 5, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 0.0,
                                  color: Colors.black45,
                                ),
                              ),
                              Text('AED' + ' ' + total.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    letterSpacing: 0.0,
                                    color: Colors.black,
                                  )),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 15, bottom: 10, right: 15),
                          child: Container(
                            child: InkWell(
                              enableFeedback: true,
                              onTap: () async {
                                if (phonenumber == null ||
                                    selectedaddress == null) {
                                  showInSnackBar('Please choose your address');
                                } else if (payment == null) {
                                  showInSnackBar(
                                      'Please choose your payment method');
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      useRootNavigator: false,
                                      builder: (_) => Container(
                                          height: 50,
                                          width: 50,
                                          child: SpinKitDoubleBounce(
                                            color: Colors.deepOrange,
                                          )));

                                  var orderid;

                                  var userid =
                                      await storage.read(key: 'userid');
                                  print(listitems[0].userid);

                                  orderid = 'SS-ORDER' +
                                      (userid.substring(0, 10) +
                                              listitems[0]
                                                  .itemid
                                                  .toString()
                                                  .substring(0, 15) +
                                              listitems[0]
                                                  .userid
                                                  .substring(0, 10))
                                          .toString();

                                  var messageurl =
                                      'https://api.sellship.co/api/stripe/pay/' +
                                          userid.toString() +
                                          '/' +
                                          payment.paymentid.toString() +
                                          '/' +
                                          total.toString() +
                                          '/' +
                                          'AED';
                                  final response = await http.get(messageurl);

                                  var paymentresponse =
                                      json.decode(response.body);

                                  if (paymentresponse.containsKey('done')) {
                                    print('success');
                                    var uuid = uuidGenerator.v1();
                                    var trref = ('SS' + uuid);
                                    var returnurl =
                                        'https://api.sellship.co/api/payment/NEW/${orderid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${total.toStringAsFixed(2)}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}/${listitems[0].quantity}/${listitems[0].selectedsize}';

                                    final response = await http.get(returnurl);

                                    if (response.statusCode == 200) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove('cartitems');
                                      Navigator.of(context).pop('dialog');
                                      var messageid = 'SS-ORDER' +
                                          userid.substring(0, 10) +
                                          listitems[0].itemid.substring(0, 15) +
                                          listitems[0].userid.substring(0, 10);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OrderBuyer(
                                                  itemid: listitems[0].itemid,
                                                  messageid: messageid,
                                                )),
                                      );
                                    }
                                  } else if (paymentresponse['error']['code'] ==
                                      'card_declined') {
                                    Navigator.of(context).pop('dialog');
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
                                  } else if (paymentresponse['error']['code'] ==
                                      'authentication_required') {
                                    var clientsecret = paymentresponse['error']
                                        ['payment_intent']['client_secret'];

                                    Stripe.init(
                                        "pk_test_51IgtU3HQRQo46FowHQtM5WCo8AoLhvyjReZonLiYWa0Ihw31LIlPyO0Y3d0wKIqe8idUnesGGXxmYjkoezfAk2Q700dh5KkpVl",
                                        returnUrlForSca: "sellship://order");

                                    final paymentIntent = await Stripe.instance
                                        .confirmPayment(clientsecret,
                                            paymentMethodId:
                                                paymentresponse['error']
                                                            ['payment_intent']
                                                        ['charges']['data'][0]
                                                    ['payment_method']);

                                    if (paymentIntent['status'] ==
                                        'succeeded') {
                                      print('Success');
                                      var uuid = uuidGenerator.v1();
                                      var trref = ('SS' + uuid);
                                      var returnurl =
                                          'https://api.sellship.co/api/payment/NEW/${orderid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${total.toStringAsFixed(2)}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}/${listitems[0].quantity}/${listitems[0].selectedsize}';

                                      final response =
                                          await http.get(returnurl);
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      if (response.statusCode == 200) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.remove('cartitems');

                                        var messageid = 'SS-ORDER' +
                                            userid.substring(0, 10) +
                                            listitems[0]
                                                .itemid
                                                .substring(0, 15) +
                                            listitems[0]
                                                .userid
                                                .substring(0, 10);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OrderBuyer(
                                                    itemid: listitems[0].itemid,
                                                    messageid: messageid,
                                                  )),
                                        );
                                      }
                                    } else {
                                      Navigator.of(context).pop('dialog');
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
                                                  'Looks like your payment has failed! Please try another payment method',
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
                                  } else {
                                    Navigator.of(context).pop('dialog');
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
                                                'Looks like your payment did not go through. Please try again',
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

                                  // Map<String, Object> body = {
                                  //   "apiOperation": "INITIATE",
                                  //   "order": {
                                  //     "name": 'SellShip Order',
                                  //     "channel": "web",
                                  //     "reference": trref,
                                  //     "amount": total.toStringAsFixed(2),
                                  //     "currency": "AED",
                                  //     "category": "pay",
                                  //   },
                                  //   "configuration": {
                                  //     "tokenizeCC": true,
                                  //     "locale": "en",
                                  //     "paymentAction": "Sale",
                                  //     "returnUrl":
                                  //         'https://api.sellship.co/api/payment/NEW/${messageid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${total.toStringAsFixed(2)}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}/${listitems[0].quantity}/${listitems[0].selectedsize}'
                                  //   },
                                  // };
                                  // var returnurl =
                                  //     'https://api.sellship.co/api/payment/NEW/${messageid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${total.toStringAsFixed(2)}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}/${listitems[0].quantity}/${listitems[0].selectedsize}';

                                  // var url =
                                  //     "https://api-stg.noonpayments.com/payment/v1/order";
                                  //
                                  // var key =
                                  //     "SellShip.SellShipApp:7d016fdd70a64b68bc99d2cece27b48d";
                                  // List encodedText = utf8.encode(key);
                                  // String base64Str = base64Encode(encodedText);
                                  // print('Key_Test $base64Str');
                                  // var heade = 'Key_Test $base64Str';

                                  // var url =
                                  //     "https://api.noonpayments.com/payment/v1/order";
                                  //
                                  // var key =
                                  //     "SellShip.SellShipApp:a42e7bc936354e9c807c0ff02670ab37";
                                  // List encodedText = utf8.encode(key);
                                  // String base64Str = base64Encode(encodedText);
                                  //
                                  // var heade = 'Key_Live $base64Str';
                                  //
                                  // Map<String, String> headers = {
                                  //   'Authorization': heade,
                                  //   'Content-type': 'application/json',
                                  //   'Accept': 'application/json',
                                  // };
                                  //
                                  // final response = await http.post(
                                  //   url,
                                  //   body: json.encode(body),
                                  //   headers: headers,
                                  // );
                                  //
                                  // print(response.body);
                                  //
                                  // if (response.statusCode == 200) {
                                  //   var jsonmessage =
                                  //       json.decode(response.body);
                                  //
                                  //   var url = jsonmessage['result']
                                  //       ['checkoutData']['postUrl'];
                                  //
                                  //   var orderid =
                                  //       jsonmessage['result']['order']['id'];
                                  //
                                  //   Navigator.of(context, rootNavigator: true)
                                  //       .pop();
                                  //
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (BuildContext context) =>
                                  //             PaymentWeb(
                                  //               returnurl: returnurl,
                                  //               url: url,
                                  //               itemid: listitems[0].itemid,
                                  //               messageid: messageid,
                                  //             )),
                                  //   );
                                  // }
                                }
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color:
                                            Colors.deepOrange.withOpacity(0.4),
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
            )
          : Container(
              height: 1,
            ),
    );
  }
}
