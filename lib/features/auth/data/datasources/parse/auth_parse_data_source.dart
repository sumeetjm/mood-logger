import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/data/model/parse/user_parse.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AuthParseDataSource extends AuthDataSource {
  AuthParseDataSource();

  @override
  Future<User> getUser() async {
    try {
      final ParseUser parseUser = await ParseUser.currentUser();
      return UserParse.fromParseUser(parseUser);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final ParseUser parseUser = await ParseUser.currentUser();
      return parseUser != null;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<User> signInWithCredentials(
      {String email, String password, String username}) async {
    try {
      final user = ParseUser(username, password, email);
      final response = await user.login();
      if (response.success) {
        return UserParse.fromParseUser(response.result);
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<User> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    try {
      ParseUser user = await ParseUser.currentUser();
      final result = await user.logout();
      if (result.success) {
        return;
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> signUp({String email, String password, String username}) async {
    try {
      final user = ParseUser(username, password, email);
      final response = await user.signUp();
      return response.success;
    } catch (_) {
      throw ServerException();
    }
  }
}
