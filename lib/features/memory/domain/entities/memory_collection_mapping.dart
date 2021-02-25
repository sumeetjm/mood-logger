import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';

// ignore: must_be_immutable
class MemoryCollectionMapping extends Base {
  final MemoryCollection memoryCollection;
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
