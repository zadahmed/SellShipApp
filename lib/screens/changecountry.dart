import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChangeCountry extends StatefulWidget {
  @override
  _ChangeCountryState createState() => _ChangeCountryState();
}

class _ChangeCountryState extends State<ChangeCountry> {
  List<String> strList = [];
  List<Widget> countrywidget = [];
  @override
  void initState() {
    fetchCountries();
    super.initState();
  }

  final storage = new FlutterSecureStorage();
  fetchCountries() async {
    var url = 'https://sellship.co/api/getcountries';
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var s = json.decode(response.body);
      for (int i = 0; i < s.length; i++) {
        countrywidget.add(
          ListTile(
            onTap: () async {
              await storage.write(key: 'country', value: s[i]);
              Navigator.of(context).pop();
            },
            title: Text(s[i]),
          ),
        );
        strList.add(s[i]);
      }

      setState(() {
        countrywidget = countrywidget;
        strList = strList;
      });
    } else {
      print(response.statusCode);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.deepOrange,
              ),
              onTap: () {
                Navigator.of(context).pop();
              }),
        ),
        title: const Text(
          'Change Country',
          style: TextStyle(
              fontFamily: 'SF',
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: AlphabetListScrollView(
        strList: strList,
        highlightTextStyle: TextStyle(
          color: Colors.deepOrange,
        ),
        showPreview: true,
        itemBuilder: (context, index) {
          return countrywidget[index];
        },
        indexedHeight: (i) {
          return 80;
        },
      ),
    );
  }
}
