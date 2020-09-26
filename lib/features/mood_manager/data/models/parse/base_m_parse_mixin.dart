import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class BaseMParseMixin<T extends BaseM> {
  ParseObject baseParseObject(BaseM baseM) {
    ParseObject parseObject = ParseObject(baseM.className);
    parseObject.set('objectId', baseM.id);
    parseObject.set('name', baseM.name);
    parseObject.set('code', baseM.code);
    parseObject.set('isActive', baseM.isActive);
    return parseObject;
  }

  Map<String, dynamic> baseParsePointer(BaseM baseM) {
    return {
      '__type': 'Pointer',
      'className': baseM.className,
      'objectId': baseM.id,
    };
  }
}
