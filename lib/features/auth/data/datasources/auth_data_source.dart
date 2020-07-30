import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_manager/core/error/exceptions.dart';

abstract class AuthDataSource {
  Future<FirebaseUser> signInWithGoogle();
  Future<FirebaseUser> signInWithCredentials({String email, String password});
  Future<void> signUp({String email, String password});
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<FirebaseUser> getUser();
}

class AuthDataSourceImpl extends AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthDataSourceImpl({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : assert(firebaseAuth != null),
        assert(googleSignin != null),
        this._firebaseAuth = firebaseAuth,
        this._googleSignIn = googleSignin;

  @override
  Future<FirebaseUser> getUser() async {
    try {
      return await _firebaseAuth.currentUser();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final currentUser = await _firebaseAuth.currentUser();
      return currentUser != null;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<FirebaseUser> signInWithCredentials(
      {String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      //debugger();
      return await _firebaseAuth.currentUser();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<FirebaseUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return await _firebaseAuth.currentUser();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (_) {
      throw ServerException();
    }
  }
}
