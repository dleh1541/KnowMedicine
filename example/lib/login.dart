import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:know_medicine/IDInputScreen.dart';
import 'package:know_medicine/Signup.dart';
import 'package:know_medicine/splash.dart';
import 'package:know_medicine/stt.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  final _idKey = GlobalKey<FormState>();
  final _pwKey = GlobalKey<FormState>();
  String? errMsg;

  @override
  void initState() {
    super.initState();
    initPrefs();
    autoLogin();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    logger.d("initPrefs() 완료");
  }

  Future<void> loginUser(String userName, String passWord) async {
    logger.d('loginUser() 호출됨');
    prefs = await SharedPreferences.getInstance();

    // prefs 데이터 확인
    // final allKeys = prefs.getKeys();
    // for (final key in allKeys) {
    //   final value = prefs.get(key);
    //   logger.d('Key: $key, Value: $value');
    // }

    const urlString = 'http://192.168.55.176:3306/login';
    // final url = Uri.parse('http://192.168.55.176:3306/login'); // 서버의 URL을 여기에 입력하세요.
    final url = Uri.parse(urlString);

    final response = await http.post(
      url,
      body: jsonEncode({
        // 'username': usernameController.text,
        // 'password': passwordController.text,
        'username': userName,
        'password': passWord,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // 서버로부터 응답을 성공적으로 받았을 때 실행할 코드
      // 로그인 성공 또는 다른 작업 수행
      // JSON 응답을 파싱하여 Map 형태로 변환
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // "access_token" 값을 추출
      String accessToken = responseData['access_token'];
      prefs.setString('accessToken', accessToken);
      prefs.setString('username', usernameController.text);

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

  Future<void> autoLogin() async {
    prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    String? id = prefs.getString('username');
    String? pw = prefs.getString('password');

    if (token != null && id != null && pw != null) {
      logger.d("액세스 토큰 확인 성공");
      loginUser(id, pw);
    } else {
      logger.d("액세스 토큰 확인 실패");
      // prefs 정보 출력
      final allKeys = prefs.getKeys();
      String prefsData = "";
      for (final key in allKeys) {
        final value = prefs.get(key);
        prefsData += '${key}: ${value}\n';
      }
      logger.d(prefsData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/image/silla.svg',
                width: 180,
                height: 180,
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: _idKey,
                child: TextFormField(
                  style: const TextStyle(fontSize: 20),
                  controller: usernameController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.account_circle, color: Colors.black26),
                    hintText: '아이디',
                    hintStyle: TextStyle(
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '아이디를 입력해주세요.';
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Form(
                key: _pwKey,
                child: TextFormField(
                  // Add TextFormField for password input
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "비밀번호를 입력해주세요.";
                    }
                  },
                  controller: passwordController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black26),
                    hintText: '비밀번호',
                    hintStyle: TextStyle(
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 20),
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  final idKeyState = _idKey.currentState!;
                  final pwKeyState = _pwKey.currentState!;

                  logger.d(
                      "idKeyState: ${idKeyState.validate()}, pwKeyState: ${pwKeyState.validate()}");

                  if (idKeyState.validate() && pwKeyState.validate()) {
                    idKeyState.save();
                    pwKeyState.save();
                    loginUser(usernameController.text, passwordController.text);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SplashScreen()),
                    // );
                  }
                }, // '로그인' 버튼을 누르면 loginUser 함수 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BEEF),
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => SignupScreen()));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IDInputScreen()));
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              // ElevatedButton(
              //   onPressed: logoutUser,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF38BEEF),
              //   ),
              //   child: Text(
              //     '로그아웃',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 20,
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w700,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    ));
  }
}
