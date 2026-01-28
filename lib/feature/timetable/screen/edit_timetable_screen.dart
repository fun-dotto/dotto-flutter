import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dotto/data/db/model/week_period_record.dart';
import 'package:dotto/domain/day_of_week.dart';
import 'package:dotto/domain/semester.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:dotto/feature/timetable/screen/select_course_screen.dart';
import 'package:dotto/feature/timetable/viewmodel/edit_timetable_viewmodel.dart';
import 'package:dotto/feature/timetable/viewstate/edit_timetable_viewstate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class EditTimetableScreen extends ConsumerStatefulWidget {
  const EditTimetableScreen({super.key});

  @override
  ConsumerState<EditTimetableScreen> createState() =>
      _EditTimetableScreenState();
}

final class _EditTimetableScreenState extends ConsumerState<EditTimetableScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final viewModel = ref.read(editTimetableViewModelProvider);
    _tabController = TabController(
      length: Semester.values.length,
      vsync: this,
      initialIndex: Semester.values.indexOf(viewModel.selectedSemester),
    );
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(editTimetableViewModelProvider.notifier).onAppear());
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final viewModel = ref.read(editTimetableViewModelProvider);
    final selected = Semester.values[_tabController.index];
    if (viewModel.selectedSemester != selected) {
      ref
          .read(editTimetableViewModelProvider.notifier)
          .onSemesterSelected(selected);
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabSelection)
      ..dispose();
    super.dispose();
  }

  Widget _tableText(
    BuildContext context,
    DayOfWeek dayOfWeek,
    TimetableSlot period,
    Semester semester,
    List<WeekPeriodRecord> records,
    List<int> personalLessonIdList,
  ) {
    final selectedLessonList = records.where((record) {
      return record.week == dayOfWeek.number &&
          record.period == period.number &&
          (record.semester == semester.number || record.semester == 0) &&
          personalLessonIdList.contains(record.lessonId);
    }).toList();
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 100,
        child: selectedLessonList.isNotEmpty
            ? Column(
                children: selectedLessonList
                    .map(
                      (lesson) => Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            lesson.lessonName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Center(
                  child: Icon(Icons.add, color: Colors.grey.shade400),
                ),
              ),
      ),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SelectCourseScreen(
              semester: semester,
              dayOfWeek: dayOfWeek,
              period: period,
            ),
            settings: RouteSettings(
              name:
                  '/home/edit_timetable/select_course?semester=${semester.number}&dayOfWeek=${dayOfWeek.number}&period=${period.number}',
            ),
          ),
        );
        await ref.read(editTimetableViewModelProvider.notifier).refresh();
      },
    );
  }

  Widget _takingCourseTable(
    Semester semester,
    List<WeekPeriodRecord> records,
    List<int> personalLessonIdList,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
            5: FlexColumnWidth(),
            6: FlexColumnWidth(),
          },
          children: <TableRow>[
            TableRow(
              children: DayOfWeek.weekdays
                  .map(
                    (e) => TableCell(
                      child: Center(
                        child: Text(
                          e.label,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...TimetableSlot.values.map(
              (period) => TableRow(
                children: DayOfWeek.weekdays
                    .map(
                      (dayOfWeek) => _tableText(
                        context,
                        dayOfWeek,
                        period,
                        semester,
                        records,
                        personalLessonIdList,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _takingCourseList(
    Semester semester,
    List<WeekPeriodRecord> records,
    List<int> personalLessonIdList,
  ) {
    final seasonList = records
        .where((record) {
          return personalLessonIdList.contains(record.lessonId) &&
              (record.semester == semester.number || record.semester == 0);
        })
        .toList()
        .sorted((a, b) {
          final dayCompare = a.week.compareTo(b.week);
          if (dayCompare != 0) {
            return dayCompare;
          }
          return a.period.compareTo(b.period);
        });
    return ListView.separated(
      itemCount: seasonList.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final record = seasonList[index];
        return ListTile(
          title: Text(record.lessonName),
          subtitle: Text(
            '${DayOfWeek.fromNumber(record.week).label}'
            '${TimetableSlot.fromNumber(record.period).number}',
          ),
        );
      },
    );
  }

  Widget _timetable(
    Semester semester,
    TimetableViewStyle viewStyle,
    List<WeekPeriodRecord> records,
    List<int> personalLessonIdList,
  ) {
    switch (viewStyle) {
      case TimetableViewStyle.table:
        return _takingCourseTable(semester, records, personalLessonIdList);
      case TimetableViewStyle.list:
        return _takingCourseList(semester, records, personalLessonIdList);
    }
  }

  Widget _buildContent(EditTimetableViewState viewModel) {
    return viewModel.weekPeriodAllRecords.when(
      data: (records) {
        return viewModel.personalLessonIdList.when(
          data: (personalLessonIdList) {
            return TabBarView(
              controller: _tabController,
              children: Semester.values
                  .map(
                    (semester) => _timetable(
                      semester,
                      viewModel.timetableViewStyle,
                      records,
                      personalLessonIdList,
                    ),
                  )
                  .toList(),
            );
          },
          error: (error, stackTrace) =>
              const Center(child: Text('データの取得に失敗しました')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) => const Center(child: Text('データの取得に失敗しました')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(editTimetableViewModelProvider);
    final selectedIndex = Semester.values.indexOf(viewModel.selectedSemester);
    if (_tabController.index != selectedIndex &&
        !_tabController.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (_tabController.index != selectedIndex) {
          _tabController.animateTo(selectedIndex);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(editTimetableViewModelProvider.notifier)
                  .onViewStyleToggled();
            },
            icon: viewModel.timetableViewStyle.icon,
          ),
        ],
        bottom: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: Semester.values.map((e) => Tab(text: e.label)).toList(),
        ),
      ),
      body: _buildContent(viewModel),
    );
  }
}
