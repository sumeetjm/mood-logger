import 'package:hive/hive.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/metadata/data/models/m_mood_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
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
      MMood mMood = MMoodParse.from(mMoodParse);
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
      List<MMood> mMoodList = List.from(
          ParseMixin.listFrom<MMood>(response.results, MMoodParse.from));
      return mMoodList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MMood>> getMMoodList() async {
    /*final mMoodBox = await Hive.openBox<MMood>("mMood");
    if (mMoodBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('mMood'))
          ..includeObject(['subMood'])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('isPrimary', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<MMood> mMoodList =
          ParseMixin.listFrom<MMood>(response.results, MMoodParse.from);
      //mMoodBox.addAll(mMoodList);
      return mMoodList;
    } else {
      throw ServerException();
    }
    /*} else {
      return mMoodBox.values.toList();
    }*/
  }
}
