import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageProvider with ChangeNotifier {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  uploadImage(File file) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    Uint8List uploadableFile = await file.readAsBytes();
    _firebaseStorage
        .ref()
        .child(user.uid)
        .child('Employees/6rmcCS7Hoc2Uim6zYOGs')
        .putData(uploadableFile)
        .onComplete
        .then((value) {
      value.ref.getDownloadURL().then((value) => print(value));
      notifyListeners();
      return true;
    }).catchError((e) {
      print('uploadImage e: $e');
      notifyListeners();
      return false;
    });
  }
}
