import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:hive/hive.dart';

part 'memory_collection_mapping.g.dart';

// ignore: must_be_immutable
@HiveType(typeId: 10)
class MemoryCollectionMapping extends Base {
  @HiveField(3)
  final MemoryCollection memoryCollection;
  @HiveField(4)
  final Memory memory;
  MemoryCollectionMapping({
    String id,
    this.memoryCollection,
    this.memory,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'memoryCollectionMapping',
        );

  @override
  List<Object> get props => [memoryCollection, memory, ...super.props];
}
