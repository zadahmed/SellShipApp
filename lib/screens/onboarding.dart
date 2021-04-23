import 'dart:convert';
import 'dart:io';
import 'package:SellShip/Navigation/routes.dart';
import 'package:SellShip/controllers/FadeAnimations.dart';
import 'package:SellShip/controllers/handleNotifications.dart';
import 'package:SellShip/screens/signUpPage.dart';
import 'package:SellShip/username.dart';
import 'package:SellShip/verification/verifyphone.dart';
import 'package:SellShip/verification/verifyphonesignup.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/onboardingvideo.MOV')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: VideoPlayer(_controller)),
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.2)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Image.asset(
              'assets/logo.png',
              width: 300,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 15, bottom: 10, right: 15),
                        child: Container(
                            child: InkWell(
                          enableFeedback: true,
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.white.withOpacity(0.4),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Sign Up',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        ))),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 15, bottom: 50, right: 15),
                        child: Container(
                            child: InkWell(
                          enableFeedback: true,
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.4),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Login',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ))),
                  ],
                ),
              )),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20, right: 30),
              child: Container(
                  child: InkWell(
                      enableFeedback: true,
                      onTap: () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RootScreen()));
                      },
                      child: Text(
                        'Just Exploring',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                      )))),
        )
      ],
    ));
  }
}
