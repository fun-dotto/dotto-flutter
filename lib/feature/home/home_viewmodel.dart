import 'dart:async';

import 'package:dotto/domain/timetable_period_style.dart';
import 'package:dotto/feature/home/home_service.dart';
import 'package:dotto/feature/home/home_viewstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
final class HomeViewModel extends _$HomeViewModel {
  late final HomeService _service;

  @override
  HomeViewState build() {
    _service = HomeService(ref);
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month, now.day);
    return HomeViewState(
      timetables: const AsyncValue.loading(),
      selectedDate: selectedDate,
      timetablePeriodStyle: const AsyncValue.loading(),
    );
  }

  Future<void> onAppear() async {
    _service.startBusPolling();
    await Future.wait([
      _refresh(),
      _service.changeDirectionOnCurrentLocation(),
    ]);
  }

  void onDateSelected(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void onTimetablePeriodStyleChanged(TimetablePeriodStyle style) {
    unawaited(_service.setTimetablePeriodStyle(style));
    state = state.copyWith(timetablePeriodStyle: AsyncValue.data(style));
  }

  Future<void> _refresh() async {
    state = state.copyWith(timetables: const AsyncValue.loading());
    final timetables = await AsyncValue.guard(() async {
      return _service.getTimetables();
    });
    final timetablePeriodStyle = await AsyncValue.guard(() async {
      return _service.getTimetablePeriodStyle();
    });
    state = state.copyWith(
      timetables: timetables,
      timetablePeriodStyle: timetablePeriodStyle,
    );
  }
}
