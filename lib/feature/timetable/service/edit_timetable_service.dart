import 'package:dotto/data/db/course_db.dart';
import 'package:dotto/data/db/model/week_period_record.dart';
import 'package:dotto/data/preference/timetable_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class EditTimetableService {
  EditTimetableService(this.ref);

  final Ref ref;

  // TODO: ドメインモデルを作成
  // TODO: TimetableRepositoryに移行
  Future<List<WeekPeriodRecord>> getWeekPeriodAllRecords() async {
    return CourseDB.getWeekPeriodAllRecords();
  }

  // TODO: ドメインモデルを作成
  // TODO: TimetableRepositoryに移行
  Future<List<int>> getPersonalLessonIdList() async {
    return TimetablePreference.getPersonalTimetableList();
  }
}
