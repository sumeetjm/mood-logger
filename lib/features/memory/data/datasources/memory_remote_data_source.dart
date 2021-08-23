import 'package:dartz/dartz.dart' show cast;
import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/core/util/hex_color.dart';

abstract class MemoryRemoteDataSource {
  Future<Memory> saveMemory(Memory memory,
      List<MediaCollectionMapping> mediaCollectionList, Task task);
  Future<MemoryCollectionMapping> archiveMemory(Memory memory);
  Future<MemoryCollection> saveMemoryCollection(
      MemoryCollection memoryCollection);
  Future<List<Memory>> getMemoryList();
  Future<List<Memory>> getMemoryListByDate(DateTime date);
  Future<List<Memory>> getMemoryListByCollection(
      MemoryCollection memoryCollection);
  Future<MapEntry<MemoryCollection, List<Memory>>>
      getCurrentUserArchiveMemoryList();
  Future<MemoryCollectionMapping> saveMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMappingList);
  Future<MemoryCollectionMapping> deactivateMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMappingList);
  Future<List<MemoryCollection>> getMemoryCollectionList();
  Future<List<MediaCollection>> getMediaCollectionListByModuleList(
      List<String> moduleList,
      {bool skipEmpty,
      String mediaType});
  Future<List<Memory>> getMemoryListByMedia(Media media);
  Future<List<Memory>> getMemory(String id);
  Future<Memory> getMemoryByTaskAndDate(Task task, DateTime date);
  Future<List<Memory>> getMemoryListByTask(Task task);
  Future<int> getTotalNoOfMemories();
  Future<List<String>> getMemoryIdListByMedia(Media media);
  Future<void> saveMemoryCount(MemoryCollection memoryCollection);
}

class MemoryParseDataSource extends MemoryRemoteDataSource {
  final CommonRemoteDataSource commonParseDataSource;
  final UserProfileRemoteDataSource userProfileRemoteDataSource;
  MemoryParseDataSource(
      {this.userProfileRemoteDataSource, this.commonParseDataSource});
  @override
  Future<Memory> saveMemory(Memory memory,
      List<MediaCollectionMapping> mediaCollectionList, Task task) async {
    mediaCollectionList = await commonParseDataSource
        .saveMediaCollectionMappingList(mediaCollectionList);
    final memoryParse = cast<MemoryParse>(memory).toParse(
        skipKeys: ['mediaCollection'],
        pointerKeys: ['mMood', 'mActivity'],
        user: await ParseUser.currentUser());
    ParseResponse response = await memoryParse.save();
    if (response.success) {
      memory = MemoryParse.from(response.results.first,
          cacheData: MemoryParse(
            collectionList:
                mediaCollectionList.map((e) => e.collection).toSet().toList(),
            mMood: memory.mMood,
            mActivityList: memory.mActivityList,
            user: memory.user,
          ),
          cacheKeys: ['mediaCollection', 'mMood', 'mActivity', 'task']);
      response = await cast<MemoryParse>(memory).toParse(
          pointerKeys: ['mediaCollection'],
          skipKeys: ['mMood', 'mActivity']).save();
      if (response.success) {
        memory = MemoryParse.from(response.results.first,
            cacheData: memory,
            cacheKeys: ['mediaCollection', 'mMood', 'mActivity', 'task']);

        if (task != null) {
          task.memoryMapByDate[DateUtil.getDateOnly(memory.logDateTime)] =
              memory;
          task.taskRepeat.markedDoneDateList = List<DateTime>.from([
            ...task.taskRepeat.markedDoneDateList,
            DateUtil.getDateOnly(memory.logDateTime)
          ]);
          response = await cast<TaskParse>(task).toParse(
              pointerKeys: ['memory'],
              selectKeys: ['memory', 'taskRepeat']).save();
          if (!response.success) {
            throw ServerException();
          }
        }
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
            'mediaCollection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereNotContainedIn(
              'objectId',
              ((await (QueryBuilder.name('memoryCollectionMapping')
                                ..whereEqualTo('isActive', true)
                                ..whereMatchesQuery(
                                    'memoryCollection',
                                    QueryBuilder.name('memoryCollection')
                                      ..whereEqualTo('name', 'ARCHIVE')
                                      ..whereEqualTo(
                                          'user',
                                          ((await ParseUser.currentUser())
                                                  as ParseUser)
                                              .toPointer())))
                              .query())
                          .results ??
                      [])
                  .map((e) => e.get('memory')['objectId'])
                  .toList())
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
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
      ..includeObject(
          ['mMood', 'mMood.subMood', 'mActivity', 'mediaCollection', 'task'])
      ..whereEqualTo('isActive', true)
      ..whereEqualTo('isArchived', false)
      ..whereGreaterThanOrEqualsTo('logDateTime', utcDate)
      ..whereLessThanOrEqualTo('logDateTime', utcDate.add(Duration(days: 1)))
      ..whereEqualTo(
          'user', ((await ParseUser.currentUser()) as ParseUser).toPointer())
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
            'memory.mMood',
            'memory.mMood.subMood',
            'memory.mActivity',
            'memory.mediaCollection',
            'memoryCollection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('memoryCollection',
              cast<MemoryCollectionParse>(memoryCollection).pointer)
          ..orderByDescending('logDateTime');
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

  Future<MemoryCollectionMapping> archiveMemory(Memory memory) async {
    UserProfile userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    MemoryCollection archiveMemoryCollection;
    if (userProfile.archiveMemoryCollection != null) {
      archiveMemoryCollection = userProfile.archiveMemoryCollection
          .incrementMemoryCount()
          .addColor(memory.mMood?.color);
    }
    return await saveMemoryCollectionMapping(
      MemoryCollectionMappingParse(
        memory: memory,
        memoryCollection: archiveMemoryCollection,
      ),
    );
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
              ?.pointer);

    ParseResponse response = await queryBuilder.query();
    if (response.success) {
      if ((response.results ?? []).isNotEmpty) {
        memoryCollectionMapping = MemoryCollectionMappingParse.from(
          response.results.first,
          cacheData: memoryCollectionMapping,
          cacheKeys: ['memory', 'memoryCollection'],
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
          await saveMemoryCount(memoryCollectionMapping.memoryCollection);
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
          ..whereNotEqualTo('name', 'ARCHIVE')
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer());
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MemoryCollection> memoryCollectionList =
          ParseMixin.listFrom<MemoryCollection>(
              response.results, MemoryCollectionParse.from);
      //memoryCollectionBox.addAll(memoryCollectionList);
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
          await saveMemoryCount(memoryCollectionMapping.memoryCollection);
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
      final List<String> moduleList,
      {bool skipEmpty,
      String mediaType}) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mediaCollection'))
          ..whereEqualTo('isActive', true)
          ..whereContainedIn('module', (moduleList ?? []))
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer());

    if (skipEmpty ?? false) {
      if (mediaType != null) {
        if (mediaType == 'PHOTO') {
          queryBuilder..whereGreaterThan('imageCount', 0);
        } else {
          queryBuilder..whereGreaterThan('videoCount', 0);
        }
      } else {
        queryBuilder..whereGreaterThan('mediaCount', 0);
      }
    } else {
      if (mediaType != null) {
        if (mediaType == 'PHOTO') {
          queryBuilder..whereGreaterThan('imageCount', 0);
        } else {
          queryBuilder..whereGreaterThan('videoCount', 0);
        }
      }
    }

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MediaCollection> mediaCollectionList =
          ParseMixin.listFrom<MediaCollection>(
              (response.results ?? []).toList(), MediaCollectionParse.from);
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<Memory>> getMemoryListByMedia(Media media) async {
    var user = await ParseUser.currentUser();
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..whereMatchesKeyInQuery(
              'mediaCollection',
              'mediaCollection',
              QueryBuilder<ParseObject>(ParseObject('mediaCollectionMapping'))
                ..whereEqualTo('media', cast<MediaParse>(media).pointer)
                ..whereEqualTo('isActive', true))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user', (user as ParseUser).toPointer())
          ..orderByDescending('logDateTime');
    ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<String> memoryIdList = await getMemoryIdListByMedia(media);
      QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
          ParseObject('memory'))
        ..whereContainedIn('objectId', memoryIdList)
        ..whereEqualTo('isActive', true)
        ..includeObject(
            ['mMood', 'mMood.subMood', 'mActivity', 'mediaCollection', 'task']);
      response = await queryBuilder.query();
      if (response.success) {
        List<MemoryParse> memoryList = ParseMixin.listFrom<MemoryParse>(
            response.results, MemoryParse.from);
        return memoryList;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<String>> getMemoryIdListByMedia(Media media) async {
    var user = await ParseUser.currentUser();
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..whereMatchesKeyInQuery(
              'mediaCollection',
              'mediaCollection',
              QueryBuilder<ParseObject>(ParseObject('mediaCollectionMapping'))
                ..whereEqualTo('media', cast<MediaParse>(media).pointer)
                ..whereEqualTo('isActive', true))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user', (user as ParseUser).toPointer())
          ..orderByDescending('logDateTime');
    ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<String> memoryIdList = List<String>.from(
          (response.results ?? []).map((e) => e.get('objectId')));
      return memoryIdList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<Memory>> getMemory(String id) async {
    var user = await ParseUser.currentUser();
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('memory'))
      ..includeObject(
          ['mMood', 'mMood.subMood', 'mActivity', 'mediaCollection', 'task'])
      ..whereEqualTo('objectId', id)
      ..whereEqualTo('isActive', true)
      ..whereEqualTo('user', (user as ParseUser).toPointer())
      ..orderByDescending('logDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MemoryParse> memoryList =
          ParseMixin.listFrom<MemoryParse>(response.results, MemoryParse.from);
      return memoryList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Memory> getMemoryByTaskAndDate(Task task, DateTime date) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskMemoryMapping'))
          ..includeObject([
            'memory',
            'task',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('task', cast<TaskParse>(task).pointer)
          ..whereEqualTo('date', date);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      if ((response.results ?? []).isEmpty) {
        return null;
      }
      final memory = MemoryParse.from(response.results.first);
      //memoryBox.add(memory);
      return memory;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<Memory>> getMemoryListByTask(Task task) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskMemoryMapping'))
          ..includeObject([
            'memory',
            'memory.mMood',
            'memory.mMood.subMood',
            'memory.mActivity',
            'memory.collection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('task', cast<TaskParse>(task).pointer);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      final memoryList = ParseMixin.listFrom<MemoryParse>(
          (response.results ?? []).map((e) => e.get("memory")).toList(),
          MemoryParse.from);
      return memoryList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<int> getTotalNoOfMemories() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
          ..count();
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> saveMemoryCount(MemoryCollection memoryCollection) async {
    final memoryCollectionParse =
        cast<MemoryCollectionParse>(memoryCollection).toParse();
    final memoryList = (await getMemoryListByCollection(memoryCollection));
    memoryCollectionParse.set('memoryCount', memoryList.length);
    final colorList =
        memoryList.map((e) => e.mMood?.color ?? Colors.grey).toList();
    memoryCollectionParse.set('averageMemoryMoodHexColor',
        ColorUtil.mix(colorList, defaultColor: Colors.grey).toHex());
    await memoryCollectionParse.save();
  }

  @override
  Future<MemoryCollection> saveMemoryCollection(
      MemoryCollection memoryCollection) async {
    final ParseResponse response =
        await cast<MemoryCollectionParse>(memoryCollection).toParse().save();
    if (response.success) {
      return memoryCollection;
    } else {
      throw ServerException();
    }
  }
}
