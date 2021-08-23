import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/network/network_info.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/core/util/hex_color.dart';

abstract class CommonRemoteDataSource {
  Future<MediaCollection> saveMediaCollection(MediaCollection mediaCollection);
  Future<Media> saveMedia(Media media);
  Future<MediaCollectionMapping> saveMediaCollectionMapping(
      final MediaCollectionMapping mediaCollectionMapping,
      {bool skipIfAlreadyPresent});
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByMedia(
      Media media, String module, ParseUser user);
  Future<List<MediaCollectionMapping>> getMediaCollectionMappingByCollection(
      MediaCollection mediaCollection,
      {Media priorityMedia,
      int limit,
      String mediaType});
  Future<List<MediaCollectionMapping>>
      getMediaCollectionMappingByCollectionList(
          List<MediaCollection> collectionList);
  Future<List<MediaCollectionMapping>> saveMediaCollectionMappingList(
      List<MediaCollectionMapping> mediaCollectionList,
      {bool skipIfAlreadyPresent});
  Future<int> getTotalNoOfMedia();
  Future<int> getTotalNoOfPhotos();
  Future<int> getTotalNoOfVideos();
  Future<void> checkConnectivity();
  Future<bool> isConnected();
}

class CommonParseDataSource extends CommonRemoteDataSource {
  final NetworkInfo networkInfo;

  CommonParseDataSource({this.networkInfo});

  @override
  Future<MediaCollectionMapping> saveMediaCollectionMapping(
      MediaCollectionMapping mediaCollectionMapping,
      {bool skipIfAlreadyPresent = false}) async {
    /*final mediaCollectionMappingBox =
        await Hive.openBox<MediaCollectionMapping>('mediaCollectionMapping');*/
    if (!skipIfAlreadyPresent ||
        !await existsMediaCollectionMappingByMediaAndMediaCollection(
            mediaCollectionMapping.media, mediaCollectionMapping.collection)) {
      ParseResponse response =
          await cast<MediaCollectionMappingParse>(mediaCollectionMapping)
              .toParse(pointerKeys: ['mediaCollection', 'media']).save();
      if (response.success) {
        var mediaCollectionMappingSaved = MediaCollectionMappingParse.from(
            response.results.first,
            cacheData: mediaCollectionMapping,
            cacheKeys: ['mediaCollection', 'media']);
        /*if (!mediaCollectionMappingBox.values
          .any((element) => element.id == mediaCollectionMappingSaved.id)) {
        mediaCollectionMappingBox.add(mediaCollectionMappingSaved);
      }*/
        await saveMediaCount(mediaCollectionMappingSaved.collection);
        return mediaCollectionMappingSaved;
      } else {
        throw ServerException();
      }
    } else {
      return mediaCollectionMapping;
    }
  }

  @override
  Future<List<MediaCollectionMapping>> saveMediaCollectionMappingList(
      List<MediaCollectionMapping> mediaCollectionMappingList,
      {bool skipIfAlreadyPresent = false}) async {
    var mediaCollectionMapByCode = Map.fromEntries(mediaCollectionMappingList
        .map((e) => MapEntry(e.collection.code, e.collection)));

    List<MediaCollection> collectionListSaved = [];
    for (final collectionEntry in mediaCollectionMapByCode.entries) {
      collectionListSaved.add(await saveMediaCollection(collectionEntry.value));
    }
    List<MediaCollectionMapping> mediaCollectionMappingListSaved = [];
    for (final mediaCollectionMapping in mediaCollectionMappingList) {
      var value = await saveMediaCollectionMapping(
        MediaCollectionMappingParse(
            collection: collectionListSaved.firstWhere((element) =>
                element.code == mediaCollectionMapping.collection.code),
            id: mediaCollectionMapping.id,
            isActive: mediaCollectionMapping.isActive,
            media: await saveMedia(mediaCollectionMapping.media)),
        skipIfAlreadyPresent: skipIfAlreadyPresent,
      );
      if (value.isActive) {
        mediaCollectionMappingListSaved.add(value);
      }
    }
    return mediaCollectionMappingListSaved;
  }

  Future<void> saveMediaCount(MediaCollection mediaCollection) async {
    final mediaCollectionParse =
        cast<MediaCollectionParse>(mediaCollection).toParse();
    final mediaCollectionMappingList =
        await getMediaCollectionMappingByCollection(mediaCollection);
    mediaCollectionParse.set('mediaCount', mediaCollectionMappingList.length);
    mediaCollectionParse.set(
        'imageCount',
        mediaCollectionMappingList
            .where((element) => element.media.mediaType == 'PHOTO')
            .length);
    mediaCollectionParse.set(
        'videoCount',
        mediaCollectionMappingList
            .where((element) => element.media.mediaType == 'VIDEO')
            .length);
    final colorList = mediaCollectionMappingList
        .map((e) => e.media?.dominantColor ?? Colors.grey)
        .toList();
    final mixColor = ColorUtil.mix(colorList);
    mediaCollectionParse.set('averageMediaHexColor', mixColor?.toHex());
    await mediaCollectionParse.save();
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
        QueryBuilder.name('mediaCollectionMapping')
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
      int limit,
      String mediaType}) async {
    /*final mediaCollectionMappingBox =
        await Hive.openBox<MediaCollectionMapping>(
            'mediaCollectionMapping_mediaCollection_${mediaCollection.id}');*/

    //if (mediaCollectionMappingBox.isEmpty) {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollectionMapping')
          ..whereEqualTo('isActive', true)
          ..orderByDescending('createdAt');
    if (mediaCollection.code != 'ALL') {
      queryBuilder
        ..whereEqualTo('mediaCollection',
            cast<MediaCollectionParse>(mediaCollection).pointer);
    } else {
      queryBuilder
        ..whereMatchesQuery(
            'mediaCollection',
            QueryBuilder.name('mediaCollection')
              ..whereEqualTo('isActive', true)
              ..whereEqualTo('user',
                  ((await ParseUser.currentUser()) as ParseUser).toPointer()));
    }
    if (limit != null) {
      queryBuilder..setLimit(limit);
    }
    if (mediaType != null) {
      queryBuilder
        ..whereMatchesQuery('media',
            QueryBuilder.name('media')..whereEqualTo('mediaType', mediaType));
    }

    ParseResponse response = await queryBuilder.query();

    if (response.success) {
      queryBuilder = QueryBuilder.name('mediaCollectionMapping')
        ..whereContainedIn('objectId',
            (response.results ?? []).map((e) => e.get('objectId')).toList())
        ..includeObject(['media', 'mediaCollection']);
      response = await queryBuilder.query();
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
        QueryBuilder.name('mediaCollectionMapping')
          ..whereContainedIn(
              'mediaCollection',
              collectionList
                  .map((collection) =>
                      cast<MediaCollectionParse>(collection).pointer)
                  .toList())
          ..whereEqualTo('isActive', true)
          ..includeObject(['media', 'mediaCollection'])
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
  Future<int> getTotalNoOfMedia() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollectionMapping')
          ..whereEqualTo('isActive', true)
          ..whereMatchesQuery(
              'mediaCollection',
              QueryBuilder(ParseObject('mediaCollection'))
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

  @override
  Future<int> getTotalNoOfPhotos() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollectionMapping')
          ..whereEqualTo('isActive', true)
          ..whereMatchesQuery(
              'mediaCollection',
              QueryBuilder(ParseObject('mediaCollection'))
                ..whereEqualTo('isActive', true)
                ..whereEqualTo('user',
                    ((await ParseUser.currentUser()) as ParseUser).toPointer()))
          ..whereMatchesQuery(
              'media',
              QueryBuilder(ParseObject('media'))
                ..whereEqualTo('isActive', true)
                ..whereEqualTo('mediaType', 'PHOTO'))
          ..count();
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<int> getTotalNoOfVideos() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollectionMapping')
          ..whereEqualTo('isActive', true)
          ..whereMatchesQuery(
              'mediaCollection',
              QueryBuilder(ParseObject('mediaCollection'))
                ..whereEqualTo('isActive', true)
                ..whereEqualTo('user',
                    ((await ParseUser.currentUser()) as ParseUser).toPointer()))
          ..whereMatchesQuery(
              'media',
              QueryBuilder(ParseObject('media'))
                ..whereEqualTo('isActive', true)
                ..whereEqualTo('mediaType', 'VIDEO'))
          ..count();
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> checkConnectivity() async {
    if (!await networkInfo.isConnected) {
      throw NoInternetException();
    }
  }

  @override
  Future<bool> isConnected() async {
    return await networkInfo.isConnected;
  }

  Future<bool> existsMediaCollectionMappingByMediaAndMediaCollection(
      Media media, MediaCollection mediaCollection) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder.name('mediaCollectionMapping')
          ..whereEqualTo('media', cast<MediaParse>(media).pointer)
          ..whereEqualTo('mediaCollection',
              cast<MediaCollectionParse>(mediaCollection).pointer)
          ..whereEqualTo('isActive', true);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count > 0;
    }
    throw ServerException();
  }
}
