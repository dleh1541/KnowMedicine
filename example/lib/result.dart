import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "dart:io";
import 'package:audioplayers/audioplayers.dart';

class ResultScreen extends StatefulWidget {
  // String medicine;
  String data;

  // ResultScreen(this.medicine);
  ResultScreen(this.data);

  @override
  // State<StatefulWidget> createState() => myresultstateful(medicine);
  State<StatefulWidget> createState() => myresultstateful(data);
}

class myresultstateful extends State<ResultScreen> {
  bool tts_on = false;
  final FlutterTts tts = FlutterTts();
  final TextEditingController controller =
      TextEditingController(text: 'Hello world');

  // String medicine;
  String data;
  double a = 0;
  int n = 0;
  late SharedPreferences prefs;

  // myresultstateful(this.medicine);
  myresultstateful(this.data);

  Duration time = Duration(seconds: 1);
  final effectsound = AudioPlayer();
  final audiopath = "soundeffect.wav";

  @override
  void initstate() {
    super.initState();
    tts.setLanguage('ko-KR');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // n = medicine_connect_num[medicine]!;
    n = 0;
    getoperate();
  }

  getInitDate() async {
    prefs = await SharedPreferences.getInstance();
    a = prefs.getDouble('speed') ?? 0.7;
    tts.setSpeechRate(a);
    tts_on = prefs.getBool('tts_switch') ?? false;
    setState(() {});
  }

  getoperate() async {
    await getInitDate();
    if (tts_on) {
      tts.speak(medicine_store[n].medicine_name + "입니다");
      sleep(time);
      tts.speak(medicine_store[n].effecttxt +
          medicine_store[n].volumetxt +
          medicine_store[n].cautiontxt);
    } else {
      effectsound.play(AssetSource(audiopath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green,
          title: Text(medicine_store[n].medicine_name),
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
                Text(
                  "      속도 조절",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                    min: 0.0,
                    max: 1.0,
                    value: a,
                    onChanged: (double value) {
                      setState(() {
                        a = value;
                        tts.stop();
                        tts.setSpeechRate(a);
                        prefs.setDouble('speed', a);
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

  Widget _buildPageContent(context) {
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
                    print(data);
                    if (tts_on == true) {
                      tts.speak(medicine_store[n].effecttxt);
                    }
                  },
                  child: Text(
                    medicine_store[n].effecttxt,
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
                      tts.speak(medicine_store[n].volumetxt);
                    }
                  },
                  child: Text(
                    medicine_store[n].volumetxt,
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
                      tts.speak(medicine_store[n].cautiontxt);
                    }
                  },
                  child: Text(
                    medicine_store[n].cautiontxt,
                    style: TextStyle(fontSize: 20),
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
                      tts.speak(medicine_store[n].cautiontxt);
                    }
                  },
                  child: Text(
                    data,
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
                    tts.speak(medicine_store[n].effecttxt +
                        medicine_store[n].volumetxt +
                        medicine_store[n].cautiontxt);
                  },
                  child: const Text("한번 더 들려드리겠습니다"),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildItemCard(context) {
    return Stack(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage(medicine_store[n].image_track),
                    height: 200,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  medicine_store[n].medicine_name,
                  style: const TextStyle(fontSize: 20),
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
}
