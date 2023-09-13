import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'PwInputScreen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
        '회원가입을 시작합니다. 원하시는 ID를 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 이름을 입력할 수 있습니다.'); // 원하는 메시지 읽기
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    effectSound.play(AssetSource("stt_start.mp3"));
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
      textController.text = _lastWords;
      print("_lastWords: ${textController.text}");
      await flutterTts.speak("입력된 ID: ${textController.text}, 맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
    });
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
                      maxLength: 20,
                      validator: (value) {
                        // if (value!.length < 5) {
                        //   return '5글자 이상 입력해주세요';
                        // }
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
                    icon: Icon(
                        _speechToText.isListening ? Icons.stop : Icons.mic),
                    iconSize: 100,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 50),
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
                            builder: (context) =>
                                PwInputScreen(id: textController.text),
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
        ));
  }
}
