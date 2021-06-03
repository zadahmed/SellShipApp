import 'package:flutter/material.dart';

class Withdrawals {
  final String withdrawalid;
  final String date;
  final double amount;
  final bool completed;
  final String iban;

  Withdrawals(
      {this.withdrawalid, this.date, this.iban, this.amount, this.completed});
}
