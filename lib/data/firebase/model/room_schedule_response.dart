import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_schedule_response.freezed.dart';
part 'room_schedule_response.g.dart';

@freezed
abstract class RoomScheduleResponse with _$RoomScheduleResponse {
  //
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RoomScheduleResponse({
    required DateTime beginDatetime,
    required DateTime endDatetime,
    required String title,
  }) = _RoomScheduleResponse;

  factory RoomScheduleResponse.fromJson(Map<String, Object?> json) =>
      _$RoomScheduleResponseFromJson(json);
}
