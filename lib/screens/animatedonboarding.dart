import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/username.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class AnimatedOnboardingScreen extends StatefulWidget {
  @override
  _AnimatedOnboardingScreenState createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(),
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.all(20),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,

      pages: [
        PageViewModel(
          title: "Browse through the latest products from local brands.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1645.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
        PageViewModel(
          title: "Pick your price on pre-loved items.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1642.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
        PageViewModel(
          title: "Create your online store within seconds.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1638.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
        PageViewModel(
          title: "Earn ratings and build your brand identity.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1642.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
        PageViewModel(
          title: "Sell anything in just a few clicks.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1640.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
        PageViewModel(
          title: "Enjoy pickup and delivery straight to your doorsteps.",
          body: "",
          image: Image.asset(
            'assets/onboarding/IMG_1644.PNG',
            fit: BoxFit.contain,
          ),
          decoration: PageDecoration(
            bodyFlex: 1,
            imageFlex: 3,
            titleTextStyle:
                TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(),
            descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            pageColor: Colors.white,
            imagePadding: EdgeInsets.only(top: 80),
          ),
        ),
      ],
      onDone: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seen', true);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()));
      },
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      // controlsMargin: const EdgeInsets.all(16),
      // controlsPadding: kIsWeb
      //     ? const EdgeInsets.all(12.0)
      //     : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      // dotsContainerDecorator: const ShapeDecoration(
      //   color: Colors.black87,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
      //   ),
      // ),
    );
  }
}

//
// @override
// Widget build(BuildContext context) {
//   return AnimatedOnboarding(
//     pages: [

//       OnboardingPage(
//           child: Column(
//             children: [
//               Container(
//                 height: 400,
//                 width: 400,
//                 child: Image.asset(
//                   'assets/onboarding/IMG_1638.PNG',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(left: 50, right: 50, top: 20),
//                   child: Text("Create your online store within seconds.",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//             ],
//           ),
//           color: Colors.deepPurpleAccent),
//       OnboardingPage(
//           child: Column(
//             children: [
//               Container(
//                 height: 400,
//                 width: 400,
//                 child: Image.asset(
//                   'assets/onboarding/IMG_1640.PNG',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(left: 50, right: 50, top: 20),
//                   child: Text("Sell anything in just a few clicks.",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//             ],
//           ),
//           color: const Color(0xffff9100)),
//       OnboardingPage(
//           child: Column(
//             children: [
//               Container(
//                 height: 400,
//                 width: 400,
//                 child: Image.asset(
//                   'assets/onboarding/IMG_1641.PNG',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(left: 50, right: 50, top: 20),
//                   child: Text("Earn ratings and build your brand identity.",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//             ],
//           ),
//           color: Colors.amber),
//       OnboardingPage(
//           child: Column(
//             children: [
//               Container(
//                 height: 400,
//                 width: 400,
//                 child: Image.asset(
//                   'assets/onboarding/IMG_1642.PNG',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(left: 50, right: 50, top: 20),
//                   child: Text("Pick your price on pre-loved items.",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//             ],
//           ),
//           color: const Color(0xff5c6bc0)),
//       OnboardingPage(
//           child: Column(
//             children: [
//               Container(
//                 height: 400,
//                 width: 400,
//                 child: Image.asset(
//                   'assets/onboarding/IMG_1644.PNG',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(left: 50, right: 50, top: 20),
//                   child: Text(
//                       "Enjoy pickup and delivery straight to your doorsteps.",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold))),
//             ],
//           ),
//           color: Colors.redAccent),
//     ],
//     pageController: PageController(),
//     onFinishedButtonTap: () async {

//     },
//     topLeftChild: Container(
//       width: 150,
//       height: 40,
//       child: Image.asset(
//         'assets/logo.png',
//         fit: BoxFit.cover,
//       ),
//     ),
//     topRightChild: FlatButton(
//       child: Text(
//         "Skip",
//         style: TextStyle(
//           color: Colors.white,
//         ),
//       ),
//       onPressed: () async {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('seen', true);
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => OnboardingScreen()));
//       },
//     ),
//   );
// }
