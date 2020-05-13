import 'package:flutter/material.dart';

class ChatMessages implements Comparable<ChatMessages> {
  final String messageid;
  final String peoplemessaged;
  final String senderid;
  final String recipentid;
  final String lastrecieved;
  final String recieveddate;
  final String hiddendate;
  final bool unread;
  final fcmtokenreciever;
  final senderName;
  final String profilepicture;
  final String itemname;
  final String itemid;
  final String offer;

  ChatMessages(
      {this.messageid,
      this.peoplemessaged,
      this.senderid,
      this.recipentid,
      this.lastrecieved,
      this.hiddendate,
      this.itemid,
      this.offer,
      this.recieveddate,
      this.profilepicture,
      this.itemname,
      this.unread,
      @required this.fcmtokenreciever,
      @required this.senderName});

  int compareTo(ChatMessages other) {
    int order = other.hiddendate.compareTo(hiddendate);
    return order;
  }
}
