import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

abstract class TActivityRemoteDataSource {
  Future<List<TActivity>> saveTActvityList(
      List<TActivity> tActivityList, TMood tMood);
  Future<List<TActivity>> updateTActvityList(List<TActivity> tActivityList);
  Future<TActivity> updatedTActvity(TActivity tActivity);
  Future<List<TActivity>> getTActvityListByMood(TMood mood);
  Future<TActivity> getTActvity(String id);
  Future<List<TActivity>> getTActvityList(List<String> ids);
}

class TActivityFirestoreDataSource extends TActivityRemoteDataSource {
  final Firestore firestore;
  TActivityFirestoreDataSource({@required this.firestore});
  @override
  Future<List<TActivity>> saveTActvityList(
      List<TActivity> tActivityList, TMood tMood) async {
    List<TActivity> savedTActivityList = [];
    tActivityList.forEach((element) async {
      element.setTMood = tMood;
      savedTActivityList.add(await saveTActvity(element));
    });
    return Future.value(savedTActivityList);
  }

  Future<TActivity> saveTActvity(TActivity tActivity) async {
    final saved = await firestore
        .collection("tActivity")
        .add((tActivity as TActivityModel).toFirestore(firestore));
    return await getTActvity(saved.documentID);
  }

  @override
  Future<List<TActivity>> updateTActvityList(
      List<TActivity> tActivityList) async {
    List<TActivity> updatedTActivityList = [];
    tActivityList.forEach((element) async {
      updatedTActivityList.add(await updatedTActvity(element));
    });
    return Future.value(updatedTActivityList);
  }

  @override
  Future<TActivity> updatedTActvity(TActivity tActivity) async {
    await firestore
        .collection("tActivity")
        .document(tActivity.id)
        .updateData((tActivity as TActivityModel).toFirestore(firestore));
    return Future.value();
  }

  @override
  Future<List<TActivity>> getTActvityListByMood(TMood tMood) {
    return firestore
        .collection('tActivity')
        .where('isActive', isEqualTo: true)
        .where('tMood', isEqualTo: firestore.document('/tMood/${tMood.id}'))
        .snapshots()
        .map((value) => value.documents
            .map((e) => TActivityModel.fromFirestore(e))
            .toList())
        .first;
  }

  @override
  Future<TActivity> getTActvity(String id) {
    //debugger();
    return firestore
        .collection('tActivity')
        .document(id)
        .snapshots()
        .map((value) => TActivityModel.fromFirestore(value))
        .first;
  }

  @override
  Future<List<TActivity>> getTActvityList(List<String> ids) {
    List<TActivity> tActivityList = [];
    ids.forEach((element) async {
      tActivityList.add(await getTActvity(element));
    });
    return Future.value(tActivityList);
  }
}
