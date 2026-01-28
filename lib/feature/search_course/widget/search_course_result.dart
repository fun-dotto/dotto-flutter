import 'package:dotto/feature/search_course/repository/search_course_repository.dart';
import 'package:dotto/feature/search_course/widget/search_course_result_item.dart';
import 'package:flutter/material.dart';

final class SearchCourseResult extends StatelessWidget {
  const SearchCourseResult({
    required this.records,
    required this.personalLessonIdList,
    required this.onTapped,
    required this.onAddButtonTapped,
    super.key,
  });

  final List<Map<String, dynamic>> records;
  final List<int> personalLessonIdList;
  final void Function(Map<String, dynamic>) onTapped;
  final void Function(int lessonId) onAddButtonTapped;

  Future<Map<int, String>> getWeekPeriod(List<int> lessonIdList) async {
    final records = await SearchCourseRepository().fetchWeekPeriodDB(
      lessonIdList,
    );
    final weekPeriodMap = <int, Map<int, List<int>>>{};
    for (final record in records) {
      final lessonId = record['lessonId'] as int;
      final week = record['week'] as int;
      final period = record['period'] as int;
      if (weekPeriodMap.containsKey(lessonId)) {
        if (weekPeriodMap[lessonId]!.containsKey(week)) {
          weekPeriodMap[lessonId]![week]!.add(period);
        } else {
          weekPeriodMap[lessonId]![week] = [period];
        }
      } else {
        weekPeriodMap[lessonId] = {
          week: [period],
        };
      }
    }
    final weekPeriodStringMap = weekPeriodMap.map((lessonId, value) {
      final weekString = <String>['', '月', '火', '水', '木', '金', '土', '日'];
      final s = <String>[];
      value.forEach((week, periodList) {
        if (week != 0) {
          s.add('${weekString[week]}${periodList.join()}');
        }
      });
      return MapEntry(lessonId, s.join(','));
    });
    return weekPeriodStringMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getWeekPeriod(records.map((e) => e['LessonId'] as int).toList()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final weekPeriodStringMap = snapshot.data!;
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (_, _) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final record = records[index];
              final lessonId = record['LessonId'] as int;
              final lessonName = record['授業名'] as String;
              final weekPeriodString = weekPeriodStringMap[lessonId] ?? '';
              return SearchCourseResultItem(
                lessonId: lessonId,
                lessonName: lessonName,
                weekPeriodString: weekPeriodString,
                isAdded: personalLessonIdList.contains(lessonId),
                onTapped: () => onTapped(record),
                onAddButtonTapped: () => onAddButtonTapped(lessonId),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
