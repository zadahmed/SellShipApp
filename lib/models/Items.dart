import 'dart:typed_data';

class Item {
  final String itemid;
  final String name;
  final String image;
  final String description;
  final String price;
  final String userid;
  final String username;
  final String useremail;
  final String latitude;
  final String longitude;
  final String usernumber;
  final String category;
  final String subcategory;
  final String subsubcategory;
  final double distance;

  Item(
      {this.itemid,
      this.name,
      this.image,
      this.description,
      this.username,
      this.useremail,
      this.usernumber,
      this.userid,
      this.latitude,
      this.longitude,
      this.price,
      this.category,
      this.subsubcategory,
      this.subcategory,
      this.distance});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemid: json['_id']['\$oid'],
      name: json['name'],
      image: json['image']['\$binary'],
      price: json['price'],
      category: json['category'],
      subcategory: json['subcategory'],
      subsubcategory: json['subsubcategory'],
      distance: json['distance'],
    );
  }
}
