import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';

abstract class TActivityRemoteDataSource {
  Future<List<TActivity>> saveTActvityList(
      List<TActivity> tActivityList, DocumentSnapshot tMoodDoc);
}

class TActivityFirestoreDataSource extends TActivityRemoteDataSource {
  final Firestore firestore;
  TActivityFirestoreDataSource({@required this.firestore});
  @override
  Future<List<TActivity>> saveTActvityList(
      List<TActivity> tActivityList, DocumentSnapshot tMoodDoc) async {
    List<TActivity> savedTActivityList = [];
    for (final tActivity in tActivityList) {
      tActivityList[0].setTMood = TMoodModel.fromId(tMoodDoc.documentID);
      savedTActivityList.add(await saveTActvity(tActivity));
    }
    return Future.value(savedTActivityList);
  }

  Future<TActivityModel> saveTActvity(TActivity tActivity) async {
    final saved = await firestore
        .collection("tActivity")
        .add((tActivity as TActivityModel).toFirestore(firestore));
    return TActivityModel.fromFirestore(await saved.get());
  }
}
