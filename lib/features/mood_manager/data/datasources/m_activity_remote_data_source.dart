import 'dart:developer';

import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_type_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class MActivityRemoteDataSource {
  Future<List<MActivity>> getMActivityList();
  Future<List<MActivity>> getMActivityListByType(MActivityType mActivityType);
  Future<MActivity> getMActivity(String id);
  Future<List<MActivity>> getMActivityByIds(List<String> ids);
  Future<List<MActivityType>> getMActivityTypeList();
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
      List<ParseObject> mActivityParseList = response.results ?? [];
      List<MActivity> mActivityList =
          MActivityParse.fromParseArray(mActivityParseList);
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
          ..whereEqualTo('mActivityType',
              (mActivityType as MActivityTypeParse).toParsePointer());

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<ParseObject> mActivityParseList = response.results ?? [];
      List<MActivity> mActivityList =
          MActivityParse.fromParseArray(mActivityParseList);
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
      MActivity mActivity = MActivityParse.fromParseObject(mActivityParse);
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
      List<ParseObject> mActivityParseList = response.results ?? [];
      List<MActivity> mActivityList =
          MActivityParse.fromParseArray(mActivityParseList);
      return mActivityList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MActivityType>> getMActivityTypeList() async {
    //debugger(when:false);
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mActivityType'))
          ..whereEqualTo('isActive', true)
          ..includeObject(['mActivity']);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<ParseObject> mActivityTypeParseList = response.results ?? [];
      List<MActivityType> mActivityTypeList =
          MActivityTypeParse.fromParseArray(mActivityTypeParseList);
      return mActivityTypeList;
    } else {
      throw ServerException();
    }
  }
}
