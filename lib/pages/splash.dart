import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:splitify/Pages/homepage.dart';
import 'package:splitify/Pages/signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    // Simulate a delay
    await Future.delayed(Duration(seconds: 2));

    // Check if the user is signed in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to HomeScreen
      Get.offAll(HomePage());
    } else {
      // User is not signed in, navigate to SignInScreen
      Get.offAll(SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
