import 'dart:convert';

import 'package:SellShip/models/databaseFields.dart';
import 'package:SellShip/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProvider {
  UserProvider() {
    // getUserData();
  }
  //class properties
  // for storing user defaults / userID ect..
  final _storage = new FlutterSecureStorage();
  final String _signUpURL = 'https://api.sellship.co/api/signup';
  User currentUser;

  /// This returns a HTTP Response that needs to be handled appropriately in the View.
  Future<void> signUpUser(
      {String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String password,
      Function onSuccess,
      Function onUserAlreadyExist,
      Function onError}) async {
    User newUser = User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    currentUser = newUser;
    print("userMap: ${newUser.toMap()}");
    Response response =
        await http.post(Uri.parse(_signUpURL), body: newUser.toMap());
    print("status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);

      if (jsondata[UserFields.id] != null) {
        // currentUser.id = jsondata[UserFields.id];
        await _storage.write(key: 'userid', value: jsondata['id']);

        onSuccess();
      } else {
        print("user exists");
        onUserAlreadyExist();
      }
    } else {
      onError();
    }
  }
}
