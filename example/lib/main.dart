import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:know_medicine/legacy/LocalAuth.dart';
import 'package:know_medicine/login/login.dart';
import 'package:know_medicine/legacy/Signup.dart';
import 'splash.dart';

/// filename: main.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///    - KnowMedicine 앱의 진입점을 정의
///    - 앱이 실행되면 LoginScreen()으로 이동
///    - 안드로이드 스튜디오 버전: Android Studio Giraffe | 2022.3.1 Patch 1
///    - Dart 버전: 3.1.0
///    - Flutter 버전: 3.13.2

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
