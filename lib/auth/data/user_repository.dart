import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

// User provider, to manage the user state
// Whether user is logged in or not

class UserRepository with ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  Status _status = Status.unauthenticated;

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User? get user => _user;
  String error = '';

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      error = "";
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        var code = e.code;
        if (code == 'user-not-found') {
          error = 'No user found for that email.';
        } else if (code == 'invalid-credential') {
          error = 'Invalid credentials. Please try again.';
        } else if (code == 'wrong-password') {
          error = 'Wrong password provided for that user.';
        } else if (code == 'invalid-email') {
          error = 'Invalid email provided.';
        } else {
          error = code;
        }
      }
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp({required String email, required String password}) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _auth.signOut();
    _status = Status.unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  // Handle user state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
    }
    notifyListeners();
  }
}
