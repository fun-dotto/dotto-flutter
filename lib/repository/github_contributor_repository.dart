import 'package:dotto/data/github/contributor_api.dart';
import 'package:dotto/domain/github_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gitHubContributorRepositoryProvider =
    Provider<GitHubContributorRepository>(
      (_) => GitHubContributorRepositoryImpl(),
    );

//
// ignore: one_member_abstracts
abstract class GitHubContributorRepository {
  Future<List<GitHubProfile>> getContributors();
}

final class GitHubContributorRepositoryImpl
    implements GitHubContributorRepository {
  @override
  Future<List<GitHubProfile>> getContributors() async {
    try {
      final contributors = await ContributorAPI.getContributors();
      return contributors
          .map(
            (e) => GitHubProfile(
              id: e.id.toString(),
              login: e.login,
              avatarUrl: e.avatarUrl,
              htmlUrl: e.htmlUrl,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
