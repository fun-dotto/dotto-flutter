import 'package:dotto/domain/timetable_course.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable.freezed.dart';

@freezed
abstract class Timetable with _$Timetable {
  const factory Timetable({
    required DateTime date,
    required List<TimetableCourse> courses,
  }) = _Timetable;
}
