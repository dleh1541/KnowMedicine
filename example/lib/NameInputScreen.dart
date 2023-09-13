import 'package:flutter/material.dart';
import 'BirthInputScreen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

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

  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak(
        '이름을 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 이름을 입력할 수 있습니다.'); // 원하는 메시지 읽기
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() async {
      _lastWords = result.recognizedWords;
      nameController.text = _lastWords;
      print("_lastWords: ${nameController.text}");
      await flutterTts.stop();
      await flutterTts.speak("입력된 이름: ${nameController.text}");
      await flutterTts.speak("맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
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
                Text('아이디: ${widget.id}'),
                Text('비밀번호: ${widget.pw}'),
                Form(
                  key: _formKey,
                  child: TextFormField(
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
                // TextFormField(
                //   controller: nameController,
                //   decoration: InputDecoration(labelText: '이름 입력'),
                // ),
                IconButton(
                  onPressed: () {
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
                  icon:
                      Icon(_speechToText.isListening ? Icons.stop : Icons.mic),
                  iconSize: 100,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
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
