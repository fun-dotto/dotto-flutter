import 'dart:convert';

import 'package:dotto/domain/user_preference_keys.dart';
import 'package:dotto/helper/user_preference_repository.dart';

final class TimetablePreference {
  /// 個人の時間割リスト（lessonIdのリスト）を取得
  static Future<List<int>> getPersonalTimetableList() async {
    final jsonString = await UserPreferenceRepository.getString(
      UserPreferenceKeys.personalTimetableListKey,
    );
    if (jsonString != null) {
      return List<int>.from(json.decode(jsonString) as List);
    }
    return [];
  }

  /// 個人の時間割リストを保存
  static Future<void> savePersonalTimetableList(List<int> lessonIds) async {
    await UserPreferenceRepository.setString(
      UserPreferenceKeys.personalTimetableListKey,
      json.encode(lessonIds),
    );
    await UserPreferenceRepository.setInt(
      UserPreferenceKeys.personalTimetableLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 最終更新タイムスタンプを取得（ミリ秒）
  static Future<int> getLastUpdateTimestamp() async {
    return await UserPreferenceRepository.getInt(
          UserPreferenceKeys.personalTimetableLastUpdateKey,
        ) ??
        0;
  }
}
