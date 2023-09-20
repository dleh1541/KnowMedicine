import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'GenderInputScreen.dart';

class BirthInputScreen extends StatefulWidget {
  final String id;
  final String pw;
  final String name;

  BirthInputScreen({required this.id, required this.pw, required this.name});

  @override
  _BirthInputScreenState createState() => _BirthInputScreenState();
}

class _BirthInputScreenState extends State<BirthInputScreen> {
  DateTime? selectedDate; // 선택한 날짜를 저장할 변수
  String? errorMessage; // 에러 메시지
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakGuideMessage();
  }

  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak('생년월일을 입력해주세요.'); // 원하는 메시지 읽기
  }

  // 생년월일 선택 팝업 호출
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        errorMessage = null;
        String date = selectedDate!.toLocal().toString().split(' ')[0];
        List<String> dateParts = date.split('-');
        flutterTts.speak(
            "${dateParts[0]}년 ${dateParts[1]}월 ${dateParts[2]}일, 맞으시면 화면 아래쪽을 눌러 다음 단계로 이동하세요.");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 생년월일 입력'),
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
                // Text('이름: ${widget.name}'),
                // if (selectedDate != null)
                //   Text('생년월일: ${selectedDate!.toLocal()}'.split(' ')[0]),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 100)),
                  onPressed: () => _selectDate(context), // 날짜 선택 팝업 호출
                  child: const Text('생년월일 선택',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  selectedDate?.toLocal().toString().split(' ')[0] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
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
                    if (selectedDate == null) {
                      setState(() {
                        errorMessage = '생년월일을 선택해주세요.';
                      });
                    } else {
                      // 다음 단계로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenderInputScreen(
                            id: widget.id,
                            pw: widget.pw,
                            name: widget.name,
                            birth: selectedDate
                                    ?.toLocal()
                                    .toString()
                                    .split(' ')[0] ??
                                '',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class _BirthInputScreenState extends State<BirthInputScreen> {
//   final TextEditingController textController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('회원가입 - 생년월일 입력'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('아이디: ${widget.id}'),
//             Text('비밀번호: ${widget.pw}'),
//             Text('이름: ${widget.name}'),
//             TextField(
//               controller: textController,
//               decoration: InputDecoration(labelText: '생년월일 입력'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // 다음 단계로 이동
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => GenderInputScreen(
//                         id: widget.id,
//                         pw: widget.pw,
//                         name: widget.name,
//                         birth: textController.text),
//                   ),
//                 );
//               },
//               child: Text('다음'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
