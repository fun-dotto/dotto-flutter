import 'package:collection/collection.dart';
import 'package:dotto/feature/search_course/domain/search_course_filter_option_choice.dart';
import 'package:dotto/feature/search_course/domain/search_course_filter_options.dart';
import 'package:dotto/feature/search_course/repository/search_course_repository.dart';
import 'package:dotto/feature/search_course/search_course_domain_error.dart';
import 'package:dotto/feature/search_course/search_course_service.dart';
import 'package:dotto/feature/search_course/search_course_viewstate.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_course_viewmodel.g.dart';

@riverpod
final class SearchCourseViewModel extends _$SearchCourseViewModel {
  late final SearchCourseService _service;

  @override
  SearchCourseViewState build() {
    _service = SearchCourseService(ref);

    return SearchCourseViewState(
      selectedChoicesMap: Map.fromIterables(
        SearchCourseFilterOptions.values,
        SearchCourseFilterOptions.values.map((e) => []),
      ),
      visibilityStatus: {
        SearchCourseFilterOptions.largeCategory,
        SearchCourseFilterOptions.term,
        SearchCourseFilterOptions.classification,
      },
      searchResults: null,
      textEditingController: TextEditingController(),
      focusNode: FocusNode(),
      grade: const AsyncValue.loading(),
      academicArea: const AsyncValue.loading(),
      personalLessonIdList: const AsyncValue.loading(),
    );
  }

  Future<void> onAppear() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    final grade = await _service.getUserGrade();
    final academicArea = await _service.getUserAcademicArea();
    final personalLessonIdList = await _service.getPersonalLessonIdList();
    state = state.copyWith(
      grade: AsyncValue.data(grade),
      academicArea: AsyncValue.data(academicArea),
      personalLessonIdList: AsyncValue.data(personalLessonIdList),
    );
  }

  Future<void> onAddButtonTapped(int lessonId) async {
    final personalLessonIdList = await _service.getPersonalLessonIdList();
    if (!personalLessonIdList.contains(lessonId)) {
      if (await _service.isOverSelected(lessonId)) {
        throw SearchCourseDomainError.overSelected;
      } else {
        await _service.addLesson(lessonId);
      }
    } else {
      await _service.removeLesson(lessonId);
    }
    final renewedPersonalLessonIdList = await _service
        .getPersonalLessonIdList();
    state = state.copyWith(
      personalLessonIdList: AsyncValue.data(renewedPersonalLessonIdList),
    );
  }

  Future<void> onSearchButtonTapped() async {
    state.focusNode.unfocus();
    final repository = SearchCourseRepository();
    final searchResults = await repository.searchCourses(
      selectedChoicesMap: state.selectedChoicesMap,
      searchWord: state.textEditingController.text,
    );
    state = state.copyWith(searchResults: searchResults);
  }

  void onCleared() {
    state.textEditingController.clear();
  }

  void onCheckboxTapped({
    required SearchCourseFilterOptions filterOption,
    required SearchCourseFilterOptionChoice choice,
    required bool? isSelected,
  }) {
    // Create a mutable deep copy of the map and its lists
    final selectedChoicesMap =
        Map<
          SearchCourseFilterOptions,
          List<SearchCourseFilterOptionChoice>
        >.fromEntries(
          state.selectedChoicesMap.entries.map(
            (entry) => MapEntry(
              entry.key,
              List<SearchCourseFilterOptionChoice>.from(entry.value),
            ),
          ),
        );
    if (isSelected ?? false) {
      selectedChoicesMap[filterOption]?.add(choice);
    } else {
      selectedChoicesMap[filterOption]?.remove(choice);
    }

    final visibilityStatus = _setVisibilityStatus(selectedChoicesMap);

    for (final e in SearchCourseFilterOptions.values) {
      if (state.visibilityStatus.contains(e) && !visibilityStatus.contains(e)) {
        selectedChoicesMap[e] = [];
      }
    }

    if (!state.visibilityStatus.contains(SearchCourseFilterOptions.grade) &&
        visibilityStatus.contains(SearchCourseFilterOptions.grade)) {
      final gradeChoice = SearchCourseFilterOptions.grade.choices
          .firstWhereOrNull(
            (e) => e.id == state.grade.value?.deprecatedFilterOptionChoiceKey,
          );
      if (gradeChoice != null) {
        selectedChoicesMap[SearchCourseFilterOptions.grade]?.add(
          gradeChoice,
        );
      }
    }

    if (!state.visibilityStatus.contains(
          SearchCourseFilterOptions.course,
        ) &&
        visibilityStatus.contains(SearchCourseFilterOptions.course)) {
      final courseChoice = SearchCourseFilterOptions.course.choices
          .firstWhereOrNull(
            (e) =>
                e.id ==
                state.academicArea.value?.deprecatedFilterOptionChoiceKey,
          );
      if (courseChoice != null) {
        selectedChoicesMap[SearchCourseFilterOptions.course]?.add(
          courseChoice,
        );
      }
    }

    state = state.copyWith(
      selectedChoicesMap: selectedChoicesMap,
      visibilityStatus: visibilityStatus,
    );
  }

  Set<SearchCourseFilterOptions> _setVisibilityStatus(
    Map<SearchCourseFilterOptions, List<SearchCourseFilterOptionChoice>>
    selectedChoicesMap,
  ) {
    final visibilityStatus = <SearchCourseFilterOptions>{
      SearchCourseFilterOptions.largeCategory,
      SearchCourseFilterOptions.term,
      SearchCourseFilterOptions.classification,
    };

    // 専門が選択されている場合
    if (selectedChoicesMap[SearchCourseFilterOptions.largeCategory]?.contains(
          SearchCourseFilterOptions.largeCategory.choices[0],
        ) ??
        false) {
      visibilityStatus
        ..add(SearchCourseFilterOptions.grade)
        ..add(SearchCourseFilterOptions.course);
    }

    // 教養が選択されている場合
    if (selectedChoicesMap[SearchCourseFilterOptions.largeCategory]?.contains(
          SearchCourseFilterOptions.largeCategory.choices[1],
        ) ??
        false) {
      visibilityStatus
        ..add(SearchCourseFilterOptions.grade)
        ..add(SearchCourseFilterOptions.educationField);
    }

    // 大学院が選択されている場合
    if (selectedChoicesMap[SearchCourseFilterOptions.largeCategory]?.contains(
          SearchCourseFilterOptions.largeCategory.choices[2],
        ) ??
        false) {
      visibilityStatus.add(SearchCourseFilterOptions.masterField);
    }

    return visibilityStatus;
  }

  void onResultRowTapped(Map<String, dynamic> record) {
    state.focusNode.unfocus();
  }
}
