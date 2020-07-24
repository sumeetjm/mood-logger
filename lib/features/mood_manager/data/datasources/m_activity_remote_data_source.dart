import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

import '../../../../core/error/exceptions.dart';

abstract class MActivityRemoteDataSource {
  Future<Map<String, List<MActivity>>> getMActivityListGroupdByType();
}

class MActivityRemoteDataSourceImpl implements MActivityRemoteDataSource {
  final http.Client client;

  MActivityRemoteDataSourceImpl({@required this.client});

  @override
  Future<Map<String, List<MActivityModel>>>
      getMActivityListGroupdByType() async {
    final response = await client.get(
      'http://10.0.2.2:8080/activity/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      Map<String, List<MActivityModel>> activityList =
          MActivityModel.fromJsonGroupedByType(jsonDecode(response.body));
      return activityList;
    } else {
      throw ServerException();
    }
  }
}
