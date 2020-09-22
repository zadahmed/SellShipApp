import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Color bgColor = Colors.amber;

class Categories {
  final String title;
  final int id;
  final IconData icon;
  final String image;
  final List<SubCategories> subCat;

  Categories({this.title, this.id, this.subCat, this.icon, this.image});
}

class SubCategories {
  final String title;
  final int id;
  final String image;

  SubCategories({this.title, this.id, this.image});
}

List<Categories> categories = [
  Categories(
    title: 'Electronics',
    id: 0,
    icon: Feather.tv,
    image: 'assets/category/Electronics@3x.png',
    subCat: [
      SubCategories(
          id: 0,
          title: 'Phones & Accessories',
          image: 'assets/electronics/phone.jpg'),
      SubCategories(
          id: 1, title: 'Gaming', image: 'assets/electronics/gaming.jpg'),
      SubCategories(
          id: 2,
          title: 'Cameras & Photography',
          image: 'assets/electronics/camera.jpg'),
      SubCategories(
          id: 3, title: 'TV & Video', image: 'assets/electronics/tv.jpeg'),
      SubCategories(
          id: 4,
          title: 'Computers,PCs & Laptops',
          image: 'assets/electronics/laptop.jpeg'),
      SubCategories(
          id: 5,
          title: 'Headphones & Mp3 Players',
          image: 'assets/electronics/headphones.jpeg'),
      SubCategories(
          id: 6,
          title: 'Sound & Audio',
          image: 'assets/electronics/speakers.jpg'),
      SubCategories(
          id: 7,
          title: 'Tablets & eReaders',
          image: 'assets/electronics/tablet.jpeg'),
      SubCategories(
          id: 8,
          title: 'Wearables',
          image: 'assets/electronics/applewatch.jpeg'),
    ],
  ),
  Categories(
    title: 'Women',
    id: 1,
    icon: Feather.shopping_bag,
    image: 'assets/category/Women@3x.png',
    subCat: [
      SubCategories(
          id: 0,
          title: 'Activewear & Sportswear',
          image: 'assets/women/jumpsuit.jpeg'),
      SubCategories(
          id: 1, title: 'Jewelry', image: 'assets/women/jewelry.jpeg'),
      SubCategories(
          id: 2, title: 'Dresses', image: 'assets/women/dresses.jpeg'),
      SubCategories(
          id: 3, title: 'Tops & Blouses', image: 'assets/women/tops.jpeg'),
      SubCategories(
          id: 4, title: 'Coats & Jackets', image: 'assets/women/jackets.jpeg'),
      SubCategories(
          id: 5, title: 'Sweaters', image: 'assets/women/hoodie.jpeg'),
      SubCategories(id: 6, title: 'Handbags', image: 'assets/women/bags.jpeg'),
      SubCategories(id: 7, title: 'Shoes', image: 'assets/women/Heels.jpeg'),
      SubCategories(
          id: 8,
          title: 'Women\'s accessories',
          image: 'assets/women/watch.jpeg'),
      SubCategories(
          id: 9, title: 'Modest wear', image: 'assets/women/modest.jpeg'),
      SubCategories(id: 10, title: 'Jeans', image: 'assets/women/jeans.jpeg'),
      SubCategories(
          id: 11, title: 'Suits & Blazers', image: 'assets/women/suits.jpeg'),
      SubCategories(
          id: 12,
          title: 'Swimwear & Beachwear',
          image: 'assets/women/swimwear.jpeg'),
      SubCategories(
          id: 13, title: 'Bottoms', image: 'assets/women/shorts.jpeg'),
    ],
  ),
  Categories(
    title: 'Men',
    id: 2,
    icon: Feather.shopping_bag,
    image: 'assets/category/Man@3x.png',
    subCat: [
      SubCategories(
          id: 0,
          title: 'Activewear & Sportswear',
          image: 'assets/men/active.jpeg'),
      SubCategories(id: 1, title: 'Tops', image: 'assets/men/shirt.jpeg'),
      SubCategories(id: 2, title: 'Shoes', image: 'assets/men/shoes.jpeg'),
      SubCategories(
          id: 3, title: 'Coats & Jackets', image: 'assets/men/coats.jpeg'),
      SubCategories(id: 4, title: 'Bottoms', image: 'assets/men/pants.jpeg'),
      SubCategories(
          id: 5,
          title: 'Nightwear & Loungewear',
          image: 'assets/men/nightwear.jpeg'),
      SubCategories(
          id: 6,
          title: 'Hoodies & Sweatshirts',
          image: 'assets/men/hoodie.jpeg'),
      SubCategories(id: 7, title: 'Jeans', image: 'assets/men/jeans.jpeg'),
      SubCategories(
          id: 8,
          title: 'Swimwear & Beachwear',
          image: 'assets/men/swimshorts.jpeg'),
    ],
  ),
  Categories(
    title: 'Toys',
    id: 3,
    icon: Feather.shopping_bag,
    image: 'assets/category/Toys@3x.png',
    subCat: [
      SubCategories(
          id: 0,
          title: 'Collectibles & Hobbies',
          image: 'assets/toys/collectibles.jpg'),
      SubCategories(
          id: 1,
          title: 'Action Figures & Accessories',
          image: 'assets/toys/actionfigures.jpeg'),
      SubCategories(
          id: 2,
          title: 'Dolls & Accessories',
          image: 'assets/toys/barbie.jpeg'),
      SubCategories(
          id: 3,
          title: 'Vintage & Antique Toys',
          image: 'assets/toys/antiquetoys.png'),
      SubCategories(
          id: 4, title: 'Trading Cards', image: 'assets/toys/cards.jpg'),
      SubCategories(
          id: 5,
          title: 'Stuffed Animals',
          image: 'assets/toys/stuffedanimals.jpg'),
      SubCategories(
          id: 6, title: 'Building Toys', image: 'assets/toys/buildingtoys.jpg'),
      SubCategories(
          id: 7, title: 'Arts & Crafts', image: 'assets/toys/artscrafts.jpg'),
      SubCategories(
          id: 8, title: 'Games & Puzzles', image: 'assets/toys/puzzles.jpeg'),
      SubCategories(
          id: 9,
          title: 'Remote Control Toys',
          image: 'assets/toys/remotecontrol.jpg'),
    ],
  ),
  Categories(
    title: 'Beauty',
    id: 4,
    icon: Feather.eye,
    image: 'assets/category/Beauty@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: "Fragrance", image: 'assets/beauty/fragrance.jpeg'),
      SubCategories(id: 1, title: "Makeup", image: 'assets/beauty/makeup.jpg'),
      SubCategories(
          id: 2, title: "Haircare", image: 'assets/beauty/haircare.png'),
      SubCategories(
          id: 3, title: "Skincare", image: 'assets/beauty/skincare.jpg'),
      SubCategories(
          id: 4,
          title: "Tools and Accessories",
          image: 'assets/beauty/tools.jpeg'),
      SubCategories(
          id: 5,
          title: 'Bath and Body',
          image: 'assets/beauty/bathandbody.jpg'),
    ],
  ),
  Categories(
    title: 'Home',
    id: 5,
    icon: Feather.home,
    image: 'assets/category/Home@3x.png',
    subCat: [
      SubCategories(id: 0, title: "Bath", image: 'assets/home/bath.jpeg'),
      SubCategories(
          id: 1, title: "Home Decor", image: 'assets/home/homedecor.jpeg'),
      SubCategories(
          id: 2, title: "Kitchen and Dining", image: 'assets/home/dining.jpeg'),
      SubCategories(
          id: 3,
          title: 'Storage and Organization',
          image: 'assets/home/organizer.jpeg'),
      SubCategories(
          id: 4, title: "Furniture", image: 'assets/home/furniture.jpeg'),
      SubCategories(
          id: 5,
          title: 'Cleaning Supplies',
          image: 'assets/home/cleaningsupplies.jpg'),
      SubCategories(id: 6, title: 'Artwork', image: 'assets/home/artwork.jpg'),
      SubCategories(
          id: 7,
          title: 'Home Appliances',
          image: 'assets/electronics/homeappliances.jpeg'),
    ],
  ),
  Categories(
    title: 'Kids',
    id: 6,
    image: 'assets/category/Toys@3x.png',
    icon: FontAwesomeIcons.babyCarriage,
    subCat: [
      SubCategories(
          id: 0, title: 'Girls Dresses', image: 'assets/baby/toy.jpeg'),
      SubCategories(
          id: 1, title: 'Girls One-pieces', image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 2,
          title: 'Girls Tops & T-shirts',
          image: 'assets/baby/milk.jpeg'),
      SubCategories(
          id: 3, title: 'Girls Bottoms', image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 4, title: 'Girls Shoes', image: 'assets/baby/clothes.jpeg'),
      SubCategories(
          id: 5, title: 'Girls Accessories', image: 'assets/baby/book.jpeg'),
      SubCategories(
          id: 6, title: 'Boys Tops & T-shirts', image: 'assets/baby/toy.jpeg'),
      SubCategories(
          id: 7, title: 'Boys Bottoms', image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 8, title: 'Boys One-pieces', image: 'assets/baby/milk.jpeg'),
      SubCategories(
          id: 9, title: 'Boys Accessories', image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 10, title: 'Boys Shoes', image: 'assets/baby/clothes.jpeg'),
    ],
  ),
  Categories(
    title: 'Sport & Leisure',
    id: 7,
    image: 'assets/category/Sports@3x.png',
    icon: FontAwesomeIcons.footballBall,
    subCat: [
      SubCategories(
          id: 0, title: 'Outdoors', image: 'assets/sport/campng.jpeg'),
      SubCategories(id: 1, title: 'Exercise', image: 'assets/sport/cycle.jpeg'),
      SubCategories(
          id: 2, title: 'Fan Shop', image: 'assets/sport/scooter.jpeg'),
      SubCategories(
          id: 3, title: 'Team Sports', image: 'assets/sport/gym.jpeg'),
      SubCategories(id: 4, title: 'Apparel', image: 'assets/sport/equipm.jpeg'),
      SubCategories(
          id: 5, title: 'Footwear', image: 'assets/sport/watersport.jpeg'),
    ],
  ),
  Categories(
    title: 'Books',
    id: 8,
    image: 'assets/category/Book@3x.png',
    icon: Feather.book_open,
    subCat: [
      SubCategories(
          id: 0, title: "Childrens books", image: 'assets/books/kids.jpeg'),
      SubCategories(
          id: 1, title: "Fiction books", image: 'assets/books/fiction.jpeg'),
      SubCategories(id: 2, title: "Comics", image: 'assets/books/comic.jpeg'),
      SubCategories(
          id: 3,
          title: "Non Fiction Books",
          image: 'assets/books/cooking.jpeg'),
      SubCategories(
          id: 4, title: 'Crime Books', image: 'assets/books/education.jpeg'),
      SubCategories(
          id: 5,
          title: 'Sci-fi & Fantasy Books',
          image: 'assets/books/language.jpeg'),
    ],
  ),
  Categories(
    title: 'Motors',
    id: 9,
    icon: FontAwesomeIcons.car,
    image: 'assets/category/Motors@3x.png',
    subCat: [
      SubCategories(id: 0, title: "Used Cars", image: 'assets/motor/car.jpeg'),
      SubCategories(
          id: 1,
          title: "Motorcycles & Scooters",
          image: 'assets/motor/motorcycle.jpeg'),
      SubCategories(
          id: 2, title: "Heavy vehicles", image: 'assets/motor/heavy.jpeg'),
      SubCategories(id: 3, title: "Boats", image: 'assets/motor/water.jpeg'),
      SubCategories(id: 4, title: "Other", image: 'assets/motor/tech.jpeg'),
    ],
  ),
  Categories(
    title: 'Property',
    id: 10,
    icon: FontAwesomeIcons.building,
    image: 'assets/category/Home@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: "Sale", image: 'assets/property/forsalehouse.jpeg'),
      SubCategories(
          id: 1, title: "Rent", image: 'assets/property/forrenthouse.jpeg'),
    ],
  ),
  Categories(
    title: 'Vintage',
    id: 11,
    icon: Icons.lightbulb_outline,
    image: 'assets/category/Vintage@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: "Bags & Purses", image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 1, title: "Antiques", image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 2, title: 'Jewelry', image: 'assets/property/other.jpeg'),
      SubCategories(id: 3, title: 'Books', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 4, title: 'Electronics', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 5, title: 'Accessories', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 6, title: 'Serving Pieces', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 7, title: 'Supplies', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 8, title: 'Clothing', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 9, title: 'Houseware', image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Luxury',
    id: 12,
    icon: Icons.lightbulb_outline,
    image: 'assets/category/Luxury@3x.png',
    subCat: [
      SubCategories(id: 0, title: 'Bags', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 1, title: 'Clothing', image: 'assets/property/other.jpeg'),
      SubCategories(id: 2, title: 'Home', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 3, title: 'Accessories', image: 'assets/property/other.jpeg'),
      SubCategories(id: 4, title: 'Shoes', image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Garden',
    id: 13,
    icon: Icons.lightbulb_outline,
    image: 'assets/category/Garden@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: 'Garden Plants', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 1,
          title: 'Pots and Garden Tools',
          image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 2,
          title: 'Artificial Plants',
          image: 'assets/property/other.jpeg'),
      SubCategories(id: 3, title: 'Other', image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Handmade',
    id: 14,
    icon: Icons.lightbulb_outline,
    image: 'assets/category/Handmade@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: 'Accessories', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 1, title: 'Paper Goods', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 2, title: 'Clothing', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 3, title: 'Bags & Purses', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 4, title: 'Jewelry', image: 'assets/property/other.jpeg'),
      SubCategories(id: 5, title: 'Music', image: 'assets/property/other.jpeg'),
      SubCategories(id: 6, title: 'Art', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 7, title: 'Weddings', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 8, title: 'Children', image: 'assets/property/other.jpeg'),
      SubCategories(id: 9, title: 'Gifts', image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Other',
    id: 15,
    icon: Icons.lightbulb_outline,
    image: 'assets/category/Info@3x.png',
    subCat: [
      SubCategories(
          id: 0, title: 'Office Supplies', image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 1,
          title: 'Daily & Travel Items',
          image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 2,
          title: 'Musical Instruments',
          image: 'assets/property/other.jpeg'),
      SubCategories(
          id: 3, title: 'Pet Supplies', image: 'assets/property/other.jpeg'),
    ],
  ),
];
