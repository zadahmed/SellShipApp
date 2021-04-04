import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddSubSubCategory extends StatefulWidget {
  final String category;
  final String subcategory;
  AddSubSubCategory({Key key, this.category, this.subcategory})
      : super(key: key);

  _AddSubSubCategoryState createState() => _AddSubSubCategoryState();
}

class _AddSubSubCategoryState extends State<AddSubSubCategory> {
  String category;

  @override
  void initState() {
    super.initState();

    setState(() {
      category = widget.category;
      subcategory = widget.subcategory;
    });
    loadsubcategory(widget.subcategory);
  }

  String subcategory;
  String subsubcategory;

  List<String> subcategories = List<String>();

  loadsubcategory(String subcategory) {
    if (category == 'Electronics') {
      if (subcategory == 'Phones & Accessories') {
        setState(() {
          subcategories = [
            'Batteries',
            'Cables & Adapters',
            'Cases, Covers & Skins',
            'Mobile Phone Accessories',
            'Mobile Phones & Smartphones',
            'Chargers & Cradles',
            'Headsets',
            'Screen Protectors',
          ];
        });
      } else if (subcategory == 'Computers,PCs & Laptops') {
        setState(() {
          subcategories = [
            'Components & Parts',
            'Computer Accessories',
            'Desktops & All-In-Ones',
            'Drives, Storage & Media',
            'Laptop & Notebooks',
            'Monitors & Screens',
            'Networking & Connectivity',
            'Printers, Scanners & Supplies'
          ];
        });
      } else if (subcategory == 'Gaming') {
        setState(() {
          subcategories = [
            'Accessories',
            'Consoles',
            'Games',
            'Handheld Consoles',
            'PC Gaming',
            'Prepaid Gaming Cards',
            'Replacement Parts & Tools',
            'Strategy Guides',
            'Video Gaming Merchandise',
          ];
        });
      } else if (subcategory == 'TV & Video') {
        setState(() {
          subcategories = [
            'DVD & Blu-ray Players',
            'Gadgets',
            'Home Audio',
            'Projectors & Screens',
            'Streaming Devices',
            'Televisions',
          ];
        });
      } else if (subcategory == 'Cameras & Photography') {
        setState(() {
          subcategories = [
            'Binoculars & Telescopes',
            'Camcorders',
            'Camera & Photo Accessories',
            'Digital Cameras',
            'Film & Polaroid',
            'Film & Polaroid Cameras',
            'Lenses & Filters',
            'Sport & Waterproof Cameras',
            'Tripods & Supports',
          ];
        });
      } else if (subcategory == 'Headphones & Mp3 Players') {
        setState(() {
          subcategories = ['Bluetooth Headphones', 'Headphones', 'Mp3 Players'];
        });
      } else if (subcategory == 'Sound & Audio') {
        setState(() {
          subcategories = [
            'Audio Accessories',
            'Bluetooth Speakers',
            'CD & Record Players',
            'DJ, Electronic Music & Karaoke',
            'Docking Stations',
            'Home Speakers & Subwoofers',
            'Microphones & Accessories',
            'Portable Stereos & Boomboxes',
            'Radios',
            'Studio Recording Equipment',
          ];
        });
      } else if (subcategory == 'Tablets & eReaders') {
        setState(() {
          subcategories = [
            'iPad',
            'Ebook Readers',
            'Tablet',
            'Tablet Accessories',
            'Tablet Cases, Covers and Skins',
          ];
        });
      } else if (subcategory == 'Wearables') {
        setState(() {
          subcategories = [
            'Fitness Trackers',
            'Smart Watches',
            'VR Headsets',
            'Smart Watch Accessories',
          ];
        });
      }
    } else if (category == 'Women') {
      if (subcategory == 'Activewear & Sportswear') {
        setState(() {
          subcategories = [
            'Jackets',
            'Jerseys',
            'Leggings, Tights, Pants',
            'Shirts & Tops',
            'Shorts',
            'Skorts, Skirts & Dresses',
            'Socks',
            'Sports Bras',
            'Tracksuits & Sweats'
          ];
        });
      } else if (subcategory == 'Jewelry') {
        setState(() {
          subcategories = [
            'Bracelets',
            'Earrings',
            'Necklaces',
            'Rings',
          ];
        });
      } else if (subcategory == 'Dresses') {
        setState(() {
          subcategories = [
            'Mini, Above Knee',
            'High Low',
            'Maxi',
            'Midi',
            'Jumpsuits & Rompers'
          ];
        });
      } else if (subcategory == 'Tops & Blouses') {
        setState(() {
          subcategories = [
            'Blouses',
            'Button-down',
            'Halters',
            'Knit Tops',
            'Polo Shirts',
            'T-Shirts',
            'Tank, Cami',
            'Tunics',
            'Wraps'
          ];
        });
      } else if (subcategory == 'Coats & Jackets') {
        setState(() {
          subcategories = [
            'Fleece Jackets',
            'Jean Jackets',
            'Motorcycle Jackets',
            'Parkas',
            'Peacoats',
            'Puffers',
            'Trench Coats',
            'Vests',
            'Windbreakers'
          ];
        });
      } else if (subcategory == 'Sweaters') {
        setState(() {
          subcategories = [
            'Cardigans',
            'Collared',
            'Cowl Neck',
            'Crewneck',
            'Full-zip',
            'Hooded',
            'Ponchos',
            'V-neck',
            'Vest, Sleeveless'
          ];
        });
      } else if (subcategory == 'Bags') {
        setState(() {
          subcategories = [
            'Backpacks',
            'Cosmetic Bags',
            'Crossbody Bags',
            'Satchels',
            'Shoulder Bags',
            'Tote Bags',
            'Waist Bags & Fanny Packs',
          ];
        });
      } else if (subcategory == 'Shoes') {
        setState(() {
          subcategories = [
            'Athletic Shoes',
            'Boots',
            'Fashion Sneakers',
            'Flats',
            'Loafers & Slip-ons',
            'Mules & Clogs',
            'Pumps',
            'Sandals',
            'Slippers'
          ];
        });
      } else if (subcategory == 'Women\'s accessories') {
        setState(() {
          subcategories = [
            'Belts',
            'Hair Accessories',
            'Hats',
            'Scarves & Wraps',
            'Sunglasses',
            'Wallets',
            'Watches'
          ];
        });
      } else if (subcategory == 'Modest wear') {
        setState(() {
          subcategories = [
            'Abayas',
            'Dresses',
            'Asian Wear',
            'Arabic Wear',
            'Hijabs'
          ];
        });
      } else if (subcategory == 'Jeans') {
        setState(() {
          subcategories = [
            'Boot Cut',
            'Boyfriend',
            'Capri, Cropped',
            'Flare',
            'Leggings & Jeggings',
            'Overalls',
            'Slim, Skinny',
            'Straight Leg',
            'Wide-Leg',
          ];
        });
      } else if (subcategory == 'Suits & Blazers') {
        setState(() {
          subcategories = [
            'Suits',
            'Blazers',
          ];
        });
      } else if (subcategory == 'Swimwear & Beachwear') {
        setState(() {
          subcategories = [
            'Swimwear',
            'Swimming accessories',
            'Beachwear',
            'Beach Accessories',
          ];
        });
      } else if (subcategory == 'Bottoms') {
        setState(() {
          subcategories = [
            'Leggings',
            'Tights',
            'Pants',
            'Shorts',
            'Skirts',
          ];
        });
      }
    } else if (category == 'Men') {
      if (subcategory == 'Activewear & Sportswear') {
        setState(() {
          subcategories = [
            'Jackets',
            'Jerseys',
            'Pants',
            'Shirts & Tops',
            'Shorts',
            'Snowsuits & Bibs',
            'Socks',
            'Vests',
            'Tracksuits & Sweats'
          ];
        });
      } else if (subcategory == 'Tops') {
        setState(() {
          subcategories = [
            'Button-Front',
            'Dress Shirts',
            'Hawaiian',
            'Henleys',
            'Polo, Rugby',
            'T-Shirts',
            'Tanks',
            'Turtlenecks'
          ];
        });
      } else if (subcategory == 'Shoes') {
        setState(() {
          subcategories = [
            'Athletic',
            'Boots',
            'Fashion Sneakers',
            'Loafers & Slip-ons',
            'Mules & Clogs',
            'Outdoor',
            'Oxfords',
            'Sandals',
            'Slippers',
            'Work & Safety'
          ];
        });
      } else if (subcategory == 'Coats & Jackets') {
        setState(() {
          subcategories = [
            'Fleece Jackets',
            'Flight/Bomber Jackets',
            'Jean Jackets',
            'Motorcycle Jackets',
            'Parkas',
            'Puffers',
            'Rainwear',
            'Vests',
            'Windbreakers'
          ];
        });
      } else if (subcategory == 'Men\'s accessories') {
        setState(() {
          subcategories = [
            'Backpacks, Bags & Briefcases',
            'Belts',
            'Hats',
            'Sunglasses',
            'Ties',
            'Wallets',
            'Watches'
          ];
        });
      } else if (subcategory == 'Bottoms') {
        setState(() {
          subcategories = [
            'Shorts',
            'Board, Surf Shorts',
            'Cargo',
            'Carpenter, Utility',
            'Casual',
            'Corduroys',
            'Denim',
            'Dress Shorts',
            'Khakis, Chinos',
          ];
        });
      } else if (subcategory == 'Nightwear & Loungewear') {
        setState(() {
          subcategories = [
            'Nightwear Pajamas',
            'Loungewear',
          ];
        });
      } else if (subcategory == 'Hoodies & Sweatshirts') {
        setState(() {
          subcategories = [
            'Hoodies',
            'Sweatshirt, Pullover',
            'Track & Sweat Pants',
            'Track & Sweat Suits',
            'Track Jackets',
          ];
        });
      } else if (subcategory == 'Jeans') {
        setState(() {
          subcategories = [
            'Baggy, Loose',
            'Boot Cut',
            'Cargo',
            'Carpenter',
            'Classic, Straight Leg',
            'Overalls',
            'Relaxed',
            'Slim, Skinny'
          ];
        });
      } else if (subcategory == 'Swimwear & Beachwear') {
        setState(() {
          subcategories = [
            'Swimwear',
            'Beachwear',
            'Swimwear Accessories',
            'Beach Accessories',
          ];
        });
      }
    } else if (category == 'Beauty') {
      if (subcategory == 'Fragrance') {
        setState(() {
          subcategories = [
            'Candles & Home Scents',
            'Kids',
            'Men',
            'Women',
            'Sets',
          ];
        });
      } else if (subcategory == 'Makeup') {
        setState(() {
          subcategories = [
            'Body',
            'Brushes & Applicators',
            'Eyes',
            'Face',
            'Lips',
            'Makeup Palettes',
            'Makeup Remover',
            'Makeup Sets',
            'Nails'
          ];
        });
      } else if (subcategory == 'Haircare') {
        setState(() {
          subcategories = [
            'Conditioners',
            'Hair & Scalp Treatments',
            'Hair Color',
            'Hair Loss Products',
            'Shampoo & Conditioner Sets',
            'Shampoos',
            'Styling Products',
            'Styling Tools'
          ];
        });
      } else if (subcategory == 'Skincare') {
        setState(() {
          subcategories = [
            'Body',
            'Eyes',
            'Face',
            'Feet',
            'Hands & Nails',
            'Lips',
            'Maternity',
            'Sets & Kits',
            'Sun'
          ];
        });
      } else if (subcategory == 'Tools and Accessories') {
        setState(() {
          subcategories = [
            'Bags & Cases',
            'Epilators',
            'Hair Styling Tools',
            'Makeup Brushes & Tools',
            'Mirrors',
            'Nail Tools',
            'Toiletry Kits',
            'Tweezers',
            'Waxing'
          ];
        });
      } else if (subcategory == 'Bath and Body') {
        setState(() {
          subcategories = [
            'Bath',
            'Bathing Accessories',
            'Cleansers',
            'Scrubs & Body Treatments',
            'Sets',
          ];
        });
      }
    } else if (category == 'Home') {
      if (subcategory == 'Bedding') {
        setState(() {
          subcategories = [
            'Jackets',
            'Jerseys',
            'Pants',
            'Shirts & Tops',
            'Shorts',
            'Snowsuits & Bibs',
          ];
        });
      } else if (subcategory == 'Bath') {
        setState(() {
          subcategories = [
            'Bath Linen Sets',
            'Bath Rugs',
            'Bathroom Accessories',
            'Bathroom Furniture Sets',
            'Bathroom Shelves',
            'Towels',
          ];
        });
      } else if (subcategory == 'Home Decor') {
        setState(() {
          subcategories = [
            'Home Decor, Area Rugs & Pads',
            'Baskets',
            'Candles & Holders',
            'Decorative Pillows',
            'Home Decor Accents',
            'Home Fragrance',
            'Lamps & Accessories',
            'Photo Albums & Frames',
            'Tapestries',
            'Window Treatments'
          ];
        });
      } else if (subcategory == 'Kitchen and Dining') {
        setState(() {
          subcategories = [
            'Bakeware',
            'Coffee & Tea Accessories',
            'Cookware',
            'Dining & Entertainment',
            'Kitchen & Table Linens',
            'Kitchen Knives & Cutlery Accessories',
            'Kitchen Storage & Organization',
            'Kitchen Utensils & Gadgets',
            'Small Appliances',
            'Wine Accessories'
          ];
        });
      } else if (subcategory == 'Storage and Organization') {
        setState(() {
          subcategories = [
            'Basket & Bins',
            'Bathroom Storage & Organization',
            'Clothing & Closet Storage',
            'Garage Storage & Organization',
            'Jewelry Boxes & Organizers',
            'Kitchen Storage & Organization',
            'Laundry Storage & Organization',
            'Racks, Shelves & Drawers',
            'Trash & Recycling'
          ];
        });
      } else if (subcategory == 'Cleaning Supplies') {
        setState(() {
          subcategories = [
            'Air Freshners',
            'Brushes',
            'Dusting',
            'Gloves',
            'Household Cleaners',
            'Mopping',
            'Paper Towels',
            'Sweeping',
            'Trash Bags'
          ];
        });
      } else if (subcategory == 'Furniture') {
        setState(() {
          subcategories = [
            'Bathroom Furniture',
            'Bedroom Furniture',
            'Home Bar Furniture',
            'Home Entertainment Furniture',
            'Home Office Furniture',
            'Kitchen & Dining Room Furniture',
            'Living Room Furniture',
            'Replacement Parts',
            'Other Furniture'
          ];
        });
      } else if (subcategory == 'Artwork') {
        setState(() {
          subcategories = [
            'Drawings',
            'Lithographs, Etchings & Woodcuts',
            'Paintings',
            'Photographs',
            'Posters & Prints',
          ];
        });
      } else if (subcategory == 'Cleaning Supplies') {
        setState(() {
          subcategories = [
            'Air Freshners',
            'Brushes',
            'Dusting',
            'Gloves',
            'Household Cleaners',
            'Mopping',
            'Paper Towels',
            'Sweeping',
            'Trash Bags'
          ];
        });
      } else if (subcategory == 'Home Appliances') {
        setState(() {
          subcategories = [
            'Home Appliances, Air Conditioners',
            'Air Purifiers',
            'Fans',
            'Humidifiers',
            'Kitchen Appliances',
            'Refrigerators',
            'Vacuums & Floor Care',
            'Washers & Dryers',
            'Water Coolers & Filters',
          ];
        });
      }
    } else if (category == 'Toys') {
      if (subcategory == 'Collectibles & Hobbies') {
        setState(() {
          subcategories = [
            'Autographs',
            'Dolls',
            'Figurines',
            'Glass',
            'Model Vehicles',
            'Pins',
            'Porcelain',
            'Souvenirs & Memorabilia',
            'Squishes',
            'Statues & Bobbleheads'
          ];
        });
      } else if (subcategory == 'Action Figures & Accessories') {
        setState(() {
          subcategories = [
            'Action Figures',
            'Action Figure Accessories',
            'Action Figure Playsets',
            'Action Figure Vehicles & Transporations',
            'Animal & Dinosaur Figures',
            'Mini Figures',
          ];
        });
      } else if (subcategory == 'Dolls & Accessories') {
        setState(() {
          subcategories = [
            'Baby Dolls',
            'Doll Accessories',
            'Doll Clothes',
            'Dollhouse Furniture & Accessories',
            'Dollhouses & Play Sets',
            'Fashion Dolls',
            'Interactive Dolls & Pets',
            'Mini Dolls & Playsets',
            'Play Animals'
          ];
        });
      } else if (subcategory == 'Vintage & Antique Toys') {
        setState(() {
          subcategories = [
            'Antique Toys',
            'Action Figures',
            'Animals',
            'Blocks',
            'Cars',
            'Children',
            'Dolls',
            'Electronics',
            'Games',
            'Puzzles',
            'Sports'
          ];
        });
      } else if (subcategory == 'Trading Cards') {
        setState(() {
          subcategories = [
            'Action, Adventure',
            'Animation',
            'Comic',
            'Historical, Military',
            'Price Guides & Publications',
            'Sci-Fi, Fantasy',
            'Sports',
            'Vintage'
          ];
        });
      } else if (subcategory == 'Stuffed Animals') {
        setState(() {
          subcategories = [
            'Beanbag Plushies',
            'Character Pillows & Blankets',
            'Plush Figures',
            'Plush Puppets',
            'Plush Purses & Accessories',
            'Stuffed Animals',
            'Stuffed Animal Accessories'
          ];
        });
      } else if (subcategory == 'Building Toys') {
        setState(() {
          subcategories = [
            'Building Kit Accessories',
            'Magnetic Construction',
            'Stacking Blocks',
            'Wooden Blocks'
          ];
        });
      } else if (subcategory == 'Arts & Crafts') {
        setState(() {
          subcategories = [
            'Aprons & Smocks',
            'Clay, Dough & Potter Kits',
            'Craft Kits',
            'Drawing & Coloring',
            'Easels & Art Tables',
            'Glue, Paste & Tape',
            'Jewelry & Bead Kits',
            'Kids Scissors',
            'Painting',
            'Stickers'
          ];
        });
      } else if (subcategory == 'Games & Puzzles') {
        setState(() {
          subcategories = [
            '3-D Puzzles',
            'Board Games',
            'Card Games',
            'Chess & Checkers',
            'Dice Games',
            'Jigsaw Puzzles',
            'Stacking Games',
            'Tile Games',
            'Trading Card Games',
            'Wooden Puzzles'
          ];
        });
      } else if (subcategory == 'Remote Control Toys') {
        setState(() {
          subcategories = [
            'Kids Drones & Flying Toys',
            'Play Vehicles',
            'Racetracks & Playsets',
            'Remote Control Vehicles & Animals',
            'Robotics',
            'Toy Vehicle Accessories',
            'Trains & Train Sets'
          ];
        });
      }
    } else if (category == 'Kids') {
      if (subcategory == 'Girls Dresses') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
            'Girls 4+',
          ];
        });
      } else if (subcategory == 'Girls One-pieces') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
          ];
        });
      } else if (subcategory == 'Girls Tops & T-shirts') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
            'Girls 4+',
          ];
        });
      } else if (subcategory == 'Girls Bottoms') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
            'Girls 4+',
          ];
        });
      } else if (subcategory == 'Girls Shoes') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
            'Girls 4+',
          ];
        });
      } else if (subcategory == 'Girls Accessories') {
        setState(() {
          subcategories = [
            'Girls 0-24 Months',
            'Girls 1-4 Years',
            'Girls 4+',
          ];
        });
      } else if (subcategory == 'Boys Tops & T-shirts') {
        setState(() {
          subcategories = [
            'Boys 0-24 Months',
            'Boys 1-4 Years',
            'Boys 4+',
          ];
        });
      } else if (subcategory == 'Boys Bottoms') {
        setState(() {
          subcategories = [
            'Boys 0-24 Months',
            'Boys 1-4 Years',
            'Boys 4+',
          ];
        });
      } else if (subcategory == 'Boys One-pieces') {
        setState(() {
          subcategories = [
            'Boys 0-24 Months',
            'Boys 1-4 Years',
          ];
        });
      } else if (subcategory == 'Boys Accessories') {
        setState(() {
          subcategories = [
            'Boys 0-24 Months',
            'Boys 1-4 Years',
            'Boys 4+',
          ];
        });
      } else if (subcategory == 'Boys Shoes') {
        setState(() {
          subcategories = [
            'Boys 0-24 Months',
            'Boys 1-4 Years',
            'Boys 4+',
          ];
        });
      }
    } else if (category == 'Sport & Leisure') {
      if (subcategory == 'Outdoors') {
        setState(() {
          subcategories = [
            'Bike & Skate',
            'Boating',
            'Fishing',
            'Hiking & Camping',
            'Indoor/Outdoor Games',
            'Skateboard',
            'Snowboard',
            'Water Sports',
            'Golf'
          ];
        });
      } else if (subcategory == 'Exercise') {
        setState(() {
          subcategories = [
            'Athletic Training',
            'Bowling',
            'Boxing & MMA',
            'Dance/Ballet',
            'Fitness Accessories',
            'Fitness Technology',
            'Strength Training',
            'Track & Field',
            'Yoga & Pilates'
          ];
        });
      } else if (subcategory == 'Fan Shop') {
        setState(() {
          subcategories = [
            'FIFA',
            'NBA',
            'NCAA',
            'NFL',
            'NHL',
            'MLB',
            'Premier League',
            'La Liga'
          ];
        });
      } else if (subcategory == 'Team Sports') {
        setState(() {
          subcategories = [
            'Badminton',
            'Baseball & Softball',
            'Basketball',
            'Football',
            'Soccer',
            'Hockey',
            'Lacrosse',
            'Tennis & Racquets',
            'Volleyball',
            'Track',
            'Swimming',
            'Gymnastics',
            'Wrestling',
            'Boxing'
          ];
        });
      } else if (subcategory == 'Apparel') {
        setState(() {
          subcategories = ['Accessories', 'Boys', 'Girls', 'Men', 'Women'];
        });
      } else if (subcategory == 'Footwear') {
        setState(() {
          subcategories = ['Cleats', 'Kids', 'Men', 'Women'];
        });
      }
    } else if (category == 'Handmade') {
      if (subcategory == 'Accessories') {
        setState(() {
          subcategories = [
            'Charm',
            'Gloves',
            'Hair',
            'Keychain',
            'Lanyard',
            'Men',
            'Patch',
            'Pin',
            'Pinback Button',
            'Scarf'
          ];
        });
      } else if (subcategory == 'Paper Goods') {
        setState(() {
          subcategories = [
            'Calendars',
            'Cards',
            'Gift Wrap',
            'Journals',
            'Notebooks',
            'Papermaking',
            'Scrapbooking',
            'Stationery',
            'Stickers'
          ];
        });
      } else if (subcategory == 'Clothing') {
        setState(() {
          subcategories = [
            'Children',
            'Corsets',
            'Costume',
            'Dresses',
            'Lingerie',
            'Shirts',
            'Shoes',
            'T-Shirts',
            'Women'
          ];
        });
      } else if (subcategory == 'Bags & Purses') {
        setState(() {
          subcategories = [
            'Backpacks',
            'Clutches',
            'Hip Bags',
            'Laptop Bags',
            'Messenger Bags',
            'Pouches',
            'Purses',
            'Totes',
            'Wristlets'
          ];
        });
      } else if (subcategory == 'Jewelry') {
        setState(() {
          subcategories = [
            'Books & Zines',
            'Clothing',
            'Jewelry',
            'Music',
          ];
        });
      } else if (subcategory == 'Music') {
        setState(() {
          subcategories = [
            'Case',
            'Equipment',
            'Instruments',
            'Posters',
            'Tapes',
            'Vinyl',
          ];
        });
      } else if (subcategory == 'Art') {
        setState(() {
          subcategories = [
            'Drawings',
            'Fiber Art',
            'Illustration',
            'Mixed Media',
            'Painting',
            'Photography',
            'Print',
            'Printmaking',
            'Sculptures'
          ];
        });
      } else if (subcategory == 'Weddings') {
        setState(() {
          subcategories = [
            'Accessories',
            'Bouqets',
            'Cake Toppers',
            'Clothing',
            'Decorations',
            'Favors',
            'Guest Books',
            'Invitations',
            'Jewelry'
          ];
        });
      } else if (subcategory == 'Children') {
        setState(() {
          subcategories = [
            'Accessories',
            'Art',
            'Baby',
            'Clothing',
            'Furniture',
            'Houseware',
            'Jewelry',
            'Toddler',
            'Toys'
          ];
        });
      } else if (subcategory == 'Gifts') {
        setState(() {
          subcategories = [
            'Readymade Gift Sets',
            'Anniversary Gifts',
            'Birthday Gifts',
            'Celebration Gifts',
          ];
        });
      }
    } else if (category == 'Books') {
      if (subcategory == 'Childrens Books') {
        setState(() {
          subcategories = [
            'Early Learning',
            'Childrens Fiction',
            'Hobbies & Interests',
            'Picture Books',
            'Poetry & Anthologies',
            'Baby Books',
            'Young Adult',
          ];
        });
      } else if (subcategory == 'Fiction Books') {
        setState(() {
          subcategories = [
            'Anthologies and Short Stories',
            'Calendars',
            'Classics',
            'Historical Fiction',
            'Romance',
            'Poetry, Drama & Literacy',
          ];
        });
      } else if (subcategory == 'Non Fiction Books') {
        setState(() {
          subcategories = [
            'Art, Fashion & Photography',
            'Astronomy & Space',
            'Electronics',
            'Biography',
            'Business, Finance & Law',
            'Computing & Internet',
            'Education',
            'Entertainment',
            'Food & Drink',
            'Health & Lifestyle',
            'History',
            'Home & Garden',
            'Hobbies',
            'Mind, Body & Spirit',
            'Language',
            'Music',
            'Philosophy',
            'Politics',
            'Pets',
            'Popular Science',
            'Science, Technology & Medicine',
            'Spirituality',
            'Sports',
            'Travel'
          ];
        });
      } else if (subcategory == 'Crime Books') {
        setState(() {
          subcategories = [
            'Classic Crime',
            'Historical Crime',
            'Thrillers',
            'True Crime',
          ];
        });
      } else if (subcategory == 'Sci-fi & Fantasy Books') {
        setState(() {
          subcategories = [
            'Science Fiction',
            'Fantasy',
            'Horror',
            'Graphic Novels',
          ];
        });
      } else if (subcategory == 'Comics') {
        setState(() {
          subcategories = [
            'Superhero',
            'Manga',
            'Humor',
            'Non-fiction',
            'Science-Fiction/Fantasy',
            'Horror',
          ];
        });
      }
    } else if (category == 'Motors') {
      if (subcategory == 'Used Cars') {
        setState(() {
          subcategories = [
            'Sedan',
            'SUV',
            'Hatchback',
            'Coupe',
            'Convertible',
            'Minivan',
            'Classic',
            'Luxury',
            'Compact',
            'Van',
            'Crossover',
            'Electric',
            'Hybrid',
            'Pickup'
          ];
        });
      } else if (subcategory == 'Motorcycles & Scooters') {
        setState(() {
          subcategories = [
            'Standard',
            'Cruiser',
            'Sports',
            'Touring',
            'Sport Touring',
            'Dual-Sport',
            'Scooters',
            'Off-road',
            'Utility',
            'Electric Scooters',
            'Tricycles',
          ];
        });
      } else if (subcategory == 'Heavy vehicles') {
        setState(() {
          subcategories = [
            'Tractors',
            'Trucks',
            'Carriers',
            'Cranes',
            'Construction',
          ];
        });
      } else if (subcategory == 'Boats') {
        setState(() {
          subcategories = [
            'Boats',
            'Motorboats',
            'Canoes',
            'Sailboats',
            'Rafts',
            'Rowboats',
            'Yacht',
            'JetSki'
          ];
        });
      } else if (subcategory == 'Other') {
        setState(() {
          subcategories = [
            'Car accessories',
            'Number plates',
            'Car tools',
            'Parts',
          ];
        });
      }
    } else if (category == 'Other') {
      if (subcategory == 'Office Supplies') {
        setState(() {
          subcategories = [
            'Basic Supplies',
            'Calendars',
            'Electronics',
            'Ink & Toner',
            'Organization',
            'Paper',
            'School Supplies',
            'Shipping Supplies',
            'Writing'
          ];
        });
      } else if (subcategory == 'Daily & Travel Items') {
        setState(() {
          subcategories = [
            'Baby & Child Care',
            'Health Care',
            'Household Supplies',
            'Medical Supplies & Equipment',
            'Personal Care',
            'Sports Nutrition',
            'Stationery & Party Supplies',
          ];
        });
      } else if (subcategory == 'Musical Instruments') {
        setState(() {
          subcategories = [
            'Amplifiers & Effects',
            'Band & Orchestra',
            'Brass Instruments',
            'Drums & Percussion',
            'Guitars',
            'Instrument Accessories',
            'Keyboards',
            'Stringed Instruments',
            'Wind & Woodwind Instruments'
          ];
        });
      } else if (subcategory == 'Pet Supplies') {
        setState(() {
          subcategories = [
            'Cage',
            'Cats',
            'Dogs',
            'Fish',
            'Pet Food',
            'Small Animals',
          ];
        });
      }
    } else if (category == 'Garden') {
      if (subcategory == 'Garden Plants') {
        setState(() {
          subcategories = [
            'Climbers and Vines',
            'Conifers',
            'Ferns',
            'Kitchen Garden',
            'Topiary',
            'Roses',
            'Herbaceous and Perennial',
            'Tropical and Exotic Plants',
            'Bulbs',
            'Bonsai',
            'Fruit Trees',
            'Patio Plants'
          ];
        });
      } else if (subcategory == 'Pots and Garden Tools') {
        setState(() {
          subcategories = [
            'Vessels',
            'Pots',
            'Home Gardening Props',
            'Other Props',
          ];
        });
      } else if (subcategory == 'Artificial Plants') {
        setState(() {
          subcategories = [
            'Office Plants',
            'House Plants',
            'Wall Hanging Plants',
            'Decoration Plants',
          ];
        });
      } else if (subcategory == 'Other') {
        setState(() {
          subcategories = [
            'Seeds',
            'Manure',
            'Other Gardening Accessories & Tools'
          ];
        });
      }
    } else if (category == 'Luxury') {
      if (subcategory == 'Bags') {
        setState(() {
          subcategories = [
            'Shoulder Bags',
            'Totes',
            'Clutches',
            'Hobos',
            'Satchels',
            'Wallets',
            'Exotic Bags',
            'Backpacks',
            'Breifcases',
            'Duffel Bags',
            'Messenger Bags',
            'Suitcases',
            'Totes'
          ];
        });
      } else if (subcategory == 'Clothing') {
        setState(() {
          subcategories = [
            'Women Dresses',
            'Women Tops',
            'Women Skirts',
            'Women Coats',
            'Women Jackets',
            'Women Pants',
            'Women Jeans & Denim',
            'Women Suits',
            'Women Sweaters',
            'Men T-Shirts & Polos',
            'Men Shirts',
            'Men Jackets',
            'Men Coats',
            'Men Pants & Jeans'
          ];
        });
      } else if (subcategory == 'Home') {
        setState(() {
          subcategories = [
            'Appliances',
            'Dining',
            'Home Decor & Accessories',
          ];
        });
      } else if (subcategory == 'Accessories') {
        setState(() {
          subcategories = [
            'Women Sunglasses',
            'Women Scarves',
            'Women Belts',
            'Women Earrings',
            'Women Bracelets',
            'Women Necklaces',
            'Women Rings',
            'Women Watches',
            'Men Watches',
            'Men Belts',
            'Men Cufflinks',
            'Men Pens',
            'Men Sunglasses',
            'Men Ties'
          ];
        });
      } else if (subcategory == 'Shoes') {
        setState(() {
          subcategories = [
            'Women Sneakers',
            'Women Pumps',
            'Women Flats',
            'Women Boots',
            'Women Sandals',
            'Men Sneakers',
            'Men Loafers',
            'Men Oxfords',
          ];
        });
      }
    } else if (category == 'Vintage') {
      if (subcategory == 'Bags & Purses') {
        setState(() {
          subcategories = [
            'Change Purses',
            'Clutches',
            'Diaper Bags',
            'Formal',
            'Handbags',
            'Luggage',
            'Pouches',
            'Purses',
            'Totes'
          ];
        });
      } else if (subcategory == 'Antiques') {
        setState(() {
          subcategories = [
            '100 Years or older',
            '50 to 75 Years',
            '75 to 100 Years',
            'Bags & Purses',
            'Books',
            'Collectibles',
            'Electronics',
            'Home Decor',
            'Jewelry'
          ];
        });
      } else if (subcategory == 'Jewelry') {
        setState(() {
          subcategories = [
            'Bracelets',
            'Brooches',
            'Earrings',
            'Necklaces',
            'Pendants',
            'Rings',
            'Watches',
          ];
        });
      } else if (subcategory == 'Books') {
        setState(() {
          subcategories = [
            'Art',
            'Children',
            'Comics',
            'Cookbooks',
            'Crafting',
            'Fiction',
            'Health',
            'Nonfiction',
            'Poetry'
          ];
        });
      } else if (subcategory == 'Electronics') {
        setState(() {
          subcategories = [
            'Cameras',
            'Clocks',
            'Games',
            'Radios',
            'Telephones',
            'Televisions',
            'Video Games',
          ];
        });
      } else if (subcategory == 'Accessories') {
        setState(() {
          subcategories = [
            'Buckles',
            'Cuff Links',
            'Eyewear',
            'Gloves',
            'Hats',
            'Keychains',
            'Scarves',
            'Shoes',
            'Wallets'
          ];
        });
      } else if (subcategory == 'Serving Pieces') {
        setState(() {
          subcategories = [
            'Butter Dishes',
            'Casserole',
            'Cream & Sugar Set',
            'Flatware',
            'Mugs',
            'Pitchers',
            'Salt & Pepper Shakers',
            'Teacups',
            'Teapots',
            'Tumblers'
          ];
        });
      } else if (subcategory == 'Supplies') {
        setState(() {
          subcategories = [
            'Bead',
            'Button',
            'Cabochon',
            'Chain',
            'Charm',
            'Fabric',
            'Finding',
            'Pattern',
            'Yarn'
          ];
        });
      } else if (subcategory == 'Clothing') {
        setState(() {
          subcategories = [
            'Baby',
            'Corsets',
            'Dresses',
            'Jackets',
            'Shirts',
            'Shorts',
            'Sweater',
            'Swimwear',
            'T-Shirts'
          ];
        });
      } else if (subcategory == 'Houseware') {
        setState(() {
          subcategories = [
            'Bowls',
            'Ceramics',
            'Coasters',
            'Cups',
            'Glasses',
            'Lights',
            'Magnets',
            'Plates',
            'Trays'
          ];
        });
      }
    }
  }

  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Sub Category',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              margin:
                  EdgeInsets.only(top: 10.0, right: 10, left: 10, bottom: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: const Color(0x80e5e9f2),
                ),
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: Icon(
                        Feather.search,
                        size: 24,
                        color: Color.fromRGBO(115, 115, 125, 1),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (text) {
                          text = text.trim();
                          text = text.toLowerCase();

                          if (text.isEmpty) {
                            loadsubcategory(subcategory);
                          }
                          List<String> filtered = List<String>();
                          filtered.clear();
                          subcategories.forEach((element) {
                            element = element.trim();
                            element = element.toLowerCase();
                            if (element.contains(text)) {
                              element = element[0].toUpperCase() +
                                  element.substring(1, element.length);
                              filtered.add(element);
                            }
                          });

                          setState(() {
                            subcategories = filtered;
                          });
                        },
                        controller: searchcontroller,
                        decoration: InputDecoration(
                            hintText: 'Search Sub Categories',
                            hintStyle: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                bottom: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subcategory,
                  style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
                child: AlphabetListScrollView(
              showPreview: true,
              strList: subcategories,
              indexedHeight: (i) {
                return 60;
              },
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          subsubcategory = subcategories[index];
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop({
                          'category': category,
                          'subcategory': subcategory,
                          'subsubcategory': subsubcategory,
                        });
                      },
                      title: subcategories[index] != null
                          ? Text(
                              subcategories[index],
                              style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 16,
                                  color: Colors.black),
                            )
                          : Text(''),
                      trailing: Padding(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        padding: EdgeInsets.only(right: 50),
                      ),
                    ));
              },
            ))
          ],
        ));
  }
}
