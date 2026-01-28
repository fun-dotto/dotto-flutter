import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_profile_response.freezed.dart';
part 'github_profile_response.g.dart';

@freezed
abstract class GitHubProfileResponse with _$GitHubProfileResponse {
  //
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GitHubProfileResponse({
    required int id,
    required String login,
    required String avatarUrl,
    required String htmlUrl,
  }) = _GitHubProfileResponse;

  factory GitHubProfileResponse.fromJson(Map<String, Object?> json) =>
      _$GitHubProfileResponseFromJson(json);
}
