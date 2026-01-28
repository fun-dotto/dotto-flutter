import 'package:dio/dio.dart';
import 'package:dotto/data/github/model/github_profile_response.dart';

final class ContributorAPI {
  static Future<List<GitHubProfileResponse>> getContributors() async {
    final dio = Dio();
    // GitHub contributors API for this repository
    const url = 'https://api.github.com/repos/fun-dotto/dotto/contributors';

    //
    // ignore: inference_failure_on_function_invocation
    final response = await dio.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to get contributors');
    }

    final data = response.data;
    if (data == null || data is! List) {
      throw Exception('Failed to get contributors');
    }

    final githubProfileResponses = data
        .map((e) => GitHubProfileResponse.fromJson(e as Map<String, dynamic>))
        .toList();

    return githubProfileResponses;
  }
}
