import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  Test({Key key}) : super(key: key);

  @override
  TestState createState() => new TestState();
}

class TestState extends State<Test> {
  @override
  void initState() {
    super.initState();
    connecttosocket();
  }

  connecttosocket() {
//    IO.Socket socket = IO.io('https://api.sellship.co');
//

    IO.Socket socket = IO.io('https://api.sellship.co', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();

//    socket.on('connect', (_) {
//      print('connect');
//      var data = {'data': 'test'};
//      socket.emit('connected', data);
//    });
    print(socket.id);
//    socket.on('event', (data) => print(data));
//    socket.on('disconnect', (_) => print('disconnect'));
//    socket.on('fromServer', (_) => print(_));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
