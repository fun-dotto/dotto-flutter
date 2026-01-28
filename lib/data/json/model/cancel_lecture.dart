import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancel_lecture.freezed.dart';
part 'cancel_lecture.g.dart';

@freezed
abstract class CancelLecture with _$CancelLecture {
  const factory CancelLecture({
    required int lessonId,
    required String date,
    required int period,
    required String lessonName,
    required String campus,
    required String staff,
    required String comment,
    required String type,
  }) = _CancelLecture;

  factory CancelLecture.fromJson(Map<String, dynamic> json) =>
      _$CancelLectureFromJson(json);
}
