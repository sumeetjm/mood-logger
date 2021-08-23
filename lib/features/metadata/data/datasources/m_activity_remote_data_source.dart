import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_type_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class MActivityRemoteDataSource {
  Future<List<MActivity>> getMActivityList();
  Future<List<MActivity>> getMActivityListBySearchText(String searchText);
  Future<List<MActivity>> getMActivityListByType(MActivityType mActivityType);
  Future<MActivity> getMActivity(String id);
  Future<List<MActivity>> getMActivityByIds(List<String> ids);
  Future<List<MActivityType>> getMActivityTypeList();
  Future<MActivity> addMActivity(MActivity activity);
}

class MActivityParseDataSource implements MActivityRemoteDataSource {
  @override
  Future<List<MActivity>> getMActivityList() async {
    final mActivityBox = await Hive.openBox<MActivity>(
        'getMActivityList${((await ParseUser.currentUser()) as ParseObject).objectId}');
    if (mActivityBox.isEmpty) {
      var queryBuilder = QueryBuilder<ParseObject>(ParseObject('mActivity'))
        ..includeObject([
          'mActivityType',
          'mActivityType.user',
          'user',
        ])
        ..whereEqualTo('user',
            ((await ParseUser.currentUser()) as ParseObject).toPointer())
        ..whereEqualTo('isActive', true);

      ParseResponse response = await queryBuilder.query();
      List results = response.results ?? [];
      if (!response.success) {
        throw ServerException();
      }
      queryBuilder = QueryBuilder<ParseObject>(ParseObject('mActivity'))
        ..includeObject([
          'mActivityType',
          'mActivityType.user',
          'user',
        ])
        ..whereEqualTo('user', null)
        ..whereEqualTo('isActive', true);

      response = await queryBuilder.query();
      if (!response.success) {
        throw ServerException();
      }
      results.addAll(response.results ?? []);
      List<MActivity> mActivityList =
          ParseMixin.listFrom<MActivity>(results, MActivityParse.from);
      mActivityBox.addAll(mActivityList);
      return mActivityList;
    } else {
      return mActivityBox.values.toList();
    }
  }

  @override
  Future<List<MActivity>> getMActivityListByType(
      MActivityType mActivityType) async {
    /*final mActivityBox = await Hive.openBox<MActivity>(
        'mActivity_mActivityType_${mActivityType.id}');
    if (mActivityBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivity'))
          ..includeObject([
            'mActivityType',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo(
              'mActivityType', cast<MActivityTypeParse>(mActivityType).pointer);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MActivity> mActivityList =
          ParseMixin.listFrom<MActivity>(response.results, MActivityParse.from);
      //mActivityBox.addAll(mActivityList);
      return mActivityList;
    } else {
      throw ServerException();
    }
    /*} else {
      return mActivityBox.values.toList();
    }*/
  }

  @override
  Future<MActivity> getMActivity(String id) async {
    /*final mActivityBox = await Hive.openBox<MActivity>('mActivity_$id');
    if (mActivityBox.get(id) != null) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivity'))
          ..includeObject([
            'mActivityType',
          ])
          ..whereEqualTo('objectId', id);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      ParseObject mActivityParse = response.result;
      MActivity mActivity = MActivityParse.from(mActivityParse);
      //mActivityBox.put(id, mActivity);
      return mActivity;
    } else {
      throw ServerException();
    }
    /*} else {
      return mActivityBox.get(id);
    }*/
  }

  @override
  Future<List<MActivity>> getMActivityByIds(List<String> ids) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivity'))
          ..includeObject([
            'mActivityType',
          ])
          ..whereContainedIn('objectId', ids);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MActivity> mActivityList =
          ParseMixin.listFrom<MActivity>(response.results, MActivityParse.from);
      return mActivityList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivityType>> getMActivityTypeList() async {
    final mActivityTypeListBox = await Hive.openBox<MActivityType>(
        'getMActivityTypeList${((await ParseUser.currentUser()) as ParseObject).objectId}');
    if (mActivityTypeListBox.isEmpty) {
      var queryBuilder = QueryBuilder<ParseObject>(ParseObject('mActivityType'))
        ..includeObject(['user'])
        ..whereEqualTo('isActive', true)
        ..whereEqualTo('user',
            ((await ParseUser.currentUser()) as ParseObject).toPointer());

      ParseResponse response = await queryBuilder.query();
      if (!response.success) {
        throw ServerException();
      }
      List results = response.results ?? [];
      queryBuilder = QueryBuilder<ParseObject>(ParseObject('mActivityType'))
        ..includeObject(['user'])
        ..whereEqualTo('isActive', true)
        ..whereEqualTo('user', null);
      response = await queryBuilder.query();
      if (!response.success) {
        throw ServerException();
      }
      results.addAll(response.results ?? []);
      List<MActivityType> mActivityTypeList =
          ParseMixin.listFrom<MActivityType>(results, MActivityTypeParse.from);
      mActivityTypeListBox.addAll(mActivityTypeList);
      return mActivityTypeList;
    } else {
      return mActivityTypeListBox.values.toList();
    }
  }

  @override
  Future<MActivity> addMActivity(MActivity activity) async {
    final mActivityBox = await Hive.openBox<MActivity>(
        'getMActivityList${((await ParseUser.currentUser()) as ParseObject).objectId}');
    final mActivityTypeBox = await Hive.openBox<MActivityType>(
        'getMActivityTypeList${((await ParseUser.currentUser()) as ParseObject).objectId}');
    final ParseResponse response = await cast<MActivityParse>(activity).toParse(
        pointerKeys: [
          if (activity.mActivityType.id != null) 'mActivityType'
        ]).save();
    if (response.success) {
      activity = MActivityParse.from(response.results.first,
          cacheData: activity,
          cacheKeys: [
            if (activity.mActivityType.id != null) 'mActivityType',
            'user'
          ]);
      mActivityBox.clear();
      mActivityTypeBox.clear();
      return activity;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivity>> getMActivityListBySearchText(
      String searchText) async {
    final mActivityBox = await Hive.openBox<MActivity>('getMActivityList');
    if (mActivityBox.isEmpty) {
      QueryBuilder<ParseObject> queryBuilder =
          QueryBuilder<ParseObject>(ParseObject('mActivity'))
            ..includeObject([
              'mActivityType',
            ])
            ..whereContains('name', searchText)
            ..whereEqualTo('isActive', true);

      final ParseResponse response = await queryBuilder.query();
      if (response.success) {
        List<MActivity> mActivityList = ParseMixin.listFrom<MActivity>(
            response.results, MActivityParse.from);
        return mActivityList;
      } else {
        throw ServerException();
      }
    } else {
      return mActivityBox.values
          .where((element) => element.activityName.contains(searchText))
          .toList();
    }
  }
}
