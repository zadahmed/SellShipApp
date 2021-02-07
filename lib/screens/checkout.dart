import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/addpayment.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class Checkout extends StatefulWidget {
  String itemid;

  Checkout({
    Key key,
    this.itemid,
  }) : super(key: key);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String itemid;

  var cardresult;
  @override
  void initState() {
    super.initState();
    getcurrency();

    setState(() {
      //TODO CHANGE
      itemid = '5ea35b603383d1370dd3713d';
    });
  }

  GlobalKey _toolTipKey = GlobalKey();

  var currency;
  var stripecurrency;

  final storage = new FlutterSecureStorage();

  List<Item> listitems = List<Item>();

  getcurrency() async {
    var countr = await storage.read(key: 'country');
    if (countr.toLowerCase() == 'united arab emirates') {
      setState(() {
        currency = 'AED';
        stripecurrency = 'AED';
      });
    }

    var url = 'https://api.sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);

    var jsonbody = json.decode(response.body);

    newItem = Item(
        name: jsonbody[0]['name'],
        itemid: jsonbody[0]['_id']['\$oid'].toString(),
        price: jsonbody[0]['price'].toString(),
        description: jsonbody[0]['description'],
        category: jsonbody[0]['category'],
        image: jsonbody[0]['image'],
        sold: jsonbody[0]['sold'] == null ? false : jsonbody[0]['sold'],
        likes: jsonbody[0]['likes'] == null ? 0 : jsonbody[0]['likes'],
        city: jsonbody[0]['city'],
        username: jsonbody[0]['username'],
        brand: jsonbody[0]['brand'] == null ? 'Other' : jsonbody[0]['brand'],
        size: jsonbody[0]['size'] == null ? '' : jsonbody[0]['size'],
        useremail: jsonbody[0]['useremail'],
        usernumber: jsonbody[0]['usernumber'],
        userid: jsonbody[0]['userid'],
        latitude: jsonbody[0]['latitude'],
        comments: jsonbody[0]['comments'] == null
            ? 0
            : jsonbody[0]['comments'].length,
        longitude: jsonbody[0]['longitude'],
        subsubcategory: jsonbody[0]['subsubcategory'],
        subcategory: jsonbody[0]['subcategory']);

    setState(() {
      newItem = newItem;
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
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Details(
                                          itemid: itemid,
                                          name: newItem.name,
                                          sold: newItem.sold,
                                          source: 'activity',
                                          image: newItem.image,
                                        )),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: newItem.image.isNotEmpty
                                          ? Hero(
                                              tag: 'activity${newItem.itemid}',
                                              child: CachedNetworkImage(
                                                imageUrl: newItem.image,
                                                height: 200,
                                                width: 300,
                                                fadeInDuration:
                                                    Duration(microseconds: 5),
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    SpinKitChasingDots(
                                                        color:
                                                            Colors.deepOrange),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            )
                                          : SpinKitFadingCircle(
                                              color: Colors.deepOrange,
                                            )),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          10,
                                      child: Text(
                                        newItem.name,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Text(
                                      '@' + newItem.username,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14,
                                          color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      currency + ' ' + newItem.price,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 14.0,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ],
                            )),
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
                            currency + ' ' + newItem.price,
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
                                print(addressresult);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Choose Address',
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
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pay Using',
                            style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          Row(
                            children: [
                              Text(
                                'Choose Payment Method',
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
                          )
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
                  'On tapping \'Pay\', you hereby accept the terms and conditions of service from SellShip and our payment provider Telr.',
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
      bottomNavigationBar: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: 1,
        child: Container(
            height: 200,
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
                        Text(currency + ' ' + newItem.price,
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
                        onTap: () async {},
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 115, 0, 1),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Color.fromRGBO(255, 115, 0, 1)
                                      .withOpacity(0.4),
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
//        body: SingleChildScrollView(
//          child: Column(
//            children: <Widget>[
//              Padding(
//                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
//                  child: InkWell(
//                      onTap: () {
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  Details(itemid: item.itemid)),
//                        );
//                      },
//                      child: Container(
//                          height: 70,
//                          width: MediaQuery.of(context).size.width,
//                          decoration: BoxDecoration(
//                            boxShadow: [
//                              BoxShadow(
//                                color: Colors.grey.shade300,
//                                offset: Offset(0.0, 1.0), //(x,y)
//                                blurRadius: 6.0,
//                              ),
//                            ],
//                            color: Colors.white,
//                          ),
//                          child: ListTile(
//                            title: Text(
//                              item.name,
//                              style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 16,
//                                  color: Colors.black,
//                                  fontWeight: FontWeight.w800),
//                            ),
//                            leading: Container(
//                              height: 70,
//                              width: 70,
//                              decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.circular(10)),
//                              child: ClipRRect(
//                                borderRadius: BorderRadius.circular(10),
//                                child: CachedNetworkImage( height: 200, width: 300,
//                                  imageUrl: item.image,
//                                ),
//                              ),
//                            ),
//                            subtitle: Text(
//                              item.price.toString() + ' ' + currency,
//                              style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 14,
//                                  color: Colors.deepOrange,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          )))),
//              Padding(
//                padding:
//                    EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
//                child: Align(
//                  alignment: Alignment.centerLeft,
//                  child: Text(
//                    'Your seller will ship out the item once the payment has been completed. Don\'t worry, we will only release the payment to the seller, once you confirm that you have recieved the item as listed.',
//                    style: TextStyle(
//                        fontFamily: 'Helvetica',
//                        fontSize: 12,
//                        color: Colors.blueGrey),
//                  ),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
//                child: Align(
//                  alignment: Alignment.centerLeft,
//                  child: Text(
//                    'Total Amount',
//                    style: TextStyle(
//                        fontFamily: 'Helvetica',
//                        fontSize: 16,
//                        fontWeight: FontWeight.w700),
//                  ),
//                ),
//              ),
//              Container(
//                decoration: BoxDecoration(
//                  color: Colors.white,
//                  boxShadow: <BoxShadow>[
//                    BoxShadow(
//                        color: Colors.grey.withOpacity(0.2),
//                        offset: const Offset(0.0, 0.6),
//                        blurRadius: 5.0),
//                  ],
//                ),
//                child: ListTile(
//                    onTap: () async {
////                      final result = await Navigator.push(
////                        context,
////                        MaterialPageRoute(builder: (context) => Address()),
////                      );
////
////                      showDialog(
////                          context: context,
////                          barrierDismissible: false,
////                          builder: (BuildContext context) {
////                            return Container(
////                              height: 100,
////                              child: Padding(
////                                  padding: const EdgeInsets.all(12.0),
////                                  child: SpinKitChasingDots(
////                                      color: Colors.deepOrangeAccent)),
////                            );
////                          });
////
////                      setState(() {
////                        addressline1 = result['addrLine1'];
////                        city = result['city'];
////                        state = result['state'];
////                        zipcode = result['zip_code'];
////
////                        deliveryaddress = result['addrLine1'] +
////                            ' ,\n' +
////                            result['city'] +
////                            ' ,' +
////                            result['state'] +
////                            ' ,' +
////                            result['zip_code'];
////                        addressreturned = true;
////                      });
////
////                      var userid = await storage.read(key: 'userid');
////                      var ratesurl = 'https://api.sellship.co/api/rates/' +
////                          addressline1 +
////                          '/' +
////                          city +
////                          '/' +
////                          state +
////                          '/' +
////                          zipcode +
////                          '/' +
////                          item.itemid +
////                          '/' +
////                          userid;
////                      final response = await http.get(ratesurl);
////                      var jsonrates = json.decode(response.body);
////
////                      print(jsonrates);
////                      var totalrat = jsonrates['rates']
////                              ['RatingServiceSelectionResponse']
////                          ['RatedShipment']['TotalCharges']['MonetaryValue'];
////                      setState(() {
////                        totalrate = totalrat;
////                      });
////                      calculatefees();
////                      Navigator.of(context, rootNavigator: true).pop('dialog');
//                    },
//                    title: Text(
//                      'Deliver To',
//                      style: TextStyle(
//                          fontFamily: 'Helvetica',
//                          fontSize: 16,
//                          fontWeight: FontWeight.w700),
//                    ),
//                    trailing: addressreturned == false
//                        ? Icon(
//                            Icons.arrow_forward_ios,
//                            size: 10,
//                          )
//                        : Text(
//                            deliveryaddress,
//                            textAlign: TextAlign.end,
//                            style: TextStyle(
//                                fontFamily: 'Helvetica',
//                                fontSize: 13,
//                                fontWeight: FontWeight.w500),
//                          )),
//              ),
//              Container(
//                decoration: BoxDecoration(
//                  color: Colors.white,
//                  boxShadow: <BoxShadow>[
//                    BoxShadow(
//                        color: Colors.grey.withOpacity(0.2),
//                        offset: const Offset(0.0, 0.6),
//                        blurRadius: 5.0),
//                  ],
//                ),
//                child: ListTile(
//                    onTap: () async {
//                      final result = await Navigator.push(
//                        context,
//                        MaterialPageRoute(builder: (context) => AddPayment()),
//                      );
//
//                      if (result is String) {
//                        print(result);
//                        if (result == 'applepay') {
//                          setState(() {
//                            paymentby = 'Apple Pay';
//                          });
//                        } else if (result == 'googlepay') {
//                          setState(() {
//                            paymentby = 'Google Pay';
//                          });
//                        }
//                      } else if (result is Payments) {
//                        setState(() {
//                          paymentby = result.cardnumber;
//                          cardresult = result;
//                        });
//                      } else if (result.containsKey("card")) {
//                        var paymentmethod = result['card']['card']['last4'];
//                        setState(() {
//                          paymentby = paymentmethod;
//                          cardresult = result['card'];
//                        });
//                      } else {
//                        setState(() {
//                          paymentby = null;
//                        });
//                      }
//                    },
//                    title: Text(
//                      'Pay using',
//                      style: TextStyle(
//                          fontFamily: 'Helvetica',
//                          fontSize: 16,
//                          fontWeight: FontWeight.w700),
//                    ),
//                    trailing: paymentby == null
//                        ? Icon(
//                            Icons.arrow_forward_ios,
//                            size: 10,
//                          )
//                        : Text(paymentby.toString())),
//              ),
//              SizedBox(
//                height: 20,
//              ),
//              Padding(
//                  padding:
//                      EdgeInsets.only(left: 10, bottom: 10, top: 20, right: 10),
//                  child: Column(
//                    children: <Widget>[
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Container(
//                            width: 250,
//                            child: Text(
//                              item.name,
//                              style: TextStyle(
//                                  fontFamily: 'Helvetica',
//                                  fontSize: 16,
//                                  color: Colors.black),
//                            ),
//                          ),
//                          Text(
//                            offer.toString() + ' ' + currency,
//                            style: TextStyle(
//                                fontFamily: 'Helvetica',
//                                fontSize: 16,
//                                color: Colors.black),
//                          )
//                        ],
//                      ),
//                      SizedBox(
//                        height: 5,
//                      ),
//                      totalrate != null
//                          ? Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  'Delivery',
//                                  style: TextStyle(
//                                      fontFamily: 'Helvetica',
//                                      fontSize: 16,
//                                      color: Colors.black),
//                                ),
//                                Text(
//                                  totalrate.toString() + ' ' + currency,
//                                  style: TextStyle(
//                                      fontFamily: 'Helvetica',
//                                      fontSize: 16,
//                                      color: Colors.black),
//                                )
//                              ],
//                            )
//                          : Container(),
//                      SizedBox(
//                        height: 5,
//                      ),
//                      SizedBox(
//                        height: 10,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Text(
//                            'Total',
//                            style: TextStyle(
//                                fontFamily: 'Helvetica',
//                                fontSize: 16,
//                                color: Colors.black),
//                          ),
//                          Text(
//                            totalpayable.toStringAsFixed(2) + ' ' + currency,
//                            style: TextStyle(
//                                fontFamily: 'Helvetica',
//                                fontSize: 16,
//                                color: Colors.black),
//                          )
//                        ],
//                      ),
//                    ],
//                  )),
//            ],
//          ),
//        ));
    );
  }
}
