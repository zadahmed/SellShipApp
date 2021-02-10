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
  final List<dynamic> tags;
  final String messageid;
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
  final int quantity;
  final String weight;
  final bool sold;
  final String size;
  final int views;
  final String orderstatus;
  final int offerstage;
  final String buyerid;
  final String sellerid;
  final String buyername;
  final String sellername;
  final String country;

  Item(
      {this.itemid,
      this.name,
      this.views,
      this.image,
      this.tags,
      this.country,
      this.quantity,
      this.image1,
      this.date,
      this.weight,
      this.image2,
      this.image3,
      this.offerstage,
      this.buyerid,
      this.sellerid,
      this.buyername,
      this.sellername,
      this.orderstatus,
      this.image4,
      this.messageid,
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
      itemid: json['itemid'],
      name: json['name'],
      image: json['image'],
      userid: json['userid'],
      price: json['price'],
      category: json['category'],
    );
  }

  Map toJson() => {
        'itemid': itemid,
        'name': name,
        'image': image,
        'userid': userid,
        'price': price,
        'username': username,
      };

  int compareTo(Item other) {
    int order = other.date.compareTo(date);
    return order;
  }

  // inside Item class
  @override
  bool operator ==(other) {
    return this.itemid == other.itemid;
  }

  @override
  int get hashCode => itemid.hashCode;
}
