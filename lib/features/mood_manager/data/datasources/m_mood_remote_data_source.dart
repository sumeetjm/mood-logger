import 'dart:developer';

import 'package:mood_manager/features/mood_manager/data/models/parse/m_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class MMoodRemoteDataSource {
  Future<List<MMood>> getMMoodList();
  Future<List<MMood>> getMMoodListByIds(List<String> ids);
  Future<MMood> getMMood(String id);
}

class MMoodParseDataSource implements MMoodRemoteDataSource {
  @override
  Future<MMood> getMMood(String id) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mMood'))
          ..whereEqualTo('objectId', id);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      ParseObject mMoodParse = response.result;
      MMood mMood = MMoodParse.fromParseObject(mMoodParse);
      return mMood;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MMood>> getMMoodListByIds(List<String> ids) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mMood'))
          ..whereContainedIn('objectId', ids);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<ParseObject> mMoodParseList = response.results ?? [];
      List<MMood> mMoodList = MMoodParse.fromParseArray(mMoodParseList);
      return mMoodList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MMood>> getMMoodList() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mMood'))
          ..includeObject(['subMood'])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('isPrimary', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<ParseObject> mMoodParseList = response.results ?? [];
      //debugger(when:false);
      List<MMood> mMoodList = MMoodParse.fromParseArray(mMoodParseList);
      return mMoodList;
    } else {
      throw ServerException();
    }
  }
}
