import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserParse extends User {
  UserParse({String id, String userId, String email, String password})
      : super(id: id, userId: userId, email: email, password: password);

  factory UserParse.fromParseUser(ParseUser parseUser) {
    if (parseUser == null) {
      return null;
    }
    return UserParse(
        id: parseUser.objectId,
        userId: parseUser.username,
        email: parseUser.emailAddress,
        password: parseUser.password);
  }
  Map<String, dynamic> toParsePointer() {
    return {'__type': 'Pointer', 'className': '_User', 'objectId': id};
  }

  ParseUser toParseUser() {
    final parseUser = ParseUser(userId, password, email);
    parseUser.set('objectId', id);
    return parseUser;
  }
}
