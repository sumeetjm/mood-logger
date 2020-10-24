import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/collection_parse.dart';
import 'package:mood_manager/features/common/data/models/photo_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MediaCollectionParse extends MediaCollection with ParseMixin {
  @override
  Base get get => this;

  MediaCollectionParse({
    String id,
    Media media,
    Collection collection,
    bool isActive = true,
  }) : super(
          id: id,
          media: media,
          collection: collection,
          isActive: isActive,
        );

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
        media:
            ParseMixin.value('media', parseOptions, transform: MediaParse.from),
        collection: ParseMixin.value('collection', parseOptions,
            transform: CollectionParse.from),
        isActive: ParseMixin.value('isActive', parseOptions));
  }

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'media': media,
        'collection': collection,
        'isActive': isActive,
      };
}
