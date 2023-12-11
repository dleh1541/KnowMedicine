import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'name_input.dart';

/// filename: pw_input.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 회원가입 화면 (3)
///     - 비밀번호 입력. 비밀번호 확인
///     - 음성인식으로 입력(STT) 기능 제공

class PwInputScreen extends StatefulWidget {
  final String id;

  PwInputScreen({required this.id});

  @override
  _PwInputScreenState createState() => _PwInputScreenState();
}

class _PwInputScreenState extends State<PwInputScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _passwordKey = GlobalKey<FormState>(); // 비밀번호 필드를 위한 GlobalKey
  final _confirmPasswordKey = GlobalKey<FormState>(); // 비밀번호 확인 필드를 위한 GlobalKey
  String? value1;
  String? value2;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  FlutterTts flutterTts = FlutterTts();
  final effectSound = AudioPlayer();
  bool _isInputComplete = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _speakGuideMessage();
  }

  /// STT용 변수를 초기화하는 메서드
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// 안내 메시지를 재생하는 메서드
  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak(
        '원하시는 비밀번호를 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 비밀번호를 입력할 수 있습니다.'); // 메시지 읽기
  }

  /// STT 시작하는 메서드
  void _startListening() async {
    effectSound.play(AssetSource("stt_start.mp3"));
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// STT 중지하는 메서드
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// 음성인식 결과를 텍스트로 변환하는 메서드
  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() async {
      _lastWords = result.recognizedWords;
      passwordController.text = _lastWords;
      confirmPasswordController.text = _lastWords;
      print("_lastWords: ${passwordController.text}");
      await flutterTts.stop();
      await flutterTts.speak(
          "입력된 비밀번호: ${passwordController.text}, 맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 비밀번호 입력'),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _passwordKey, // 비밀번호 필드의 GlobalKey를 설정
                    child: TextFormField(
                      style: const TextStyle(fontSize: 20),
                      maxLength: 30,
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: '비밀번호 입력', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value!.isEmpty) {
                          flutterTts.speak('비밀번호를 1글자 이상 입력해주세요.');
                          return '1글자 이상 입력해주세요.';
                        }
                        value1 = value;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Form(
                    key: _confirmPasswordKey, // 비밀번호 확인 필드의 GlobalKey를 설정
                    child: TextFormField(
                      style: TextStyle(fontSize: 20),
                      maxLength: 30,
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: '비밀번호 다시 입력',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        // if (value!.isEmpty) {
                        //   return '1글자 이상 입력해주세요.';
                        // }
                        if (value != value1) {
                          print('value: ${value} / value1: ${value1}');
                          return '비밀번호가 일치하지 않습니다.';
                        }
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {
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
                      padding:
                          EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                      minimumSize: Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // 원하는 둥글기 정도 조절
                      ),
                    ),
                    onPressed: () {
                      final passwordKeyState = _passwordKey.currentState!;
                      final confirmPasswordKeyState =
                          _confirmPasswordKey.currentState!;
                      if (passwordKeyState.validate() &&
                          confirmPasswordKeyState.validate()) {
                        passwordKeyState.save();
                        confirmPasswordKeyState.save();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NameInputScreen(
                                  id: widget.id, pw: passwordController.text),
                            ));
                      }
                    },
                    child: Text('다음', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          )
          ),
    );
  }
}