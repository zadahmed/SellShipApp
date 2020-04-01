import 'package:flutter/material.dart';

Color bgColor = Color(0xfff5f5f5);

List<String> homeHero = [
  "https://images.unsplash.com/photo-1502123909989-c9d05c43046a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjF9&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1572435230185-33504bec96c2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=334&q=80",
  "https://images.unsplash.com/photo-1528384483229-b4a97480dbea?ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
  "https://www.kindpng.com/picc/m/5-55436_transparent-cartoon-shoes-png-vans-old-skool-zwart.png",
];

class Product {
  final String mainImage;
  final List<String> images;
  final List<String> tags;
  final List<Color> colors;
  final List<int> size;
  final String title;
  final String price;
  final double rating;
  Product({
    this.rating,
    this.price,
    this.mainImage,
    this.images,
    this.tags,
    this.colors,
    this.size,
    this.title,
  });
}

List<Product> products = [
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://demo.woothemes.com/woocommerce/wp-content/uploads/sites/56/2013/06/cd_5_flat.jpg',
      'http://demo.woothemes.com/woocommerce/wp-content/uploads/sites/56/2013/06/cd_3_angle.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://demo.woothemes.com/woocommerce/wp-content/uploads/sites/56/2013/06/cd_3_angle.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'https://www.stickpng.com/assets/images/580b57fbd9996e24bc43bf85.png',
      'https://img.favpng.com/23/4/0/tote-bag-red-leather-handbag-png-favpng-ki0rQC3dTsbB0fdQT3WvmvxrU.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'https://www.stickpng.com/assets/images/580b57fbd9996e24bc43bf85.png',
      'https://img.favpng.com/23/4/0/tote-bag-red-leather-handbag-png-favpng-ki0rQC3dTsbB0fdQT3WvmvxrU.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'https://www.stickpng.com/assets/images/580b57fbd9996e24bc43bf85.png',
      'https://img.favpng.com/23/4/0/tote-bag-red-leather-handbag-png-favpng-ki0rQC3dTsbB0fdQT3WvmvxrU.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'https://www.stickpng.com/assets/images/580b57fbd9996e24bc43bf85.png',
      'https://img.favpng.com/23/4/0/tote-bag-red-leather-handbag-png-favpng-ki0rQC3dTsbB0fdQT3WvmvxrU.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Hand Bag",
    price: "USD. 400.00",
    images: [
      'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'https://www.stickpng.com/assets/images/580b57fbd9996e24bc43bf85.png',
      'https://img.favpng.com/23/4/0/tote-bag-red-leather-handbag-png-favpng-ki0rQC3dTsbB0fdQT3WvmvxrU.jpg',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Bag', 'HandBag', 'Price', 'Quality'],
    rating: 3.5,
  ),
  Product(
    title: "Adidas Superstar",
    price: "USD. 59.00",
    images: [
      'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
      'https://www.transparentpng.com/thumb/adidas-shoes/a4xO3G-adidas-shoes-adidas-shoe-kids-superstar-daddy-grade.png',
      'https://www.jing.fm/clipimg/full/35-352776_adidas-shoes-clipart-picsart-png-shoes-png-for.png',
    ],
    colors: [Colors.black, Colors.red, Colors.yellow],
    mainImage: 'http://www.miss-blog.fr/media/import/Images/adida%20superstar-896uqv.jpg',
    size: [1,2,3,4,5,6,7,8,9],
    tags: ['Product', 'Shoe', 'Adidas', 'Price', 'Quality'],
    rating: 3.5,
  ),
];



class Categories {
  final String title;
  final int id;
  final List<SubCategories> subCat;

  Categories({this.title, this.id, this.subCat});
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
    subCat: [
      SubCategories(id: 0, title: 'Phones'),
      SubCategories(id: 1, title: 'Laptops'),
      SubCategories(id: 2, title: 'Drones'),
      SubCategories(id: 3, title: 'Graphics Cards'),
      SubCategories(id: 4, title: 'CPU'),
      SubCategories(id: 5, title: 'Motherboard'),
    ],
  ),
  Categories(
    title: 'Shoes',
    id: 1,
    subCat: [
      SubCategories(id: 0, title: "OXFORD"),
      SubCategories(id: 1, title: "DERBY"),
      SubCategories(id: 2, title: "MEN’S BOOTS"),
      SubCategories(id: 3, title: "MOCCASIN"),
      SubCategories(id: 4, title: "LOAFER"),
      SubCategories(id: 5, title: "BLUCHER"),
      SubCategories(id: 6, title: "BOAT SHOE"),
      SubCategories(id: 7, title: "MONK"),
      SubCategories(id: 8, title: "STRAP"),
      SubCategories(id: 9, title: "BUDAPESTER"),
      SubCategories(id: 10, title: "BUCKLED SHOES"),
      SubCategories(id: 11, title: "LACE-UP SHOES"),
      SubCategories(id: 12, title: "SLIP-ON SHOES"),
    ],
  ),
  Categories(
    title: 'Cloths',
    id: 2,
    subCat: [
      SubCategories(id: 0, title: "Jackets and coats"),
      SubCategories(id: 1, title: "Trousers and shorts"),
      SubCategories(id: 2, title: "Underwear"),
      SubCategories(id: 3, title: "Suits"),
      SubCategories(id: 4, title: "Skirts and dresses"),
      SubCategories(id: 5, title: "Sweaters and waistcoats"),
    ],
  ),
  Categories(
    title: 'Home',
    id: 3,
    subCat: [
      SubCategories(id: 0, title: "Microwave oven"),
      SubCategories(id: 1, title: "Stacked washing machine \& clothes dryer"),
      SubCategories(id: 2, title: "Gas fireplace"),
      SubCategories(id: 3, title: "Refrigerators"),
      SubCategories(id: 4, title: "Vacuum cleaner"),
      SubCategories(id: 5, title: "Electric water heater tank"),
      SubCategories(id: 6, title: "Small twin window fan"),
    ],
  ),
];



