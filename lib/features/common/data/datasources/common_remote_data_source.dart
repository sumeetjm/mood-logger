import 'package:dartz/dartz.dart';
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
}

class CommonParseDataSource extends CommonRemoteDataSource {
  @override
  Future<MediaCollectionMapping> saveMediaCollectionMapping(
      MediaCollectionMapping mediaCollectionMapping) async {
    ParseResponse response =
        await cast<MediaCollectionMappingParse>(mediaCollectionMapping)
            .toParse(pointerKeys: ['collection', 'media']).save();

    if (response.success) {
      return MediaCollectionMappingParse.from(response.results.first,
          cacheData: mediaCollectionMapping,
          cacheKeys: ['collection', 'media']);
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
    final ParseResponse response =
        await cast<MediaParse>(media).toParse().save();
    if (response.success) {
      return MediaParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MediaCollection> saveMediaCollection(
      MediaCollection collection) async {
    final ParseResponse response =
        await cast<MediaCollectionParse>(collection).toParse().save();
    if (response.success) {
      return MediaCollectionParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByMedia(
      Media media, String module, ParseUser user) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('collection'))
          ..whereEqualTo('module', module)
          ..whereEqualTo('user', user.toPointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      MediaCollection collection =
          MediaCollectionParse.from(response.results.first);
      return getMediaCollectionMappingByCollection(collection);
    }
    throw ServerException();
  }

  @override
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByCollection(
      MediaCollection mediaCollection,
      {Media priorityMedia,
      int limit}) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mediaCollection'))
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
      if (priorityMedia != null) {
        final priorityMediaCollection = mediaCollectionList
            .firstWhere((element) => element.media == priorityMedia);
        mediaCollectionList
            .removeWhere((element) => element.media == priorityMedia);
        mediaCollectionList.insert(0, priorityMediaCollection);
      }
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollectionMapping>>
      getMediaCollectionMappingByCollectionList(
          List<MediaCollection> collectionList) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mediaCollection'))
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
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }
}
