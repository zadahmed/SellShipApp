import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/username.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:animated_onboarding/animated_onboarding.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class AnimatedOnboardingScreen extends StatefulWidget {
  @override
  _AnimatedOnboardingScreenState createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOnboarding(
      pages: [
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1645.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text(
                        "Browse through the latest products from local brands.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: Color.fromRGBO(135, 206, 235, 1)),
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1638.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text("Create your online store within seconds.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: Colors.deepPurpleAccent),
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1640.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text("Sell anything in just a few clicks.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: const Color(0xffff9100)),
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1641.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text("Earn ratings and build your brand identity.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: Colors.amber),
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1642.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text("Pick your price on pre-loved items.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: const Color(0xff5c6bc0)),
        OnboardingPage(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: 400,
                  child: Image.asset(
                    'assets/onboarding/IMG_1644.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                    child: Text(
                        "Enjoy pickup and delivery straight to your doorsteps.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            color: Colors.redAccent),
      ],
      pageController: PageController(),
      onFinishedButtonTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seen', true);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()));
      },
      topLeftChild: Container(
        width: 150,
        height: 40,
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
        ),
      ),
      topRightChild: FlatButton(
        child: Text(
          "Skip",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seen', true);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => OnboardingScreen()));
        },
      ),
    );
  }
}
