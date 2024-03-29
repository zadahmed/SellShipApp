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
  List tags;
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
  int quantity;
  final String weight;
  final bool sold;
  var size;
  final int views;
  final String orderstatus;
  final int offerstage;
  final String buyerid;
  final String sellerid;
  final String buyername;
  final String sellername;
  final String country;
  final String originalprice;
  final bool approved;
  final bool makeoffers;
  final bool buyerprotection;
  final bool freedelivery;
  String selectedsize;
  final String storetype;
  final String saleprice;

  Item(
      {this.itemid,
      this.name,
      this.saleprice,
      this.makeoffers,
      this.approved,
      this.buyerprotection,
      this.storetype,
      this.views,
      this.image,
      this.tags,
      this.originalprice,
      this.country,
      this.quantity,
      this.image1,
      this.date,
      this.weight,
      this.freedelivery,
      this.image2,
      this.selectedsize,
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
      freedelivery: json['freedelivery'],
      category: json['category'],
      weight: json['weight'],
      quantity: json['quantity'],
      saleprice: json['saleprice'],
      selectedsize: json['selectedsize'],
    );
  }

  Map toJson() => {
        'itemid': itemid,
        'name': name,
        'image': image,
        'userid': userid,
        'price': price,
        'username': username,
        'sellerid': sellerid,
        'freedelivery': freedelivery,
        'sellername': sellername,
        'quantity': quantity,
        'saleprice': saleprice,
        'weight': weight,
        'selectedsize': selectedsize,
      };

  int compareTo(Item other) {
    int order = other.date.compareTo(date);
    return order;
  }

  @override
  String getSuspensionTag() => itemid;

  // inside Item class
  @override
  bool operator ==(other) {
    return this.itemid == other.itemid;
  }

  @override
  int get hashCode => itemid.hashCode;
}
