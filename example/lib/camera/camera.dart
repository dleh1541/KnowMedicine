import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:know_medicine/result/result.dart';
import '../legacy/Previewpage.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../global_url.dart';

/// filename: camera.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 카메라 기능을 수행하는 화면
///     - 약품 촬영 후 서버에 업로드
///     - 이미지 분석 결과를 정상적으로 받으면 결과 화면으로 이동

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  late SharedPreferences prefs;
  final FlutterTts tts = FlutterTts(); // 음성 안내를 위한 TTS 변수 초기화
  double a = 0;
  bool isLoaded = true;
  DateTime? currentBackPressTime;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getInitDate();
  }

  /// 음성 안내를 제공하는 메서드
  getInitDate() async {
    prefs = await SharedPreferences.getInstance();
    a = prefs.getDouble('speed') ?? 0.5; // 말하기 속도 설정
    tts.setSpeechRate(a);
    tts.speak("원하시는 의약품을 촬영해주세요");
  }

  /// 사진 촬영 및 이미지 전송하는 메서드
  /// 서버 응답에 따라 결과 화면으로 이동하거나 오류 메시지 출력
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }

    setState(() {
      isLoaded = false;
    });

    try {
      await _cameraController.setFlashMode(FlashMode.auto);
      await _cameraController.setFocusMode(FocusMode.locked);
      await _cameraController.setExposureMode(ExposureMode.locked);
      // NativeShutterSound.play();
      XFile picture = await _cameraController.takePicture();
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setExposureMode(ExposureMode.auto);
      await _cameraController.setFlashMode(FlashMode.off);

      prefs = await SharedPreferences.getInstance();

      // HTTP POST 요청
      const urlString = "$globalURL/photo";
      final uri = Uri.parse(urlString);
      final request = http.MultipartRequest('POST', uri);

      //로컬 저장소에서 accesstoken 불러오기
      final accessToken = prefs.getString('accessToken');
      final user_id = prefs.getString('id');
      print(accessToken);
      // 사진 파일 추가
      final file = await http.MultipartFile.fromPath('photo', picture.path);
      request.files.add(file);

      // 필요한 경우 다른 데이터(헤더, 바디 등)를 추가
      request.headers['Authorization'] = 'Bearer $accessToken';
      // 'id' 필드에 'user_id' 추가
      if (user_id != null) {
        request.fields['id'] = user_id;
      }

      final response = await request.send();

      if (response.statusCode == 200) { // 성공적으로 업로드된 경우 처리
        print('사진 업로드 성공');

        final responseText = await response.stream.bytesToString();
        print('서버에서 받은 텍스트 데이터: $responseText');

        // JSON 문자열을 Map으로 파싱
        Map<String, dynamic> jsonData = json.decode(responseText);

        // "medicine_list" 키를 통해 Medicine 객체 목록으로 파싱
        List<Medicine> medicineList = (jsonData['medicine_list'] as List)
            .map((item) => Medicine.fromJson(item))
            .toList();

        setState(() {
          isLoaded = true;
        });

        // Name이 "뒷면"인 Medicine 객체가 있는지 확인
        bool containsBackSide = medicineList.any((medicine) => medicine.name == '뒷면');

        // ResultScreen으로 데이터를 전달하고 화면 전환
        if (medicineList.isNotEmpty && !containsBackSide) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => ResultScreen(responseText),
              builder: (context) => ResultScreen(medicineList),
            ),
          );
        } else if (containsBackSide) {
          tts.speak("약품의 뒷면입니다. 뒤집어서 다시 촬영해주세요.");
        } else {
          tts.speak("다시 촬영해주세요");
        }
      } else { // 업로드 실패 또는 오류 처리
        print('사진 업로드 실패: ${response.reasonPhrase}');
        tts.speak('네트워크 오류입니다. 다시 시도해주세요.');
        setState(() {
          isLoaded = true;
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  /// 카메라를 초기화하는 메서드
  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high);

    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  /// 카메라 화면 UI
  @override
  Widget build(BuildContext context) {
    // 로딩 애니메이션
    if (!isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.green, //Colors.amber
        body: Center(
          child: SpinKitFadingCircle(
            color: Colors.white,
            size: 80.0,
          ),
        ),
      );
    }

    return WillPopScope(
      child: Scaffold(
          body: SafeArea(
        child: Stack(children: [
          (_cameraController.value.isInitialized)
              ? CameraPreview(_cameraController)
              : Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator())),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    color: Colors.black),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                            _isRearCameraSelected
                                ? CupertinoIcons.switch_camera
                                : CupertinoIcons.switch_camera_solid,
                            color: Colors.white),
                        onPressed: () {
                          setState(() =>
                              _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(
                              widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      )),
                      Expanded(
                          child: IconButton(
                        onPressed: takePicture,
                        iconSize: 50,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.circle, color: Colors.white),
                      )),
                      const Spacer(),
                    ]),
              )),
        ]),
      )),
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('뒤로 가기 버튼을 한 번 더 누르면 앱을 종료합니다.'),
            ),
          );
          return false;
        }
        SystemNavigator.pop();
        return true;
      },
    );
  }
}

/// 약품 정보를 정의한 클래스
class Medicine {
  final String id;
  final String name;
  final String? thumbLink;
  final String effectType;
  final String effect;
  final String usageType;
  final String usage;
  final String cautionType;
  final String caution;

  Medicine({
    required this.id,
    required this.name,
    required this.thumbLink,
    required this.effectType,
    required this.effect,
    required this.usageType,
    required this.usage,
    required this.cautionType,
    required this.caution,
  });

  // JSON 데이터에서 Medicine 객체로 변환하는 팩토리 메서드
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['med_id'],
      name: json['name'],
      thumbLink: json['thumbLink'] as String?,
      effectType: json['effect_type'],
      effect: json['effect'],
      usageType: json['usage_type'],
      usage: json['usage'],
      cautionType: json['caution_type'],
      caution: json['caution'],
    );
  }
}
