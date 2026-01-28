import 'package:freezed_annotation/freezed_annotation.dart';

part 'sup_lecture.freezed.dart';
part 'sup_lecture.g.dart';

@freezed
abstract class SupLecture with _$SupLecture {
  const factory SupLecture({
    required String date,
    required String lessonName,
    required int period,
  }) = _SupLecture;

  factory SupLecture.fromJson(Map<String, dynamic> json) =>
      _$SupLectureFromJson(json);
}
