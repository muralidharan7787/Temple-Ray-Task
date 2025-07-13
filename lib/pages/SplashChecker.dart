// splash_checker.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_front/global/Common.dart';

import '../NavMain.dart';
import '../SignInAndUp.dart';

class SplashChecker extends StatefulWidget {
  const SplashChecker({super.key});

  @override
  State<SplashChecker> createState() => _SplashCheckerState();
}

class _SplashCheckerState extends State<SplashChecker> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await Future.delayed(const Duration(seconds: 2)); // ⏳ Shows animation for 2 seconds

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NavMain()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInAndUp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Common.secondary,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Lottie.asset(
          'assets/animation/travel.json',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Container(
          height: 0,
          color: Common.secondary, // ✅ optional for background color match
        ),
      ),
    );
  }
}
