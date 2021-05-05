import 'dart:convert';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/addpayment.dart';
import 'package:SellShip/screens/address.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/onboardingbottom.dart';
import 'package:SellShip/screens/pay.dart';

import 'package:SellShip/screens/paymentweb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checkout extends StatefulWidget {
  String itemid;
  String messageid;

  Checkout({
    Key key,
    this.itemid,
    this.messageid,
  }) : super(key: key);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
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

  TextEditingController promocodecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    checkuser();
    getcurrency();

    setState(() {});
  }

  GlobalKey _toolTipKey = GlobalKey();

  var currency;
  var stripecurrency;

  bool promocodeactive = true;

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List cartitems = prefs.getStringList('cartitems');

    var deliverycharges;
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
            userid: decodeditem['sellerid'] == null
                ? decodeditem['userid']
                : decodeditem['sellerid'],
            username: decodeditem['sellername'] == null
                ? decodeditem['username']
                : decodeditem['sellername']);

        if (newItem.freedelivery == false) {
          var weightfees;
          if (newItem.weight == '5') {
            weightfees = 20;
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

        orderprice = double.parse(newItem.price);
        if (newItem.saleprice != null) {
          subtotal = double.parse(newItem.saleprice);
        } else {
          subtotal = double.parse(newItem.price);
        }

        listitems.add(newItem);
      }
    }

    if (mounted) {
      setState(() {
        currency = 'AED';
        stripecurrency = 'AED';
        subtotal = subtotal;
        total = subtotal + deliverycharges;
        listitems = listitems;
      });
    }
  }

  var orderprice;
  var deliveryamount;
  Item newItem;
  var addressline1;
  var city;
  var state;
  var paymentby;
  var payment;
  var totalrate;
  var deliveryaddress;

  var discount;

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
          listitems.isNotEmpty
              ? Padding(
                  padding:
                      EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
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
                                                      builder: (context) =>
                                                          Details(
                                                            itemid:
                                                                listitems[index]
                                                                    .itemid,
                                                            name:
                                                                listitems[index]
                                                                    .name,
                                                            sold:
                                                                listitems[index]
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
                                                            BorderRadius
                                                                .circular(5),
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
                                                                          color:
                                                                              Colors.deepOrange),
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
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        width: MediaQuery.of(
                                                                        context)
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
                                                                  FontWeight
                                                                      .bold,
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
                                                      listitems[index]
                                                                  .saleprice !=
                                                              null
                                                          ? Text.rich(
                                                              TextSpan(
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                    text: 'AED ' +
                                                                        listitems[index]
                                                                            .saleprice,
                                                                    style: new TextStyle(
                                                                        color: Colors
                                                                            .redAccent,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  new TextSpan(
                                                                    text: '\nAED ' +
                                                                        listitems[index]
                                                                            .price
                                                                            .toString(),
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          10,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                    ),
                                                                  ),
                                                                  new TextSpan(
                                                                    text: ' -' +
                                                                        (((double.parse(listitems[index].price.toString()) - double.parse(listitems[index].saleprice.toString())) / double.parse(listitems[index].price.toString())) *
                                                                                100)
                                                                            .toStringAsFixed(0) +
                                                                        '%',
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Text(
                                                              currency +
                                                                  ' ' +
                                                                  listitems[
                                                                          index]
                                                                      .price,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                    ],
                                                  ),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                showDialog<
                                                                    void>(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false, // user must tap button!
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title:
                                                                          Text(
                                                                        'Are you sure you want to move this item to favourites?',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18.0,
                                                                            fontWeight:
                                                                                FontWeight.w800),
                                                                      ),
                                                                      actions: <
                                                                          Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Favourite Item',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 16.0,
                                                                                fontWeight: FontWeight.w800),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            var userid =
                                                                                await storage.read(key: 'userid');

                                                                            var url =
                                                                                'https://api.sellship.co/api/favourite/' + userid;

                                                                            Map<String, String>
                                                                                body =
                                                                                {
                                                                              'itemid': listitems[0].itemid,
                                                                            };

                                                                            final response =
                                                                                await http.post(Uri.parse(url), body: json.encode(body));

                                                                            if (response.statusCode ==
                                                                                200) {
                                                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                              prefs.remove('cartitems');
                                                                              setState(() {
                                                                                listitems = [];
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                              showInSnackBar(listitems[0].name + ' has been moved to favourites');
                                                                            } else {
                                                                              print(response.statusCode);
                                                                            }
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Cancel',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                                fontSize: 16.0,
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.w800),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                      radius:
                                                                          14,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      child:
                                                                          Icon(
                                                                        FeatherIcons
                                                                            .heart,
                                                                        size:
                                                                            16,
                                                                        color: Colors
                                                                            .grey,
                                                                      )),
                                                            ),
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  showDialog<
                                                                      void>(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false, // user must tap button!
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title:
                                                                            Text(
                                                                          'Are you sure you want to remove this item?',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.w800),
                                                                        ),
                                                                        actions: <
                                                                            Widget>[
                                                                          TextButton(
                                                                            child:
                                                                                Text(
                                                                              'Remove Item',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w800),
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                              prefs.remove('cartitems');
                                                                              setState(() {
                                                                                listitems = [];
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                Text(
                                                                              'Cancel',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: 16.0, color: Colors.red, fontWeight: FontWeight.w800),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                        radius:
                                                                            14,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .white,
                                                                        child:
                                                                            Icon(
                                                                          FeatherIcons
                                                                              .trash2,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              Colors.grey,
                                                                        ))),
                                                          ],
                                                        )
                                                      ])
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Helvetica',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ));
                                },
                              ),
                            ),
                          ])))
              : Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width - 100,
                          child: Image.asset('assets/143.png',
                              fit: BoxFit.contain),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Looks like you have\'nt added anything\nin your cart yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ])),

          listitems.isNotEmpty
              ? Padding(
                  padding:
                      EdgeInsets.only(left: 15, bottom: 10, top: 5, right: 15),
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
                                'Delivery Address',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                ),
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
                                        selectedaddress =
                                            addressresult['address'];
                                        phonenumber =
                                            addressresult['phonenumber'];
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
                                            MediaQuery.of(context).size.width /
                                                2,
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
                                      selectedaddress == null
                                          ? Icon(
                                              FeatherIcons.chevronRight,
                                              size: 14,
                                              color: Colors.blueGrey,
                                            )
                                          : Container()
                                    ],
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(131, 146, 165, 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          cursorColor: Color(0xFF979797),
                                          controller: promocodecontroller,
                                          enableSuggestions: true,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                            hintText: "Enter Promo Code",
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  promocodecontroller.clear();
                                                });
                                              },
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                            ),
                                            labelStyle: TextStyle(
                                              fontFamily: 'Helvetica',
                                              fontSize: 16,
                                              color: Colors.grey.shade300,
                                            ),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 16,
                                            ),
                                            focusColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        enableFeedback: true,
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          var welcomeuser =
                                              prefs.getBool('welcomeuser');
                                          if (welcomeuser == false ||
                                              welcomeuser == null) {
                                            if (promocodecontroller.text
                                                .contains('WELCOMESHIP')) {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              List cartitems = prefs
                                                  .getStringList('cartitems');

                                              var deliverycharges;
                                              if (cartitems != null) {
                                                for (int i = 0;
                                                    i < cartitems.length;
                                                    i++) {
                                                  var decodeditem =
                                                      json.decode(cartitems[i]);

                                                  Item newItem = Item(
                                                      name: decodeditem['name'],
                                                      selectedsize: decodeditem[
                                                          'selectedsize'],
                                                      quantity: decodeditem[
                                                          'quantity'],
                                                      itemid:
                                                          decodeditem['itemid'],
                                                      weight:
                                                          decodeditem['weight'],
                                                      freedelivery: decodeditem[
                                                          'freedelivery'],
                                                      price:
                                                          decodeditem['price']
                                                              .toString(),
                                                      saleprice: decodeditem[
                                                                  'saleprice'] ==
                                                              null
                                                          ? null
                                                          : decodeditem[
                                                              'saleprice'],
                                                      image:
                                                          decodeditem['image'],
                                                      userid: decodeditem[
                                                                  'sellerid'] ==
                                                              null
                                                          ? decodeditem[
                                                              'userid']
                                                          : decodeditem[
                                                              'sellerid'],
                                                      username: decodeditem[
                                                                  'sellername'] ==
                                                              null
                                                          ? decodeditem[
                                                              'username']
                                                          : decodeditem[
                                                              'sellername']);

                                                  if (newItem.freedelivery ==
                                                      false) {
                                                    var weightfees;
                                                    if (newItem.weight == '5') {
                                                      weightfees = 20;
                                                    } else if (newItem.weight ==
                                                        '10') {
                                                      weightfees = 30;
                                                    } else if (newItem.weight ==
                                                        '20') {
                                                      weightfees = 50;
                                                    } else if (newItem.weight ==
                                                        '50') {
                                                      weightfees = 110;
                                                    }

                                                    setState(() {
                                                      deliveryamount = 'AED ' +
                                                          weightfees.toString();
                                                      deliverycharges =
                                                          double.parse(
                                                              weightfees
                                                                  .toString());
                                                    });
                                                  } else {
                                                    setState(() {
                                                      deliveryamount = 'FREE';
                                                      deliverycharges = 0.0;
                                                    });
                                                  }

                                                  orderprice = double.parse(
                                                      newItem.price);
                                                  if (newItem.saleprice !=
                                                      null) {
                                                    subtotal = double.parse(
                                                        newItem.saleprice);
                                                  } else {
                                                    subtotal = double.parse(
                                                        newItem.price);
                                                  }
                                                }
                                              }

                                              total =
                                                  subtotal + deliverycharges;

                                              discount = total * 0.10;

                                              if (discount > 30) {
                                                discount = 30;
                                                total = total - discount;
                                              } else {
                                                discount = total * 0.10;
                                                total = total - discount;
                                                print(total);
                                              }
                                              setState(() {
                                                promocodeactive = true;
                                                total = total;
                                                discount = discount;
                                              });
                                            } else {
                                              setState(() {
                                                discount = null;
                                                promocodeactive = false;
                                              });
                                            }
                                          }
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Container(
                                              height: 50,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.deepOrange),
                                              child: Center(
                                                child: Text(
                                                  'Apply',
                                                  style: TextStyle(
                                                    fontFamily: 'Helvetica',
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ))),
                          promocodeactive == false
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text(
                                        'Oops! Promocode is invalid.',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      )
                                    ])
                              : Container(),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  subtotal != 0.0
                                      ? currency +
                                          ' ' +
                                          orderprice.toStringAsFixed(2)
                                      : 'AED 0',
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          listitems[0].saleprice != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Discount',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        Text(
                                          '  -' +
                                              (((double.parse(listitems[0]
                                                                  .price
                                                                  .toString()) -
                                                              double.parse(
                                                                  listitems[0]
                                                                      .saleprice
                                                                      .toString())) /
                                                          double.parse(
                                                              listitems[0]
                                                                  .price
                                                                  .toString())) *
                                                      100)
                                                  .toStringAsFixed(0) +
                                              '%',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 14,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      subtotal != 0.0
                                          ? ' -' +
                                              currency +
                                              (double.parse(
                                                          listitems[0].price) -
                                                      double.parse(listitems[0]
                                                          .saleprice))
                                                  .toString()
                                          : 'AED 0',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          discount != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Discount - WELCOMESHIP',
                                          style: TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontSize: 16,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '- ' +
                                          currency +
                                          discount.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                currency + total.toStringAsFixed(2),
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )))
              : Container(),
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
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Pay(
                                              messageid: widget.messageid,
                                              itemid: widget.itemid,
                                              discountccode: 'WELCOMESHIP',
                                              price: total,
                                              address: selectedaddress,
                                              phonenumber: phonenumber,
                                            )),
                                  );
                                }
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(65, 105, 225, 1),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color:
                                            Color.fromRGBO(65, 105, 225, 0.4),
                                        offset: const Offset(1.1, 1.1),
                                        blurRadius: 10.0),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Proceed to Payment',
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
