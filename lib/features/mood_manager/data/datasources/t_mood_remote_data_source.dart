import 'dart:convert';

import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../core/error/exceptions.dart';

abstract class TMoodRemoteDataSource {
  Future<List<TMoodModel>> getTMoodList();
  Future<TMoodModel> saveTMood(TMoodModel tMood);
}

class TMoodRemoteDataSourceImpl implements TMoodRemoteDataSource {
  final http.Client client;

  TMoodRemoteDataSourceImpl({@required this.client});

  @override
  Future<List<TMoodModel>> getTMoodList() async {
    final response = await client.get(
      'http://10.0.2.2:8080/transaction/mood/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      List<TMoodModel> moodTransactionList =
          TMoodModel.fromJsonArray(jsonDecode(response.body));
      return moodTransactionList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<TMoodModel> saveTMood(TMoodModel tMood) async {
    final response =
        await client.post('http://10.0.2.2:8080/transaction/mood/save',
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(tMood.toJson()));
    if (response.statusCode == 200) {
      return TMoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException();
    }
  }
}
