import 'package:flutter/material.dart';
import 'package:know_medicine/login.dart';
import 'package:know_medicine/Signup.dart';
import 'splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '\one',
      routes: {
        // '\one': (context)=> SplashScreen(),
        '\one': (context)=> LoginScreen(),
        // '\one': (context) => SignupScreen(),
        // '\one': (context) => TestScreen(),
      },
    );
  }
}
