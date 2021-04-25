import 'dart:async';
import 'dart:io';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/animatedonboarding.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/starterscreen.dart';
import 'package:SellShip/screens/subcategory.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/itemProvider.dart';
import 'providers/userProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  OneSignal.shared.init("3df1c23c-12b8-4282-b6ac-a7d34d063a55", iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  });
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://c71fb642da6d4c138ddf0148d297f5ca@o568777.ingest.sentry.io/5714098';
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getuser();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));
  }

  FirebaseAnalytics analytics = FirebaseAnalytics();

  getuser() async {
    userid = await storage.read(key: 'userid');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    await storage.write(key: 'country', value: 'United Arab Emirates');
    setState(() {
      userid = userid;
      seen = _seen;
    });
  }

  var userid;
  var seen;

  Widget checkwidget() {
    if (userid == null) {
      return OnboardingScreen();
    } else {
      if (seen == false) {
        return AnimatedOnboardingScreen();
      } else {
        return RootScreen();
      }
    }
  }

  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return MultiProvider(
        providers: [
          Provider<UserProvider>(create: (context) => UserProvider()),
          Provider<ItemProvider>(create: (context) => ItemProvider())
        ],
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Helvetica'),
          routes: {
            Routes.addBrands: (context) => Brands(),
            Routes.addCategory: (context) => AddCategory(),
            Routes.addItem: (context) => AddItem(),
            Routes.addPayment: (context) => AddPayment(),
            Routes.address: (context) => Address(),
            Routes.addSubCategory: (context) => AddSubCategory(),
            Routes.addSubSubCategory: (context) => AddSubSubCategory(),
            Routes.balance: (context) => Balance(),
            Routes.categoryDetail: (context) => CategoryDetail(),
            Routes.changeCountry: (context) => ChangeCountry(),
            Routes.chatPageView: (context) => ChatPageView(),
            Routes.checkout: (context) => Checkout(),
            Routes.comments: (context) => CommentsPage(),
            Routes.details: (context) => Details(),
            Routes.editItem: (context) => EditItem(),
            Routes.editProfile: (context) => EditProfile(),
            Routes.favourites: (context) => FavouritesScreen(),
            Routes.featureItem: (context) => FeatureItem(),
            Routes.forgotPassword: (context) => ForgotPassword(),
            Routes.home: (context) => HomeScreen(),
            Routes.loginPage: (context) => ProfilePage(),
            Routes.loginProfile: (context) => LoginPage(),
            Routes.messages: (context) => Messages(),
            Routes.myItems: (context) => MyItems(),
            Routes.notifications: (context) => NotifcationPage(),
            Routes.onBoarding: (context) => OnboardingScreen(),
            Routes.orderBuyer: (context) => OrderBuyer(),
            Routes.orderSeller: (context) => OrderSeller(),
            Routes.orderSellerUAE: (context) => OrderSellerUAE(),
            Routes.otpScreen: (context) => OTPScreen(),
            Routes.privacyPolicy: (context) => PrivacyPolicy(),
            Routes.profile: (context) => ProfilePage(),
            Routes.reviewBuyer: (context) => ReviewBuyer(),
            Routes.reviews: (context) => ReviewsPage(),
            Routes.reviewSeller: (context) => ReviewSeller(),
            Routes.rootScreen: (context) => RootScreen(),
            Routes.search: (context) => Search(),
            Routes.settings: (context) => Settings(),
            Routes.signUpProfile: (context) => SignUpPage(),
            Routes.starterScreen: (context) => StarterPage(),
            Routes.subCategory: (context) => SubCategory(),
            Routes.termsAndConditions: (context) => TermsandConditions(),
            Routes.userItems: (context) => UserItems(),
          },
          debugShowCheckedModeBanner: false,
          color: Colors.blue,
          home: checkwidget(),
        ));
  }
}
