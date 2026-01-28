import 'package:dotto/domain/timetable.dart';
import 'package:dotto/domain/timetable_period_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_viewstate.freezed.dart';

@freezed
abstract class HomeViewState with _$HomeViewState {
  const factory HomeViewState({
    required AsyncValue<List<Timetable>> timetables,
    required DateTime selectedDate,
    required AsyncValue<TimetablePeriodStyle> timetablePeriodStyle,
  }) = _HomeViewState;
}
