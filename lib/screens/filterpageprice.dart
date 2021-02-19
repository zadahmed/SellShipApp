import 'dart:convert';
import 'dart:io';
import 'package:SellShip/controllers/custom_slider_thumb.dart';
import 'package:SellShip/controllers/customslider.dart';
import 'package:SellShip/models/Items.dart';
import 'package:SellShip/screens/comments.dart';
import 'package:SellShip/screens/orderbuyer.dart';
import 'package:SellShip/screens/orderbuyeruae.dart';
import 'package:SellShip/screens/orderseller.dart';
import 'package:SellShip/screens/orderselleruae.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:SellShip/screens/details.dart';
import 'package:numeral/numeral.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class FilterPagePrice extends StatefulWidget {
  FilterPagePrice({Key key}) : super(key: key);
  @override
  FilterPagePriceState createState() => FilterPagePriceState();
}

class FilterPagePriceState extends State<FilterPagePrice> {
  var price;
  TextEditingController minpricecontroller = new TextEditingController();
  TextEditingController maxpricecontroller = new TextEditingController();

  double _minvalue = 0;
  double _maxvalue = 0;

  Widget slidercustommin(BuildContext context) {
    double paddingFactor = .2;

    double sliderHeight = 48;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: (sliderHeight),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(
            Radius.circular((sliderHeight * .3)),
          ),
          color: Colors.deepOrange),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            sliderHeight * paddingFactor, 2, sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Text(
              'AED ${0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbRect(
                      thumbHeight: 45,
                      thumbRadius: sliderHeight * .4,
                      min: 0,
                      max: 10000,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(
                      value: _minvalue,
                      divisions: 200,
                      onChanged: (value) {
                        setState(() {
                          _minvalue = value;
                          _maxvalue = value;
                        });
                      }),
                ),
              ),
            ),
            SizedBox(
              width: sliderHeight * .1,
            ),
            Text(
              'AED ${10000}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget slidercustommax(BuildContext context) {
    double paddingFactor = .2;

    double sliderHeight = 48;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: (sliderHeight),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(
            Radius.circular((sliderHeight * .3)),
          ),
          color: Colors.deepOrange),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            sliderHeight * paddingFactor, 2, sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Text(
              'AED ${(_minvalue * 10000).toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbRect(
                      thumbHeight: 45,
                      thumbRadius: sliderHeight * .4,
                      min: 0,
                      max: 10000,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(
                      value: _maxvalue,
                      divisions: 200,
                      onChanged: (value) {
                        setState(() {
                          _maxvalue = value;
                        });
                      }),
                ),
              ),
            ),
            SizedBox(
              width: sliderHeight * .1,
            ),
            Text(
              'AED ${10000}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Filter',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context, {
                  'minprice': (_minvalue * 10000).toStringAsFixed(0),
                  'maxprice': (_maxvalue * 10000).toStringAsFixed(0),
                });
              }),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'Minimum Price',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'AED ' + (_minvalue * 10000).toStringAsFixed(0),
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: slidercustommin(context),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'Maximum Price',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'AED ' + (_maxvalue * 10000).toStringAsFixed(0),
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: slidercustommax(context),
                      ),
                    ],
                  ))
            ]),
          ),
        ],
      ),
    );
  }
}
