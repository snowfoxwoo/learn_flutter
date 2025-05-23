import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() =>
    runApp(XylophoneApp()); //lamdar function only allows one line of code

class XylophoneApp extends StatelessWidget {
  void playSound(int soundNumber) {
    final assetsAudioPlayer = AssetsAudioPlayer();
    assetsAudioPlayer.open(Audio('assets/note$soundNumber.wav'));
  }

  Expanded buildKey({required Color color, required int soundNumber}) {
    return Expanded(
      child: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          playSound(soundNumber);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // cover the whole width of column widget
          children: [
            buildKey(color: Colors.red, soundNumber: 1),
            buildKey(color: Colors.orange, soundNumber: 2),
            buildKey(color: Colors.yellow, soundNumber: 3),
            buildKey(color: Colors.blue, soundNumber: 4),
            buildKey(color: Colors.green, soundNumber: 5),
            buildKey(color: Colors.purple, soundNumber: 6),
            buildKey(color: Colors.brown, soundNumber: 7),
          ],
        )),
      ),
    );
  }
}
