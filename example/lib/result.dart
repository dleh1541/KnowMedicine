import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "dart:io";
import 'package:audioplayers/audioplayers.dart';
import 'package:know_medicine/camera_page.dart';

class ResultScreen extends StatefulWidget {
  // String medicine;
  // String data;
  final List<Medicine> medicine_list;

  // ResultScreen(this.medicine);
  ResultScreen(this.medicine_list);

  @override
  // State<StatefulWidget> createState() => myresultstateful(medicine);
  State<StatefulWidget> createState() => _ResultScreenState(medicine_list);
}

class _ResultScreenState extends State<ResultScreen> {
  PageController _pageController = PageController(initialPage: 0);
  bool tts_on = false;
  final FlutterTts tts = FlutterTts();
  final TextEditingController controller =
      TextEditingController(text: 'Hello world');

  // String medicine;
  // String data;
  List<Medicine> medicine_list;
  double tts_speed = 0;
  int medicine_id = 0;
  int idx = 0;
  late SharedPreferences prefs;
  bool isTtsSpeaking = false; // TTS가 읽고 있는지 여부를 나타내는 변수 추가

  // myresultstateful(this.medicine);
  _ResultScreenState(this.medicine_list);

  Duration time = Duration(seconds: 1);
  final effectSound = AudioPlayer();
  final audioPath = "soundeffect.wav";

  @override
  void initState() {
    super.initState();
    tts.setLanguage('ko-KR');
    _setAwaitOptions();

    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!isTtsSpeaking) {
        if (idx < medicine_list.length) {
          idx++;
        } else {
          idx = 0;
        }

        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tts.stop(); // 앱이 종료될 때 TTS 중지
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // n = medicine_connect_num[medicine]!;
    // n = 0;
    // medicine_id = medicine_list[idx].id;
    getOperate();
  }

  Future _setAwaitOptions() async {
    await tts.awaitSpeakCompletion(true);
  }

  getInitDate() async {
    prefs = await SharedPreferences.getInstance();
    tts_speed = prefs.getDouble('speed') ?? 0.7;
    tts.setSpeechRate(tts_speed);
    tts_on = prefs.getBool('tts_switch') ?? false;
    setState(() {});
  }

  getOperate() async {
    await getInitDate();
/*    if (tts_on) {
      tts.speak(medicine_store[medicine_id].medicine_name + "입니다");
      sleep(time);
      tts.speak(medicine_store[medicine_id].effecttxt +
          medicine_store[medicine_id].volumetxt +
          medicine_store[medicine_id].cautiontxt);
    } else {
      effectsound.play(AssetSource(audiopath));
    }*/

    if (isTtsSpeaking) {
      tts.stop();
    }

    if (tts_on) {
      setState(() {
        isTtsSpeaking = true;
      });

      await Future.delayed(const Duration(milliseconds: 100));

      await tts.speak("${medicine_list[idx].name}입니다");
      await Future.delayed(const Duration(milliseconds: 500));
      await tts.speak(medicine_list[idx].effect);
      await Future.delayed(const Duration(milliseconds: 500));
      await tts.speak(medicine_list[idx].usage);
      await Future.delayed(const Duration(milliseconds: 500));
      await tts.speak(medicine_list[idx].caution);

      setState(() {
        isTtsSpeaking = false;
      });
    } else {
      effectSound.play(AssetSource(audioPath));
    }
  }

  @override
  // !!! 기존 코드 !!!
/*
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green,
          // title: Text(medicine_store[n].medicine_name),
          title: const Text('약품 정보'),
        ),
        drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
              const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/image/silla.png'),
                ),
                accountName: Text('신라시스템 인턴'),
                accountEmail: Text('kgh@silla.com'),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
              ),
              SwitchListTile(
                value: tts_on,
                title: const Text(
                  '말하기 기능',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (bool value) {
                  setState(() {
                    tts_on = value;
                    prefs.setBool('tts_switch', tts_on);
                  });
                },
              ),
              Row(
                children: [
                  const Text(
                    "      속도 조절",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                      min: 0.0,
                      max: 1.0,
                      value: tts_speed,
                      onChanged: (double value) {
                        setState(() {
                          tts_speed = value;
                          tts.stop();
                          tts.setSpeechRate(tts_speed);
                          prefs.setDouble('speed', tts_speed);
                          tts.speak("이정도 속도로 말하게 됩니다");
                        });
                      }),
                ],
              ),
            ],
        )),
        body: _buildPageContent(context),
      ),
      onWillPop: () async {
        tts.stop();
        tts.speak("원하시는 의약품을 촬영해주세요");
        return true;
      },
    );
  }
*/

  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green,
          // title: Text(medicine_store[n].medicine_name),
          title: const Text('약품 정보'),
        ),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/image/silla.png'),
              ),
              accountName: Text('신라시스템 인턴'),
              accountEmail: Text('kgh@silla.com'),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
            ),
            // SwitchListTile(
            //   value: tts_on,
            //   title: const Text(
            //     '말하기 기능',
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   onChanged: (bool value) {
            //     setState(() {
            //       tts_on = value;
            //       prefs.setBool('tts_switch', tts_on);
            //     });
            //   },
            // ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              height: 100,
              child: OutlinedButton(
                onPressed: () {
                  if (isTtsSpeaking) {
                    tts.stop();
                    setState(() {
                      isTtsSpeaking = false;
                    });
                  }

                  setState(() {
                    tts_on = !tts_on; // tts_on 상태를 토글
                    prefs.setBool(
                        'tts_switch', tts_on); // 변경된 상태를 SharedPreferences에 저장
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: tts_on
                      ? BorderSide(color: Colors.green, width: 2.0)
                      : BorderSide(color: Colors.black12, width: 2.0),
                  backgroundColor: tts_on
                      ? Colors.green
                      : Colors.white, // tts_on 상태에 따라 색상 변경
                ),
                child: Text(
                  '말하기 기능',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: tts_on ? Colors.white : Colors.black12, // 텍스트 색상 변경
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 30,
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    // "      속도 조절",
                    "말하기 속도 조절",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Slider(
                      min: 0.0,
                      max: 1.0,
                      value: tts_speed,
                      onChanged: (double value) {
                        print('Slider onChanged 호출됨');
                        setState(() {
                          tts_speed = value;
                          tts.stop();
                          tts.setSpeechRate(tts_speed);
                          prefs.setDouble('speed', tts_speed);
                          // tts.speak("이정도 속도로 말하게 됩니다");
                        });
                        if (tts_on) {
                          tts.speak("이정도 속도로 말하게 됩니다");
                        }
                      }),
                ],
              ),
            ),
          ],
        )),
        body: _buildPageContent(context),
      ),
      onWillPop: () async {
        tts.stop();
        tts.speak("원하시는 의약품을 촬영해주세요");
        return true;
      },
    );
  }

  // !!! 기존 코드 !!!
  Widget _buildItemCard(context) {
    return Stack(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    // image: AssetImage(medicine_store[medicine_id].image_track),
                    image: AssetImage(medicine_list[idx].thumbLink),
                    height: 200,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  // medicine_store[medicine_id].medicine_name,
                  medicine_list[idx].name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: medicine_list.length,
          itemBuilder: (context, index) {
            return ListView(
              children: [
                _buildItemCard(context),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 15.0),
                      padding: const EdgeInsets.all(15.0),
                      color: Colors.white,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (tts_on == true) {
                            if (isTtsSpeaking) {
                              await tts.stop();
                            }
                            await tts.speak(medicine_list[index].effect);
                          }
                        },
                        child: Text(
                          '【효능·효과】\n${medicine_list[index].effect}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 15.0),
                      padding: const EdgeInsets.all(15.0),
                      color: Colors.white,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (tts_on == true) {
                            if (isTtsSpeaking) {
                              await tts.stop();
                            }
                            await tts.speak(medicine_list[index].usage);
                          }
                        },
                        child: Text(
                          '【용법·용량】\n${medicine_list[index].usage}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 15.0),
                      padding: const EdgeInsets.all(15.0),
                      color: Colors.white,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (tts_on == true) {
                            if (isTtsSpeaking) {
                              await tts.stop();
                            }
                            await tts.speak(medicine_list[index].caution);
                          }
                        },
                        child: Text(
                          '【주의사항】\n${medicine_list[index].caution}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 200, // 빈 박스의 높이를 조정하십시오.
                    ),
                  ],
                ),
              ],
            );
          },
          onPageChanged: (int page) {
            setState(() {
              idx = page;
            });
            getOperate();
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.green,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (isTtsSpeaking) {
                  await tts.stop();
                }

                if (tts_on) {
                  setState(() {
                    isTtsSpeaking = true;
                  });
                  // await tts.speak('${medicine_list[idx].name}입니다.');
                  // await Future.delayed(const Duration(milliseconds: 500));
                  // await tts.speak(medicine_list[idx].effect +
                  //     medicine_list[idx].usage +
                  //     medicine_list[idx].caution);
                  await tts.speak("${medicine_list[idx].name}입니다");
                  await Future.delayed(const Duration(milliseconds: 500));
                  await tts.speak(medicine_list[idx].effect);
                  await Future.delayed(const Duration(milliseconds: 500));
                  await tts.speak(medicine_list[idx].usage);
                  await Future.delayed(const Duration(milliseconds: 500));
                  await tts.speak(medicine_list[idx].caution);
                  setState(() {
                    isTtsSpeaking = false;
                  });
                }
                // getOperate();
              },
              child: const Text(
                "한번 더 듣기",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// !!! 기존 코드 !!!
/*  Widget _buildPageContent(context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView(children: <Widget>[
          _buildItemCard(context),
          Column(children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              color: Colors.white,
              child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    print(medicine_list);
                    if (tts_on == true) {
                      // tts.speak(medicine_store[medicine_id].effecttxt);
                      tts.speak(medicine_list[idx].effect);
                    }
                  },
                  child: Text(
                    // medicine_store[medicine_id].effecttxt,
                    '【효능·효과】\n${medicine_list[idx].effect}',
                    style: const TextStyle(fontSize: 20),
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              color: Colors.white,
              child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (tts_on == true) {
                      // tts.speak(medicine_store[medicine_id].volumetxt);
                      tts.speak(medicine_list[idx].usage);
                    }
                  },
                  child: Text(
                    // medicine_store[medicine_id].volumetxt,
                    '【용법·용량】\n${medicine_list[idx].usage}',
                    style: const TextStyle(fontSize: 20),
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              color: Colors.white,
              child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (tts_on == true) {
                      // tts.speak(medicine_store[medicine_id].cautiontxt);

                      tts.speak(medicine_list[idx].caution);
                    }
                  },
                  child: Text(
                    // medicine_store[medicine_id].cautiontxt,
                    '【주의사항】\n${medicine_list[idx].caution}',
                    style: TextStyle(fontSize: 20),
                  )),
            ),
          ]),
        ])),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.green,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // tts.speak(medicine_store[medicine_id].effecttxt +
                    //     medicine_store[medicine_id].volumetxt +
                    //     medicine_store[medicine_id].cautiontxt);
                    tts.speak(medicine_list[idx].effect +
                        medicine_list[idx].usage +
                        medicine_list[idx].caution);
                  },
                  child: const Text(
                    "한번 더 듣기",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }*/
}
