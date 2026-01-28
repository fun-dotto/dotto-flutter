import 'package:freezed_annotation/freezed_annotation.dart';

part 'one_week_schedule.freezed.dart';
part 'one_week_schedule.g.dart';

@freezed
abstract class OneWeekSchedule with _$OneWeekSchedule {
  const factory OneWeekSchedule({
    required String lessonId,
    required String start,
    required int period,
    required String resourceId,
    required String title,
  }) = _OneWeekSchedule;

  factory OneWeekSchedule.fromJson(Map<String, dynamic> json) =>
      _$OneWeekScheduleFromJson(json);
}
