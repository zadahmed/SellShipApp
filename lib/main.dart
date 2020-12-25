import 'dart:async';

import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/screens/details.dart';
import 'package:SellShip/screens/rootscreen.dart';
import 'package:SellShip/screens/starterscreen.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
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

  bool allowed =
      await OneSignal.shared.promptUserForPushNotificationPermission();
  if (!allowed) {
    OneSignal.shared.promptUserForPushNotificationPermission();
  }
  await OneSignal.shared.sendTags({
    "device_type": "mobile",
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange, //or set color with: Color(0xFF0000FF)
    ));
  }

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return MultiProvider(
        providers: [
          Provider<UserProvider>(create: (context) => UserProvider()),
          Provider<ItemProvider>(create: (context) => ItemProvider())
        ],
        child: MaterialApp(
          builder: BotToastInit(),
          routes: {
            Routes.addBrands: (context) => Brands(),
            Routes.addCategory: (context) => AddCategory(),
            Routes.addItem: (context) => AddItem(),
            Routes.addPayment: (context) => AddPayment(),
            Routes.address: (context) => Address(),
            Routes.addSubCategory: (context) => AddSubCategory(),
            Routes.addSubSubCategory: (context) => AddSubSubCategory(),
            Routes.balance: (context) => Balance(),
            Routes.boysFashion: (context) => BoysFashion(),
            Routes.categories: (context) => CategoryScreen(),
            Routes.categoryDetail: (context) => CategoryDetail(),
            Routes.changeCountry: (context) => ChangeCountry(),
            Routes.chatPageView: (context) => ChatPageView(),
            Routes.checkout: (context) => Checkout(),
            Routes.checkoutUAE: (context) => CheckoutUAE(),
            Routes.comments: (context) => CommentsPage(),
            Routes.details: (context) => Details(),
            Routes.editItem: (context) => EditItem(),
            Routes.editProfile: (context) => EditProfile(),
            Routes.favourites: (context) => FavouritesScreen(),
            Routes.featureItem: (context) => FeatureItem(),
            Routes.forgotPassword: (context) => ForgotPassword(),
            Routes.girlsFashion: (context) => GirlsFashion(),
            Routes.home: (context) => HomeScreen(),
            Routes.loginPage: (context) => ProfilePage(),
            Routes.loginProfile: (context) => LoginPage(),
            Routes.messages: (context) => Messages(),
            Routes.myItems: (context) => MyItems(),
            Routes.notifications: (context) => NotifcationPage(),
            Routes.onBoarding: (context) => OnboardingScreen(),
            Routes.orderBuyer: (context) => OrderBuyer(),
            Routes.orderBuyerUAE: (context) => OrderBuyerUAE(),
            Routes.orders: (context) => OrdersScreen(), //
            Routes.orderSeller: (context) => OrderDetail(),
            Routes.orderSellerUAE: (context) => OrderDetailUAE(),
            Routes.otpScreen: (context) => OTPScreen(),
            Routes.paymentDone: (context) => PaymentDone(),
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
            Routes.womenFashion: (context) => WomenFashion(),
          },
          debugShowCheckedModeBanner: false,
          color: Colors.blue,
          home: new Splash(),
        ));
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  void navigatetoscreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new RootScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new StarterPage()));
    }
  }

  Future handleDynamicLinks() async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');

      var id = deepLink.queryParameters['id'];

      if (id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(itemid: id)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    new Timer(new Duration(milliseconds: 10), () {
      if (mounted) {
        handleDynamicLinks();
        navigatetoscreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return new Scaffold(
      backgroundColor: Colors.deepOrange,
    );
  }
}
