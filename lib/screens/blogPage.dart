import 'package:cached_network_image/cached_network_image.dart';
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
            Html(
              data: widget.content,
              onLinkTap: (url) {
                print("Opening $url...");
              },
              onImageError: (exception, stackTrace) {
                print(exception);
              },
            ),
          ],
        ));
  }
}
