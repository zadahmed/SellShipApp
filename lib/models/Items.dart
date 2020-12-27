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
  int likes;
  final int comments;
  final String city;
  final String useremail;
  final String date;
  final String latitude;
  final String longitude;
  final String usernumber;
  final String condition;
  final String category;
  final String subcategory;
  final String subsubcategory;
  final double distance;
  final String brand;
  final int weight;
  final bool sold;
  final String size;
  final int views;
  final String orderstatus;

  Item(
      {this.itemid,
      this.name,
      this.views,
      this.image,
      this.image1,
      this.date,
      this.weight,
      this.image2,
      this.image3,
      this.orderstatus,
      this.image4,
      this.comments,
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

  int compareTo(Item other) {
    int order = other.date.compareTo(date);
    return order;
  }
}
