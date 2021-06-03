import 'dart:convert';
import 'package:SellShip/screens/chatpageview.dart';
import 'package:SellShip/screens/home.dart';
import 'package:SellShip/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:locally/locally.dart';
import 'package:intercom_flutter/intercom_flutter.dart' show Intercom;

//
//class OneSignalNotifications{
//  OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
//  // will be called whenever a notification is received
//  });
//
//  OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
//  // will be called whenever a notification is opened/button pressed.
//  });
//
//  OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//  // will be called whenever the permission changes
//  // (ie. user taps Allow on the permission prompt in iOS)
//  });
//
//  OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
//  // will be called whenever the subscription changes
//  //(ie. user gets registered with OneSignal and gets a user ID)
//  });
//
//  OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
//  // will be called whenever then user's email subscription changes
//  // (ie. OneSignal.setEmail(email) is called and the user gets registered
//  });
//
//// For each of the above functions, you can also pass in a
//// reference to a function as well:
//
//  void _handleNotificationReceived(OSNotification notification) {
//
//  }
//
//  void main() {
//    OneSignal.shared.setNotificationReceivedHandler(_handleNotificationReceived);
//  }
//}
