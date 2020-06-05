import 'dart:convert';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:locally/locally.dart';
import 'package:overlay_support/overlay_support.dart';

class FirebaseNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future getNotifications(BuildContext context) async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var title = message['notification']['title'];
        var body = message['notification']['body'];

        Locally locally = Locally(
          context: context,
          payload: 'test',
          pageRoute: MaterialPageRoute(builder: (context) => Messages()),
          appIcon: 'mipmap/ic_launcher',
        );
        locally.show(title: title, message: body);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    await _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    var token = await _firebaseMessaging.getToken();

    return token;
  }

  postNotification({title, body, to}) async {
    var res = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAJ43JO4Q:APA91bGKOls-gW5zRmx5Eh96VBtrRQqxhk9uQG2u8tyIhK7h8I8Ov7e6NTaBNv8XQ0HYPNJ2zA88d7e1KCjhl7IpprRnSYa00YPKd4RpGZQYfLNevDHtxv0vL8NOnPWjP4wGX_Xd2jJD',
      },
      body: jsonEncode(
        <String, dynamic>{
          "data": {"title": title, "Body": body},
          "to": to
        },
      ),
    );
    print(jsonEncode(
      <String, dynamic>{
        "data": {"title": title, "Body": body},
        "to": to
      },
    ));
    print(res.body);
  }
}
