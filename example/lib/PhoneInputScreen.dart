import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:know_medicine/login.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 휴대폰 번호 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('아이디: ${widget.id}'),
            Text('비밀번호: ${widget.pw}'),
            Text('이름: ${widget.name}'),
            Text('생년월일: ${widget.birth}'),
            Text('성별: ${widget.gender}'),
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value!.length != 11) {
                    return '올바르지 않은 전화번호입니다.';
                  }
                },
                maxLength: 11,
                keyboardType: TextInputType.number,
                controller: textController,
                decoration: InputDecoration(
                    labelText: '휴대폰 번호 입력', border: OutlineInputBorder()),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                ],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                minimumSize: Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 원하는 둥글기 정도 조절
                ),
              ),
              onPressed: () {
                final formKeyState = _formKey.currentState!;

                if (formKeyState.validate()) {
                  formKeyState.save();
                  // 다음 단계로 이동
                  print("${textController.text}");
                }

                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => LoginScreen(),
                //   ),
                // );
              },
              child: Text('완료', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
