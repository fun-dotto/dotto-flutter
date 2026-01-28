import 'dart:async';

import 'package:dotto/domain/day_of_week.dart';
import 'package:dotto/domain/semester.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:dotto/feature/timetable/viewmodel/select_course_viewmodel.dart';
import 'package:dotto_design_system/component/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SelectCourseScreen extends ConsumerStatefulWidget {
  const SelectCourseScreen({
    required this.semester,
    required this.dayOfWeek,
    required this.period,
    super.key,
  });

  final Semester semester;
  final DayOfWeek dayOfWeek;
  final TimetableSlot period;

  @override
  ConsumerState<SelectCourseScreen> createState() => _SelectCourseScreenState();
}

final class _SelectCourseScreenState extends ConsumerState<SelectCourseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(
              selectCourseViewModelProvider(
                widget.semester,
                widget.dayOfWeek,
                widget.period,
              ).notifier,
            )
            .onAppear(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(
      selectCourseViewModelProvider(
        widget.semester,
        widget.dayOfWeek,
        widget.period,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.semester.label} ${widget.dayOfWeek.label}曜${widget.period.number}限',
        ),
      ),
      body: viewModel.availableCourses.when(
        data: (availableCourses) {
          return viewModel.personalLessonIdList.when(
            data: (personalLessonIdList) {
              if (availableCourses.isEmpty) {
                return const Center(child: Text('対象の科目はありません'));
              }
              return ListView.builder(
                itemCount: availableCourses.length,
                itemBuilder: (context, index) {
                  final course = availableCourses[index];
                  final isSelected = personalLessonIdList.contains(course.lessonId);
                  return ListTile(
                    title: Text(course.lessonName),
                    trailing: isSelected
                        ? DottoButton(
                            onPressed: () async {
                              await ref
                                  .read(
                                    selectCourseViewModelProvider(
                                      widget.semester,
                                      widget.dayOfWeek,
                                      widget.period,
                                    ).notifier,
                                  )
                                  .onCourseRemoved(course.lessonId);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            type: DottoButtonType.outlined,
                            child: const Text('削除'),
                          )
                        : DottoButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(
                                    selectCourseViewModelProvider(
                                      widget.semester,
                                      widget.dayOfWeek,
                                      widget.period,
                                    ).notifier,
                                  )
                                  .onCourseAdded(course.lessonId);
                              if (!success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('3科目以上選択することはできません'),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            child: const Text('追加'),
                          ),
                  );
                },
              );
            },
            error: (error, stackTrace) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          );
        },
        error: (error, stackTrace) =>
            const Center(child: Text('データの取得に失敗しました')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
