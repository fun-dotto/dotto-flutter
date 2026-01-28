import 'package:dotto/data/db/course_db.dart';
import 'package:dotto/data/preference/timetable_preference.dart';
import 'package:dotto/domain/academic_area.dart';
import 'package:dotto/domain/grade.dart';
import 'package:dotto/domain/user_preference_keys.dart';
import 'package:dotto/helper/user_preference_repository.dart';
import 'package:dotto/repository/timetable_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SearchCourseService {
  SearchCourseService(this.ref);

  final Ref ref;

  Future<Grade?> getUserGrade() async {
    final deprecatedGradeKey = await UserPreferenceRepository.getString(
      UserPreferenceKeys.grade,
    );
    return Grade.fromDeprecatedUserPreferenceKey(deprecatedGradeKey ?? '');
  }

  Future<AcademicArea?> getUserAcademicArea() async {
    final deprecatedAcademicAreaKey = await UserPreferenceRepository.getString(
      UserPreferenceKeys.course,
    );
    return AcademicArea.fromDeprecatedUserPreferenceKey(
      deprecatedAcademicAreaKey ?? '',
    );
  }

  Future<List<int>> getPersonalLessonIdList() async {
    return TimetablePreference.getPersonalTimetableList();
  }

  Future<void> addLesson(int lessonId) async {
    await ref.read(timetableRepositoryProvider).addLesson(lessonId);
  }

  Future<void> removeLesson(int lessonId) async {
    await ref.read(timetableRepositoryProvider).removeLesson(lessonId);
  }

  /// 指定された科目が重複選択されているかチェック
  ///
  /// 重複が検出された場合、超過分を自動的に削除し、trueを返す。
  /// 重複がない場合はfalseを返す。
  Future<bool> isOverSelected(int lessonId) async {
    final weekPeriodAllRecords = await CourseDB.getWeekPeriodAllRecords();
    final personalLessonIdList = await getPersonalLessonIdList();

    final filterWeekPeriod = weekPeriodAllRecords
        .where((element) => element.lessonId == lessonId)
        .toList();
    final targetWeekPeriod = filterWeekPeriod
        .where((element) => element.semester != 0)
        .toList();

    // 開講時期が0（通年）の場合は前期・後期両方に展開
    for (final element in filterWeekPeriod.where(
      (element) => element.semester == 0,
    )) {
      final e1 = element.copyWith(semester: 10);
      final e2 = element.copyWith(semester: 20);
      targetWeekPeriod.addAll([e1, e2]);
    }

    final removeLessonIdList = <int>{};
    var flag = false;

    for (final record in targetWeekPeriod) {
      final term = record.semester;
      final week = record.week;
      final period = record.period;

      final selectedLessonList = weekPeriodAllRecords.where((record) {
        return record.week == week &&
            record.period == period &&
            (record.semester == term || record.semester == 0) &&
            personalLessonIdList.contains(record.lessonId);
      }).toList();

      if (selectedLessonList.length > 1) {
        final removeLessonList = selectedLessonList.sublist(
          2,
          selectedLessonList.length,
        );
        if (removeLessonList.isNotEmpty) {
          removeLessonIdList.addAll(
            removeLessonList.map((e) => e.lessonId).toSet(),
          );
        }
        flag = true;
      }
    }

    return flag;
  }
}
