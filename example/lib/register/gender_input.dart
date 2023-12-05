import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:know_medicine/register/phone_input.dart';

class GenderInputScreen extends StatefulWidget {
  final String id;
  final String pw;
  final String name;
  final String birth;

  GenderInputScreen({
    required this.id,
    required this.pw,
    required this.name,
    required this.birth,
  });

  @override
  _GenderInputScreenState createState() => _GenderInputScreenState();
}

class _GenderInputScreenState extends State<GenderInputScreen> {
  String? selectedGender; // 선택한 성별을 저장할 변수
  bool isMale = false;
  bool isFemale = false;
  late List<bool> isSelected;
  String? errorMessage; // 에러 메시지
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakGuideMessage();
    isSelected = [isMale, isFemale];
  }

  void _speakGuideMessage() async {
    await flutterTts.setLanguage('ko-KR'); // 한국어 설정
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정
    await flutterTts.speak('성별을 선택해주세요. 왼쪽이 남성, 오른쪽이 여성입니다.'); // 원하는 메시지 읽기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 성별 입력'),
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
                // Text('생년월일: ${widget.birth}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Radio<String>(
                    //   value: '남성',
                    //   groupValue: selectedGender,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedGender = value;
                    //       errorMessage = null;
                    //       flutterTts.speak('남성');
                    //     });
                    //   },
                    // ),
                    // Text('남성', style: TextStyle(fontSize: 24)),
                    // Radio<String>(
                    //   value: '여성',
                    //   groupValue: selectedGender,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedGender = value;
                    //       errorMessage = null;
                    //       flutterTts.speak('여성');
                    //     });
                    //   },
                    // ),
                    // Text('여성', style: TextStyle(fontSize: 24)),
                    ToggleButtons(
                      color: Colors.black26,
                      constraints: BoxConstraints.expand(
                          width: ((MediaQuery.of(context).size.width - 36) / 2),
                          height: 100),
                      isSelected: isSelected,
                      onPressed: (value) {
                        if (value == 0) {
                          isMale = true;
                          isFemale = false;
                          selectedGender = '남성';
                        } else {
                          isMale = false;
                          isFemale = true;
                          selectedGender = '여성';
                        }
                        setState(() {
                          isSelected = [isMale, isFemale];
                        });
                        flutterTts.speak(selectedGender!);
                      },
                      children: const [
                        Text(
                          '남성',
                          style: TextStyle(fontSize: 36),
                        ),
                        Text(
                          '여성',
                          style: TextStyle(fontSize: 36),
                        ),
                      ],
                    )
                  ],
                ),
                if (errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
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
                    if (selectedGender == null) {
                      // if (isSelected == null) {
                      setState(() {
                        errorMessage = '성별을 선택해주세요.';
                        flutterTts.speak('성별이 선택되지 않았습니다. 성별을 선택해주세요.');
                      });
                    } else {
                      // 다음 단계로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneInputScreen(
                            id: widget.id,
                            pw: widget.pw,
                            name: widget.name,
                            birth: widget.birth,
                            gender: selectedGender ?? '', // 선택한 성별
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

// class _GenderInputScreenState extends State<GenderInputScreen> {
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
//             Text('생년월일: ${widget.birth}'),
//             TextField(
//               controller: textController,
//               decoration: InputDecoration(labelText: '성별 입력'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // 다음 단계로 이동
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PhoneInputScreen(
//                         id: widget.id,
//                         pw: widget.pw,
//                         name: widget.name,
//                         birth: widget.birth,
//                         gender: textController.text),
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