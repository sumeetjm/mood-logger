import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

import '../../../../core/error/exceptions.dart';

abstract class MActivityRemoteDataSource {
  Future<List<MActivity>> getMActivityList();
  Future<List<MActivity>> getMActivityListByType(MActivityType mActivityType);
  Future<MActivity> getMActivity(String id);
  Future<List<MActivity>> getMActivityByIds(List<String> ids);
}

/*class MActivityRemoteDataSourceImpl implements MActivityRemoteDataSource {
  final http.Client client;

  MActivityRemoteDataSourceImpl({@required this.client});

  @override
  Future<Map<String, List<MActivity>>>
      getMActivityListGroupdByType() async {
    final response = await client.get(
      'http://10.0.2.2:8080/activity/get',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      Map<String, List<MActivity>> activityList =
          MActivityModel.fromJsonGroupedByType(jsonDecode(response.body));
      return activityList;
    } else {
      throw ServerException();
    }
  }
}*/

class MActivityFirestoreDataSource implements MActivityRemoteDataSource {
  final Firestore firestore;

  MActivityFirestoreDataSource({@required this.firestore});

  @override
  Future<List<MActivity>> getMActivityList() async {
    return firestore
        .collection('mActivity')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((value) => value.documents
            .map((e) => MActivityModel.fromFirestore(e))
            .toList())
        .first;
  }

  @override
  Future<List<MActivity>> getMActivityListByType(
      MActivityType mActivityType) async {
    return firestore
        .collection('mActivity')
        .where('isActive', isEqualTo: true)
        .where('mActivityType',
            isEqualTo: firestore.document('/mActivityType/${mActivityType.id}'))
        .snapshots()
        .map((value) => value.documents
            .map((e) => MActivityModel.fromFirestore(e))
            .toList())
        .first;
  }

  @override
  Future<MActivity> getMActivity(String id) async {
    return firestore
        .collection('mActivity')
        .document(id)
        .snapshots()
        .map((value) => MActivityModel.fromFirestore(value))
        .first;
  }

  @override
  Future<List<MActivity>> getMActivityByIds(List<String> ids) {
    List<MActivity> mActivityList = [];
    ids.forEach((element) async {
      mActivityList.add(await getMActivity(element));
    });
    return Future.value(mActivityList);
  }
}
