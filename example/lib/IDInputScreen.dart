import 'package:flutter/material.dart';

import 'PwInputScreen.dart';

class IDInputScreen extends StatefulWidget {
  @override
  _IDInputScreenState createState() => _IDInputScreenState();
}

class _IDInputScreenState extends State<IDInputScreen> {
  final TextEditingController textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 아이디 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                    return '1글자 이상 입력해주세요.';
                  }
                },
                controller: textController,
                decoration: const InputDecoration(
                    labelText: '아이디 입력', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 16.0),
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
    );
  }
}
