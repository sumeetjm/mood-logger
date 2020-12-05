import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/common/data/models/collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class CommonRemoteDataSource {
  Future<Collection> saveCollection(Collection collection);
  Future<Media> saveMedia(Media media);
  Future<MediaCollection> saveMediaCollection(
      final MediaCollection mediaCollection);
  Future<List<MediaCollection>> getMediaCollectionByMedia(
      Media media, String module, ParseUser user);
  Future<List<MediaCollection>> getMediaCollectionByCollection(
      Collection collection,
      {Media priorityMedia});
  Future<List<MediaCollection>> saveMediaCollectionList(
      List<MediaCollection> mediaCollectionList);
}

class CommonParseDataSource extends CommonRemoteDataSource {
  @override
  Future<MediaCollection> saveMediaCollection(
      MediaCollection mediaCollection) async {
    ParseResponse response = await cast<MediaCollectionParse>(mediaCollection)
        .toParse(pointerKeys: ['collection', 'media']).save();

    if (response.success) {
      return MediaCollectionParse.from(response.results.first,
          cacheData: mediaCollection, cacheKeys: ['collection', 'media']);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollection>> saveMediaCollectionList(
      List<MediaCollection> mediaCollectionList) async {
    Set<Collection> collectionList =
        mediaCollectionList.map((e) => e.collection).toSet();
    List<Collection> collectionListSaved = [];
    for (final collection in collectionList) {
      collectionListSaved.add(await saveCollection(collection));
    }
    List<MediaCollection> mediaCollectionListSaved = [];
    for (final mediaCollection in mediaCollectionList) {
      mediaCollectionListSaved.add(await saveMediaCollection(
        MediaCollectionParse(
            collection: collectionListSaved.firstWhere(
                (element) => element.code == mediaCollection.collection.code),
            id: mediaCollection.id,
            isActive: mediaCollection.isActive,
            media: await saveMedia(mediaCollection.media)),
      ));
    }

    return mediaCollectionListSaved;
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
  Future<Collection> saveCollection(Collection collection) async {
    final ParseResponse response =
        await cast<CollectionParse>(collection).toParse().save();
    if (response.success) {
      return CollectionParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MediaCollection>> getMediaCollectionByMedia(
      Media media, String module, ParseUser user) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('collection'))
          ..whereEqualTo('module', module)
          ..whereEqualTo('user', user.toPointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      Collection collection = CollectionParse.from(response.results.first);
      return getMediaCollectionByCollection(collection);
    }
    throw ServerException();
  }

  @override
  Future<List<MediaCollection>> getMediaCollectionByCollection(
      Collection collection,
      {Media priorityMedia}) async {
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('mediaCollection'))
      ..whereEqualTo('collection', cast<CollectionParse>(collection).pointer)
      ..whereEqualTo('isActive', true)
      ..includeObject(['media, collection'])
      ..orderByDescending('createdAt');

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      final List<MediaCollection> mediaCollectionList =
          ParseMixin.listFrom<MediaCollection>(
              response.results, MediaCollectionParse.from);

      final priorityMediaCollection = mediaCollectionList
          .firstWhere((element) => element.media == priorityMedia);
      mediaCollectionList
          .removeWhere((element) => element.media == priorityMedia);
      mediaCollectionList.insert(0, priorityMediaCollection);
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }
}
