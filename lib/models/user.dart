import 'package:SellShip/models/databaseFields.dart';

class User {
  String userid;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;
  String profilepicture;
  String username;
  String productsnumber;

  User(
      {this.firstName,
      this.userid,
      this.lastName,
      this.phoneNumber,
      this.username,
      this.email,
      this.productsnumber,
      this.password,
      this.profilepicture});

  User.fromDB({Map<String, dynamic> dbSnapshot}) {
    firstName = dbSnapshot[UserFields.firstName];
    lastName = dbSnapshot[UserFields.lastName];
    email = dbSnapshot[UserFields.email];
    phoneNumber = dbSnapshot[UserFields.phoneNumber];
    password = dbSnapshot[UserFields.password];
  }

  Map<String, dynamic> toMap() {
    return {
      UserFields.firstName: firstName,
      UserFields.lastName: lastName,
      UserFields.phoneNumber: phoneNumber,
      UserFields.email: email,
      UserFields.password: password,
    };
  }

  int compareTo(User other) {
    int order = other.productsnumber.compareTo(productsnumber);
    return order;
  }

  @override
  bool operator ==(other) {
    return this.userid == other.userid;
  }

  @override
  int get hashCode => userid.hashCode;
}
