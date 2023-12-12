import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:know_medicine/register/pw_input.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../global_url.dart';

/// filename: id_input.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 회원가입 화면 (2)
///     - 아이디 입력. 중복 검사
///     - 음성인식으로 입력(STT) 기능 제공

class IDInputScreen extends StatefulWidget {
  @override
  _IDInputScreenState createState() => _IDInputScreenState();
}

class _IDInputScreenState extends State<IDInputScreen> {
  final TextEditingController textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  FlutterTts flutterTts = FlutterTts();
  final effectSound = AudioPlayer();
  bool _isInputComplete = false;
  bool _isListening = false;
  bool _isIdAvailable = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _speakGuideMessage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  /// 안내 메시지를 재생하는 메서드
  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak(
        '원하시는 ID를 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 이름을 입력할 수 있습니다.'); // 원하는 메시지 읽기
  }

  /// STT용 변수를 초기화하는 메서드
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// STT 시작하는 메서드
  void _startListening() async {
    // logger.d("_startListening() 호출: ${DateTime.now().toLocal()}");
    effectSound.play(AssetSource("stt_start.mp3"));
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// STT 중지하는 메서드
  void _stopListening() async {
    // logger.d("_stopListening() 호출: ${DateTime.now().toLocal()}");
    await _speechToText.stop();
    setState(() {});
  }

  /// 음성인식 결과를 텍스트로 변환하는 메서드
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() async {
      _lastWords = result.recognizedWords;
      textController.text = _lastWords;
      print("_lastWords: ${textController.text}");
      await flutterTts.speak(
          "입력된 ID: ${textController.text}, 맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
    });
  }

  /// 아이디 중복검사 메서드
  Future<void> checkId() async {
    logger.d("checkId() 호출됨");

    // const urlString = 'http://192.168.55.176:3306/idValidation';
    const urlString = "$globalURL/idValidation";
    final url = Uri.parse(urlString);
    final response = await http.post(
      url,
      body: jsonEncode({
        'id': textController.text,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      setState(() {
        _isIdAvailable = true;
      });

      // 이상 없으면 다음 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PwInputScreen(id: textController.text),
        ),
      );
    } else {
      setState(() {
        _isIdAvailable = false;
      });
      flutterTts.speak("이미 사용 중인 아이디입니다.");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('회원가입 - 아이디 입력'),
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
                      style: TextStyle(fontSize: 20),
                      maxLength: 20,
                      validator: (value) {
                        if (value!.isEmpty) {
                          flutterTts.speak('아이디를 1글자 이상 입력해주세요.');
                          return '1글자 이상 입력해주세요.';
                        }
                      },
                      controller: textController,
                      onEditingComplete: () =>
                          {print("onEditingComplete 콜백 호출!")},
                      decoration: const InputDecoration(
                          labelText: '아이디 입력', border: OutlineInputBorder()),
                    ),
                  ),
                  if (_isIdAvailable == false)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        "이미 사용 중인 아이디입니다.",
                        style: TextStyle(color: Colors.redAccent),
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
                            BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      final formKeyState = _formKey.currentState!;
                      if (formKeyState.validate()) {
                        formKeyState.save();
                        checkId();
                      }
                    },
                    child: const Text('다음', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
