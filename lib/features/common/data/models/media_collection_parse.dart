import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MediaCollectionParse extends MediaCollection with ParseMixin {
  @override
  Base get get => this;

  MediaCollectionParse({
    String id,
    bool isActive = true,
    String code,
    String name,
    String mediaType,
    String module,
    int mediaCount,
    ParseUser user,
  }) : super(
          id: id,
          isActive: isActive,
          code: code,
          name: name ?? code,
          mediaType: mediaType,
          module: module,
          mediaCount: mediaCount,
          user: user,
        );

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': name,
        'code': code,
        'mediaType': mediaType,
        'module': module,
        'mediaCount': mediaCount,
        'isActive': isActive,
        'user': user,
      };

  static MediaCollectionParse from(ParseObject parseObject,
      {MediaCollectionParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MediaCollectionParse(
      id: ParseMixin.value('objectId', parseOptions),
      name: ParseMixin.value('name', parseOptions),
      code: ParseMixin.value('code', parseOptions),
      mediaType: ParseMixin.value('mediaType', parseOptions),
      module: ParseMixin.value('module', parseOptions),
      mediaCount: ParseMixin.value('mediaCount', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      user: ParseMixin.value('user', parseOptions),
    );
  }
}
