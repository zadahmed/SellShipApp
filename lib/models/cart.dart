import 'package:flutter/cupertino.dart';
import 'package:sellship/global.dart';

class CartBloc with ChangeNotifier {
  List<Product> _cart = [];
  List<Product> get cart => _cart;

  void addCart(Product value) {
    cart.add(value);
    notifyListeners();
  }
}
