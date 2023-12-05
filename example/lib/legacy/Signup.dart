import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupScreen> {
  // 필요한 상태 변수 및 컨트롤러를 선언하세요.
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String _selectedGender = "남성"; // 초기값으로 '남성' 설정
  DateTime? _selectedDate; // 선택된 날짜를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '아이디'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // 초기 선택 날짜
                    firstDate: DateTime(1900), // 사용 가능한 가장 이른 날짜
                    lastDate: DateTime.now(), // 사용 가능한 가장 늦은 날짜
                  );

                  if (selectedDate != null) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });

                    // 선택된 날짜를 텍스트 입력 필드에 표시
                    _dobController.text =
                        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(labelText: '생년월일'),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Text('성별: '),
                  Radio(
                    value: "남성",
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as String;
                      });
                    },
                  ),
                  Text('남성'),
                  Radio(
                    value: "여성",
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as String;
                      });
                    },
                  ),
                  Text('여성'),
                ],
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: '전화번호'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // 회원가입 버튼을 눌렀을 때 실행되는 로직을 추가하세요.
                  // 예를 들면, 이메일과 비밀번호를 사용하여 회원가입 요청을 보내는 코드 등을 추가할 수 있습니다.
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
