import 'package:dartz/dartz.dart';
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
      return mActivityList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivity>> getMActivityListByType(
      MActivityType mActivityType) async {
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
      return mActivityList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MActivity> getMActivity(String id) async {
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
      return mActivity;
    } else {
      throw ServerException();
    }
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
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivityType'))
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MActivityType> mActivityTypeList =
          ParseMixin.listFrom<MActivityType>(
              response.results, MActivityTypeParse.from);
      return mActivityTypeList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MActivity> addMActivity(MActivity activity) async {
    final ParseResponse response = await cast<MActivityParse>(activity).toParse(
        pointerKeys: [
          if (activity.mActivityType.id != null) 'mActivityType'
        ]).save();
    if (response.success) {
      activity = MActivityParse.from(response.results.first,
          cacheData: activity,
          cacheKeys: [if (activity.mActivityType.id != null) 'mActivityType']);
      return activity;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivity>> getMActivityListBySearchText(
      String searchText) async {
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
  }
}
