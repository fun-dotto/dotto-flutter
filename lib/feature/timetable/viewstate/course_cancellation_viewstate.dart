import 'package:dotto/data/json/model/cancel_lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_cancellation_viewstate.freezed.dart';

@freezed
abstract class CourseCancellationViewState with _$CourseCancellationViewState {
  const factory CourseCancellationViewState({
    required AsyncValue<List<CancelLecture>> courseCancellations,
    required bool isFilteredOnlyTaking,
  }) = _CourseCancellationViewState;
}
