import 'package:dotto/data/db/course_db.dart';
import 'package:dotto/data/db/model/week_period_record.dart';
import 'package:dotto/data/preference/timetable_preference.dart';
import 'package:dotto/domain/day_of_week.dart';
import 'package:dotto/domain/semester.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:dotto/repository/timetable_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SelectCourseService {
  SelectCourseService(this.ref);

  final Ref ref;

  Future<List<WeekPeriodRecord>> getAvailableCourses({
    required Semester semester,
    required DayOfWeek dayOfWeek,
    required TimetableSlot period,
  }) async {
    return CourseDB.getAvailableCourses(
      week: dayOfWeek.number,
      period: period.number,
      semester: semester.number,
    );
  }

  Future<List<int>> getPersonalLessonIdList() async {
    return TimetablePreference.getPersonalTimetableList();
  }

  Future<void> addLesson(int lessonId) async {
    final repository = ref.read(timetableRepositoryProvider);
    await repository.addLesson(lessonId);
  }

  Future<void> removeLesson(int lessonId) async {
    final repository = ref.read(timetableRepositoryProvider);
    await repository.removeLesson(lessonId);
  }

  Future<bool> isOverSelected(int lessonId) async {
    final weekPeriodAllRecords = await CourseDB.getWeekPeriodAllRecords();
    final personalLessonIdList = await getPersonalLessonIdList();

    final filterWeekPeriod = weekPeriodAllRecords
        .where((element) => element.lessonId == lessonId)
        .toList();
    final targetWeekPeriod = filterWeekPeriod
        .where((element) => element.semester != 0)
        .toList();

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
      final selectedLessonList = weekPeriodAllRecords.where((r) {
        return r.week == record.week &&
            r.period == record.period &&
            (r.semester == record.semester || r.semester == 0) &&
            personalLessonIdList.contains(r.lessonId);
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

    if (removeLessonIdList.isNotEmpty) {
      final updatedList = personalLessonIdList
          .where((id) => !removeLessonIdList.contains(id))
          .toList();
      await _savePersonalLessonIdList(updatedList);
    }

    return flag;
  }

  Future<void> _savePersonalLessonIdList(List<int> lessonIdList) async {
    await TimetablePreference.savePersonalTimetableList(lessonIdList);
  }
}
