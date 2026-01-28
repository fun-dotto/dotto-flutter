import 'package:dotto_design_system/component/button.dart';
import 'package:flutter/material.dart';

final class TimetableButtons extends StatelessWidget {
  const TimetableButtons({
    required this.onCourseCancellationPressed,
    required this.onEditTimetablePressed,
    super.key,
  });

  final VoidCallback onCourseCancellationPressed;
  final VoidCallback onEditTimetablePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DottoButton(
          onPressed: onCourseCancellationPressed,
          type: DottoButtonType.text,
          child: const Text('休講・補講'),
        ),
        const Spacer(),
        DottoButton(
          onPressed: onEditTimetablePressed,
          type: DottoButtonType.text,
          child: const Text('時間割を編集'),
        ),
      ],
    );
  }
}
