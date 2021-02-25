import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class MemoryRemoteDataSource {
  Future<Memory> saveMemory(
      Memory memory, List<MediaCollectionMapping> mediaCollectionList);
  Future<Memory> archiveMemory(Memory memory);
  Future<List<Memory>> getMemoryList();
  Future<List<Memory>> getMemoryListByDate(DateTime date);
  Future<List<Memory>> getMemoryListByCollection(
      MemoryCollection memoryCollection);
  Future<MapEntry<MemoryCollection, List<Memory>>>
      getCurrentUserArchiveMemoryList();
  Future<List<MemoryCollectionMapping>> saveArchiveMemoryCollectionMappingList(
      List<MemoryCollectionMapping> memoryCollectionMappingList);
  Future<MemoryCollectionMapping> saveMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMappingList);
  Future<MemoryCollectionMapping> deactivateMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMappingList);
  Future<List<MemoryCollection>> getMemoryCollectionList();
  Future<List<MediaCollection>> getMediaCollectionListByModuleList(
      List<String> moduleList);
}

class MemoryParseDataSource extends MemoryRemoteDataSource {
  final CommonRemoteDataSource commonParseDataSource;
  final UserProfileRemoteDataSource userProfileRemoteDataSource;
  MemoryParseDataSource(
      {this.userProfileRemoteDataSource, this.commonParseDataSource});
  @override
  Future<Memory> saveMemory(
      Memory memory, List<MediaCollectionMapping> mediaCollectionList) async {
    mediaCollectionList = await commonParseDataSource
        .saveMediaCollectionMappingList(mediaCollectionList);
    ParseResponse response = await cast<MemoryParse>(memory).toParse(
        skipKeys: ['collection'], pointerKeys: ['mMood', 'mActivity']).save();
    if (response.success) {
      memory = MemoryParse.from(response.results.first,
          cacheData: MemoryParse(
              collectionList:
                  mediaCollectionList.map((e) => e.collection).toSet().toList(),
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
            'mMood.subMood',
            'mActivity',
            'mActivity.mActivityType',
            'collection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('isArchived', false)
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

  @override
  Future<List<Memory>> getMemoryListByDate(DateTime date) async {
    DateTime utcDate = date.toUtc();
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('memory'))
      ..includeObject([
        'mMood',
        'mMood.subMood',
        'mActivity',
        'collection',
      ])
      ..whereEqualTo('isActive', true)
      ..whereEqualTo('isArchived', false)
      ..whereGreaterThanOrEqualsTo('logDateTime', utcDate)
      ..whereLessThanOrEqualTo('logDateTime', utcDate.add(Duration(days: 1)))
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

  @override
  Future<List<Memory>> getMemoryListByCollection(
      MemoryCollection memoryCollection) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memoryCollectionMapping'))
          ..includeObject([
            'memory',
            'memoryCollection',
            'memory.mMood',
            'memory.mMood.subMood',
            'memory.mActivity',
            'memory.collection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('memoryCollection',
              cast<MemoryCollectionParse>(memoryCollection).pointer);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<Memory> memoryList = ParseMixin.listFrom<Memory>(
          (response.results ?? []).map((e) => e.get('memory')).toList(),
          MemoryParse.from);
      return memoryList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MapEntry<MemoryCollection, List<Memory>>>
      getCurrentUserArchiveMemoryList() async {
    final UserProfile userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    final archiveMemoryList =
        await getMemoryListByCollection(userProfile.archiveMemoryCollection);
    return MapEntry(userProfile.archiveMemoryCollection, archiveMemoryList);
  }

  @override
  Future<List<MemoryCollectionMapping>> saveArchiveMemoryCollectionMappingList(
      List<MemoryCollectionMapping> memoryCollectionMappingList) async {
    UserProfile userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    userProfile.archiveMemoryCollection =
        memoryCollectionMappingList.first.memoryCollection;
    ParseResponse response =
        await cast<UserProfileParse>(userProfile).toParse(selectKeys: [
      'objectId',
      'archiveMemoryCollection',
    ]).save();
    if (response.success) {
      userProfile = UserProfileParse.from(response.results.first,
          cacheData: userProfile,
          notCacheKeys: [
            'objectId',
            'archiveMemoryCollection',
          ]);
      final memoryCollectionMappingFutureList = memoryCollectionMappingList
          .map((e) => saveMemoryCollectionMapping(MemoryCollectionMappingParse(
                id: e.id,
                memory: e.memory,
                memoryCollection: userProfile.archiveMemoryCollection,
              )))
          .toList();
      return Future.wait(memoryCollectionMappingFutureList);
    } else {
      throw ServerException();
    }
  }

  Future<Memory> archiveMemory(Memory memory) async {
    UserProfile userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    MemoryCollection archiveMemoryCollection;
    if (userProfile.archiveMemoryCollection != null) {
      archiveMemoryCollection = userProfile.archiveMemoryCollection
          .incrementMemoryCount()
          .addColor(memory.mMood?.color);
    } else {
      userProfile.archiveMemoryCollection = MemoryCollectionParse(
        name: 'ARCHIVE',
        averageMemoryMoodColor: memory.mMood?.color,
        memoryCount: 1,
      );
      ParseResponse response =
          await cast<UserProfileParse>(userProfile).toParse(selectKeys: [
        'objectId',
        'archiveMemoryCollection',
      ]).save();
      if (response.success) {
        userProfile = UserProfileParse.from(response.results.first,
            cacheData: userProfile,
            notCacheKeys: [
              'objectId',
              'archiveMemoryCollection',
            ]);
        archiveMemoryCollection = userProfile.archiveMemoryCollection;
      } else {
        throw ServerException();
      }
    }
    await saveMemoryCollectionMapping(
      MemoryCollectionMappingParse(
        memory: memory,
        memoryCollection: archiveMemoryCollection,
      ),
    );
    return memory;
  }

  @override
  Future<MemoryCollectionMapping> saveMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMapping) async {
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('memoryCollectionMapping'))
      ..whereEqualTo('isActive', true)
      ..whereEqualTo(
          'memory', cast<MemoryParse>(memoryCollectionMapping.memory)?.pointer)
      ..whereEqualTo(
          'memoryCollection',
          cast<MemoryCollectionParse>(memoryCollectionMapping.memoryCollection)
              .toParse());

    ParseResponse response = await queryBuilder.query();
    if (response.success) {
      if ((response.results ?? []).isNotEmpty) {
        memoryCollectionMapping = MemoryCollectionMappingParse.from(
          response.results.first,
          cacheData: memoryCollectionMapping,
          cacheKeys: ['memory'],
        );
        return memoryCollectionMapping;
      } else {
        response =
            await cast<MemoryCollectionMappingParse>(memoryCollectionMapping)
                .toParse(pointerKeys: ['memory']).save();
        if (response.success) {
          memoryCollectionMapping = MemoryCollectionMappingParse.from(
            response.results.first,
            cacheData: memoryCollectionMapping,
            cacheKeys: ['memory'],
          );
          return memoryCollectionMapping;
        } else {
          throw ServerException();
        }
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MemoryCollection>> getMemoryCollectionList() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memoryCollection'))
          ..whereEqualTo('isActive', true)
          ..whereNotEqualTo('name', 'ARCHIVE');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MemoryCollection> memoryCollectionList =
          ParseMixin.listFrom<MemoryCollection>(
              response.results, MemoryCollectionParse.from);
      return memoryCollectionList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MemoryCollectionMapping> deactivateMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMapping) async {
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('memoryCollectionMapping'))
      ..whereEqualTo('isActive', true)
      ..whereEqualTo(
          'memory', cast<MemoryParse>(memoryCollectionMapping.memory)?.pointer)
      ..whereEqualTo(
          'memoryCollection',
          cast<MemoryCollectionParse>(memoryCollectionMapping.memoryCollection)
              .pointer);

    ParseResponse response = await queryBuilder.query();
    if (response.success) {
      if ((response.results ?? []).isNotEmpty) {
        memoryCollectionMapping = MemoryCollectionMappingParse.from(
          response.results.first,
          cacheData: memoryCollectionMapping,
          cacheKeys: ['memory', 'isActive', 'memoryCollection'],
        );

        response =
            await cast<MemoryCollectionMappingParse>(memoryCollectionMapping)
                .toParse(
          pointerKeys: ['memory', 'memoryCollection'],
        ).save();
        if (response.success) {
          memoryCollectionMapping = MemoryCollectionMappingParse.from(
            response.results.first,
            cacheData: memoryCollectionMapping,
            cacheKeys: ['memory', 'memoryCollection'],
          );
          return memoryCollectionMapping;
        } else {
          throw ServerException();
        }
      }
      return memoryCollectionMapping;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollection>> getMediaCollectionListByModuleList(
      final List<String> moduleList) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('collection'))
          ..whereEqualTo('isActive', true)
          ..whereContainedIn('module', (moduleList ?? []));
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MediaCollection> mediaCollectionList =
          ParseMixin.listFrom<MediaCollection>(
              response.results, MediaCollectionParse.from);
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }
}
