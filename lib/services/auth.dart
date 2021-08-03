import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get getUserStream => _auth.authStateChanges();

  Future<User?> anonLogin() async {
    UserCredential userCred = await _auth.signInAnonymously();
    return userCred.user;
  }

  Future<void> logOut() async => _auth.signOut();
}
