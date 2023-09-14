import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'NameInputScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PwInputScreen extends StatefulWidget {
  final String id;

  PwInputScreen({required this.id});

  @override
  _PwInputScreenState createState() => _PwInputScreenState();
}

class _PwInputScreenState extends State<PwInputScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _passwordKey = GlobalKey<FormState>(); // 비밀번호 필드를 위한 GlobalKey
  final _confirmPasswordKey =
      GlobalKey<FormState>(); // 비밀번호 확인 필드를 위한 GlobalKey
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

  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak(
        '원하시는 비밀번호를 입력해주세요. 화면 중앙을 터치하시면 음성인식으로 비밀번호를 입력할 수 있습니다.'); // 원하는 메시지 읽기
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
                  Text('아이디: ${widget.id}'),
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
                  SizedBox(
                    height: 16.0,
                  ),
                  Form(
                    key: _confirmPasswordKey, // 비밀번호 확인 필드의 GlobalKey를 설정
                    child: TextFormField(
                      style: TextStyle(fontSize: 20),
                      maxLength: 30,
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
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
                  //   icon: Icon(
                  //       _speechToText.isListening ? Icons.stop : Icons.mic),
                  //   iconSize: 100,
                  // ),
                  SizedBox(height: 16.0),
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
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Text('아이디: ${widget.id}'),
          //     Form(
          //       key: _passwordKey, // 비밀번호 필드의 GlobalKey를 설정
          //       child: TextFormField(
          //         maxLength: 30,
          //         controller: passwordController,
          //         obscureText: true,
          //         decoration: InputDecoration(
          //             labelText: '비밀번호 입력', border: OutlineInputBorder()),
          //         validator: (value) {
          //           if (value!.isEmpty) {
          //             return '1글자 이상 입력해주세요.';
          //           }
          //           value1 = value;
          //         },
          //       ),
          //     ),
          //     SizedBox(
          //       height: 16.0,
          //     ),
          //     Form(
          //       key: _confirmPasswordKey, // 비밀번호 확인 필드의 GlobalKey를 설정
          //       child: TextFormField(
          //         maxLength: 30,
          //         controller: confirmPasswordController,
          //         obscureText: true,
          //         decoration: InputDecoration(
          //             labelText: '비밀번호 다시 입력', border: OutlineInputBorder()),
          //         validator: (value) {
          //           // if (value!.isEmpty) {
          //           //   return '1글자 이상 입력해주세요.';
          //           // }
          //           if (value != value1) {
          //             print('value: ${value} / value1: ${value1}');
          //             return '비밀번호가 일치하지 않습니다.';
          //           }
          //         },
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         if (_speechEnabled) {
          //           if (!_speechToText.isListening) {
          //             _startListening();
          //           } else {
          //             _stopListening();
          //           }
          //         } else {
          //           print("Error: 음성인식 불가");
          //         }
          //       },
          //       icon: Icon(_speechToText.isListening ? Icons.stop : Icons.mic),
          //       iconSize: 100,
          //     ),
          //     SizedBox(height: 16.0),
          //     ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          //         minimumSize: Size(double.infinity, 0),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30.0), // 원하는 둥글기 정도 조절
          //         ),
          //       ),
          //       onPressed: () {
          //         final passwordKeyState = _passwordKey.currentState!;
          //         final confirmPasswordKeyState =
          //             _confirmPasswordKey.currentState!;
          //         if (passwordKeyState.validate() &&
          //             confirmPasswordKeyState.validate()) {
          //           passwordKeyState.save();
          //           confirmPasswordKeyState.save();
          //           Navigator.pushReplacement(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => NameInputScreen(
          //                     id: widget.id, pw: passwordController.text),
          //               ));
          //         }
          //       },
          //       child: Text('다음', style: TextStyle(fontSize: 24)),
          //     ),
          //   ],
          // ),
          ),
    );
  }
}

/*
class _PwInputScreenState extends State<PwInputScreen> {
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 비밀번호 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('아이디: ${widget.id}'),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 회원가입 완료 또는 다른 작업 수행
                // 비밀번호 입력 완료 후 회원가입을 완료하거나 다른 작업을 수행할 수 있음
              },
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }}
*/

/*
class _PwInputScreenState extends State<PwInputScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  String errorText = ''; // 비밀번호 불일치 오류 메시지
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 비밀번호 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('아이디: ${widget.id}'),
            Form(key: _formKey, child: TextFormField(
              maxLength: 30,
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
              validator: (value1) {
                if (value1!.isEmpty) {
                  return '1글자 이상 입력해주세요.';
                }
              },
            ),
            ),
            Form(key: _formKey, child: TextFormField(
              maxLength: 30,
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
              validator: (value2) {
                if (value1 != value2) {
                  return '1글자 이상 입력해주세요.';
                }
              },
            ),
            ),
            // TextFormField(
            //   controller: passwordController,
            //   obscureText: true,
            //   decoration: InputDecoration(labelText: '비밀번호'),
            // ),
            // TextFormField(
            //   controller: confirmPasswordController,
            //   obscureText: true,
            //   decoration: InputDecoration(labelText: '비밀번호 확인'),
            // ),
            SizedBox(height: 16.0),
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                final formKeyState = _formKey.currentState!;
                if (passwordController.text == confirmPasswordController.text) {
                  setState(() {
                    errorText = '비밀번호 일치!';
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NameInputScreen(
                                id: widget.id, pw: passwordController.text),
                      ));
                } else {
                  setState(() {
                    errorText = '비밀번호가 일치하지 않습니다.';
                  });
                }
              },
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
