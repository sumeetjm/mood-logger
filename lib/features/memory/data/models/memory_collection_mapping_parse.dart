import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

// ignore: must_be_immutable
class MemoryCollectionMappingParse extends MemoryCollectionMapping
    with ParseMixin {
  MemoryCollectionMappingParse({
    String id,
    MemoryCollection memoryCollection,
    Memory memory,
    bool isActive = true,
  }) : super(
          id: id,
          memoryCollection: memoryCollection,
          memory: memory,
          isActive: isActive,
        );

  @override
  List<Object> get props => [memoryCollection, memory, ...super.props];

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'memory': memory,
        'memoryCollection': memoryCollection,
        'isActive': isActive,
      };

  static MemoryCollectionMappingParse from(ParseObject parseObject,
      {MemoryCollectionMappingParse cacheData,
      List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MemoryCollectionMappingParse(
      id: ParseMixin.value('objectId', parseOptions),
      memory:
          ParseMixin.value('memory', parseOptions, transform: MemoryParse.from),
      memoryCollection: ParseMixin.value(
        'memoryCollection',
        parseOptions,
        transform: MemoryCollectionParse.from,
      ),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }
}
