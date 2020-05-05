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

  SubCategories({this.title, this.id});
}

List<Categories> categories = [
  Categories(
    title: 'Electronics',
    id: 0,
    icon: Feather.tv,
    image: 'assets/tv.jpg',
    subCat: [
      SubCategories(id: 0, title: 'Phones & Accessories'),
      SubCategories(id: 1, title: 'Gaming'),
      SubCategories(id: 2, title: 'Cameras & Photography'),
      SubCategories(id: 3, title: 'Car Technology'),
      SubCategories(id: 4, title: 'Computers,PCs & Laptops'),
      SubCategories(id: 5, title: 'Drones'),
      SubCategories(id: 6, title: 'Home Appliances'),
      SubCategories(id: 7, title: 'Smart Home & Security'),
      SubCategories(id: 8, title: 'Sound & Audio'),
      SubCategories(id: 9, title: 'Tablets & eReaders'),
      SubCategories(id: 10, title: 'TV & Video'),
      SubCategories(id: 11, title: 'Wearables'),
      SubCategories(id: 12, title: 'Virtual Reality'),
    ],
  ),
  Categories(
    title: 'Fashion & Accessories',
    id: 1,
    icon: Feather.shopping_bag,
    image: 'assets/couple.jpeg',
    subCat: [
      SubCategories(id: 0, title: "Women"),
      SubCategories(id: 1, title: "Men"),
      SubCategories(id: 2, title: "Girls"),
      SubCategories(id: 3, title: "Boys"),
      SubCategories(id: 4, title: "Unisex"),
    ],
  ),
  Categories(
    title: 'Home & Garden',
    id: 2,
    icon: Feather.home,
    image: 'assets/home.jpg',
    subCat: [
      SubCategories(id: 0, title: "Home & Garden"),
    ],
  ),
  Categories(
    title: 'Baby & Child',
    id: 3,
    image: 'assets/baby.png',
    icon: FontAwesomeIcons.babyCarriage,
    subCat: [
      SubCategories(id: 0, title: "Baby & Child"),
    ],
  ),
  Categories(
    title: 'Sport & Leisure',
    id: 4,
    image: 'assets/sport.jpeg',
    icon: FontAwesomeIcons.footballBall,
    subCat: [
      SubCategories(id: 0, title: "Sport & Leisure"),
    ],
  ),
  Categories(
    title: 'Movies, Books & Music',
    id: 5,
    image: 'assets/books.jpeg',
    icon: Feather.book_open,
    subCat: [
      SubCategories(id: 0, title: "Movies, Books & Music"),
    ],
  ),
  Categories(
    title: 'Motors',
    id: 6,
    icon: FontAwesomeIcons.car,
    image: 'assets/car.jpg',
    subCat: [
      SubCategories(id: 0, title: "Cars"),
      SubCategories(id: 1, title: "Motorcycles & Scooters"),
    ],
  ),
  Categories(
    title: 'Property',
    id: 7,
    icon: FontAwesomeIcons.building,
    image: 'assets/home.jpg',
    subCat: [
      SubCategories(id: 0, title: "Property for Sale"),
      SubCategories(id: 1, title: "Property for Rent"),
    ],
  ),
  Categories(
    title: 'Services',
    id: 8,
    icon: Feather.settings,
    image: 'assets/tv.jpg',
    subCat: [
      SubCategories(id: 0, title: "Services"),
    ],
  ),
  Categories(
    title: 'Other',
    id: 9,
    icon: Icons.lightbulb_outline,
    image: 'assets/tv.jpeg',
    subCat: [
      SubCategories(id: 0, title: "Other"),
    ],
  ),
];
