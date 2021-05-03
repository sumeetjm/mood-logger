import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';

mixin ParseMixin {
  Base get get;

  ParseObject get parse {
    ParseObject parseObject = ParseObject(get.className);
    parseObject.set("objectId", get.id);
    parseObject.set('isActive', get.isActive);
    return parseObject;
  }

  bool get isSaved => get.id != null;

  Map<String, dynamic> get pointer {
    return {
      '__type': 'Pointer',
      'className': get.className,
      'objectId': get.id,
    };
  }

  ParseObject toParse(
      {List<String> skipKeys = const [],
      List<String> pointerKeys = const [],
      List<String> selectKeys = const [],
      ParseUser user}) {
    final ParseObject parseObject = parse;
    map.forEach((key, value) {
      if ((selectKeys.isNotEmpty && selectKeys.contains(key)) ||
          (!skipKeys.contains(key) && selectKeys.isEmpty)) {
        final valueParse = parseValue(value, pointerKeys.contains(key));
        parseObject.set(key, valueParse);
      }
    });

    if (user != null) {
      parseObject.set('user', user);
    }
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

  static value(String key, Map parseOptions,
      {Function transform, dynamic defaultValue}) {
    var value = parseOptions['data'].get(key);
    if (parseOptions['cacheKeys'].contains(key)) {
      value = parseOptions['cacheData'].map[key];
      Function cacheTransform = parseOptions['cacheTransform'] == null
          ? null
          : parseOptions['cacheTransform'][key];
      if (cacheTransform != null) {
        return cacheTransform(value);
      }
      return value;
    } else if (transform != null) {
      return getValue(value, transform);
    }
    return value ?? defaultValue;
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

  static Map<String, dynamic> toPointer(Map<String, dynamic> map) {
    return {
      '__type': 'Pointer',
      'className': map['className'],
      'objectId': map['objectId'],
    };
  }

  Map<String, dynamic> get map;
}
