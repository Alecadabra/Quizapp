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
  // The value pulled from Firestore, or 'None'
  String _firestoreValue = 'None';

  // A textual description of whether or not the user is logged in
  String _loginState = 'unknown';

  // The value entered into the app to upload to Firestore
  String _textFieldValue = '';

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final String _key = 'jKrKCYcAxsMo7YKhet8l';

  final _iconLoading = CircularProgressIndicator();
  final _iconLogin = Icon(Icons.login, color: Colors.white);
  final _iconLogout = Icon(Icons.logout, color: Colors.white);
  final _iconSuccess = Icon(Icons.check, color: Colors.white);
  final _iconError = Icon(Icons.error, color: Colors.white);
  final _iconConnected = Icon(Icons.cloud_done);

  @override
  void initState() {
    super.initState();
    // Set the login state from the provider's user reference
    _updateLoginState(Provider.of<User?>(context, listen: false));
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _showMessage('Connected to Firebase', icon: _iconConnected);
    });
  }

  // Logs in to Firebase anonymously
  void _login() async {
    _showMessage("Logging in...", icon: _iconLoading);
    _updateLoginState(await _authService.anonLogin());
    _showMessage("Logged in", icon: _iconLogin);
  }

  // Logs out of Firebase anonymously
  void _logout() async {
    _showMessage("Logging out...", icon: _iconLoading);
    await _authService.logOut();
    _updateLoginState(Provider.of<User?>(context, listen: false));
    _showMessage("Logged out", icon: _iconLogout);
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

  // Gets a value from Firestore and updates _firestoreValue with it
  void _firestoreGet() async {
    _showMessage("Downloading...", icon: _iconLoading);
    try {
      // Get the data document map from Firestore
      Map<String, dynamic>? data = await _databaseService.getValue(_key);
      setState(() {
        // Set the state value to the 'value' from the map
        _firestoreValue = data!['value'] ?? 'Returned null';
      });
      _showMessage(
        "Value \"$_firestoreValue\" downloaded.",
        icon: _iconSuccess,
      );
    } catch (e) {
      // Exception thrown probably due to lack of permission or network
      _showMessage("An error occurred.\n$e", icon: _iconError);
    }
  }

  void _firestoreUpdate(String value) async {
    try {
      _showMessage("Uploading...", icon: _iconLoading);

      await _databaseService.setValue(_key, value);

      _showMessage("Value \"$value\" uploaded.", icon: _iconSuccess);
    } catch (e) {
      _showMessage("An error occurred.\n$e", icon: _iconError);
    }
  }

  void _showMessage(String message, {Widget? icon}) async {
    var messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: icon != null
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: icon,
                  ),
                  Expanded(
                    child: Text(
                      message,
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )
            : Text(message),
      ),
    );
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
              Text(
                _loginState,
                overflow: TextOverflow.clip,
              ),
              TextButton(
                onPressed: () {
                  _login();
                  Navigator.pop(context);
                },
                child: Text('Log In'),
              ),
              TextButton(
                onPressed: () {
                  _logout();
                  Navigator.pop(context);
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
