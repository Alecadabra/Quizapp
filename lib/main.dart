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
  // A value pulled from Firestore, or 'null'
  String _firestoreValue = 'null';

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  // Gets a value from Firestore and updates _firestoreValue with it
  void _updateFirestoreValue() async {
    try {
      // Get the data document map from Firestore
      Map<String, dynamic>? data =
          await DatabaseService().getValue('jKrKCYcAxsMo7YKhet8l');
      setState(() {
        // Set the state value to the 'value' from the map
        _firestoreValue = data!['value'] ?? 'Returned null';
      });
    } catch (e) {
      // Exception thrown probably due to lack of permission or network
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
          title: Text('My Test'),
        ),
        body: Center(
          child: Text(_firestoreValue),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _updateFirestoreValue,
          child: Icon(Icons.download),
        ),
      ),
      theme: ThemeData(primaryColor: Colors.blue),
    );
  }
}
