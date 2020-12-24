import 'package:SellShip/models/databaseFields.dart';

class User {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;
  String fcmToken;

  User(
      {this.firstName,
      this.lastName,
      this.phoneNumber,
      this.email,
      this.password,
      this.fcmToken});

  User.fromDB({Map<String, dynamic> dbSnapshot}) {
    firstName = dbSnapshot[UserFields.firstName];
    lastName = dbSnapshot[UserFields.lastName];
    email = dbSnapshot[UserFields.email];
    phoneNumber = dbSnapshot[UserFields.phoneNumber];
    password = dbSnapshot[UserFields.password];
    fcmToken = dbSnapshot[UserFields.fcmtoken];
  }

  Map<String, dynamic> toMap() {
    return {
      UserFields.firstName: firstName,
      UserFields.lastName: lastName,
      UserFields.phoneNumber: phoneNumber,
      UserFields.email: email,
      UserFields.password: password,
      UserFields.fcmtoken: fcmToken
    };
  }
}
