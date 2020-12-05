import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class MemoryRemoteDataSource {
  Future<Memory> saveMemory(
      Memory memory, List<MediaCollection> mediaCollectionList);
  Future<List<Memory>> getMemoryList();
}

class MemoryParseDataSource extends MemoryRemoteDataSource {
  final CommonRemoteDataSource commonParseDataSource;
  MemoryParseDataSource({this.commonParseDataSource});
  @override
  Future<Memory> saveMemory(
      Memory memory, List<MediaCollection> mediaCollectionList) async {
    mediaCollectionList = await commonParseDataSource
        .saveMediaCollectionList(mediaCollectionList);
    ParseResponse response = await cast<MemoryParse>(memory).toParse(
        skipKeys: ['collection'], pointerKeys: ['mMood', 'mActivity']).save();
    if (response.success) {
      memory = MemoryParse.from(response.results.first,
          cacheData: MemoryParse(
              collectionList:
                  mediaCollectionList.map((e) => e.collection).toList(),
              mMood: memory.mMood,
              mActivityList: memory.mActivityList),
          cacheKeys: ['collection', 'mMood', 'mActivity']);
      response = await cast<MemoryParse>(memory).toParse(
          pointerKeys: ['collection'], skipKeys: ['mMood', 'mActivity']).save();
      if (response.success) {
        memory = MemoryParse.from(response.results.first,
            cacheData: memory, cacheKeys: ['collection', 'mMood', 'mActivity']);
        return memory;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<Memory>> getMemoryList() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..includeObject([
            'mMood',
            'mActivity',
            'collection',
          ])
          ..whereEqualTo('isActive', true)
          ..orderByDescending('logDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<Memory> memoryList =
          ParseMixin.listFrom<Memory>(response.results, MemoryParse.from);
      return memoryList;
    } else {
      throw ServerException();
    }
  }
}
