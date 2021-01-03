import 'package:mood_manager/features/common/domain/entities/base.dart';

class Collection extends Base {
  final String mediaType;
  final String name;
  final String code;
  final String module;
  final int mediaCount;

  Collection({
    String id,
    this.name,
    this.code,
    this.module,
    this.mediaType,
    this.mediaCount,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'collection',
        );

  @override
  List<Object> get props =>
      [...super.props, mediaType, name, code, module, mediaCount];
}
