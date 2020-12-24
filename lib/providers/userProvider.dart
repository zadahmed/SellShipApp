import 'dart:convert';

import 'package:SellShip/models/databaseFields.dart';
import 'package:SellShip/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

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
      String fcmtoken,
      Function onSuccess,
      Function onUserAlreadyExist,
      Function onError}) async {
    User newUser = User(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        fcmToken: fcmtoken);

    currentUser = newUser;
    print("userMap: ${newUser.toMap()}");
    Response response = await http.post(_signUpURL, body: newUser.toMap());
    print("status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);

      if (jsondata[UserFields.id] != null) {
        // currentUser.id = jsondata[UserFields.id];
        await _storage.write(key: 'userid', value: jsondata['id']);

        /// handle UI Events on callbacks
        onSuccess();
      } else {
        print("user exists");
        onUserAlreadyExist();
      }
    } else {
      onError();
    }
  }

// _getLocation() async {
//   Location _location = new Location();
//   var location;
//
//   try {
//     location = await _location.getLocation();
//     await storage.write(key: 'latitude', value: location.latitude.toString());
//     await storage.write(
//         key: 'longitude', value: location.longitude.toString());
//     var userid = await storage.read(key: 'userid');
//
//     await storage.write(
//         key: 'longitude', value: location.longitude.toString());
//     setState(() {
//       position =
//           LatLng(location.latitude.toDouble(), location.longitude.toDouble());
//       getcity();
//     });
//
//     var token = await FirebaseNotifications().getNotifications(context);
//     if (userid != null) {
//       print(token + "\n Token was recieved from firebase");
//       var url =
//           'https://api.sellship.co/api/checktokenfcm/' + userid + '/' + token;
//       print(url);
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         print(response.body);
//       } else {
//         print(response.statusCode);
//       }
//     }

}
