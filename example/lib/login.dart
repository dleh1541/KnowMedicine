import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:know_medicine/Signup.dart';
import 'package:know_medicine/splash.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    print('loginUser() 호출됨');

    const urlString = 'http://192.168.55.176:3306/login';
    // final url = Uri.parse('http://192.168.55.176:3306/login'); // 서버의 URL을 여기에 입력하세요.
    final url = Uri.parse(urlString);

    final response = await http.post(
      url,
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // 서버로부터 응답을 성공적으로 받았을 때 실행할 코드
      // 로그인 성공 또는 다른 작업 수행
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else {
      // 서버로부터 오류 응답을 받았을 때 실행할 코드
      // 로그인 실패 또는 오류 처리
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("로그인 실패"),
            content: Text("아이디 또는 비밀번호가 잘못되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> logoutUser() async {
    const urlString = 'http://192.168.55.176:3306/logout';
    // final url = Uri.parse('http://192.168.55.176:3306/login'); // 서버의 URL을 여기에 입력하세요.
    final url = Uri.parse(urlString);

    final response = await http.post(
      url,
      body: jsonEncode({
        'username': 'logoutTest_id',
        'password': 'logoutTest_pw',
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('logoutUser() 호출됨');

    if (response.statusCode == 200) {
      // 서버로부터 응답을 성공적으로 받았을 때 실행할 코드
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("로그아웃 성공"),
            content: Text("로그아웃되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    } else {
      // 서버로부터 오류 응답을 받았을 때 실행할 코드
      // 로그인 실패 또는 오류 처리
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("로그아웃 실패"),
            content: Text("알 수 없는 오류로 로그아웃에 실패했습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: double.infinity,
        // height: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: 90,
              top: 150,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/image/silla2.png'), // 로컬 이미지의 경로
                  ),
                ),
              ),
            ), // 로고
            Positioned(
              left: 37,
              top: 369,
              child: SizedBox(
                width: 291,
                height: 62,
                child: TextFormField(
                  // Add TextFormField for username input
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(
                      color: Color(0xFF696363),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ), // 아이디
            Positioned(
              left: 37,
              top: 462,
              child: SizedBox(
                width: 291,
                height: 62,
                child: TextFormField(
                  // Add TextFormField for password input
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(
                      color: Color(0xFF726B6B),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
            ), // 비밀번호
            Positioned(
              left: 77,
              top: 620,
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ), // 회원가입
            Positioned(
              left: 210,
              top: 620,
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ), // 비밀번호 찾기
            Positioned(
              left: 37,
              top: 545,
              child: Container(
                width: 291,
                height: 54,
                child: ElevatedButton(
                  onPressed: loginUser, // '로그인' 버튼을 누르면 loginUser 함수 호출
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF38BEEF),
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ), // 로그인 버튼

            Positioned(
                left: 37,
                top: 650,
                child: Container(
                  width: 291,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: logoutUser,
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF38BEEF),
                    ),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )), // 로그아웃 버튼
          ],
        ),
      ),
    ));
  }
}
