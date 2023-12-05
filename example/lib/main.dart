import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:know_medicine/legacy/LocalAuth.dart';
import 'package:know_medicine/login/login.dart';
import 'package:know_medicine/legacy/Signup.dart';
import 'splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '\one',
      routes: {
        '\one': (context) => LoginScreen(),
      },
    );
  }
}
