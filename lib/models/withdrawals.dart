import 'package:flutter/material.dart';

class Withdrawals {
  final String withdrawalid;
  final String date;
  final int amount;
  final bool completed;

  Withdrawals({this.withdrawalid, this.date, this.amount, this.completed});
}
