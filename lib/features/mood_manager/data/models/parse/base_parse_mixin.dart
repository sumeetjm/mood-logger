import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';

mixin ParseMixin {
  Base get get;

  ParseObject get parse {
    ParseObject parseObject = ParseObject(get.className);
    parseObject.set("objectId", get.id);
    parseObject.set('isActive', get.isActive);
    return parseObject;
  }

  Map<String, dynamic> get pointer {
    return {
      '__type': 'Pointer',
      'className': get.className,
      'objectId': get.id,
    };
  }

  ParseObject toParse(
      {List<String> skipKeys = const [], List<String> pointerKeys = const []}) {
    final ParseObject parseObject = parse;
    map.forEach((key, value) {
      if (!skipKeys.contains(key)) {
        final valueParse = parseValue(value, pointerKeys.contains(key));
        parseObject.set(key, valueParse);
      }
    });
    return parseObject;
  }

  parseValue(value, bool isPointer) {
    if (value is List) {
      return value.map((e) => parseValue(e, isPointer)).toList();
    } else if (value is ParseMixin) {
      if (isPointer) {
        return value.pointer;
      } else {
        return value.toParse();
      }
    } else {
      return value;
    }
  }

  static value(String key, Map parseOptions, {Function transform}) {
    final value = parseOptions['data'].get(key);
    if (parseOptions['cacheKeys'].contains(key)) {
      return parseOptions['cacheData'].map[key];
    } else if (transform != null) {
      return getValue(value, transform);
    }
    return value;
  }

  static getValue(dynamic value, Function transformer) {
    if (value is List) {
      return value.map((e) => getValue(e, transformer)).toList();
    } else if (transformer != null) {
      return transformer(value);
    } else {
      return value;
    }
  }

  static List<T> listFrom<T>(List array, Function transform) {
    return List<T>.from((array ?? []).map((e) => transform(e)).toList());
  }

  Map<String, dynamic> get map;
}
