import 'package:dotto/controller/user_controller.dart';
import 'package:dotto/feature/kamoku_detail/kamoku_detail_feedback.dart';
import 'package:dotto/feature/kamoku_detail/kamoku_detail_kakomon_list.dart';
import 'package:dotto/feature/kamoku_detail/kamoku_detail_syllabus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class KamokuDetailScreen extends ConsumerWidget {
  const KamokuDetailScreen({
    required this.lessonId,
    required this.lessonName,
    super.key,
    this.kakomonLessonId,
  });

  final int lessonId;
  final String lessonName;
  final int? kakomonLessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final isAuthenticated = user != null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lessonName),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(text: 'シラバス'),
              Tab(text: 'レビュー'),
              Tab(text: '過去問'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            KamokuDetailSyllabusScreen(lessonId: lessonId),
            KamokuFeedbackScreen(
              lessonId: lessonId,
              isAuthenticated: isAuthenticated,
            ),
            KamokuDetailKakomonListScreen(
              lessonId: kakomonLessonId ?? lessonId,
              isAuthenticated: isAuthenticated,
            ),
          ],
        ),
      ),
    );
  }
}
