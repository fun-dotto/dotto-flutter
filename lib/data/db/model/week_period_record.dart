import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_period_record.freezed.dart';

@freezed
abstract class WeekPeriodRecord with _$WeekPeriodRecord {
  const factory WeekPeriodRecord({
    required int lessonId,
    required int week,
    required int period,
    required int semester,
    required String lessonName,
  }) = _WeekPeriodRecord;

  factory WeekPeriodRecord.fromMap(Map<String, dynamic> map) {
    return WeekPeriodRecord(
      lessonId: map['lessonId'] as int,
      week: map['week'] as int,
      period: map['period'] as int,
      semester: map['開講時期'] as int,
      lessonName: map['授業名'] as String,
    );
  }
}
