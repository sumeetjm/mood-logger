import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MediaCollectionMappingParse extends MediaCollectionMapping
    with ParseMixin {
  @override
  Base get get => this;

  MediaCollectionMappingParse({
    String id,
    Media media,
    MediaCollection collection,
    bool isActive = true,
  }) : super(
          id: id,
          media: media,
          collection: collection,
          isActive: isActive,
        );

  static MediaCollectionMappingParse from(ParseObject parseObject,
      {MediaCollectionMappingParse cacheData,
      List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MediaCollectionMappingParse(
        id: ParseMixin.value('objectId', parseOptions),
        media:
            ParseMixin.value('media', parseOptions, transform: MediaParse.from),
        collection: ParseMixin.value('mediaCollection', parseOptions,
            transform: MediaCollectionParse.from),
        isActive: ParseMixin.value('isActive', parseOptions));
  }

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'media': media,
        'mediaCollection': collection,
        'isActive': isActive,
      };
}
