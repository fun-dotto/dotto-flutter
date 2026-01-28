import 'package:collection/collection.dart';
import 'package:dotto/domain/timetable.dart';
import 'package:dotto/domain/timetable_course.dart';
import 'package:dotto/domain/timetable_course_type.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:dotto_design_system/style/semantic_color.dart';
import 'package:flutter/material.dart';

final class TimetableView extends StatelessWidget {
  const TimetableView({
    required this.timetable,
    required this.onCourseSelected,
    super.key,
  });
  final Timetable? timetable;
  final void Function(TimetableCourse) onCourseSelected;

  Widget _canceledLabel() {
    return Row(
      children: [
        Icon(Icons.cancel_outlined, color: SemanticColor.light.accentError),
        Text('休講', style: TextStyle(color: SemanticColor.light.accentError)),
      ],
    );
  }

  Widget _madeUpLabel() {
    return Row(
      children: [
        Icon(Icons.info_outline, color: SemanticColor.light.accentWarning),
        Text('補講', style: TextStyle(color: SemanticColor.light.accentWarning)),
      ],
    );
  }

  Widget _slotButton({
    required TimetableSlot slot,
    required TimetableCourse? course,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        backgroundColor: SemanticColor.light.backgroundSecondary,
        disabledBackgroundColor: SemanticColor.light.backgroundTertiary,
        overlayColor: SemanticColor.light.accentPrimary,
        side: BorderSide(color: SemanticColor.light.borderPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: course != null ? () => onCourseSelected(course) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              Text(
                course?.courseName ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: SemanticColor.light.labelPrimary,
                ),
              ),
              switch (course?.type) {
                TimetableCourseType.cancelled => _canceledLabel(),
                TimetableCourseType.madeUp => _madeUpLabel(),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
          Text(
            course?.roomName ?? '',
            style: TextStyle(
              fontSize: 12,
              color: SemanticColor.light.labelSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot({
    required TimetableSlot slot,
    required TimetableCourse? course,
  }) {
    return Row(
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 24,
            child: Center(
              child: Text(
                slot.number.toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: SemanticColor.light.accentPrimary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _slotButton(slot: slot, course: course),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: TimetableSlot.values
          .map(
            (slot) => _slot(
              slot: slot,
              course: timetable?.courses.firstWhereOrNull(
                (course) => course.slot == slot,
              ),
            ),
          )
          .toList(),
    );
  }
}
