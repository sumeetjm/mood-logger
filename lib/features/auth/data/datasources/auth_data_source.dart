import 'package:mood_manager/features/auth/domain/entitles/user.dart';

abstract class AuthDataSource {
  Future<User> signInWithGoogle();
  Future<User> signInWithCredentials(
      {String email, String password, String username});
  Future<void> signUp({String email, String password});
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<User> getUser();
}
