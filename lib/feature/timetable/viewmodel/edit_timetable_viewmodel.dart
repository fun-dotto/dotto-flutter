import 'package:dotto/domain/semester.dart';
import 'package:dotto/feature/timetable/service/edit_timetable_service.dart';
import 'package:dotto/feature/timetable/viewstate/edit_timetable_viewstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_timetable_viewmodel.g.dart';

@riverpod
final class EditTimetableViewModel extends _$EditTimetableViewModel {
  late final EditTimetableService _service;

  @override
  EditTimetableViewState build() {
    _service = EditTimetableService(ref);
    final now = DateTime.now();
    final initialSemester = (now.month >= 9) || (now.month <= 2)
        ? Semester.fall
        : Semester.spring;
    return EditTimetableViewState(
      weekPeriodAllRecords: const AsyncValue.loading(),
      personalLessonIdList: const AsyncValue.loading(),
      selectedSemester: initialSemester,
      timetableViewStyle: TimetableViewStyle.table,
    );
  }

  Future<void> onAppear() async {
    await _refresh();
  }

  Future<void> refresh() async {
    await _refresh();
  }

  void onSemesterSelected(Semester semester) {
    state = state.copyWith(selectedSemester: semester);
  }

  void onViewStyleToggled() {
    final newStyle = state.timetableViewStyle == TimetableViewStyle.table
        ? TimetableViewStyle.list
        : TimetableViewStyle.table;
    state = state.copyWith(timetableViewStyle: newStyle);
  }

  Future<void> _refresh() async {
    final weekPeriodAllRecords = await AsyncValue.guard(() async {
      return _service.getWeekPeriodAllRecords();
    });
    final personalLessonIdList = await AsyncValue.guard(() async {
      return _service.getPersonalLessonIdList();
    });
    state = state.copyWith(
      weekPeriodAllRecords: weekPeriodAllRecords,
      personalLessonIdList: personalLessonIdList,
    );
  }
}
