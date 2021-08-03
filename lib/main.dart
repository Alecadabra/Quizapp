import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:quizapp/services/db.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(primaryColor: Colors.purple),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A value pulled from Firestore, or 'null'
  String _firestoreValue = 'null';

  // Gets a value from Firestore and updates _firestoreValue with it
  void _updateFirestoreValue() async {
    try {
      await Firebase.initializeApp();
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
        _firestoreValue = 'Exception thrown! $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Test'),
      ),
      body: Center(
        child: Text(_firestoreValue),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateFirestoreValue,
        child: Icon(Icons.download),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
