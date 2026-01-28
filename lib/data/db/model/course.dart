import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required int lessonId,
    required String lessonName,
    int? kakomonLessonId,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
