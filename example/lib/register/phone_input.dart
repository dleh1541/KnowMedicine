import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:know_medicine/login/login.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../global_url.dart';

/// filename: phone_input.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 회원가입 화면 (7)
///     - 전화번호 입력
///     - 회원가입 성공 시, 로그인 화면으로 이동

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class PhoneInputScreen extends StatefulWidget {
  final String id;
  final String pw;
  final String name;
  final String birth;
  final String gender;

  PhoneInputScreen({
    required this.id,
    required this.pw,
    required this.name,
    required this.birth,
    required this.gender,
  });

  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final effectSound = AudioPlayer();
  FlutterTts flutterTts = FlutterTts();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    initPrefs();
    _speakGuideMessage();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// 안내 메시지를 재생하는 메서드
  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak(
        '휴대폰 번호를 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 휴대폰 번호를 입력할 수 있습니다.'); // 원하는 메시지 읽기
  }

  /// STT용 변수를 초기화하는 메서드
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// STT 시작하는 메서드
  void _startListening() async {
    effectSound.play(AssetSource('stt_start.mp3'));
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// STT 중지하는 메서드
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// 음성인식 결과를 텍스트로 변환하는 메서드
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() async {
      _lastWords = result.recognizedWords;
      textController.text = _lastWords.replaceAll('-', '');
      print("_lastWords: ${textController.text}");
      await flutterTts.stop();
      await flutterTts.speak(
          "입력된 전화번호: ${textController.text}, 맞으시면 화면 아래쪽을 눌러 회원가입을 완료하세요.");
    });
  }

  /// 입력받은 정보로 회원가입 수행하는 메서드
  Future<void> signUpUser() async {
    logger.d('signUpUser() 호출됨');

    await prefs.setString("id", widget.id);
    await prefs.setString("pw", widget.pw);
    await prefs.setString("name", widget.name);
    await prefs.setString("birth", widget.birth);
    await prefs.setString("gender", widget.gender);
    await prefs.setString("phone", textController.text);

    // prefs 데이터 확인
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      final value = prefs.get(key);
      logger.d('Key: $key, Value: $value');
    }

    // const urlString = 'http://192.168.55.176:3306/signup';
    const urlString = "$globalURL/signup";
    final url = Uri.parse(urlString);
    final response = await http.post(
      url,
      body: jsonEncode({
        'user_id': widget.id,
        'password': widget.pw,
        'name': widget.name,
        'birthday': widget.birth,
        'gender': widget.gender,
        'phone': textController.text
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
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('id', widget.id);
      await prefs.setString('pw', widget.pw);

      await flutterTts.speak("회원가입을 완료했습니다.");
      await Future.delayed(const Duration(seconds: 3)); // 3초 대기 (TTS가 완료될 때까지)

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } else {
      // 서버로부터 오류 응답을 받았을 때 실행할 코드
      // 로그인 실패 또는 오류 처리
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("회원가입 실패"),
            content: const Text("회원가입에 실패했습니다. 다시 시도해주세요."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입 - 휴대폰 번호 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 20),
                    validator: (value) {
                      if (value!.length != 11) {
                        flutterTts.speak('올바르지 않은 전화번호입니다. 다시 입력해주세요.');
                        return '올바르지 않은 전화번호입니다.';
                      }
                    },
                    maxLength: 11,
                    keyboardType: TextInputType.number,
                    controller: textController,
                    decoration: const InputDecoration(
                        labelText: '휴대폰 번호 입력', border: OutlineInputBorder()),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity, // 원하는 가로 너비로 조절
                  child: InkWell(
                    onTap: () {
                      // 아이콘 버튼이 클릭되었을 때 실행할 코드
                      if (_speechEnabled) {
                        if (!_speechToText.isListening) {
                          _startListening();
                        } else {
                          _stopListening();
                        }
                      } else {
                        print("Error: 음성인식 불가");
                      }
                    },
                    child: Icon(
                      _speechToText.isListening ? Icons.stop : Icons.mic,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 50),
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // 원하는 둥글기 정도 조절
                    ),
                  ),
                  onPressed: () {
                    final formKeyState = _formKey.currentState!;

                    if (formKeyState.validate()) {
                      formKeyState.save();
                      print("${textController.text}");
                      signUpUser();
                    }

                    },
                  child: const Text('완료', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
