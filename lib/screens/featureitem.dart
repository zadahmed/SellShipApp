import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FeatureItem extends StatefulWidget {
  final String itemid;
  FeatureItem({Key key, this.itemid}) : super(key: key);

  _FeatureItemState createState() => _FeatureItemState();
}

class _FeatureItemState extends State<FeatureItem> {
  String itemid;

  @override
  void initState() {
    super.initState();
    setState(() {
      itemid = widget.itemid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          pinned: true,
          title: Text(
            'Boost Ad',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ));
  }
}
