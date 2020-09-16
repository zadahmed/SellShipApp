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
    image: 'assets/categories/tv.png',
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
          title: 'Computer accessories',
          image: 'assets/electronics/computeraccessories.jpg'),
      SubCategories(
          id: 6, title: 'Drones', image: 'assets/electronics/drones.jpeg'),
      SubCategories(
          id: 7,
          title: 'Home Appliances',
          image: 'assets/electronics/homeappliances.jpeg'),
      SubCategories(
          id: 8,
          title: 'Sound & Audio',
          image: 'assets/electronics/headphones.jpeg'),
      SubCategories(
          id: 9,
          title: 'Tablets & eReaders',
          image: 'assets/electronics/tablet.jpeg'),
      SubCategories(
          id: 10,
          title: 'Wearables',
          image: 'assets/electronics/applewatch.jpeg'),
      SubCategories(
          id: 11,
          title: 'Virtual Reality',
          image: 'assets/electronics/vr.jpeg'),
    ],
  ),
  Categories(
    title: 'Women',
    id: 1,
    icon: Feather.shopping_bag,
    image: 'assets/categories/beach-shirt.png',
    subCat: [
      SubCategories(id: 0, title: "Women", image: 'assets/fashion/women.jpeg'),
      SubCategories(id: 1, title: "Men", image: 'assets/fashion/men.jpg'),
      SubCategories(id: 2, title: "Girls", image: 'assets/fashion/girl.jpeg'),
      SubCategories(id: 3, title: "Boys", image: 'assets/fashion/boys.jpg'),
      SubCategories(id: 4, title: "Unisex", image: 'assets/fashion/unisex.jpg'),
    ],
  ),
  Categories(
    title: 'Men',
    id: 2,
    icon: Feather.shopping_bag,
    image: 'assets/categories/beach-shirt.png',
    subCat: [
      SubCategories(id: 0, title: "Women", image: 'assets/fashion/women.jpeg'),
      SubCategories(id: 1, title: "Men", image: 'assets/fashion/men.jpg'),
      SubCategories(id: 2, title: "Girls", image: 'assets/fashion/girl.jpeg'),
      SubCategories(id: 3, title: "Boys", image: 'assets/fashion/boys.jpg'),
      SubCategories(id: 4, title: "Unisex", image: 'assets/fashion/unisex.jpg'),
    ],
  ),
  Categories(
    title: 'Toys',
    id: 3,
    icon: Feather.shopping_bag,
    image: 'assets/categories/beach-shirt.png',
    subCat: [
      SubCategories(id: 0, title: "Women", image: 'assets/fashion/women.jpeg'),
      SubCategories(id: 1, title: "Men", image: 'assets/fashion/men.jpg'),
      SubCategories(id: 2, title: "Girls", image: 'assets/fashion/girl.jpeg'),
      SubCategories(id: 3, title: "Boys", image: 'assets/fashion/boys.jpg'),
      SubCategories(id: 4, title: "Unisex", image: 'assets/fashion/unisex.jpg'),
    ],
  ),
  Categories(
    title: 'Beauty',
    id: 4,
    icon: Feather.eye,
    image: 'assets/categories/804.png',
    subCat: [
      SubCategories(
          id: 0, title: "Fragrance", image: 'assets/beauty/fragrance.jpeg'),
      SubCategories(
          id: 1,
          title: "Perfume for men",
          image: 'assets/beauty/perfumemen.jpeg'),
      SubCategories(
          id: 2,
          title: "Perfume for women",
          image: 'assets/beauty/perfumewomen.jpeg'),
      SubCategories(id: 3, title: "Makeup", image: 'assets/beauty/makeup.jpg'),
      SubCategories(
          id: 4, title: "Haircare", image: 'assets/beauty/haircare.png'),
      SubCategories(
          id: 5, title: "Skincare", image: 'assets/beauty/skincare.jpg'),
      SubCategories(
          id: 6,
          title: "Tools and Accessories",
          image: 'assets/beauty/tools.jpeg'),
      SubCategories(
          id: 7,
          title: "Mens grooming",
          image: 'assets/beauty/mengrooming.jpeg'),
      SubCategories(
          id: 8, title: "Gift sets", image: 'assets/beauty/giftset.jpeg'),
    ],
  ),
  Categories(
    title: 'Home',
    id: 5,
    icon: Feather.home,
    image: 'assets/categories/cabinet.png',
    subCat: [
      SubCategories(id: 0, title: "Bedding", image: 'assets/home/bedding.jpeg'),
      SubCategories(id: 1, title: "Bath", image: 'assets/home/bath.jpeg'),
      SubCategories(
          id: 2, title: "Home Decor", image: 'assets/home/homedecor.jpeg'),
      SubCategories(
          id: 3, title: "Kitchen and Dining", image: 'assets/home/dining.jpeg'),
      SubCategories(
          id: 4,
          title: "Home storage & organization",
          image: 'assets/home/organizer.jpeg'),
      SubCategories(
          id: 5, title: "Furniture", image: 'assets/home/furniture.jpeg'),
      SubCategories(
          id: 6, title: "Garden & outdoor", image: 'assets/home/garden.jpeg'),
      SubCategories(
          id: 7, title: "Lamps & Lighting", image: 'assets/home/lamp.jpeg'),
      SubCategories(
          id: 8,
          title: "Tools & Home improvement",
          image: 'assets/home/tools.jpeg'),
    ],
  ),
  Categories(
    title: 'Kids',
    id: 6,
    image: 'assets/categories/baby-sock.png',
    icon: FontAwesomeIcons.babyCarriage,
    subCat: [
      SubCategories(id: 0, title: "Kids toys", image: 'assets/baby/toy.jpeg'),
      SubCategories(
          id: 1, title: "Baby transport", image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 2, title: "Nursing and feeding", image: 'assets/baby/milk.jpeg'),
      SubCategories(
          id: 3,
          title: "Bathing & Baby care",
          image: 'assets/baby/accesso.jpeg'),
      SubCategories(
          id: 4,
          title: "Baby clothing & shoes",
          image: 'assets/baby/clothes.jpeg'),
      SubCategories(
          id: 5, title: "Parenting Books", image: 'assets/baby/book.jpeg'),
    ],
  ),
  Categories(
    title: 'Sports',
    id: 7,
    image: 'assets/categories/basketball.png',
    icon: FontAwesomeIcons.footballBall,
    subCat: [
      SubCategories(
          id: 0, title: "Camping & Hiking", image: 'assets/sport/campng.jpeg'),
      SubCategories(id: 1, title: "Cycling", image: 'assets/sport/cycle.jpeg'),
      SubCategories(
          id: 2,
          title: "Scooters & accessories",
          image: 'assets/sport/scooter.jpeg'),
      SubCategories(
          id: 3, title: "Strength & weights", image: 'assets/sport/gym.jpeg'),
      SubCategories(id: 4, title: "Yoga", image: 'assets/sport/yoga.jpeg'),
      SubCategories(
          id: 5, title: "Cardio equipment", image: 'assets/sport/equipm.jpeg'),
      SubCategories(
          id: 6, title: "Water sports", image: 'assets/sport/watersport.jpeg'),
      SubCategories(
          id: 7, title: "Raquet sports", image: 'assets/sport/raquet.jpeg'),
      SubCategories(id: 8, title: "Boxing", image: 'assets/sport/boxing.jpeg'),
      SubCategories(id: 9, title: "Other", image: 'assets/sport/raquet.jpeg'),
    ],
  ),
  Categories(
    title: 'Books',
    id: 8,
    image: 'assets/categories/books.png',
    icon: Feather.book_open,
    subCat: [
      SubCategories(
          id: 0, title: "Childrens books", image: 'assets/books/kids.jpeg'),
      SubCategories(
          id: 1, title: "Fiction books", image: 'assets/books/fiction.jpeg'),
      SubCategories(id: 2, title: "Comics", image: 'assets/books/comic.jpeg'),
      SubCategories(id: 3, title: "Sports", image: 'assets/books/non.jpeg'),
      SubCategories(
          id: 4, title: "Science", image: 'assets/books/science.jpeg'),
      SubCategories(
          id: 5,
          title: "Diet, Health & Fitness",
          image: 'assets/books/diet.jpeg'),
      SubCategories(
          id: 6,
          title: "Business & Finance",
          image: 'assets/books/business.jpeg'),
      SubCategories(
          id: 7,
          title: "Biogpraphy & Autobiography",
          image: 'assets/books/bio.jpeg'),
      SubCategories(
          id: 8, title: "Crime & Mystery", image: 'assets/books/crime.jpeg'),
      SubCategories(
          id: 9, title: "History", image: 'assets/books/hisstory.jpeg'),
      SubCategories(
          id: 10,
          title: "Cook Books & Food",
          image: 'assets/books/cooking.jpeg'),
      SubCategories(
          id: 11, title: "Education", image: 'assets/books/education.jpeg'),
      SubCategories(
          id: 12,
          title: "Foreign Language Study",
          image: 'assets/books/language.jpeg'),
      SubCategories(id: 13, title: "Travel", image: 'assets/books/travel.jpeg'),
      SubCategories(
          id: 14, title: "Magazine", image: 'assets/books/magazin.jpeg'),
      SubCategories(id: 15, title: "Other", image: 'assets/books/kids.jpeg'),
    ],
  ),
  Categories(
    title: 'Motors',
    id: 9,
    icon: FontAwesomeIcons.car,
    image: 'assets/categories/car.png',
    subCat: [
      SubCategories(id: 0, title: "Used Cars", image: 'assets/motor/car.jpeg'),
      SubCategories(
          id: 1,
          title: "Motorcycles & Scooters",
          image: 'assets/motor/motorcycle.jpeg'),
      SubCategories(
          id: 2, title: "Heavy vehicles", image: 'assets/motor/heavy.jpeg'),
      SubCategories(id: 3, title: "Boats", image: 'assets/motor/water.jpeg'),
      SubCategories(
          id: 4, title: "Number plates", image: 'assets/motor/plate.jpeg'),
      SubCategories(
          id: 5, title: "Auto accessories", image: 'assets/motor/access.jpeg'),
      SubCategories(
          id: 6, title: "Car Technology", image: 'assets/motor/tech.jpeg'),
    ],
  ),
  Categories(
    title: 'Property',
    id: 10,
    icon: FontAwesomeIcons.building,
    image: 'assets/categories/house.png',
    subCat: [
      SubCategories(
          id: 0,
          title: "For Sale - Houses & Apartment",
          image: 'assets/property/forsalehouse.jpeg'),
      SubCategories(
          id: 1,
          title: "For Rent - Houses & Apartment",
          image: 'assets/property/forrenthouse.jpeg'),
      SubCategories(
          id: 2,
          title: "For Rent - Shops & Offices",
          image: 'assets/property/building.jpeg'),
      SubCategories(
          id: 3, title: "Guest Houses", image: 'assets/property/forrent1.jpeg'),
    ],
  ),
  Categories(
    title: 'Vintage',
    id: 11,
    icon: Icons.lightbulb_outline,
    image: 'assets/categories/tv.png',
    subCat: [
      SubCategories(id: 0, title: "Other", image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Luxury',
    id: 12,
    icon: Icons.lightbulb_outline,
    image: 'assets/categories/tv.png',
    subCat: [
      SubCategories(id: 0, title: "Other", image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Garden',
    id: 13,
    icon: Icons.lightbulb_outline,
    image: 'assets/categories/tv.png',
    subCat: [
      SubCategories(id: 0, title: "Other", image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Handmade',
    id: 14,
    icon: Icons.lightbulb_outline,
    image: 'assets/categories/tv.png',
    subCat: [
      SubCategories(id: 0, title: "Other", image: 'assets/property/other.jpeg'),
    ],
  ),
  Categories(
    title: 'Other',
    id: 15,
    icon: Icons.lightbulb_outline,
    image: 'assets/categories/tv.png',
    subCat: [
      SubCategories(id: 0, title: "Other", image: 'assets/property/other.jpeg'),
    ],
  ),
];
