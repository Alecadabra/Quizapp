import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MyFirstWidget(
          color: Colors.teal,
        ),
      ),
    );
  }
}

class MyFirstWidget extends StatefulWidget {
  final Color color;

  const MyFirstWidget({Key? key, this.color = Colors.red}) : super(key: key);

  @override
  _MyFirstWidgetState createState() => _MyFirstWidgetState();
}

class _MyFirstWidgetState extends State<MyFirstWidget> {
  int count = 0;

  @override
  void initState() {
    // Do stuff before initialisation
    super.initState();
  }

  @override
  void dispose() {
    // Do stuff before dying
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: Text('$count'),
        onPressed: () {
          setState(() {
            count++;
          });
        },
      ),
    );
  }
}
