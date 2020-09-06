import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserParse extends User {
  UserParse({String userId, String email, String password})
      : super(userId: userId, email: email, password: password);

  factory UserParse.fromParseUser(ParseUser parseUser) {
    if (parseUser == null) {
      return null;
    }
    return UserParse(
        userId: parseUser.objectId,
        email: parseUser.emailAddress,
        password: parseUser.password);
  }
}
