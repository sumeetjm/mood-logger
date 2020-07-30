import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';

import '../../../../core/error/exceptions.dart';

abstract class MMoodRemoteDataSource {
  Future<List<MMood>> getMMoodList();
  Future<List<MMood>> getMMoodListByIds(List<String> ids);
  Future<MMood> getMMood(String id);
}

/*class MMoodRemoteDataSourceImpl implements MMoodRemoteDataSource {
  final http.Client client;

  MMoodRemoteDataSourceImpl({@required this.client});

  @override
  Future<List<MMood>> getMMoodList() async {
    final response = await client.get(
      'http://10.0.2.2:8080/mood/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<MMood> moodList =
          MMoodModel.fromJsonArray(jsonDecode(response.body));

      return moodList;
    } else {
      throw ServerException();
    }
  }
}*/

class MMoodFirestoreDataSource implements MMoodRemoteDataSource {
  final Firestore firestore;

  MMoodFirestoreDataSource({@required this.firestore});

  @override
  Future<MMood> getMMood(String id) {
    final mMood = firestore
        .collection('mMood')
        .document(id)
        .snapshots()
        .map((event) => MMoodModel.fromFirestore(event))
        .first;
    //.then((value) => MMoodModel.fromFirestore(value));
    return mMood;
  }

  @override
  Future<List<MMood>> getMMoodListByIds(List<String> ids) {
    //debugger();
    List<MMood> mMoodList = [];
    ids.forEach((element) async {
      mMoodList.add(await getMMood(element));
    });
    return Future.value(mMoodList);
  }

  @override
  Future<List<MMood>> getMMoodList() {
    final mMoodList = firestore
        .collection('mMood')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((value) =>
            value.documents.map((e) => MMoodModel.fromFirestore(e)).toList())
        .first;
    return mMoodList;
  }
}
