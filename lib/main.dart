import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:quizapp/services/auth.dart';

import 'package:quizapp/services/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _init = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // TODO Something went wrong
          return Scaffold(body: Icon(Icons.error));
        } else if (snapshot.connectionState != ConnectionState.done) {
          // TODO Loading
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.grey),
              ),
            ),
          );
        } else {
          // Success
          return MultiProvider(
            providers: [
              StreamProvider<User?>.value(
                value: AuthService().getUserStream,
                initialData: AuthService().currentUser,
              ),
            ],
            child: MaterialApp(
              home: HomeScreen(),
              theme: ThemeData(primaryColor: Colors.green),
            ),
          );
        } // If
      }, // Builder
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

  String _loginState = 'unknown';

  String _textFieldValue = '';

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final String _key = 'jKrKCYcAxsMo7YKhet8l';

  @override
  void initState() {
    super.initState();
    _updateLoginState(Provider.of<User?>(context, listen: false));
  }

  // Gets a value from Firestore and updates _firestoreValue with it
  void _firestoreGet() async {
    try {
      // Get the data document map from Firestore
      Map<String, dynamic>? data = await _databaseService.getValue(_key);
      setState(() {
        // Set the state value to the 'value' from the map
        _firestoreValue = data!['value'] ?? 'Returned null';
      });
    } catch (e) {
      // Exception thrown probably due to lack of permission or network
      _showError("An error occurred.\n$e");
    }
  }

  void _login() async {
    _updateLoginState(await _authService.anonLogin());
  }

  void _logout() async {
    await _authService.logOut();
    _updateLoginState(Provider.of<User?>(context, listen: false));
  }

  void _updateLoginState(User? user) {
    setState(() {
      if (user == null) {
        _loginState = "Not logged in";
      } else {
        _loginState = "Logged in,\nUID: ${user.uid}";
      }
    });
  }

  void _firestoreUpdate(String value) async {
    try {
      await _databaseService.setValue(_key, value);
    } catch (e) {
      _showError("An error occurred.\n$e");
    }
  }

  void _showError(String error) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fireflutter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Spacer(flex: 2),
            Text(
              'Downloaded Value',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 64, vertical: 8),
              child: Text('\"$_firestoreValue\"'),
            ),
            TextButton(
              onPressed: _firestoreGet,
              child: Text('Download'),
            ),
            Spacer(),
            Text(
              'Edit Value',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 64, vertical: 8),
              child: TextField(
                onChanged: (text) => {
                  setState(() {
                    _textFieldValue = text;
                  })
                },
                decoration: InputDecoration(
                  labelText: 'Enter value to upload',
                ),
              ),
            ),
            TextButton(
              onPressed: () => _firestoreUpdate(_textFieldValue),
              child: Text('Upload'),
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
      drawer: Drawer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loginState),
              TextButton(onPressed: _login, child: Text('Log In')),
              TextButton(onPressed: _logout, child: Text('Log Out')),
            ],
          ),
        ),
      ),
    );
  }
}
