import 'package:dotto/domain/day_of_week.dart';
import 'package:dotto/domain/semester.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:dotto/feature/timetable/service/select_course_service.dart';
import 'package:dotto/feature/timetable/viewstate/select_course_viewstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_course_viewmodel.g.dart';

@riverpod
final class SelectCourseViewModel extends _$SelectCourseViewModel {
  late final SelectCourseService _service;

  @override
  SelectCourseViewState build(
    Semester semester,
    DayOfWeek dayOfWeek,
    TimetableSlot period,
  ) {
    _service = SelectCourseService(ref);
    return SelectCourseViewState(
      semester: semester,
      dayOfWeek: dayOfWeek,
      period: period,
      availableCourses: const AsyncValue.loading(),
      personalLessonIdList: const AsyncValue.loading(),
    );
  }

  Future<void> onAppear() async {
    await _refresh();
  }

  Future<bool> onCourseAdded(int lessonId) async {
    final isOverSelected = await _service.isOverSelected(lessonId);
    if (isOverSelected) {
      return false;
    }
    await _service.addLesson(lessonId);
    await _refresh();
    return true;
  }

  Future<void> onCourseRemoved(int lessonId) async {
    await _service.removeLesson(lessonId);
    await _refresh();
  }

  Future<void> _refresh() async {
    final availableCourses = await AsyncValue.guard(() async {
      return _service.getAvailableCourses(
        semester: state.semester,
        dayOfWeek: state.dayOfWeek,
        period: state.period,
      );
    });
    final personalLessonIdList = await AsyncValue.guard(() async {
      return _service.getPersonalLessonIdList();
    });
    state = state.copyWith(
      availableCourses: availableCourses,
      personalLessonIdList: personalLessonIdList,
    );
  }
}
