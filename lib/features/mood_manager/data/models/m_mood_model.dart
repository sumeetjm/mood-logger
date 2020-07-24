import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MMoodModel extends MMood {
  MMoodModel(
      {@required int moodId,
      @required String moodName,
      @required String moodCode,
      @required Color color,
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
}
