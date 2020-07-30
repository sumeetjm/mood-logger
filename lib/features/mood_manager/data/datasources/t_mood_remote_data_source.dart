import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/t_activity_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/injection_container.dart';

import '../../../../core/error/exceptions.dart';

abstract class TMoodRemoteDataSource {
  Future<List<TMood>> getTMoodList();
  Future<TMood> getTMood(String id);
  Future<List<TMood>> getTMoodListByIds(List<String> ids);
  Future<TMood> saveTMood({TMood tMood, List<TActivity> tActivityList});
  Future<TMood> updateTMood({TMood tMood, List<TActivity> tActivityList});
}

/*class TMoodRemoteDataSourceImpl implements TMoodRemoteDataSource {
  final http.Client client;

  TMoodRemoteDataSourceImpl({@required this.client});

  @override
  Future<List<TMood>> getTMoodList() async {
    final response = await client.get(
      'http://10.0.2.2:8080/transaction/mood/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      List<TMood> moodTransactionList =
          TMoodModel.fromJsonArray(jsonDecode(response.body));
      return moodTransactionList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<TMood> saveTMood(
      {TMoodModel tMood, List<TActivity> tActivityList}) async {
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
}*/

class TMoodFirestoreDataSource extends TMoodRemoteDataSource {
  final Firestore firestore;
  TActivityRemoteDataSource activityDataSource;

  TMoodFirestoreDataSource({@required this.firestore}) {
    activityDataSource = sl<TActivityRemoteDataSource>();
  }

  @override
  Future<TMood> saveTMood(
      {TMood tMood, List<TActivity> tActivityList = const []}) async {
    debugger(when: true);
    final saved = await (await firestore
            .collection("tMood")
            .add((tMood as TMoodModel).toFirestore(firestore)))
        .get();

    final savedTMood = TMoodModel.fromFirestore(saved);
    (tActivityList ?? []).forEach((element) async {
      await activityDataSource.saveTActvityList(tActivityList, savedTMood);
    });
    return savedTMood;
  }

  @override
  Future<TMood> updateTMood(
      {TMood tMood, List<TActivity> tActivityList = const []}) async {
    debugger(when: false);
    await firestore
        .collection("tMood")
        .document(tMood.id)
        .updateData((tMood as TMoodModel).toFirestore(firestore));
    final tMoodModel = TMoodModel.fromFirestore(
        await firestore.collection("tMood").document(tMood.id).get());
    await activityDataSource.updateTActvityList((tActivityList ?? []));
    return tMoodModel;
  }

  @override
  Future<TMood> getTMood(String id) {
    return firestore
        .collection('tMood')
        .document(id)
        .snapshots()
        .map((value) => TMoodModel.fromFirestore(value))
        .first;
  }

  @override
  Future<List<TMood>> getTMoodListByIds(List<String> ids) {
    List<TMood> tMoodList = [];
    ids.forEach((element) async {
      tMoodList.add(await getTMood(element));
    });
    return Future.value(tMoodList);
  }

  @override
  Future<List<TMood>> getTMoodList() {
    //debugger();
    firestore
        .collection('tMood')
        .where("isActive", isEqualTo: true)
        .orderBy('logDateTime', descending: true)
        .getDocuments()
        .then((value) => value.documents.map((e) {
              return TMoodModel.fromFirestore(e);
            }).toList());
  }
}
