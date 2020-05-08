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
    image: 'assets/tv.jpg',
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
    title: 'Fashion & Accessories',
    id: 1,
    icon: Feather.shopping_bag,
    image: 'assets/couple.jpeg',
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
    id: 2,
    icon: Feather.eye,
    image: 'assets/couple.jpeg',
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
    title: 'Home & Garden',
    id: 3,
    icon: Feather.home,
    image: 'assets/home.jpg',
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
    title: 'Baby & Child',
    id: 4,
    image: 'assets/baby.png',
    icon: FontAwesomeIcons.babyCarriage,
    subCat: [
      SubCategories(id: 0, title: "Kids toys"),
      SubCategories(id: 1, title: "Baby transport"),
      SubCategories(id: 2, title: "Nursing and feeding"),
      SubCategories(id: 3, title: "Bathing & Baby care"),
      SubCategories(id: 4, title: "Baby clothing & shoes"),
      SubCategories(id: 5, title: "Parenting Books"),
    ],
  ),
  Categories(
    title: 'Sport & Leisure',
    id: 5,
    image: 'assets/sport.jpeg',
    icon: FontAwesomeIcons.footballBall,
    subCat: [
      SubCategories(id: 0, title: "Camping & Hiking"),
      SubCategories(id: 1, title: "Cycling"),
      SubCategories(id: 2, title: "Scooters & accessories"),
      SubCategories(id: 3, title: "Strength & weights"),
      SubCategories(id: 4, title: "Yoga"),
      SubCategories(id: 5, title: "Cardio equipment"),
      SubCategories(id: 6, title: "Water sports"),
      SubCategories(id: 7, title: "Raquet sports"),
      SubCategories(id: 8, title: "Boxing"),
      SubCategories(id: 9, title: "Other"),
    ],
  ),
  Categories(
    title: 'Books',
    id: 6,
    image: 'assets/books.jpeg',
    icon: Feather.book_open,
    subCat: [
      SubCategories(id: 0, title: "Childrens books"),
      SubCategories(id: 1, title: "Fiction books"),
      SubCategories(id: 2, title: "Comics"),
      SubCategories(id: 3, title: "Sports"),
      SubCategories(id: 4, title: "Science"),
      SubCategories(id: 5, title: "Diet, Health & Fitness"),
      SubCategories(id: 6, title: "Business & Finance"),
      SubCategories(id: 7, title: "Biogpraphy & Autobiography"),
      SubCategories(id: 8, title: "Crime & Mystery"),
      SubCategories(id: 9, title: "History"),
      SubCategories(id: 10, title: "Cook Books & Food"),
      SubCategories(id: 11, title: "Education"),
      SubCategories(id: 12, title: "Foreign Language Study"),
      SubCategories(id: 13, title: "Travel"),
      SubCategories(id: 14, title: "Magazine"),
      SubCategories(id: 15, title: "Other"),
    ],
  ),
  Categories(
    title: 'Motors',
    id: 7,
    icon: FontAwesomeIcons.car,
    image: 'assets/car.jpg',
    subCat: [
      SubCategories(id: 0, title: "Used Cars"),
      SubCategories(id: 1, title: "Motorcycles & Scooters"),
      SubCategories(id: 2, title: "Heavy vehicles"),
      SubCategories(id: 3, title: "Boats"),
      SubCategories(id: 4, title: "Number plates"),
      SubCategories(id: 5, title: "Auto accessories"),
      SubCategories(id: 6, title: "Car Technology"),
    ],
  ),
  Categories(
    title: 'Property',
    id: 8,
    icon: FontAwesomeIcons.building,
    image: 'assets/home.jpg',
    subCat: [
      SubCategories(id: 0, title: "For Sale - Houses & Apartment"),
      SubCategories(id: 1, title: "For Rent - Houses & Apartment"),
      SubCategories(id: 2, title: "For Rent - Shops & Offices"),
      SubCategories(id: 3, title: "Guest Houses"),
    ],
  ),
  Categories(
    title: 'Other',
    id: 10,
    icon: Icons.lightbulb_outline,
    image: 'assets/tv.jpeg',
    subCat: [
      SubCategories(id: 0, title: "Other"),
    ],
  ),
];
