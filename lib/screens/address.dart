import 'dart:convert';

import 'package:SellShip/models/Items.dart';
import 'package:SellShip/payments/existingcard.dart';
import 'package:SellShip/payments/stripeservice.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/paymentdone.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class AddressModel {
  String addresstype;
  String address;
  String addressline1;
  String addressline2;
  String city;
  String country;
  String area;
  String phonenumber;

  AddressModel(
      {this.addresstype,
      this.address,
      this.phonenumber,
      this.addressline1,
      this.addressline2,
      this.area,
      this.city,
      this.country});
}

class _AddressState extends State<Address> {
  final addresslinecontroller = TextEditingController();
  final addressline2controller = TextEditingController();

  final citycontroller = TextEditingController();

  final phonenumbercontroller = TextEditingController();

  var phonenumber;

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

  String statecode;

  var selectedCity;

  int radiovalue = -1;

  var selectedaddress;
  var selectedarea;

  List<AddressModel> addresseslist = List<AddressModel>();

  bool loading = true;

  List<String> adareas = [
    'MANGROVE',
    'KHALIFA PARK',
    'ZAYED SPORTS CITY',
    'SAS AL NAKHL',
    'AL GURM',
    'AL MUZOON',
    'SAADIYAT ISLAND',
    'YAS ISLAND',
    'AL MAQTA',
    'KHALIFA A',
    'KHALIFA B',
    'MASDAR CITY',
    'AL RAHA',
    'AL BAHYA',
    'AL SHAHMA',
    'AL RAHBA',
    'AL SHELEILAH',
    'KHALIFA IND ZONE',
    'AL SAMHA',
    'ZAYED MILITARY CITY',
    'AL FALAH NEW',
    'AL FALAH OLD',
    'AL SHAMKHA',
    'MBZ',
    'BANIYAS EAST',
    'BANIYAS WEST',
    'MAFRAQ IND AREA',
    'AL SHAMKHA SOUTH',
    'AL NAHDA',
    'AL ME`RAD',
    'AL ADLA',
    'AL FAYA',
    'AL WATHBA',
    'AL WATHBA SOUTH',
    'AL DHAFRA',
    'ICAD 3',
    'MUSSAFAH SOUTH',
    'I CAD 1',
    'MUSSAFAH IND',
    'MUSSAFAH',
    'KIZAD',
    'AL BATEIN',
    'AL MUSHRIF',
    'AL NAHYAN',
    'AL ZAFRANAH',
    'AL MUSALLA',
    'AL ETHIHAD',
    'AL KHALIDYA',
    'TOURIST CLUB AREA',
    'AL MARYAH ISLAND',
    'AL REEM ISLAND',
    'EMASSIES DISTRICT',
    'AL HOSN',
    'AL MANHAL',
    'AL DHAFRAH',
    'AL MARINA',
    'SHAKHBOUT CITY',
    'AL SHAWAMIKH',
  ];

  List<String> ajmanareas = [
    'ALCOURNISH',
    'AL RUMAILAH',
    'AL RUMAILAH 3',
    'AL RASHIDIYA',
    'AL RASHIDIYA 2',
    'AL RASHIDIYA 3',
    'AL NAKHIL',
    'AL BUSTAN',
    'AL BATAIN',
    'AL NUAIMIA',
    'AL NUAIMIA 1',
    'AJM INDUSTRIAL AREA',
    'AL MWAIHAT',
    'AL MWAIHAT 2',
    'AL MWAIHAT 3',
    'AL TALLA 1',
    'AL TALLA 2',
    'AL MUNTAZI 1',
    'AL MUNTAZI 2',
    'HAMIDIYA',
    'AL RAWDA 2',
    'AL RAWDA 1',
    'AL JERF IND AREA 3',
    'AL JERF IND AREA 2',
    'AL JERF IND AREA 1',
    'AL BAHIA',
    'AJM INDUSTRIAL AREA 2',
    'AL HAMRIYAH FZ',
    'MESHAIREF',
  ];

  List<String> alainareas = [
    'AL DHAHIR',
    'UM GHAFA',
    'AL KHRAIR',
    'MALAGIT',
    'JEBAL HAFEET',
    'AL SAROOJ',
    'AL SANAIYA',
    'FALAJ HAZZAA',
    'AL GRAYYEH',
    'GAFAT AL NAYYAR',
    'ZAKHER',
    'AL SALAMAT',
    'AL BATEEN',
    'AL MAQAM',
    'AL KHABISI',
    'AL MUWAIJI',
    'AL TOWAYYA',
    'AL JIMI',
    'CENTRAL DISTRICT',
    'AL MASOUDI',
    'AL QATTARA',
    'AL HILI',
    'AL FOAH',
    'AL HAYER',
    'AL FAQA',
    'AL SHUWAIB',
    'AL MARKHANIA',
  ];

  List<String> dxbareas = [
    'AL GHARHOUD',
    'AL MAMZAR',
    'BUR DUBAI',
    'AL BARSHA',
    'AL RIGGA',
    'ABU HAIL',
    'JUMERAH 1',
    'JUMERAH 2',
    'UMM SUQUEIM',
    'UMM SUQUEIM 2',
    'UMM SUQUEIM 3',
    'MEDIA CITY',
    'PALM JUMEIRAH',
    'JEBAL ALI IND AREA',
    'TECOM',
    'DEIRA',
    'Dubai Far Area',
    'JEBAL ALI FZ',
    'MOTOR CITY',
    'AL SUFOUH',
    'JUMEIRAH VILL CIRCLE',
    'ARABIAN RANCHES',
    'DIP',
    'NAD AL SHEBA',
    'DXB SILICON OASIS',
    'ACADEMIC CITY',
    'BUKADRA',
    'RAS AL KHOUR',
    'RAS AL KHOUR IND 1',
    'RAS AL KHOUR IND',
    'NADD AL HAMAR',
    'AL WARQA 1',
    'AL WARQA',
    'WARSAN 2',
    'AL KHAWANEEJ',
    'MIRDIF',
    'AL RASHIDYA',
    'DFC',
    'DAFZA',
    'JAFZA',
    'AL MIZHAR',
    'AL MIZHAR 2',
    'OUD AL MUTEENA',
    'MUHAISNAH',
    'UMM RAMOOL',
    'PORT SAEED',
    'NAIF',
    'AL NAHDA 1',
    'AL NAHDA 2',
    'AL QUSAIS IND',
    'AL QUSAIS',
    'AL TWAR 1',
    'AL TWAR 2',
    'AL TWAR 3',
    'AL QUSAIS 2',
    'AL QUSAIS 3',
    'MUHAISNAH 3',
    'AL QUSAIS IND 5',
    'HUR AL ANZ',
    'AL JAFFILIYA',
    'ZA`ABEEL',
    'ZA`ABEEL 1',
    'AL WASEL',
    'AL SAFA',
    'AL SAFA 2',
    'UMM AL SHEIF',
    'AL QOUZ',
    'AL QOUZ 4',
    'EMIRATES HILLS',
    'INTERNET CITY',
    'AL SATWA',
  ];

  List<String> fujairahareas = [
    'FUJAIRAH',
    'AL DHAID',
    'AL MANAMA',
    'MASSAFI',
  ];

  List<String> rakares = [
    'AL KHARAN',
    'AL QIR',
    'SHA`AM',
    'GHALILAH',
    'JULPHAR',
    'AL MATAF',
    'SEIH AL HARF',
    'AL DHAIT SOUTH',
    'AL DHAIT NORTH',
    'KHUZAM',
    'DAFAN AL KHOUR',
    'AL MAMMOURAH',
    'AL NAKHEEL',
    'AL ZAHRA',
    'AL JUWAIS',
    'AL QURM',
    'AL KHARRAN',
    'AL RAMS',
    'AL SHARISHA',
    'AL SALL',
    'AL DARBIJANYAH',
    'RAS AL SELAAB',
    'SIDROH',
    'DAHAN',
    'DAFAN AL KHOR',
    'AL NADIYAH',
  ];

  List<String> sharjahareas = [
    'AL KHAN',
    'ABU SHAGARA',
    'SHJ INDUSTRIAL AREA',
    'AL FALAH',
    'AL NOOF',
    'AL JURAINAH',
    'UNIVERSITY CITY',
    'MUWAILIH COMMERCIAL',
    'WASIT',
    'MUGHAIDIR',
    'INDUSTRIAL AREA',
    'AL MAMZAR',
    'AL MAJAZ',
    'AL KHALIDYA',
    'AL LAYYEH',
    'HALWAN',
    'AL SHARQ',
    'AL BU DANIQ',
    'AL QASMIYA',
    'AL MAHATAH',
    'UMM AL TARAFFA',
    'AL MARERJA',
    'AL SHUWAIHEAN',
    'AL NABBA',
    'AL MUJARRAH',
    'BU TINA',
    'AL NASSERYA',
    'AL RAMLA EAST',
    'AL RAMLA WEST',
    'AL YARMOOK',
    'AL GHUBAIBA',
    'SAMNAN',
    'AL SHAHBA',
    'EMIRATES INDUSTRIAL CITY',
    'AL SAJA`A IND SUBURB',
    'AL RAHMANIYA',
    'AL KHEZAMIA',
    'AL ABAR',
    'DASMAN',
    'AL FALAJ',
    'AL QOAZ',
    'AL RAMTHA',
    'AL RAMAQYA',
    'MUWAFJAH',
    'AL YASH',
    'AL AZRA',
    'AL RIQA',
    'AL JAZZAT',
    'AL HAZANNAH',
    'AL SABKHA',
    'AL GHAFIA',
    'AL NEKHAILAT',
    'AL HEERAH',
    'SHARQAN',
    'AL RIFA`AH',
    'AL FISHT',
    'AL GHARAYEN',
  ];

  List<String> uaqareas = [
    'EMIRATES MODERN IND AREA',
    'AL SALAMAH',
    'AL HAMRIYA',
    'AL RAAS',
    'AL RAUDAH',
    'OLD TOWN AREA',
    'AL HUMRAH'
  ];

  var addressreturned;

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  loadaddresses() async {
    addresseslist.clear();
    var user = await storage.read(key: 'userid');

    var url = "https://api.sellship.co/api/getaddresses/" + user;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonbody = json.decode(response.body);
      for (int i = 0; i < jsonbody.length; i++) {
        addresseslist.add(AddressModel(
            addresstype: jsonbody[i]['addresstype'],
            addressline1: jsonbody[i]['addressline1'],
            addressline2: jsonbody[i]['addressline2'],
            city: jsonbody[i]['city'],
            country: jsonbody[i]['country'],
            area: jsonbody[i]['area'],
            address: ' ' +
                jsonbody[i]['addressline1'] +
                ',\n ' +
                jsonbody[i]['addressline2'] +
                ',\n ' +
                capitalize(jsonbody[i]['area'].toString().toLowerCase()) +
                ',\n ' +
                jsonbody[i]['city'] +
                ',\n ' +
                jsonbody[i]['country'],
            phonenumber: jsonbody[i]['phonenumber']));
      }

      if (addresseslist != null) {
        setState(() {
          loading = false;
          addressreturned = "";
          addresseslist = addresseslist;
        });
      } else {
        setState(() {
          loading = false;
          addressreturned = addresseslist[0].address;
          addresseslist = addresseslist;
        });
      }
    } else {
      print(response.statusCode);
      setState(() {
        loading = false;
        addresseslist = [];
      });
    }
  }

  List<String> areas = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(242, 244, 248, 1),
        appBar: AppBar(
          elevation: 0,
          leading: InkWell(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Address',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
          ),
        ),
        body: Column(children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 10, right: 15),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Address',
                      style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    backgroundColor: Colors.white,
                                    content: StatefulBuilder(
                                        // You need this, notice the parameters below:
                                        builder: (BuildContext context,
                                            StateSetter updateState) {
                                      return Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2 +
                                              100,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          child: Scrollbar(
                                              child: SingleChildScrollView(
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Add Address',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                    letterSpacing: 0.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Padding(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          autofocus: true,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          icon: Icon(Icons
                                                              .keyboard_arrow_down),
                                                          hint: Text(
                                                            'Address Type',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          value:
                                                              selectedaddress,
                                                          onChanged: (value) {
                                                            updateState(() {
                                                              selectedaddress =
                                                                  value;
                                                            });
                                                          },
                                                          items: <String>[
                                                            'Home',
                                                            'Work',
                                                            'Other',
                                                          ].map((String value) {
                                                            return new DropdownMenuItem<
                                                                    String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      200,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        value),
                                                                  ),
                                                                ));
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          autofocus: true,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          icon: Icon(Icons
                                                              .keyboard_arrow_down),
                                                          hint: Text(
                                                            'City',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          value: selectedCity,
                                                          onChanged: (value) {
                                                            updateState(() {
                                                              selectedCity =
                                                                  value;
                                                            });

                                                            if (value ==
                                                                'Abu Dhabi') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                adareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas = adareas;
                                                              });
                                                            } else if (value ==
                                                                'Dubai') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                dxbareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas =
                                                                    dxbareas;
                                                              });
                                                            } else if (value ==
                                                                'Sharjah') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                sharjahareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas =
                                                                    sharjahareas;
                                                              });
                                                            } else if (value ==
                                                                'Alain') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                alainareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas =
                                                                    alainareas;
                                                              });
                                                            } else if (value ==
                                                                'Fujairah') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                fujairahareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas =
                                                                    fujairahareas;
                                                              });
                                                            } else if (value ==
                                                                'Ras Al Khaimah') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                rakares.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas = rakares;
                                                              });
                                                            } else if (value ==
                                                                'Umm Al Quwain') {
                                                              selectedarea =
                                                                  null;
                                                              updateState(() {
                                                                uaqareas.sort((String
                                                                            a,
                                                                        String
                                                                            b) =>
                                                                    a.compareTo(
                                                                        b));
                                                                areas =
                                                                    uaqareas;
                                                              });
                                                            }
                                                          },
                                                          items: <String>[
                                                            'Abu Dhabi',
                                                            'Alain',
                                                            'Dubai',
                                                            'Sharjah',
                                                            'Ajman',
                                                            'Umm Al Quwain',
                                                            'Ras Al Khaimah',
                                                            'Fujairah'
                                                          ].map((String value) {
                                                            return new DropdownMenuItem<
                                                                    String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      200,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        value),
                                                                  ),
                                                                ));
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          autofocus: true,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Helvetica',
                                                            fontSize: 16,
                                                          ),
                                                          icon: Icon(Icons
                                                              .keyboard_arrow_down),
                                                          hint: Text(
                                                            'Area',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          value: selectedarea,
                                                          onChanged: (value) {
                                                            updateState(() {
                                                              selectedarea =
                                                                  value;
                                                            });
                                                          },
                                                          items: areas.map(
                                                              (String value) {
                                                            return new DropdownMenuItem<
                                                                    String>(
                                                                value: value,
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      200,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                        capitalize(
                                                                            value.toLowerCase())),
                                                                  ),
                                                                ));
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          addressline2controller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Apartment/Villa Number",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      controller:
                                                          addresslinecontroller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Street/Apartment/Villa Name",
                                                              labelStyle:
                                                                  TextStyle(
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                fontSize: 16,
                                                              ),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10),
                                                ),
                                                Padding(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        bottom: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child:
                                                        InternationalPhoneNumberInput(
                                                      isEnabled: true,
                                                      onInputChanged:
                                                          (PhoneNumber
                                                              number) async {
                                                        if (number != null) {
                                                          setState(() {
                                                            phonenumber = number
                                                                .toString();
                                                          });
                                                        }
                                                      },
                                                      autoValidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      countries: ['AE'],
                                                      textFieldController:
                                                          phonenumbercontroller,
                                                      inputDecoration:
                                                          InputDecoration(
                                                              border:
                                                                  UnderlineInputBorder(),
                                                              hintText:
                                                                  "501234567",
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey.shade300,
                                                          offset: Offset(
                                                              0.0, 1.0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      enabled: false,
                                                      cursorColor:
                                                          Color(0xFF979797),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      controller:
                                                          countrycontroller,
                                                      enableSuggestions: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Country",
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      'Helvetica',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              focusColor:
                                                                  Colors.black,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              disabledBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              )),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      top: 5,
                                                      right: 10,
                                                      bottom: 10),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                    onTap: () async {
                                                      if (addresslinecontroller
                                                              .text.isEmpty ||
                                                          addressline2controller
                                                              .text.isEmpty ||
                                                          selectedCity ==
                                                              null ||
                                                          selectedaddress ==
                                                              null ||
                                                          phonenumbercontroller
                                                              .text.isEmpty) {
                                                        showDialog(
                                                            context: context,
                                                            useRootNavigator:
                                                                false,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title:
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      content: Text(
                                                                          "Oops looks like something is missing."),
                                                                      actions: [
                                                                        InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(10),
                                                                              child: Container(
                                                                                height: 48,
                                                                                width: 100,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.black,
                                                                                  borderRadius: const BorderRadius.all(
                                                                                    Radius.circular(10.0),
                                                                                  ),
                                                                                  boxShadow: <BoxShadow>[
                                                                                    BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
                                                                                  ],
                                                                                ),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Close',
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
                                                                      ],
                                                                    ));
                                                      } else {
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            useRootNavigator:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0)), //this right here
                                                                  child: Container(
                                                                      height: 170,
                                                                      padding: EdgeInsets.all(15),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            'Adding New Address..',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Helvetica',
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                              height: 50,
                                                                              width: 50,
                                                                              child: SpinKitDoubleBounce(
                                                                                color: Colors.deepOrange,
                                                                              )),
                                                                        ],
                                                                      )));
                                                            });

                                                        var url = 'https://api.sellship.co/api/addaddress/' +
                                                            userid +
                                                            '/' +
                                                            selectedaddress +
                                                            '/' +
                                                            selectedarea +
                                                            '/' +
                                                            addresslinecontroller
                                                                .text
                                                                .trim() +
                                                            '/' +
                                                            addressline2controller
                                                                .text
                                                                .trim() +
                                                            '/' +
                                                            selectedCity +
                                                            '/' +
                                                            phonenumber +
                                                            '/' +
                                                            country;

                                                        final response =
                                                            await http.get(url);

                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          var jsonbody = json
                                                              .decode(response
                                                                  .body);

                                                          print(jsonbody);

                                                          showDialog(
                                                              context: context,
                                                              useRootNavigator:
                                                                  false,
                                                              builder: (_) =>
                                                                  AssetGiffyDialog(
                                                                    image: Image
                                                                        .asset(
                                                                      'assets/yay.gif',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    title: Text(
                                                                      'Address Added!',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              22.0,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    onlyOkButton:
                                                                        true,
                                                                    entryAnimation:
                                                                        EntryAnimation
                                                                            .DEFAULT,
                                                                    onOkButtonPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        loading =
                                                                            true;
                                                                      });
                                                                      loadaddresses();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              'dialog');
                                                                    },
                                                                  ));
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop('dialog');

                                                          print(response
                                                              .statusCode);
                                                        }
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Container(
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(
                                                                10.0),
                                                          ),
                                                          boxShadow: <
                                                              BoxShadow>[
                                                            BoxShadow(
                                                                color: Colors
                                                                    .deepPurpleAccent
                                                                    .withOpacity(
                                                                        0.4),
                                                                offset:
                                                                    const Offset(
                                                                        1.1,
                                                                        1.1),
                                                                blurRadius:
                                                                    10.0),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Add Address',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  0.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          )));
                                    }));
                              });
                        },
                        child: CircleAvatar(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.deepPurpleAccent,
                        )),
                  ],
                )),
          ),
          loading == false
              ? addresseslist.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: addresseslist.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  addressreturned =
                                      addresseslist[index].address;

                                  var returnedaddress = {
                                    'address': addresseslist[index],
                                    'phonenumber':
                                        addresseslist[index].phonenumber,
                                  };
                                  Navigator.pop(context, returnedaddress);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white),
                                  height: 210,
                                  width: MediaQuery.of(context).size.width / 2,
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                              value: index,
                                              groupValue: radiovalue,
                                              onChanged: (intvalue) {
                                                setState(() {
                                                  addressreturned =
                                                      addresseslist[index]
                                                          .address;
                                                  radiovalue = intvalue;
                                                });
                                              }),
                                          Text(
                                            addresseslist[index].addresstype,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            addresseslist[index].address,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blueGrey),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            addresseslist[index].phonenumber,
                                            style: TextStyle(
                                                fontFamily: 'Helvetica',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.deepOrangeAccent),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ))
                  : Container()
              : Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: ListView(
                      children: [0]
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 300.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      height: 280.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                )
        ]));
  }
}
