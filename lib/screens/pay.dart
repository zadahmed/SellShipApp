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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slugid/slugid.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:uuid/uuid.dart';

class Pay extends StatefulWidget {
  String itemid;
  String messageid;
  AddressModel address;
  String phonenumber;
  double price;
  String discountccode;

  Pay({
    Key key,
    this.itemid,
    this.discountccode,
    this.messageid,
    this.price,
    this.phonenumber,
    this.address,
  }) : super(key: key);
  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  var messageid;
  var cardresult;
  double total;
  double subtotal = 0.0;
  checkuser() async {
    var uuidmessage = Slugid.nice().toString().toUpperCase();
    var userid = await storage.read(key: 'userid');

    setState(() {
      messageid = 'SS' + uuidmessage;
    });

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

    StripePayment.setOptions(StripeOptions(
        publishableKey:
            //     "pk_test_51IgtU3HQRQo46FowHQtM5WCo8AoLhvyjReZonLiYWa0Ihw31LIlPyO0Y3d0wKIqe8idUnesGGXxmYjkoezfAk2Q700dh5KkpVl",
            "pk_live_51IgtU3HQRQo46FowVzqt5d8VVYrjNyL66rnckL1DrzyEB6iz5I1mvLhjRxa9BOdAGDFpjvRMLKyO2PsGy3ywi8l300fChGmh9p",
        merchantId: "merchant.com.zafra.sellship",
        androidPayMode: 'production'));

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

    var deliverycharges = 0.0;
    if (cartitems != null) {
      for (int i = 0; i < cartitems.length; i++) {
        var decodeditem = json.decode(cartitems[i]);

        Item newItem = Item(
            name: decodeditem['name'],
            selectedsize: decodeditem['selectedsize'],
            quantity: decodeditem['quantity'],
            itemid: decodeditem['itemid'],
            weight: decodeditem['weight'],
            freedelivery: decodeditem['freedelivery'],
            price: decodeditem['price'].toString(),
            saleprice: decodeditem['saleprice'] == null
                ? null
                : decodeditem['saleprice'],
            image: decodeditem['image'],
            userid: decodeditem['userid'],
            username: decodeditem['username']);

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
            deliverycharges =
                deliverycharges + double.parse(weightfees.toString());
          });
        } else {
          setState(() {
            deliveryamount = 'FREE';
            deliverycharges = deliverycharges + 0.0;
          });
        }

        if (newItem.saleprice != null) {
          subtotal = double.parse(newItem.saleprice) + subtotal;
        } else {
          subtotal = double.parse(newItem.price) + subtotal;
        }

        listitems.add(newItem);
      }
    }

    setState(() {
      subtotal = subtotal + deliverycharges;
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
                                        FeatherIcons.chevronRight,
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
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    FeatherIcons.chevronRight,
                                    size: 14,
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
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review your Order',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listitems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: EdgeInsets.all(5),
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
                                                    MainAxisAlignment.start,
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
                                                      textAlign: TextAlign.left,
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
                                                  listitems[index].saleprice !=
                                                          null
                                                      ? Text.rich(
                                                          TextSpan(
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text: 'AED ' +
                                                                    listitems[
                                                                            index]
                                                                        .saleprice,
                                                                style: new TextStyle(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              new TextSpan(
                                                                text: '\nAED ' +
                                                                    listitems[
                                                                            index]
                                                                        .price
                                                                        .toString(),
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 10,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                ),
                                                              ),
                                                              new TextSpan(
                                                                text: ' -' +
                                                                    (((double.parse(listitems[index].price.toString()) - double.parse(listitems[index].saleprice.toString())) / double.parse(listitems[index].price.toString())) *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    '%',
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Text(
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
                                                              color:
                                                                  Colors.black),
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
                                            MainAxisAlignment.spaceBetween,
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
                      ]))),
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
                          child: Row(
                            children: [
                              Container(
                                child: InkWell(
                                  enableFeedback: true,
                                  onTap: () async {
                                    if (phonenumber == null ||
                                        selectedaddress == null) {
                                      showInSnackBar(
                                          'Please choose your address');
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

                                      var messageurl =
                                          'https://api.sellship.co/api/stripe/pay/' +
                                              userid.toString() +
                                              '/' +
                                              payment.paymentid.toString() +
                                              '/' +
                                              total.toString() +
                                              '/' +
                                              'AED';
                                      final response =
                                          await http.get(Uri.parse(messageurl));

                                      var paymentresponse =
                                          json.decode(response.body);

                                      if (paymentresponse.containsKey('done')) {
                                        var url =
                                            'https://api.sellship.co/api/payment/${messageid}';

                                        Dio dio = new Dio();
                                        FormData formData;

                                        formData = FormData.fromMap({
                                          'items': json.encode(listitems),
                                          'senderid': userid,
                                          'recieverid': listitems[0].userid,
                                          'addressline1':
                                              selectedaddress.addressline1,
                                          'addressline2':
                                              selectedaddress.addressline2,
                                          'city': selectedaddress.city,
                                          'phonenumber':
                                              selectedaddress.phonenumber,
                                          'area': selectedaddress.area,
                                          'deliveryamount': deliveryamount,
                                          'paymentid':
                                              payment.paymentid.toString(),
                                          'totalpayable':
                                              total.toStringAsFixed(2)
                                        });

                                        var response =
                                            await dio.post(url, data: formData);
                                        print(response.statusCode);
                                        print('response');

                                        if (response.statusCode == 200) {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.remove('cartitems');
                                          Navigator.of(context).pop('dialog');

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderBuyer(
                                                      items: listitems,
                                                      messageid: messageid,
                                                    )),
                                          );
                                        }
                                      } else if (paymentresponse['error']
                                              ['code'] ==
                                          'card_declined') {
                                        Navigator.of(context).pop('dialog');
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            useRootNavigator: false,
                                            builder: (_) => new AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  content: Builder(
                                                    builder: (context) {
                                                      return Container(
                                                          height: 380,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 250,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/oops.gif',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                'Oops!',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              InkWell(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      30,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              115,
                                                                              0,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color: Color(0xFF9DA3B4).withOpacity(
                                                                                0.1),
                                                                            blurRadius:
                                                                                65.0,
                                                                            offset:
                                                                                Offset(0.0, 15.0))
                                                                      ]),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Close",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop(
                                                                          'dialog');
                                                                },
                                                              ),
                                                            ],
                                                          ));
                                                    },
                                                  ),
                                                ));
                                      } else if (paymentresponse['error']
                                              ['code'] ==
                                          'authentication_required') {
                                        var clientsecret =
                                            paymentresponse['error']
                                                    ['payment_intent']
                                                ['client_secret'];

                                        // Stripe.init(
                                        //     "pk_test_51IgtU3HQRQo46FowHQtM5WCo8AoLhvyjReZonLiYWa0Ihw31LIlPyO0Y3d0wKIqe8idUnesGGXxmYjkoezfAk2Q700dh5KkpVl",
                                        //     returnUrlForSca:
                                        //         "sellship://order");

                                        Stripe.init(
                                            "pk_live_51IgtU3HQRQo46FowVzqt5d8VVYrjNyL66rnckL1DrzyEB6iz5I1mvLhjRxa9BOdAGDFpjvRMLKyO2PsGy3ywi8l300fChGmh9p",
                                            returnUrlForSca:
                                                "sellship://order");

                                        final paymentIntent = await Stripe
                                            .instance
                                            .confirmPayment(clientsecret,
                                                paymentMethodId: paymentresponse[
                                                                'error']
                                                            ['payment_intent']
                                                        ['charges']['data'][0]
                                                    ['payment_method']);

                                        if (paymentIntent['status'] ==
                                            'succeeded') {
                                          print('Success');

                                          var url =
                                              'https://api.sellship.co/api/payment/${messageid}';

                                          Dio dio = new Dio();
                                          FormData formData;

                                          formData = FormData.fromMap({
                                            'items': json.encode(listitems),
                                            'senderid': userid,
                                            'recieverid': listitems[0].userid,
                                            'addressline1':
                                                selectedaddress.addressline1,
                                            'addressline2':
                                                selectedaddress.addressline2,
                                            'city': selectedaddress.city,
                                            'phonenumber':
                                                selectedaddress.phonenumber,
                                            'area': selectedaddress.area,
                                            'deliveryamount': deliveryamount,
                                            'paymentid': payment.paymentid,
                                            'totalpayable':
                                                total.toStringAsFixed(2)
                                          });

                                          var response = await dio.post(url,
                                              data: formData);
                                          print(response.statusCode);
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                          if (response.statusCode == 200) {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.remove('cartitems');

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderBuyer(
                                                        items: listitems,
                                                        messageid: messageid,
                                                      )),
                                            );
                                          }
                                        } else {
                                          Navigator.of(context).pop('dialog');
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              useRootNavigator: false,
                                              builder: (_) => new AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                    content: Builder(
                                                      builder: (context) {
                                                        return Container(
                                                            height: 380,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: 250,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/oops.gif',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  'Oops!',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                InkWell(
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        30,
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                        color: Color.fromRGBO(
                                                                            255,
                                                                            115,
                                                                            0,
                                                                            1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              color: Color(0xFF9DA3B4).withOpacity(0.1),
                                                                              blurRadius: 65.0,
                                                                              offset: Offset(0.0, 15.0))
                                                                        ]),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Close",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Helvetica',
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop(
                                                                            'dialog');
                                                                  },
                                                                ),
                                                              ],
                                                            ));
                                                      },
                                                    ),
                                                  ));
                                        }
                                      } else {
                                        Navigator.of(context).pop('dialog');
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            useRootNavigator: false,
                                            builder: (_) => new AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  content: Builder(
                                                    builder: (context) {
                                                      return Container(
                                                          height: 380,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 250,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/oops.gif',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                'Oops!',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              InkWell(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      30,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              115,
                                                                              0,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color: Color(0xFF9DA3B4).withOpacity(
                                                                                0.1),
                                                                            blurRadius:
                                                                                65.0,
                                                                            offset:
                                                                                Offset(0.0, 15.0))
                                                                      ]),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Close",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Helvetica',
                                                                          fontSize:
                                                                              18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop(
                                                                          'dialog');
                                                                },
                                                              ),
                                                            ],
                                                          ));
                                                    },
                                                  ),
                                                ));
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 52,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.deepOrange
                                                .withOpacity(0.4),
                                            offset: const Offset(1.1, 1.1),
                                            blurRadius: 10.0),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Pay',
                                        textAlign: TextAlign.center,
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
                              ),
                              InkWell(
                                onTap: () async {
                                  var response =
                                      StripePayment.paymentRequestWithNativePay(
                                    androidPayOptions: AndroidPayPaymentRequest(
                                      totalPrice: subtotal.toString(),
                                      currencyCode: "AED",
                                    ),
                                    applePayOptions: ApplePayPaymentOptions(
                                      countryCode: 'AE',
                                      currencyCode: 'AED',
                                      items: [
                                        ApplePayItem(
                                          label: 'SellShip',
                                          amount: subtotal.toString(),
                                        )
                                      ],
                                    ),
                                  ).then((token) async {
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
                                    var userid =
                                        await storage.read(key: 'userid');
                                    var messageurl =
                                        'https://api.sellship.co/api/stripe/native/pay/' +
                                            userid.toString() +
                                            '/' +
                                            token.tokenId.toString() +
                                            '/' +
                                            total.toString() +
                                            '/' +
                                            'AED';
                                    final response =
                                        await http.get(Uri.parse(messageurl));

                                    var paymentresponse =
                                        json.decode(response.body);

                                    if (paymentresponse.containsKey('done')) {
                                      print('success');
                                      print(paymentresponse['paymentid']);
                                      StripePayment.completeNativePayRequest()
                                          .then((_) async {
                                        var url =
                                            'https://api.sellship.co/api/payment/${messageid}';

                                        Dio dio = new Dio();
                                        FormData formData;

                                        formData = FormData.fromMap({
                                          'items': json.encode(listitems),
                                          'senderid': userid,
                                          'recieverid': listitems[0].userid,
                                          'addressline1':
                                              selectedaddress.addressline1,
                                          'addressline2':
                                              selectedaddress.addressline2,
                                          'city': selectedaddress.city,
                                          'phonenumber':
                                              selectedaddress.phonenumber,
                                          'area': selectedaddress.area,
                                          'deliveryamount': deliveryamount,
                                          'paymentid':
                                              paymentresponse['paymentid'],
                                          'totalpayable':
                                              total.toStringAsFixed(2)
                                        });

                                        var response =
                                            await dio.post(url, data: formData);
                                        if (response.statusCode == 200) {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.remove('cartitems');
                                          Navigator.of(context).pop('dialog');

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderBuyer(
                                                      items: listitems,
                                                      messageid: messageid,
                                                    )),
                                          );
                                        }
                                      });
                                    }
                                  });
                                },
                                child: Platform.isIOS
                                    ? Container(
                                        height: 52,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                20,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(25.0),
                                          ),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                offset: const Offset(1.1, 1.1),
                                                blurRadius: 10.0),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.applePay,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        ))
                                    : Container(
                                        height: 52,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                20,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(25.0),
                                          ),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                offset: const Offset(1.1, 1.1),
                                                blurRadius: 10.0),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.googlePay,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        )),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
