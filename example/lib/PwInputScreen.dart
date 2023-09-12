import 'package:flutter/material.dart';

import 'NameInputScreen.dart';

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
            Form(
              key: _passwordKey, // 비밀번호 필드의 GlobalKey를 설정
              child: TextFormField(
                maxLength: 30,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: '비밀번호 입력', border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '1글자 이상 입력해주세요.';
                  }
                  value1 = value;
                },
              ),
            ),
            SizedBox(height: 16.0,),
            Form(
              key: _confirmPasswordKey, // 비밀번호 확인 필드의 GlobalKey를 설정
              child: TextFormField(
                maxLength: 30,
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: '비밀번호 다시 입력', border: OutlineInputBorder()),
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
