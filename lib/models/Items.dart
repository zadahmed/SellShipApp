class Item {
  final String name;
  final String description;
  final int price;
  final String category;
  final String subcategory;
  final String subsubcategory;
  final String userid;
  final String username;
  final double latitude;
  final double longitude;
  final String phonenumber;
  final String city;

  Item(
      this.name,
      this.description,
      this.phonenumber,
      this.price,
      this.category,
      this.subcategory,
      this.subsubcategory,
      this.userid,
      this.username,
      this.latitude,
      this.city,
      this.longitude);

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'subcategory': subcategory,
        'subsubcategory': subsubcategory,
        'userid': userid,
        'username': username,
        'latitude': latitude,
        'longitude': longitude,
        'phonenumber': phonenumber,
        'city': city
      };
}
