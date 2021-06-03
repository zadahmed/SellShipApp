import 'package:SellShip/screens/helpcentre.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';

class BlogPage extends StatefulWidget {
  BlogPage(
      {Key key,
      this.title,
      this.content,
      this.related,
      this.image,
      this.blogid})
      : super(key: key);

  final String title;
  final int blogid;
  final String content;
  final String image;
  final List related;

  @override
  _BlogPageState createState() => new _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  void initState() {
    super.initState();
    enableanalytics();
  }

  enableanalytics() async {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    await analytics.setCurrentScreen(
      screenName: 'App:ViewBlog',
      screenClassOverride: 'AppViewBlog',
    );
    await analytics.logViewItem(
      itemId: widget.blogid.toString(),
      itemName: widget.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica'),
          ),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Hero(
                tag: 'Blog${widget.blogid}',
                child: CachedNetworkImage(imageUrl: widget.image),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
              child: Text(
                widget.title,
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 27.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
                left: 10,
                right: 10,
              ),
              child: Html(
                data: widget.content,
                onImageError: (exception, stackTrace) {
                  print(exception);
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpCentre()),
                    );
                  },
                  child: Text(
                    'Need more help and support? Check out our Help Centre',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 13.0,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ))
          ],
        ));
  }
}
