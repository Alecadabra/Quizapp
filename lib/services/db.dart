import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Gets the document map from the 'test' in Firestore
  Future<Map<String, dynamic>?> getValue(id) {
    return _db.collection('test').doc(id).get().then((snap) => snap.data());
  }
}
