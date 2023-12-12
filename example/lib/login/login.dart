import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:know_medicine/legacy/Signup.dart';
import 'package:know_medicine/splash.dart';
import 'package:know_medicine/legacy/stt.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../global_url.dart';
import '../register/agree.dart';

/// filename: login.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 앱 실행 시 가장 먼저 실행되는 화면
///     - 아이디, 비밀번호를 입력받아 로그인을 수행
///     - 저장된 회원정보가 있을 시, 자동로그인 수행
///     - 저장된 회원정보가 없을 시, 회원가입 화면으로 이동

// 콘솔에 디버그용 메세지를 출력하기 위한 Logger 변수 정의
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
  final _idKey = GlobalKey<FormState>();
  final _pwKey = GlobalKey<FormState>();
  String? errMsg;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initPrefs();
    autoLogin();
  }

  /// SharedPreference를 초기화하는 메서드
  /// SharedPreference는 key-value 형식으로 데이터를 로컬 디바이스에 저장함
  /// 회원정보 및 액세스 토큰을 저장하기 위해 사용
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    logger.d("initPrefs() 완료");
  }

  /// 로딩 다이얼로그
  /// 로그인 시, 서버와 통신하는 동안 로딩 애니메이션을 표시
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  /// 로그인을 수행하는 메서드
  Future<void> loginUser(String userName, String passWord) async {
    logger.d('loginUser() 호출됨');
    prefs = await SharedPreferences.getInstance();
    // const urlString = 'http://192.168.55.176:3306/login';
    const urlString = "$globalURL/login";
    final url = Uri.parse(urlString);

    try {
      _showLoadingDialog(); // 로딩 애니메이션 작동

      // POST 방식으로 로그인 요청
      final response = await http.post(
        url,
        body: jsonEncode({
          'username': userName,
          'password': passWord,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException(
            'Connection Time Out'); // 5초 이상 서버 응답이 없으면 TimeoutException 발생
      });

      if (!mounted) return;

      Navigator.pop(context); // 로딩 애니메이션 중지

      if (response.statusCode == 200) { // 서버로부터 정상적으로 응답이 왔을 때
        Map<String, dynamic> responseData = jsonDecode(response.body);

        String accessToken = responseData['access_token'];
        prefs.setString('accessToken', accessToken); // 액세스 토큰을 sharedPreference에 저장
        prefs.setString('id', userName); // 아이디도 sharedPreference에 저장

        // 다음 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else { // 서버로부터 응답이 정상적이지 않을 때
        // 로그인 실패 다이얼로그를 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("로그인 실패"),
              content: const Text("아이디 또는 비밀번호가 잘못되었습니다."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      }
    } on TimeoutException { // TimeoutException 발생 시
      if (!mounted) return;

      Navigator.pop(context); // 로딩 애니메이션 중지

      // 서버 연결 실패 다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("서버 연결 실패"),
            content: const Text("서버 연결에 실패했습니다. 나중에 다시 시도해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    } on SocketException { // SocketException 발생 시 (네트워크에 연결 되어있지 않을 때)
      if (!mounted) return;

      Navigator.pop(context); // 로딩 애니메이션 중지

      // 네트워크 오류 다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("네트워크 오류"),
            content: const Text("기기가 네트워크에 연결되어 있지 않습니다. 네트워크를 확인해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

  /// 로그아웃을 수행하는 메서드 (현재 미사용)
  Future<void> logoutUser() async {
    // const urlString = 'http://192.168.55.176:3306/logout';
    const urlString = "$globalURL/logout";
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

  /// 자동 로그인을 수행하는 메서드
  Future<void> autoLogin() async {
    prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    String? id = prefs.getString('id');
    String? pw = prefs.getString('pw');

    if (token != null && id != null && pw != null) { // 액세스 토큰, 아이디, 비밀번호가 저장되어 있을 때
      logger.d("액세스 토큰 확인 성공");
      showPrefs();
      loginUser(id, pw); // 로그인 메서드 호출
    } else {
      logger.d("액세스 토큰 확인 실패");
      showPrefs();

      if (!mounted) return;
      // 토큰 정보가 없을경우 바로 회원가입 화면으로 넘어감
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AgreeScreen()));
    }
  }

  /// SharedPreference에 저장된 내용을 출력하는 메서드
  void showPrefs() {
    final allKeys = prefs.getKeys();
    String prefsData = "";
    int keyCount = 0;

    for (final key in allKeys) {
      final value = prefs.get(key);
      prefsData += '$key: $value';
      if (++keyCount < allKeys.length) {
        prefsData += '\n';
      }
    }

    logger.d(prefsData);
  }

  // 화면 UI를 정의하는 위젯
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
                      // 아이디가 비어있을 때
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
                      // 비밀번호가 비어있을 때
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
                height: 20,
              ),
              ElevatedButton(
                // '로그인' 버튼
                onPressed: () {
                  final idKeyState = _idKey.currentState!;
                  final pwKeyState = _pwKey.currentState!;

                  logger.d(
                      "idKeyState: ${idKeyState.validate()}, pwKeyState: ${pwKeyState.validate()}");

                  if (idKeyState.validate() && pwKeyState.validate()) {
                    idKeyState.save();
                    pwKeyState.save();
                    loginUser(usernameController.text,
                        passwordController.text); // loginUser 메서드 호출
                  }
                },
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
                    onTap: () { // 회원가입 화면으로 이동
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AgreeScreen()));
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
                    onTap: () {}, // 비밀번호 찾기 기능은 미구현
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
