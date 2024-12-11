import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLogin = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserFromPreferences();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      log('Started login');
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );
      log('Credentials $credential');

      UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;

      log('User here $_user');

      if (_user != null) {
        Map<String, dynamic> userInfoMap = {
          "email": _user!.email,
          "name": _user!.displayName,
          "imgUrl": _user!.photoURL,
          "id": _user!.uid,
        };

        await DatabaseMethods().addUser(_user!.uid, userInfoMap);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', _user!.uid);
        prefs.setString('userName', _user!.displayName ?? '');
        prefs.setString('userEmail', _user!.email ?? '');
        prefs.setString('userPhotoUrl', _user!.photoURL ?? '');
        _isLogin = true;
        log('Users informed ${_user!.uid} ${_user!.displayName} ${_user!.email} ${_user!.photoURL}');

        notifyListeners();
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear user data from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _isLogin = false;
      notifyListeners();
    } catch (e) {
      print("Error during Sign-Out: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      _isLogin = true;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
