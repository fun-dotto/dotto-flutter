import 'package:dotto/data/db/model/course.dart';
import 'package:dotto/data/db/model/week_period_record.dart';
import 'package:dotto/feature/search_course/repository/syllabus_database_config.dart';
import 'package:sqflite/sqflite.dart';

final class CourseDB {
  /// 指定された授業IDでデータベースから授業情報を取得する
  static Future<Course?> fetchDB(int lessonId) async {
    final dbPath = await SyllabusDatabaseConfig().getDBPath();
    final database = await openDatabase(dbPath);

    final records = await database.rawQuery(
      'SELECT LessonId, 過去問, 授業名 FROM sort where LessonId = ?',
      [lessonId],
    );
    if (records.isEmpty) {
      return null;
    }
    final record = records.first;
    return Course(
      lessonId: record['LessonId'] as int,
      kakomonLessonId: record['過去問'] as int?,
      lessonName: record['授業名'] as String,
    );
  }

  static Future<List<String>> getLessonNameList(List<int> lessonIdList) async {
    final dbPath = await SyllabusDatabaseConfig().getDBPath();
    final database = await openDatabase(dbPath);

    final List<Map<String, dynamic>> records = await database.rawQuery(
      'SELECT 授業名 FROM sort WHERE LessonId in (${lessonIdList.join(",")})',
    );
    final lessonNameList = records.map((e) => e['授業名'] as String).toList();
    return lessonNameList;
  }

  /// 授業IDリストから授業名と授業IDのマップを取得する
  static Future<Map<String, int>> getLessonIdMap(List<int> lessonIdList) async {
    final dbPath = await SyllabusDatabaseConfig().getDBPath();
    final database = await openDatabase(dbPath);

    final List<Map<String, dynamic>> records = await database.rawQuery(
      'SELECT LessonId, 授業名 FROM sort WHERE LessonId in (${lessonIdList.join(",")})',
    );

    final lessonIdMap = <String, int>{};
    for (final record in records) {
      final lessonName = record['授業名'] as String;
      final lessonId = record['LessonId'] as int;
      lessonIdMap[lessonName] = lessonId;
    }
    return lessonIdMap;
  }

  /// week_periodテーブルから全レコードを取得する
  static Future<List<WeekPeriodRecord>> getWeekPeriodAllRecords() async {
    final dbPath = await SyllabusDatabaseConfig().getDBPath();
    final database = await openDatabase(dbPath);
    final List<Map<String, dynamic>> records = await database.rawQuery(
      'SELECT * FROM week_period order by lessonId',
    );
    return records.map(WeekPeriodRecord.fromMap).toList();
  }

  /// 指定された曜日・時限・学期に該当するweek_periodレコードを取得する
  static Future<List<WeekPeriodRecord>> getAvailableCourses({
    required int week,
    required int period,
    required int semester,
  }) async {
    final dbPath = await SyllabusDatabaseConfig().getDBPath();
    final database = await openDatabase(dbPath);
    final List<Map<String, dynamic>> records = await database.rawQuery(
      'SELECT * FROM week_period order by lessonId',
    );
    return records
        .where((record) =>
            record['week'] == week &&
            record['period'] == period &&
            (record['開講時期'] == semester || record['開講時期'] == 0))
        .map(WeekPeriodRecord.fromMap)
        .toList();
  }
}
