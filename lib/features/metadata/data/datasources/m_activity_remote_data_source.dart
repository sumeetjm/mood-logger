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
    /*final mActivityBox = await Hive.openBox<MActivity>('mActivity');
    if (mActivityBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivity'))
          ..includeObject([
            'mActivityType',
          ])
          ..whereEqualTo('isActive', true);

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
    /*final mActivityTypeListBox =
        await Hive.openBox<MActivityType>('mActivityType');
    if (mActivityTypeListBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivityType'))
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MActivityType> mActivityTypeList =
          ParseMixin.listFrom<MActivityType>(
              response.results, MActivityTypeParse.from);
      //mActivityTypeListBox.addAll(mActivityTypeList);
      return mActivityTypeList;
    } else {
      throw ServerException();
    }
    /*} else {
      return mActivityTypeListBox.values.toList();
    }*/
  }

  @override
  Future<MActivity> addMActivity(MActivity activity) async {
    /*final mActivityTypeBox = await Hive.openBox<MActivityType>('mActivityType');
    final mActivityBox = await Hive.openBox<MActivity>('mActivity');*/
    final ParseResponse response = await cast<MActivityParse>(activity).toParse(
        pointerKeys: [
          if (activity.mActivityType.id != null) 'mActivityType'
        ]).save();
    if (response.success) {
      activity = MActivityParse.from(response.results.first,
          cacheData: activity,
          cacheKeys: [if (activity.mActivityType.id != null) 'mActivityType']);
      /*if (!mActivityTypeBox.values
          .any((element) => element.id == activity.id)) {
        mActivityTypeBox.add(activity.mActivityType);
      }
      mActivityBox.add(activity);*/
      return activity;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivity>> getMActivityListBySearchText(
      String searchText) async {
    /*final mActivityBox = await Hive.openBox<MActivity>('mActivity');
    if (mActivityBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivity'))
          ..includeObject([
            'mActivityType',
          ])
          ..whereContains('name', searchText)
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MActivity> mActivityList =
          ParseMixin.listFrom<MActivity>(response.results, MActivityParse.from);
      return mActivityList;
    } else {
      throw ServerException();
    }
    /*} else {
      return mActivityBox.values
          .where((element) => element.activityName.contains(searchText))
          .toList();
    }*/
  }
}
