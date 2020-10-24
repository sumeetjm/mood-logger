import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/collection.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/media.dart';

class MediaCollection extends Base {
  final Media media;
  final Collection collection;

  MediaCollection({
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
