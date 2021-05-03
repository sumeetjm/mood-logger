import 'package:dartz/dartz.dart' show cast;
import 'package:hive/hive.dart';
import 'package:mood_manager/core/error/exceptions.dart';
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

abstract class MemoryRemoteDataSource {
  Future<Memory> saveMemory(Memory memory,
      List<MediaCollectionMapping> mediaCollectionList, Task task);
  Future<Memory> archiveMemory(Memory memory);
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
      List<String> moduleList);
  Future<List<Memory>> getMemoryListByMedia(Media media);
  Future<List<Memory>> getMemory(String id);
  Future<Memory> getMemoryByTaskAndDate(Task task, DateTime date);
  Future<List<Memory>> getMemoryListByTask(Task task);
  Future<int> getTotalNoOfMemories();
}

class MemoryParseDataSource extends MemoryRemoteDataSource {
  final CommonRemoteDataSource commonParseDataSource;
  final UserProfileRemoteDataSource userProfileRemoteDataSource;
  MemoryParseDataSource(
      {this.userProfileRemoteDataSource, this.commonParseDataSource});
  @override
  Future<Memory> saveMemory(Memory memory,
      List<MediaCollectionMapping> mediaCollectionList, Task task) async {
    /*final memoryBox = await Hive.openBox<Memory>('memory');*/
    mediaCollectionList = await commonParseDataSource
        .saveMediaCollectionMappingList(mediaCollectionList);
    final memoryParse = cast<MemoryParse>(memory).toParse(
        skipKeys: ['collection'],
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
          cacheKeys: ['collection', 'mMood', 'mActivity', 'task']);
      response = await cast<MemoryParse>(memory).toParse(
          pointerKeys: ['collection'], skipKeys: ['mMood', 'mActivity']).save();
      if (response.success) {
        memory = MemoryParse.from(response.results.first,
            cacheData: memory,
            cacheKeys: ['collection', 'mMood', 'mActivity', 'task']);

        if (task != null) {
          task.memoryMapByDate[DateUtil.getDateOnly(memory.logDateTime)] =
              memory;
          response = await cast<TaskParse>(task)
              .toParse(pointerKeys: ['memory'], selectKeys: ['memory']).save();
          if (!response.success) {
            throw ServerException();
          }
        }
        /*if (!memoryBox.values.any((element) => element.id == memory.id)) {
          memoryBox.add(memory);
        } else {
          memoryBox.putAt(
              memoryBox.values
                  .toList()
                  .indexWhere((element) => element.id == memory.id),
              memory);
        }*/
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
    /*final memoryBox = await Hive.openBox<Memory>('memory');
    if (memoryBox.isEmpty) {*/
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
      //memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /*} else {
      final list = memoryBox.values.toList();
      list.sort((a, b) => a.logDateTime.compareTo(b.logDateTime));
      return list;
    }*/
  }

  @override
  Future<List<Memory>> getMemoryListByDate(DateTime date) async {
    /*final memoryBox =
        await Hive.openBox<Memory>('memory_date_${date.toString()}');
    if (memoryBox.isEmpty) {*/
    DateTime utcDate = date.toUtc();
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('memory'))
      ..includeObject(
          ['mMood', 'mMood.subMood', 'mActivity', 'collection', 'task'])
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
      // memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /* } else {
      final list = memoryBox.values.toList();
      list.sort((a, b) => a.logDateTime.compareTo(b.logDateTime));
      return list;
    }*/
  }

  @override
  Future<List<Memory>> getMemoryListByCollection(
      MemoryCollection memoryCollection) async {
    /*final memoryBox = await Hive.openBox<Memory>(
        'memory_memoryCollection_${memoryCollection.id}');
    if (memoryBox.isEmpty) {*/
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
              cast<MemoryCollectionParse>(memoryCollection).pointer)
          ..orderByDescending('logDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<Memory> memoryList = ParseMixin.listFrom<Memory>(
          (response.results ?? []).map((e) => e.get('memory')).toList(),
          MemoryParse.from);
      //memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /*} else {
      final list = memoryBox.values.toList();
      list.sort((a, b) => a.logDateTime.compareTo(b.logDateTime));
      return list;
    }*/
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

  Future<Memory> archiveMemory(Memory memory) async {
    UserProfile userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    MemoryCollection archiveMemoryCollection;
    if (userProfile.archiveMemoryCollection != null) {
      archiveMemoryCollection = userProfile.archiveMemoryCollection
          .incrementMemoryCount()
          .addColor(memory.mMood?.color);
    }
    await saveMemoryCollectionMapping(
      MemoryCollectionMappingParse(
        memory: memory,
        memoryCollection: archiveMemoryCollection,
      ),
    );
    /*final memoryBox = await Hive.openBox<Memory>(
        'memory_memoryCollection_${archiveMemoryCollection.id}');
    if (!memoryBox.values.any((element) => element.id == memory.id)) {
      memoryBox.add(memory);
    } else {
      memoryBox.putAt(
          memoryBox.values
              .toList()
              .indexWhere((element) => element.id == memory.id),
          memory);
    }*/
    return memory;
  }

  @override
  Future<MemoryCollectionMapping> saveMemoryCollectionMapping(
      MemoryCollectionMapping memoryCollectionMapping) async {
    /*final memoryCollectionMappingBox =
        await Hive.openBox<MemoryCollectionMapping>('memoryCollectionMapping');*/
    final memoryCollectionParse =
        cast<MemoryCollectionParse>(memoryCollectionMapping.memoryCollection)
            .toParse(user: await ParseUser.currentUser());
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memoryCollectionMapping'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('memory',
              cast<MemoryParse>(memoryCollectionMapping.memory)?.pointer)
          ..whereEqualTo('memoryCollection', memoryCollectionParse);

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
          /*if (!memoryCollectionMappingBox.values
              .any((element) => element.id == memoryCollectionMapping.id)) {
            memoryCollectionMappingBox.add(memoryCollectionMapping);
          } else {
            memoryCollectionMappingBox.putAt(
                memoryCollectionMappingBox.values.toList().indexWhere(
                    (element) => element.id == memoryCollectionMapping.id),
                memoryCollectionMapping);
          }*/
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
    /*final memoryCollectionBox =
        await Hive.openBox<MemoryCollection>('memoryCollection');
    if (memoryCollectionBox.isEmpty) {*/
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
    /*} else {
      return memoryCollectionBox.values.toList();
    }*/
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
    /*final Map<String, Box> mediaCollectionBoxMap = {};
    for (final module in moduleList) {
      mediaCollectionBoxMap[module] =
          await Hive.openBox<MediaCollection>('mediaCollection_module_$module');
    }
    if (mediaCollectionBoxMap.values.any((element) => element.isEmpty)) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('collection'))
          ..whereEqualTo('isActive', true)
          ..whereContainedIn('module', (moduleList ?? []))
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer());
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MediaCollection> mediaCollectionList =
          ParseMixin.listFrom<MediaCollection>(
              response.results, MediaCollectionParse.from);
      /*mediaCollectionBoxMap.forEach((key, value) {
          value.addAll(
              mediaCollectionList.where((element) => element.module == key));
        });*/
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
    /*} else {
      return List<MediaCollection>.from(mediaCollectionBoxMap.values
          .map((e) => e.values)
          .expand((element) => element)
          .toList());
    }*/
  }

  @override
  Future<List<Memory>> getMemoryListByMedia(Media media) async {
    var user = await ParseUser.currentUser();
    /*final memoryBox = await Hive.openBox<Memory>('memory_media_${media.id}');
    if (memoryBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..includeObject(
              ['mMood', 'mMood.subMood', 'mActivity', 'collection', 'task'])
          ..whereArrayContainsAll(
              'collection',
              ((await (QueryBuilder<ParseObject>(ParseObject('mediaCollection'))
                                ..whereEqualTo(
                                    'media', cast<MediaParse>(media).pointer)
                                ..whereEqualTo('module', 'MEMORY')
                                ..whereEqualTo('isActive', true))
                              .query())
                          .results ??
                      [])
                  .map((e) => e.get('collection'))
                  .toList())
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user', (user as ParseUser).toPointer())
          ..orderByDescending('logDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MemoryParse> memoryList =
          ParseMixin.listFrom<MemoryParse>(response.results, MemoryParse.from);
      //memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /*} else {
      return memoryBox.values.toList();
    }*/
  }

  @override
  Future<List<Memory>> getMemory(String id) async {
    //final memoryBox = await Hive.openBox<Memory>('memory');
    var user = await ParseUser.currentUser();
    //if (memoryBox.isEmpty) {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('memory'))
          ..includeObject(
              ['mMood', 'mMood.subMood', 'mActivity', 'collection', 'task'])
          ..whereEqualTo('objectId', id)
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user', (user as ParseUser).toPointer())
          ..orderByDescending('logDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MemoryParse> memoryList =
          ParseMixin.listFrom<MemoryParse>(response.results, MemoryParse.from);
      //memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /*} else {
      return memoryBox.values.toList();
    }*/
  }

  @override
  Future<Memory> getMemoryByTaskAndDate(Task task, DateTime date) async {
    /*final memoryBox = await Hive.openBox<Memory>(
        'memory_task_${task.id}_date_${date.toString()}');
    if (memoryBox.isEmpty) {*/
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
    /*} else {
      return memoryBox.values.first;
    }*/
  }

  @override
  Future<List<Memory>> getMemoryListByTask(Task task) async {
    /*final memoryBox = await Hive.openBox<Memory>('memory_task_${task.id}');
    if (memoryBox.isEmpty) {*/
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
      //memoryBox.addAll(memoryList);
      return memoryList;
    } else {
      throw ServerException();
    }
    /*} else {
      return memoryBox.values.toList();
    }*/
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
}
