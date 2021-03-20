import 'package:parse_server_sdk/parse_server_sdk.dart';

class DataSourceHelper {
  Future<ParseObject> setUser(ParseObject parseObject) async {
    parseObject.set(
        'user', ((await ParseUser.currentUser()) as ParseUser).toPointer());
    return parseObject;
  }
}
