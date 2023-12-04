import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:know_medicine/IDInputScreen.dart';
import 'package:know_medicine/globalURL.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

class AgreeScreen extends StatefulWidget {
  @override
  _AgreeScreenState createState() => _AgreeScreenState();
}

class _AgreeScreenState extends State<AgreeScreen> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  FlutterTts flutterTts = FlutterTts();
  String agreeText = '';

  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  @override
  void initState() {
    super.initState();
    _speakAgreeMessage();
  }

  void _speakAgreeMessage() async {
    await flutterTts.setLanguage('ko-KR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(
        '회원가입을 시작합니다. 개인정보수집 약관에 동의해주세요.\n개인정보 수집·이용 목적: KnowMedicine 앱의 회원 서비스 제공에 관련한 목적으로 개인정보를 수집합니다.\n수집·이용하려는 개인정보의 항목: 이름, 생년월일, 성별, 전화번호\n보유 및 이용 기간: 입력일로부터 1년까지\n위 약관에 동의하시면 화면 아래쪽을 눌러 다음 단계로 이동하세요');
  }

  Future<void> goNext() async {
    /*
    const urlString = "$globalURL/???";
    final url = Uri.parse(urlString);
    final response = await http.post(
      url,
      body: jsonEncode({
        // 인코딩할 정보
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    */

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => IDInputScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('회원가입 - 개인정보수집동의'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '이용약관에 동의해주세요.',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                      '개인정보 수집·이용 목적: KnowMedicine 앱의 회원 서비스 제공에 관련한 목적으로 개인정보를 수집합니다.\n\n'
                      '수집·이용하려는 개인정보의 항목: 이름, 생년월일, 성별, 전화번호\n\n'
                      '보유 및 이용 기간: 입력일로부터 1년까지'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 50),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      // Add your button onPressed logic here
                      goNext();
                    },
                    child: const Text(
                      '동의하기',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
