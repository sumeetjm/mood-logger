import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_type_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

class StreamService {
  final Firestore firestore;

  StreamService({Firestore firestore})
      : assert(firestore != null),
        this.firestore = firestore;

  Stream<List<MMood>> get moods {
    final collection =
        firestore.collection("mMood").where("isActive", isEqualTo: true);
    return collection.snapshots().map((list) =>
        list.documents.map((e) => MMoodModel.fromFirestore(e)).toList());
  }

  Stream<List<MActivity>> activityList({String mActivityTypeRefKey}) {
    final collection = firestore
        .collection("mActivity")
        .where("isActive", isEqualTo: true)
        .where("mActivityType",
            isEqualTo:
                firestore.document("/mActivityType/$mActivityTypeRefKey"));
    return collection.snapshots().map((list) =>
        list.documents.map((e) => MActivityModel.fromFirestore(e)).toList());
  }

  Stream<List<MActivityType>> get activityTypeList {
    final collection = firestore
        .collection("mActivityType")
        .where("isActive", isEqualTo: true);
    return collection.snapshots().map((list) => list.documents
        .map((e) => MActivityTypeModel.fromFirestore(e))
        .toList());
  }

  Stream<List<TMood>> get tMoodList {
    final collection =
        firestore.collection("tMood").where("isActive", isEqualTo: true);
    return collection.snapshots().map((list) =>
        list.documents.map((e) => TMoodModel.fromFirestore(e)).toList());
  }

  Stream<List<MMood>> mMoodList(List<TMood> tMoodList) {
    if (tMoodList == null || tMoodList.isEmpty) {
      return Stream.value([]);
    }
    final collection = firestore
        .collection("mMood")
        .where("isActive", isEqualTo: true)
        .where(FieldPath.documentId,
            whereIn: tMoodList.map((e) => e.mMood.id).toList());
    return collection.snapshots().map((list) =>
        list.documents.map((e) => MMoodModel.fromFirestore(e)).toList());
  }

  Stream<MMood> mMood(TMood tMood) {
    final collection = firestore.collection("mMood").document(tMood.mMood.id);
    return collection.snapshots().map((doc) => MMoodModel.fromFirestore(doc));
  }

  Stream<Color> color(TMood tMood) {
    final collection = firestore.collection("mMood").document(tMood.mMood.id);
    return collection
        .snapshots()
        .map((doc) => HexColor.fromHex(doc['hexColor']));
  }

  Stream<List<TActivity>> tActivityList(TMood tMood) {
    final collection = firestore
        .collection("tActivity")
        .where("isActive", isEqualTo: true)
        .where("tMood",
            isEqualTo: firestore.document("/tMood/${tMood.transMoodId}"));
    return collection.snapshots().map((list) =>
        list.documents.map((e) => TActivityModel.fromFirestore(e)).toList());
  }

  Stream<List<MActivity>> mActivityList(List<TActivity> tActivityList) {
    if (tActivityList == null || tActivityList.isEmpty) {
      return Stream.value([]);
    }
    final collection = firestore
        .collection("mActivity")
        .where("isActive", isEqualTo: true)
        .where(FieldPath.documentId,
            whereIn: tActivityList.map((e) => e.mActivity.id).toList());
    return collection.snapshots().map((list) =>
        list.documents.map((e) => MActivityModel.fromFirestore(e)).toList());
  }

  Stream<Color> headerColor(List<TMood> tMoodList) {
    if (tMoodList == null || tMoodList.isEmpty) {
      return Stream.value(Colors.white);
    }
    final collection = firestore
        .collection("mMood")
        .where("isActive", isEqualTo: true)
        .where(FieldPath.documentId,
            whereIn: tMoodList.map((e) => e.mMood.id).toList());
    return collection.snapshots().map((list) => list.documents
        .map((e) => HexColor.fromHex(e['hexColor']))
        .reduce((value, element) => ColorUtil.mix([value, element])));
  }
}
