import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  Activity({Key key}) : super(key: key);

  @override
  _ActivityState createState() => new _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Activity',
          style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20.0,
              color: Color.fromRGBO(115, 115, 125, 1),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
