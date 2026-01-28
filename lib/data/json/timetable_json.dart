import 'dart:convert';

import 'package:dotto/data/json/model/cancel_lecture.dart';
import 'package:dotto/data/json/model/one_week_schedule.dart';
import 'package:dotto/data/json/model/sup_lecture.dart';
import 'package:dotto/helper/read_json_file.dart';

final class TimetableJSON {
  /// 1週間分の授業スケジュールを取得
  static Future<List<OneWeekSchedule>> fetchOneWeekSchedule() async {
    try {
      final jsonString = await readJsonFile('map/oneweek_schedule.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => OneWeekSchedule.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Exception {
      return [];
    }
  }

  /// 休講情報を取得
  static Future<List<CancelLecture>> fetchCancelLectures() async {
    try {
      final jsonData = await readJsonFile('home/cancel_lecture.json');
      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      return jsonList
          .map((json) => CancelLecture.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Exception {
      return [];
    }
  }

  /// 補講情報を取得
  static Future<List<SupLecture>> fetchSupLectures() async {
    try {
      final jsonData = await readJsonFile('home/sup_lecture.json');
      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      return jsonList
          .map((json) => SupLecture.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Exception {
      return [];
    }
  }
}
