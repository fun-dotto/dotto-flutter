import 'package:dotto/feature/timetable/service/course_cancellation_service.dart';
import 'package:dotto/feature/timetable/viewstate/course_cancellation_viewstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_cancellation_viewmodel.g.dart';

@riverpod
final class CourseCancellationViewModel extends _$CourseCancellationViewModel {
  late final CourseCancellationService _service;

  @override
  CourseCancellationViewState build() {
    _service = CourseCancellationService(ref);
    return const CourseCancellationViewState(
      courseCancellations: AsyncValue.loading(),
      isFilteredOnlyTaking: true,
    );
  }

  Future<void> onAppear() async {
    await _refresh();
  }

  Future<void> onFilterToggled() async {
    final newFilterState = !state.isFilteredOnlyTaking;
    state = state.copyWith(
      isFilteredOnlyTaking: newFilterState,
      courseCancellations: const AsyncValue.loading(),
    );
    await _refresh();
  }

  Future<void> _refresh() async {
    final courseCancellations = await AsyncValue.guard(() async {
      return _service.getCourseCancellations(
        isFilteredOnlyTaking: state.isFilteredOnlyTaking,
      );
    });
    state = state.copyWith(courseCancellations: courseCancellations);
  }
}
