import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:know_medicine/login/login.dart';
import 'camera/camera.dart';

/// filename: splash.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 카메라 화면에 진입하기 전 스플래시 화면
///     - 카메라를 불러오는 동안 대기

class SplashScreen extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  // 비동기로 카메라를 불러오는 함수
  _asyncMethod() async {
    await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(child: GestureDetector(
            onTap: () {
              availableCameras().then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CameraPage(cameras: value))));
            },
          )),
        ),
      ),
    );
  }
}
