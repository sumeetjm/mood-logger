import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MMoodModel extends MMood {
  MMoodModel(
      {String moodId,
      String moodName,
      String moodCode,
      Color color,
      bool isActive = true})
      : super(
            moodId: moodId,
            moodName: moodName,
            moodCode: moodCode,
            color: color,
            isActive: isActive);

  factory MMoodModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return MMoodModel(
        moodId: json['id'],
        moodName: json['name'],
        moodCode: json['code'],
        isActive: json['isActive'],
        color: HexColor.fromHex(json['hexColor']));
  }

  factory MMoodModel.fromFirestore(DocumentSnapshot doc) {
    if (doc == null) {
      return null;
    }
    return MMoodModel(
        moodId: doc.documentID,
        moodName: doc['name'],
        moodCode: doc['code'],
        isActive: doc['isActive'],
        color: HexColor.fromHex(doc['hexColor']));
  }

  factory MMoodModel.fromId(String moodId) {
    return MMoodModel(moodId: moodId);
  }

  static List<MMoodModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => MMoodModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'color': color.toHex(),
      'isActive': isActive,
    };
  }

  factory MMoodModel.initial() {
    return MMoodModel(
        color: Colors.white,
        isActive: true,
        moodCode: '',
        moodId: '',
        moodName: '');
  }
}
