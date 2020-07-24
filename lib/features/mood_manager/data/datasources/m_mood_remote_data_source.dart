import 'dart:convert';

import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../core/error/exceptions.dart';

abstract class MMoodRemoteDataSource {
  Future<List<MMoodModel>> getMMoodList();
}

class MMoodRemoteDataSourceImpl implements MMoodRemoteDataSource {
  final http.Client client;

  MMoodRemoteDataSourceImpl({@required this.client});

  @override
  Future<List<MMoodModel>> getMMoodList() async {
    final response = await client.get(
      'http://10.0.2.2:8080/mood/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<MMoodModel> moodList =
          MMoodModel.fromJsonArray(jsonDecode(response.body));

      return moodList;
    } else {
      throw ServerException();
    }
  }
}
