import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MyFirstWidget(),
      ),
    );
  }
}

class MyFirstWidget extends StatelessWidget {
  final Color color;

  const MyFirstWidget({Key? key, this.color = Colors.red}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isAndroid
          ? Switch(value: true, onChanged: (v) => null)
          : CupertinoSwitch(value: true, onChanged: (v) => null),
    );
  }
}
