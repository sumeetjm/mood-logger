import 'package:mood_manager/features/auth/domain/entitles/user.dart';

abstract class AuthDataSource {
  Future<User> signInWithGoogle();
  Future<User> signInWithCredentials(
      {String email, String password, String username});
  Future<void> signUp({String email, String password, String username});
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<User> getUser();
  Future<User> signInWithFacebook();
  Future<bool> isUserExist({String email});
  Future<bool> isUsernameExist({String username});
  Future<void> linkWithGoogle();
  Future<void> linkWithFacebook();
}
