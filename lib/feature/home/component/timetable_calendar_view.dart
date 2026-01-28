import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:dotto/domain/timetable.dart';
import 'package:dotto/domain/timetable_course.dart';
import 'package:dotto/feature/home/component/timetable_view.dart';
import 'package:dotto/helper/date_formatter.dart';
import 'package:dotto_design_system/style/semantic_color.dart';
import 'package:flutter/material.dart';

final class TimetableCalendarView extends StatelessWidget {
  const TimetableCalendarView({
    required this.timetables,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onCourseSelected,
    super.key,
  });
  final List<Timetable> timetables;
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final void Function(TimetableCourse) onCourseSelected;

  Widget _dateButton({
    required DateTime date,
    required bool isSelected,
    required void Function() onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16),
          foregroundColor: isSelected
              ? SemanticColor.light.labelTertiary
              : SemanticColor.light.labelSecondary,
          backgroundColor: isSelected
              ? SemanticColor.light.accentPrimary
              : SemanticColor.light.backgroundSecondary,
          overlayColor: SemanticColor.light.accentPrimary,
          side: BorderSide(color: SemanticColor.light.borderPrimary),
          shape: const CircleBorder(),
          fixedSize: const Size(48, 48),
        ),
        onPressed: onPressed,
        child: Text(DateFormatter.dayOfMonth(date)),
      ),
    );
  }

  Widget _dateButtons({
    required List<DateTime> dates,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: dates
          .map(
            (date) => _dateButton(
              date: date,
              isSelected: selectedDate == date,
              onPressed: () {
                onDateSelected(date);
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final selectedDate = DateTime(now.year, now.month, now.day);
    final dates = List.generate(
      5,
      (index) => monday.add(Duration(days: index)),
    );
    return Column(
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: dates
              .map(
                (date) => SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      DateFormatter.dayOfWeek(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: SemanticColor.light.labelPrimary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        CarouselSlider(
          items: [
            _dateButtons(
              dates: dates,
            ),
            _dateButtons(
              dates: dates
                  .map((date) => date.add(const Duration(days: 7)))
                  .toList(),
            ),
          ],
          options: CarouselOptions(
            height: 48,
            viewportFraction: 1,
            enableInfiniteScroll: false,
          ),
        ),
        TimetableView(
          timetable: timetables.firstWhereOrNull(
            (timetable) => timetable.date.isAtSameMomentAs(selectedDate),
          ),
          onCourseSelected: onCourseSelected,
        ),
      ],
    );
  }
}
