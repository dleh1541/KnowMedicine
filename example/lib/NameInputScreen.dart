import 'package:flutter/material.dart';
import 'BirthInputScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 - 이름 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                    return '1글자 이상 입력해주세요.';
                  }
                },
              ),
            ),
            // TextFormField(
            //   controller: nameController,
            //   decoration: InputDecoration(labelText: '이름 입력'),
            // ),
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
    );
  }
}
