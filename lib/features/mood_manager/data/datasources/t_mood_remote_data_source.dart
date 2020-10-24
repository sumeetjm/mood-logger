import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/base_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class TMoodRemoteDataSource {
  Future<List<TMood>> getTMoodList();
  Future<TMood> getTMood(String id);
  Future<List<TMood>> getTMoodListByIds(List<String> ids);
  Future<TMood> saveTMood(TMood tMood);
  Future<Map<DateTime, List<TMood>>> getTMoodListMapByDate();
}

class TMoodParseDataSource extends TMoodRemoteDataSource {
  @override
  Future<TMood> saveTMood(TMood tMood) async {
    ParseObject tMoodParse = cast<TMoodParse>(tMood).parse;
    ParseObject user = await ParseUser.currentUser();
    tMoodParse.set('user', user.toPointer());
    ParseResponse response = await tMoodParse.save();
    if (response.success) {
      tMoodParse = response.result;
      List<ParseObject> tActivityParseList = List();
      for (final tActivity in tMood.tActivityList) {
        ParseObject tActivityParse = cast<TActivityParse>(tActivity).parse;
        final ParseResponse response = await tActivityParse.save();
        if (response.success) {
          tActivityParse = response.result;
          tActivityParseList.add(tActivityParse);
        } else {
          throw ServerException();
        }
      }
      tMoodParse.set('tActivity', tActivityParseList);
      response = await tMoodParse.save();
      if (response.success) {
        tMoodParse = response.result;
        return TMoodParse.from(tMoodParse);
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<TMood> getTMood(String id) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('tMood'))
          ..includeObject([
            'mMood',
            'tActivity',
            'tActivity.mActivity',
            'tActivity.mActivity',
          ])
          ..whereEqualTo('objectId', id);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      ParseObject tMoodParse = response.result;
      TMood tMood = TMoodParse.from(tMoodParse);
      return tMood;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<TMood>> getTMoodListByIds(List<String> ids) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('tMood'))
          ..includeObject([
            'mMood',
            'tActivity',
            'tActivity.mActivity',
            'tActivity.mActivity.mActivityType',
          ])
          ..whereContainedIn('objectId', ids)
          ..orderByDescending('logDateTime');

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<TMood> tMoodList =
          ParseMixin.listFrom<TMood>(response.results, TMoodParse.from);
      return tMoodList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<TMood>> getTMoodList() async {
    ParseUser user = await ParseUser.currentUser();
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('tMood'))
          ..includeObject([
            'mMood',
            'mMood.subMood',
            'tActivity',
            'tActivity.mActivity',
            'tActivity.mActivity.mActivityType',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user', user.toPointer())
          ..orderByDescending('logDateTime');

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<TMood> tMoodList =
          ParseMixin.listFrom<TMood>(response.results, TMoodParse.from);
      return tMoodList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Map<DateTime, List<TMood>>> getTMoodListMapByDate() async {
    List<TMood> tMoodList = await getTMoodList();
    return TMoodParse.subListMapByDate(tMoodList);
  }
}
