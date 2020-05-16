class Item {
  final String itemid;
  final String name;
  final String image;
  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String image5;
  final String description;
  final String price;
  final String userid;
  final String username;
  final int likes;
  final String city;
  final String useremail;
  final String latitude;
  final String longitude;
  final String usernumber;
  final String condition;
  final String category;
  final String subcategory;
  final String subsubcategory;
  final double distance;
  final String brand;
  final bool sold;
  final String size;

  Item(
      {this.itemid,
      this.name,
      this.image,
      this.image1,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.likes,
      this.description,
      this.condition,
      this.username,
      this.city,
      this.useremail,
      this.usernumber,
      this.userid,
      this.latitude,
      this.longitude,
      this.price,
      this.category,
      this.subsubcategory,
      this.subcategory,
      this.brand,
      this.size,
      this.sold,
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
