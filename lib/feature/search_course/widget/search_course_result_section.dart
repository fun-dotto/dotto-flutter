import 'package:dotto/feature/search_course/widget/search_course_result.dart';
import 'package:flutter/material.dart';

final class SearchCourseResultSection extends StatelessWidget {
  const SearchCourseResultSection({
    required this.courses,
    required this.personalLessonIdList,
    required this.onTapped,
    required this.onAddButtonTapped,
    super.key,
  });

  final List<Map<String, dynamic>> courses;
  final List<int> personalLessonIdList;
  final void Function(Map<String, dynamic>) onTapped;
  final void Function(int lessonId) onAddButtonTapped;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }
    if (courses.isNotEmpty) {
      return SearchCourseResult(
        records: courses,
        personalLessonIdList: personalLessonIdList,
        onTapped: onTapped,
        onAddButtonTapped: onAddButtonTapped,
      );
    }
    return const Center(
      child: Padding(padding: EdgeInsets.all(16), child: Text('見つかりませんでした')),
    );
  }
}
