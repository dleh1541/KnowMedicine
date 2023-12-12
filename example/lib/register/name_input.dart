import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

import 'birth_input.dart';

/// filename: name_input.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 회원가입 화면 (4)
///     - 이름 입력
///     - 음성인식으로 입력(STT) 기능 제공

class NameInputScreen extends StatefulWidget {
  final String id;
  final String pw;

  NameInputScreen({required this.id, required this.pw});

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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

  /// 안내 메시지를 재생하는 메서드
  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts
        .speak('이름을 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 이름을 입력할 수 있습니다.'); // 원하는 메시지 읽기
  }

  /// STT용 변수를 초기화하는 메서드
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
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
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() async {
      _lastWords = result.recognizedWords;
      nameController.text = _lastWords;
      print("_lastWords: ${nameController.text}");
      await flutterTts.stop();
      await flutterTts.speak(
          "입력된 이름: ${nameController.text}, 맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 이름 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text('아이디: ${widget.id}'),
                // Text('비밀번호: ${widget.pw}'),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    style: TextStyle(fontSize: 20),
                    maxLength: 10,
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: '이름 입력', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        flutterTts.speak('이름을 1글자 이상 입력해주세요.');
                        return '1글자 이상 입력해주세요.';
                      }
                    },
                  ),
                ),
                Container(
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
                // TextFormField(
                //   controller: nameController,
                //   decoration: InputDecoration(labelText: '이름 입력'),
                // ),
                // IconButton(
                //   onPressed: () {
                //     if (_speechEnabled) {
                //       if (!_speechToText.isListening) {
                //         _startListening();
                //       } else {
                //         _stopListening();
                //       }
                //     } else {
                //       print("Error: 음성인식 불가");
                //     }
                //   },
                //   icon:
                //       Icon(_speechToText.isListening ? Icons.stop : Icons.mic),
                //   iconSize: 100,
                // ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                    minimumSize: Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // 원하는 둥글기 정도 조절
                    ),
                  ),
                  onPressed: () {
                    final formKeyState = _formKey.currentState!;

                    if (formKeyState.validate()) {
                      formKeyState.save();
                      // 다음 단계로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BirthInputScreen(
                            id: widget.id,
                            pw: widget.pw,
                            name: nameController.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('다음', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
