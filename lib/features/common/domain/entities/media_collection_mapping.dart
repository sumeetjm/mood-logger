import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';

class MediaCollectionMapping extends Base {
  final Media media;
  final MediaCollection collection;

  MediaCollectionMapping({
    String id,
    this.media,
    this.collection,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'mediaCollection',
        );

  @override
  // TODO: implement props
  List<Object> get props => [...super.props, media, collection];
}
