import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:quizapp/services/db.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _firestoreValue = 'null';

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  void _updateFirestoreValue() async {
    try {
      var data = await DatabaseService().getValue('jKrKCYcAxsMo7YKhet8l');
      setState(() {
        _firestoreValue = data!['value'] ?? 'Returned null';
      });
    } catch (e) {
      setState(() {
        _firestoreValue = 'Exception thrown!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Test App'),
        ),
        body: Center(
          child: Text(_firestoreValue),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _updateFirestoreValue(),
          child: Icon(Icons.download),
        ),
        drawer: Drawer(),
      ),
      theme: ThemeData(primaryColor: Colors.blue),
    );
  }
}
