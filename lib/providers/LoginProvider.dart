import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salarymanager/main.dart';

class LoginProvider with ChangeNotifier {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;

  FirebaseUser get currentUser => user;

  Future signIn() async {
    GoogleSignInAccount _googleUser;
    if (_googleSignIn.currentUser == null) {
      print('if');
      _googleUser =
          await _googleSignIn.signIn().then((value) => value).catchError((e) {
        print('signIn e: $e');
      });
    } else {
      _googleUser = await _googleSignIn
          .signInSilently()
          .then((value) => value)
          .catchError((e) {
        print('signInSilent e: $e');
      });
    }
    GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    await _firebaseAuth
        .signInWithCredential(credential)
        .then((value) => user = value.user);
    print(user.uid);
  }

  getUser() {
    _firebaseAuth.onAuthStateChanged.listen((firebaseUser) {
      user = firebaseUser;
    });
  }

  Future signOut() async {
    return await _googleSignIn.signOut().then((value) async {
     return await _firebaseAuth.signOut();
    });
  }
}
