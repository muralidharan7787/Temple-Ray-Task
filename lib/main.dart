import 'package:flutter/material.dart';
import 'package:task_front/pages/SplashChecker.dart';

import 'SignInAndUp.dart';
import 'global/Common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilot Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'bevan',
        scaffoldBackgroundColor: Common.background,
        // splashColor: Colors.transparent,
        highlightColor: Colors.transparent,

        hoverColor: Colors.transparent,

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Common.secondary,              // Caret color (blinking)
          selectionColor: Common.secondary.withOpacity(0.3), // Text highlight
          selectionHandleColor: Common.secondary,     // Drag handle color
        ),

        // ✅ Global AppBar style
        appBarTheme: AppBarTheme(
          // systemOverlayStyle: SystemUiOverlayStyle(
          //   // statusBarColor: Common.primary, // ✅ match your intended color
          //   // statusBarIconBrightness: Brightness.light,
          // ),
          backgroundColor: Common.secondary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Common.primary),
          titleTextStyle: TextStyle(
            color: Common.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ✅ Global BottomNavigationBar style
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Common.secondary,
          selectedItemColor: Common.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: SplashChecker(),
    );
  }
}