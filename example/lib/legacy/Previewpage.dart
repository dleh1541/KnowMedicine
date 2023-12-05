// import 'package:async/async.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:core';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_vision/flutter_vision.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'result.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PreviewPage extends StatefulWidget {
//   PreviewPage({Key? key, required this.picture}) : super(key: key);
//   final XFile picture;
//
//   @override
//   State<PreviewPage> createState() => _YoloState(key: key, picture: picture);
// }
//
// class _YoloState extends State<PreviewPage> {
//   _YoloState({Key? key, required this.picture});
//
//   final XFile picture;
//   File? imageFile;
//   int imageHeight = 1;
//   int imageWidth = 1;
//   int popcount = 0;
//   bool isLoaded = false;
//   late FlutterVision vision;
//   late List<Map<String, dynamic>> yoloResults;
//   late AsyncMemoizer _memoizer;
//   final FlutterTts tts = FlutterTts();
//   final TextEditingController controller =
//       TextEditingController(text: 'Hello world');
//   late SharedPreferences prefs;
//   double a = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     vision = FlutterVision();
//     _memoizer = AsyncMemoizer();
//     loadYoloModel().then((value) {
//       setState(() {
//         yoloResults = [];
//         isLoaded = true;
//       });
//     });
//     tts.setLanguage('ko-KR');
//     tts.setSpeechRate(0.7);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     getInitDate();
//   }
//
//   getInitDate() async {
//     prefs = await SharedPreferences.getInstance();
//     a = prefs.getDouble('speed') ?? 0.7;
//     tts.setSpeechRate(a);
//     setState(() {});
//   }
//
//   _fetchData() async {
//     return _memoizer.runOnce(() async {
//       // This below code will call only ones. This will return the same data directly without performing any Future task.
//       await yoloOnImage();
//       return 3;
//     });
//   }
//
//   void dispose() {
//     super.dispose();
//     //await vision.closeYoloModel();
//   }
//
//   getImage() async {
//     final XFile? pickedFile = picture;
//     if (pickedFile != null) {
//       setState(() {
//         imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!isLoaded) {
//       return const Scaffold(
//         backgroundColor: Colors.green, //Colors.amber
//         body: Center(
//           child: SpinKitFadingCircle(
//             color: Colors.white,
//             size: 80.0,
//           ),
//         ),
//       );
//     }
//
//     return FutureBuilder(
//         future: _fetchData(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             if (yoloResults.length >= 2) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 tts.speak("하나의 의약품만 촬영해 주세요");
//                 popcount++;
//                 if (popcount == 2) {
//                   Navigator.pop(context);
//                 }
//               });
//             } else if (yoloResults.isEmpty) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 tts.speak("다시 촬영해주세요");
//                 popcount++;
//                 if (popcount == 1) {
//                   Navigator.pop(context);
//                 }
//               });
//             } else if (yoloResults[0].values.last == "뒷면") {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 tts.speak("의약품의 앞면을 촬영해 주세요");
//                 popcount++;
//                 if (popcount == 2) {
//                   Navigator.pop(context);
//                 }
//               });
//             } else if (yoloResults.length == 1) {
//               return ResultScreen(yoloResults[0].values.last);
//             } else {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 tts.speak("다시 촬영해주세요");
//                 popcount++;
//                 if (popcount == 1) {
//                   Navigator.pop(context);
//                 }
//               });
//             }
//           }
//           return const Scaffold(
//             backgroundColor: Colors.green, //Colors.amber
//             body: Center(
//               child: SpinKitFadingCircle(
//                 color: Colors.white,
//                 size: 80.0,
//               ),
//             ),
//           );
//         });
//   }
//
//   Future<void> loadYoloModel() async {
//     await vision.loadYoloModel(
//         labels: 'assets/label.txt',
//         modelPath: 'assets/best_float32.tflite',
//         modelVersion: "yolov8",
//         numThreads: 2,
//         useGpu: true);
//     setState(() {
//       isLoaded = true;
//     });
//   }
//
//   Future<void> yoloOnImage() async {
//     await getImage();
//     yoloResults.clear();
//     Uint8List byte = await imageFile!.readAsBytes();
//     final image = await decodeImageFromList(byte);
//     imageHeight = image.height;
//     imageWidth = image.width;
//     final result = await vision.yoloOnImage(
//         bytesList: byte,
//         imageHeight: image.height,
//         imageWidth: image.width,
//         iouThreshold: 0.8,
//         confThreshold: 0.4,
//         classThreshold: 0.5);
//     if (result.isNotEmpty) {
//       setState(() {
//         yoloResults = result;
//       });
//     }
//   }
// }
