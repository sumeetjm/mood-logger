import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class CommonRemoteDataSource {
  Future<MediaCollection> saveMediaCollection(MediaCollection mediaCollection);
  Future<Media> saveMedia(Media media);
  Future<MediaCollectionMapping> saveMediaCollectionMapping(
      final MediaCollectionMapping mediaCollectionMapping);
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByMedia(
      Media media, String module, ParseUser user);
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByCollection(
      MediaCollection mediaCollection,
      {Media priorityMedia,
      int limit});
  Future<List<MediaCollectionMapping>>
      getMediaCollectionMappingByCollectionList(
          List<MediaCollection> collectionList);
  Future<List<MediaCollectionMapping>> saveMediaCollectionMappingList(
      List<MediaCollectionMapping> mediaCollectionList);
  Future<int> getTotalNoOfPhotos();
}

class CommonParseDataSource extends CommonRemoteDataSource {
  @override
  Future<MediaCollectionMapping> saveMediaCollectionMapping(
      MediaCollectionMapping mediaCollectionMapping) async {
    /*final mediaCollectionMappingBox =
        await Hive.openBox<MediaCollectionMapping>('mediaCollectionMapping');*/
    ParseResponse response =
        await cast<MediaCollectionMappingParse>(mediaCollectionMapping)
            .toParse(pointerKeys: ['collection', 'media']).save();

    if (response.success) {
      var mediaCollectionMappingSaved = MediaCollectionMappingParse.from(
          response.results.first,
          cacheData: mediaCollectionMapping,
          cacheKeys: ['collection', 'media']);
      /*if (!mediaCollectionMappingBox.values
          .any((element) => element.id == mediaCollectionMappingSaved.id)) {
        mediaCollectionMappingBox.add(mediaCollectionMappingSaved);
      }*/
      return mediaCollectionMappingSaved;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollectionMapping>> saveMediaCollectionMappingList(
      List<MediaCollectionMapping> mediaCollectionMappingList) async {
    Set<MediaCollection> mediaCollectionList =
        mediaCollectionMappingList.map((e) => e.collection).toSet();
    List<MediaCollection> collectionListSaved = [];
    for (final collection in mediaCollectionList) {
      collectionListSaved.add(await saveMediaCollection(collection));
    }
    List<MediaCollectionMapping> mediaCollectionMappingListSaved = [];
    for (final mediaCollectionMapping in mediaCollectionMappingList) {
      mediaCollectionMappingListSaved.add(await saveMediaCollectionMapping(
        MediaCollectionMappingParse(
            collection: collectionListSaved.firstWhere((element) =>
                element.code == mediaCollectionMapping.collection.code),
            id: mediaCollectionMapping.id,
            isActive: mediaCollectionMapping.isActive,
            media: await saveMedia(mediaCollectionMapping.media)),
      ));
    }

    return mediaCollectionMappingListSaved;
  }

  @override
  Future<Media> saveMedia(Media media) async {
    /*final mediaBox = await Hive.openBox<Media>('media');*/
    final ParseResponse response =
        await cast<MediaParse>(media).toParse().save();
    if (response.success) {
      final mediaSaved = MediaParse.from(response.results.first);
      /*if (!mediaBox.values.any((element) => element.id == mediaSaved.id)) {
        mediaBox.add(mediaSaved);
      } else {
        mediaBox.putAt(
            mediaBox.values
                .toList()
                .indexWhere((element) => element.id == mediaSaved.id),
            mediaSaved);
      }*/
      return mediaSaved;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MediaCollection> saveMediaCollection(
      MediaCollection collection) async {
    /*final mediaCollectionBox =
        await Hive.openBox<MediaCollection>('mediaCollection');*/
    final ParseResponse response =
        await cast<MediaCollectionParse>(collection).toParse().save();
    if (response.success) {
      final mediaCollectionSaved =
          MediaCollectionParse.from(response.results.first);
      /*if (!mediaCollectionBox.values
          .any((element) => element.id == mediaCollectionSaved.id)) {
        mediaCollectionBox.add(mediaCollectionSaved);
      } else {
        mediaCollectionBox.putAt(
            mediaCollectionBox.values
                .toList()
                .indexWhere((element) => element.id == mediaCollectionSaved.id),
            mediaCollectionSaved);
      }*/
      return mediaCollectionSaved;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByMedia(
      Media media, String module, ParseUser user) async {
    /*final mediaCollectionMappingBox =
        await Hive.openBox<MediaCollectionMapping>(
            'mediaCollection_media_${media.id}');*/
    //if (mediaCollectionMappingBox.isEmpty) {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollection')
          ..whereEqualTo('media', cast<MediaParse>(media).pointer)
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      final List<MediaCollectionMapping> mediaCollectionList =
          ParseMixin.listFrom<MediaCollectionMapping>(
              response.results, MediaCollectionMappingParse.from);
      /*mediaCollectionMappingBox.addAll(mediaCollectionList);*/
      return mediaCollectionList;
    }
    throw ServerException();
    /*} else {
      final mediaCollectionList = mediaCollectionMappingBox.values.toList();
      return mediaCollectionList;
    }*/
  }

  @override
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByCollection(
      MediaCollection mediaCollection,
      {Media priorityMedia,
      int limit}) async {
    /*final mediaCollectionMappingBox =
        await Hive.openBox<MediaCollectionMapping>(
            'mediaCollectionMapping_mediaCollection_${mediaCollection.id}');*/

    //if (mediaCollectionMappingBox.isEmpty) {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollection')
          ..whereEqualTo('isActive', true)
          ..includeObject(['media, collection'])
          ..orderByDescending('createdAt');
    if (mediaCollection.code != 'ALL') {
      queryBuilder
        ..whereEqualTo(
            'collection', cast<MediaCollectionParse>(mediaCollection).pointer);
    }
    if (limit != null) {
      queryBuilder..setLimit(limit);
    }

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      final List<MediaCollectionMapping> mediaCollectionList =
          ParseMixin.listFrom<MediaCollectionMapping>(
              response.results, MediaCollectionMappingParse.from);
      /*mediaCollectionMappingBox.addAll(mediaCollectionList);*/
      setPriorityOrder(mediaCollectionList, priorityMedia);
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
    /*} else {
      final mediaCollectionList = mediaCollectionMappingBox.values.toList();
      setPriorityOrder(mediaCollectionList, priorityMedia);
      return mediaCollectionList;
    }*/
  }

  void setPriorityOrder(
      List<MediaCollectionMapping> mediaCollectionList, Media priorityMedia) {
    if (priorityMedia != null) {
      final priorityMediaCollectionList = mediaCollectionList
          .where((element) => element.media == priorityMedia)
          .toList();
      mediaCollectionList
          .removeWhere((element) => element.media == priorityMedia);
      if (priorityMediaCollectionList.length > 0) {
        mediaCollectionList.insert(0, priorityMediaCollectionList.first);
      }
    }
  }

  @override
  Future<List<MediaCollectionMapping>>
      getMediaCollectionMappingByCollectionList(
          List<MediaCollection> collectionList) async {
    /*final Map<String, Box> mediaCollectionMappingBoxMap = {};
    for (final collection in collectionList) {
      mediaCollectionMappingBoxMap[collection.id] =
          await Hive.openBox<MediaCollectionMapping>(
              'mediaCollectionMapping_mediaCollection_${collection.id}');
    }
    if (mediaCollectionMappingBoxMap.values.any((element) => element.isEmpty)) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollection')
          ..whereContainedIn(
              'collection',
              collectionList
                  .map((collection) =>
                      cast<MediaCollectionParse>(collection).pointer)
                  .toList())
          ..whereEqualTo('isActive', true)
          ..includeObject(['media', 'collection'])
          ..orderByDescending('createdAt');

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      final List<MediaCollectionMapping> mediaCollectionList =
          ParseMixin.listFrom<MediaCollectionMapping>(
              response.results, MediaCollectionMappingParse.from);
      /*mediaCollectionMappingBoxMap.forEach((key, value) {
          mediaCollectionList.forEach((e1) {
            if (!value.values.any((e2) => e1.id == e2.id)) {
              value.add(e1);
            } else {
              value.putAt(
                  value.values.toList().indexWhere((e2) => e1.id == e2.id), e1);
            }
          });
        });*/
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
    /*} else {
      return List<MediaCollectionMapping>.from(mediaCollectionMappingBoxMap
          .values
          .map((e) => e.values)
          .expand((element) => element)
          .toList());
    }*/
  }

  @override
  Future<int> getTotalNoOfPhotos() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollection')
          ..whereEqualTo('isActive', true)
          ..whereMatchesQuery(
              'collection',
              QueryBuilder(ParseObject('collection'))
                ..whereEqualTo('isActive', true)
                ..whereEqualTo('user',
                    ((await ParseUser.currentUser()) as ParseUser).toPointer()))
          ..count();
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count;
    } else {
      throw ServerException();
    }
  }
}
