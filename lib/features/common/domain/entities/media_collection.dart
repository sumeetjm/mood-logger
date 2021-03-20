import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MediaCollection extends Base {
  final String mediaType;
  final String name;
  final String code;
  final String module;
  int mediaCount;
  ParseUser user;

  MediaCollection({
    String id,
    this.name,
    this.code,
    this.module,
    this.mediaType,
    this.mediaCount = 0,
    bool isActive = true,
    this.user,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'collection',
        );

  MediaCollection incrementMediaCount() {
    mediaCount++;
    return this;
  }

  MediaCollection decrementMediaCount() {
    mediaCount--;
    return this;
  }

  @override
  List<Object> get props =>
      [...super.props, mediaType, name, code, module, mediaCount, user];
}
