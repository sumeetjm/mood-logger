import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class CollectionParse extends Collection with ParseMixin {
  @override
  Base get get => this;

  CollectionParse({
    String id,
    bool isActive,
    String name,
    String code,
    String mediaType,
    String module,
  }) : super(
          id: id,
          isActive: isActive,
          code: code,
          name: name,
          mediaType: mediaType,
          module: module,
        );

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': name,
        'code': code,
        'mediaType': mediaType,
        'module': module,
        'isActive': isActive,
      };

  static CollectionParse from(ParseObject parseObject,
      {CollectionParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return CollectionParse(
      id: ParseMixin.value('objectId', parseOptions),
      name: ParseMixin.value('name', parseOptions),
      code: ParseMixin.value('code', parseOptions),
      mediaType: ParseMixin.value('collectionType', parseOptions),
      module: ParseMixin.value('module', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }
}
