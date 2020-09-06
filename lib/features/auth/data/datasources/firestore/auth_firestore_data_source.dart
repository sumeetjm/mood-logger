import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/data/model/firestore/user_firestore.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';

class AuthFirestoreDataSource extends AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthFirestoreDataSource(
      {FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : assert(firebaseAuth != null),
        assert(googleSignin != null),
        this._firebaseAuth = firebaseAuth,
        this._googleSignIn = googleSignin;

  @override
  Future<User> getUser() async {
    try {
      final firebaseUser = await _firebaseAuth.currentUser();
      return UserFirestore(uId: firebaseUser.uid, email: firebaseUser.email);
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
  Future<User> signInWithCredentials(
      {String email, String password, String username}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final firebaseUser = await _firebaseAuth.currentUser();
      return UserFirestore(uId: firebaseUser.uid, email: firebaseUser.email);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = await _firebaseAuth.currentUser();
      return UserFirestore(uId: firebaseUser.uid, email: firebaseUser.email);
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
