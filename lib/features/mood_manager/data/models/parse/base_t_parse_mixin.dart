import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class BaseTParseMixin<T extends BaseT> {
  ParseObject baseParseObject(BaseT baseT) {
    ParseObject parseObject = ParseObject(baseT.className);
    parseObject.set('objectId', baseT.id);
    parseObject.set('isActive', baseT.isActive);
    return parseObject;
  }

  Map<String, dynamic> baseParsePointer(BaseT baseT) {
    return {
      '__type': 'Pointer',
      'className': baseT.className,
      'objectId': baseT.id,
    };
  }
}
