import 'dart:async';

import 'package:dotto/controller/config_controller.dart';
import 'package:dotto/domain/quick_link.dart';
import 'package:dotto/domain/timetable_period_style.dart';
import 'package:dotto/feature/home/component/bus_card.dart';
import 'package:dotto/feature/home/component/file_grid.dart';
import 'package:dotto/feature/home/component/file_tile.dart';
import 'package:dotto/feature/home/component/funch_card.dart';
import 'package:dotto/feature/home/component/link_grid.dart';
import 'package:dotto/feature/home/component/timetable_buttons.dart';
import 'package:dotto/feature/home/component/timetable_calendar_view.dart';
import 'package:dotto/feature/home/home_viewmodel.dart';
import 'package:dotto/feature/kamoku_detail/kamoku_detail_screen.dart';
import 'package:dotto/feature/timetable/screen/course_cancellation_screen.dart';
import 'package:dotto/feature/timetable/screen/edit_timetable_screen.dart';
import 'package:dotto/widget/web_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(homeViewModelProvider.notifier).onAppear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider);
    final config = ref.watch(configProvider);

    final fileItems = <(String label, String url, IconData icon)>[
      ('学年暦', config.officialCalendarPdfUrl, Icons.event_note),
      ('時間割 前期', config.timetable1PdfUrl, Icons.calendar_month),
      ('時間割 後期', config.timetable2PdfUrl, Icons.calendar_month),
    ];
    final infoTiles = <Widget>[
      ...fileItems.map(
        (item) => FileTile(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WebPdfViewer(url: item.$2, filename: item.$1),
                settings: RouteSettings(
                  name: '/home/web_pdf_viewer?url=${item.$2}',
                ),
              ),
            );
          },
          icon: item.$3,
          title: item.$1,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dotto'),
        centerTitle: false,
        actions: [
          viewModel.timetablePeriodStyle.when(
            data: (style) {
              return Row(
                spacing: 4,
                children: [
                  const Text('時刻を表示'),
                  Switch(
                    value: style == TimetablePeriodStyle.numberAndTime,
                    onChanged: (value) {
                      ref
                          .read(homeViewModelProvider.notifier)
                          .onTimetablePeriodStyleChanged(
                            value
                                ? TimetablePeriodStyle.numberAndTime
                                : TimetablePeriodStyle.numberOnly,
                          );
                    },
                  ),
                ],
              );
            },
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              spacing: 16,
              children: [
                Column(
                  spacing: 8,
                  children: [
                    switch (viewModel.timetables) {
                      AsyncData(:final value) => TimetableCalendarView(
                        timetables: value,
                        selectedDate: viewModel.selectedDate,
                        onDateSelected: ref
                            .read(homeViewModelProvider.notifier)
                            .onDateSelected,
                        onCourseSelected: (course) async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              // TODO: CourseDetailScreenへの置き換え
                              builder: (_) => KamokuDetailScreen(
                                lessonId: course.lessonId,
                                lessonName: course.courseName,
                                kakomonLessonId: course.kakomonLessonId,
                              ),
                              settings: RouteSettings(
                                name: '/courses/${course.lessonId}',
                              ),
                            ),
                          );
                        },
                      ),
                      AsyncError() => const SizedBox.shrink(),
                      AsyncLoading() => const SizedBox.shrink(),
                    },
                    TimetableButtons(
                      onCourseCancellationPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CourseCancellationScreen(),
                            settings: const RouteSettings(
                              name: '/home/course_cancellation',
                            ),
                          ),
                        );
                      },
                      onEditTimetablePressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const EditTimetableScreen(),
                            settings: const RouteSettings(
                              name: '/home/edit_timetable',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const BusCard(),
                if (config.isFunchEnabled) ...[
                  const FunchCard(),
                ],
                Column(
                  spacing: 8,
                  children: [
                    FileGrid(children: infoTiles),
                    const LinkGrid(links: QuickLink.links),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
