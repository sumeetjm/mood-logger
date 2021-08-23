import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:hive/hive.dart';

part 'media_collection_mapping.g.dart';

@HiveType(typeId: 8)
class MediaCollectionMapping extends Base {
  @HiveField(3)
  final Media media;
  @HiveField(4)
  final MediaCollection collection;

  MediaCollectionMapping({
    String id,
    this.media,
    this.collection,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'mediaCollectionMapping',
        );

  @override
  List<Object> get props => [...super.props, media, collection];
}
