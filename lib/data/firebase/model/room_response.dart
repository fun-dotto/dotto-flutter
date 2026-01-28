import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_response.freezed.dart';
part 'room_response.g.dart';

@freezed
abstract class RoomResponse with _$RoomResponse {
  //
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RoomResponse({
    required String? classroomNo,
    required String? detail,
    required String header,
    required String? mail,
    required List<String>? searchWordList,
  }) = _RoomResponse;

  factory RoomResponse.fromJson(Map<String, Object?> json) =>
      _$RoomResponseFromJson(json);
}
