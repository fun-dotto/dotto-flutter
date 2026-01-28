import 'dart:async';

import 'package:dotto/feature/kamoku_detail/kamoku_detail_screen.dart';
import 'package:dotto/feature/search_course/domain/search_course_filter_option_choice.dart';
import 'package:dotto/feature/search_course/domain/search_course_filter_options.dart';
import 'package:dotto/feature/search_course/search_course_domain_error.dart';
import 'package:dotto/feature/search_course/search_course_viewmodel.dart';
import 'package:dotto/feature/search_course/search_course_viewstate.dart';
import 'package:dotto/feature/search_course/widget/search_course_action_buttons.dart';
import 'package:dotto/feature/search_course/widget/search_course_box.dart';
import 'package:dotto/feature/search_course/widget/search_course_filter_section.dart';
import 'package:dotto/feature/search_course/widget/search_course_result_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SearchCourseScreen extends ConsumerStatefulWidget {
  const SearchCourseScreen({super.key});

  @override
  ConsumerState<SearchCourseScreen> createState() => _SearchCourseScreenState();
}

final class _SearchCourseScreenState extends ConsumerState<SearchCourseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(searchCourseViewModelProvider.notifier).onAppear());
    });
  }

  Widget _body({
    required SearchCourseViewState viewModel,
    required void Function(
      SearchCourseFilterOptions filterOption,
      SearchCourseFilterOptionChoice choice,
      bool? isSelected,
    )
    onChanged,
    required void Function() onCleared,
    required void Function() onSearchButtonTapped,
    required void Function(Map<String, dynamic>) onTapped,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchCourseBox(
            textEditingController: viewModel.textEditingController,
            focusNode: viewModel.focusNode,
            onCleared: onCleared,
            onSubmitted: (value) => onSearchButtonTapped(),
          ),
          SearchCourseFilterSection(
            visibilityStatus: viewModel.visibilityStatus,
            selectedChoicesMap: viewModel.selectedChoicesMap,
            onChanged: onChanged,
          ),
          SearchCourseActionButtons(
            onSearchButtonTapped: onSearchButtonTapped,
          ),
          SearchCourseResultSection(
            courses: viewModel.searchResults ?? [],
            personalLessonIdList: viewModel.personalLessonIdList.value ?? [],
            onTapped: onTapped,
            onAddButtonTapped: (lessonId) async {
              try {
                await ref
                    .read(searchCourseViewModelProvider.notifier)
                    .onAddButtonTapped(lessonId);
              } on SearchCourseDomainError catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(searchCourseViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('科目'), centerTitle: false),
      body: _body(
        viewModel: viewModel,
        onChanged: (filterOption, choice, isSelected) => ref
            .read(searchCourseViewModelProvider.notifier)
            .onCheckboxTapped(
              filterOption: filterOption,
              choice: choice,
              isSelected: isSelected,
            ),
        onCleared: () =>
            ref.read(searchCourseViewModelProvider.notifier).onCleared(),
        onSearchButtonTapped: () => ref
            .read(searchCourseViewModelProvider.notifier)
            .onSearchButtonTapped(),
        onTapped: (record) async {
          final lessonId = record['LessonId'] as int;
          final lessonName = record['授業名'] as String;
          final kakomonLessonId = record['過去問'] as int?;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => KamokuDetailScreen(
                lessonId: lessonId,
                lessonName: lessonName,
                kakomonLessonId: kakomonLessonId,
              ),
              settings: RouteSettings(
                name:
                    '/course/course_detail?lessonId=$lessonId&lessonName=$lessonName&kakomonLessonId=$kakomonLessonId',
              ),
            ),
          );
          ref
              .read(searchCourseViewModelProvider.notifier)
              .onResultRowTapped(record);
        },
      ),
    );
  }
}
