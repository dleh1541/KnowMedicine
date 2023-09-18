import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:know_medicine/LocalAuth.dart';
import 'package:know_medicine/login.dart';
import 'package:know_medicine/Signup.dart';
import 'splash.dart';

void main() {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FlutterNativeSplash.remove();
    return MaterialApp(
      initialRoute: '\one',
      routes: {
        '\one': (context) => LoginScreen(),
        // '\one': (context) => LocalAuth(),
      },
    );
  }
}
