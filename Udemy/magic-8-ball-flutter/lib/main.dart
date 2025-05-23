import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text("Ask Me Anything"),
      ),
      body: BallImage(),
    );
  }
}

class BallImage extends StatefulWidget {
  const BallImage({Key? key}) : super(key: key);

  @override
  State<BallImage> createState() => _BallImageState();
}

class _BallImageState extends State<BallImage> {
  int ballNumber = 0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            ballNumber = Random().nextInt(5) + 1;
          });
        },
        child: Image.asset('images/ball$ballNumber.png'),
      ),
    );
  }
}

void main() => runApp(
      MaterialApp(
        home: HomePage(),
      ),
    );
