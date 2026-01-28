import 'package:dotto/data/db/model/week_period_record.dart';
import 'package:dotto/domain/semester.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_timetable_viewstate.freezed.dart';

@freezed
abstract class EditTimetableViewState with _$EditTimetableViewState {
  const factory EditTimetableViewState({
    required AsyncValue<List<WeekPeriodRecord>> weekPeriodAllRecords,
    required AsyncValue<List<int>> personalLessonIdList,
    required Semester selectedSemester,
    required TimetableViewStyle timetableViewStyle,
  }) = _EditTimetableViewState;
}

enum TimetableViewStyle {
  table(icon: Icon(Icons.table_chart)),
  list(icon: Icon(Icons.list))
  ;

  const TimetableViewStyle({required this.icon});

  final Icon icon;
}
