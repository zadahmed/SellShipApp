import 'dart:convert';
import 'dart:io';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/addpayment.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';

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

class CheckoutOffer extends StatefulWidget {
  String itemid;
  String offer;
  String messageid;
  String ordertype;

  CheckoutOffer({
    Key key,
    this.messageid,
    this.ordertype,
    this.itemid,
    this.offer,
  }) : super(key: key);
  @override
  _CheckoutOfferState createState() => _CheckoutOfferState();
}

class _CheckoutOfferState extends State<CheckoutOffer> {
  var cardresult;
  double total;
  double subtotal = 0.0;
  @override
  void initState() {
    super.initState();
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

    if (cartitems != null) {
      for (int i = 0; i < cartitems.length; i++) {
        var decodeditem = json.decode(cartitems[i]);

        print(decodeditem);
        Item newItem = Item(
            name: decodeditem['name'],
            itemid: decodeditem['itemid'],
            price: decodeditem['price'].toString(),
            image: decodeditem['image'],
            userid: decodeditem['sellerid'],
            username: decodeditem['sellername']);

        subtotal = double.parse(widget.offer);
        print(newItem.itemid);

        listitems.add(newItem);
      }
    }

    setState(() {
      subtotal = subtotal;
      listitems = listitems;
    });
  }

  Item newItem;
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
      backgroundColor: Color.fromRGBO(242, 244, 248, 1),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          'Checkout',
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
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        listitems.isNotEmpty
                            ? Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: listitems.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsets.all(10),
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Details(
                                                          itemid:
                                                              listitems[index]
                                                                  .itemid,
                                                          name: listitems[index]
                                                              .name,
                                                          sold: listitems[index]
                                                              .sold,
                                                          source: 'activity',
                                                          image:
                                                              listitems[index]
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
                                                                fit: BoxFit
                                                                    .cover,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Text(
                                                      '@' +
                                                          listitems[index]
                                                              .username,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      currency +
                                                          ' ' +
                                                          listitems[index]
                                                              .price,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontSize: 14.0,
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )));
                                  },
                                ),
                              )
                            : Center(
                                child: Text('Cart is Empty'),
                              )
                      ]))),
          Padding(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            subtotal != 0.0
                                ? currency + ' ' + subtotal.toString()
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
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Free',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
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
                                  Text(
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
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.blueGrey,
                                  )
                                ],
                              )),
                        ],
//                      ),
//                      SizedBox(
//                        height: 15,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: [
//                          Text(
//                            'Pay Using',
//                            style: TextStyle(
//                                fontFamily: 'Helvetica',
//                                fontSize: 18,
//                                color: Colors.black,
//                                fontWeight: FontWeight.w800),
//                          ),
//                          Row(
//                            children: [
//                              Text(
//                                'Choose Payment Method',
//                                style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 16,
//                                  color: Colors.blueGrey,
//                                ),
//                              ),
//                              Icon(
//                                Icons.chevron_right,
//                                size: 16,
//                                color: Colors.blueGrey,
//                              )
//                            ],
//                          )
                      )
                    ],
                  ))),
          // Padding(
          //   padding: EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
          //   child: Container(
          //     padding: EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15), color: Colors.white),
          //     child: ListTile(
          //       leading: Container(
          //         height: 50,
          //         width: 50,
          //         decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(15),
          //             color: Colors.deepOrangeAccent.withOpacity(0.2)),
          //         child: Center(
          //           child: Icon(
          //             Icons.warning,
          //             color: Colors.deepOrangeAccent,
          //           ),
          //         ),
          //       ),
          //       title: Text(
          //         'On tapping \'Pay\', you hereby accept the terms and conditions ',
          //         style: TextStyle(
          //             fontFamily: 'Helvetica',
          //             fontSize: 12,
          //             color: Colors.blueGrey),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: AnimatedOpacity(
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
                        Text(currency + ' ' + subtotal.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 0.0,
                              color: Colors.black,
                            )),
                      ],
                    )),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 10, right: 15),
                    child: Container(
                      child: InkWell(
                        enableFeedback: true,
                        onTap: () async {
                          if (phonenumber == null || selectedaddress == null) {
                            showInSnackBar('Please choose your address');
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
                            var uuid = uuidGenerator.v1();
                            var trref = ('SS' + uuid);

                            var messageid;
                            if (widget.messageid == null) {
                              messageid = uuidGenerator.v4();
                            } else {
                              messageid = widget.messageid;
                            }

                            var userid = await storage.read(key: 'userid');
                            print(listitems[0].userid);

                            messageid = 'SS-ORDER' +
                                (userid.substring(0, 10) +
                                    listitems[0]
                                        .itemid
                                        .toString()
                                        .substring(0, 15) +
                                    listitems[0].userid.substring(0, 10))
                                    .toString();
                            print(messageid);

                            var returnurl;
                            if (widget.ordertype == 'EXISTING') {
                              returnurl =
                                  'https://api.sellship.co/api/payment/EXISTING/${messageid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${subtotal}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}';
                            } else {
                              returnurl =
                                  'https://api.sellship.co/api/payment/NEW/${messageid}/${userid}/${listitems[0].userid}/${listitems[0].itemid}/${subtotal}/${selectedaddress.addressline1}/${selectedaddress.addressline2}/${selectedaddress.area}/${selectedaddress.city}/${selectedaddress.phonenumber}/${trref}';
                            }

                            Map<String, Object> body = {
                              "apiOperation": "INITIATE",
                              "order": {
                                "name": listitems[0].name,
                                "channel": "web",
                                "reference": trref,
                                "amount": subtotal,
                                "currency": "AED",
                                "category": "pay",
                              },
                              "configuration": {
                                "tokenizeCC": true,
                                "locale": "en",
                                "paymentAction": "Sale",
                                "returnUrl": returnurl
                              },
                            };

                            var url =
                                "https://api.noonpayments.com/payment/v1/order";

                            var key =
                                "SellShip.SellShipApp:a42e7bc936354e9c807c0ff02670ab37";
                            List encodedText = utf8.encode(key);
                            String base64Str = base64Encode(encodedText);
                            print('Key_Test $base64Str');

                            var heade = 'Key_Live $base64Str';

                            Map<String, String> headers = {
                              'Authorization': heade,
                              'Content-type': 'application/json',
                              'Accept': 'application/json',
                            };

                            final response = await http.post(
                              url,
                              body: json.encode(body),
                              headers: headers,
                            );

                            if (response.statusCode == 200) {
                              var jsonmessage = json.decode(response.body);

                              var url = jsonmessage['result']['checkoutData']
                                  ['postUrl'];

                              var orderid =
                                  jsonmessage['result']['order']['id'];

                              // final orderresponse = await http.get(
                              //   'https://api.sellship.co/api/noon/save/orderid/${messageid}/${orderid}/${userid}',
                              // );

                              // print(orderresponse.statusCode);
                              // print(orderresponse.body);
                              //
                              // Navigator.of(context, rootNavigator: true).pop();
                              //
                              // if (orderresponse.statusCode == 200) {
                              Navigator.of(context, rootNavigator: true).pop();



                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PaymentWeb(
                                          returnurl: returnurl,
                                          url: url,
                                          itemid: listitems[0].itemid,
                                          messageid: messageid,
                                        )),
                              );
                            }
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
    );
  }
}
