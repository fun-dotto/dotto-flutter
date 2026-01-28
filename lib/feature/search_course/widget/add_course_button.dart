import 'package:flutter/material.dart';

final class AddCourseButton extends StatelessWidget {
  const AddCourseButton({
    required this.lessonId,
    required this.isAdded,
    required this.onAddButtonTapped,
    super.key,
  });

  final int lessonId;
  final bool isAdded;
  final void Function() onAddButtonTapped;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.playlist_add,
        color: isAdded ? Colors.green : Colors.black,
      ),
      onPressed: onAddButtonTapped,
    );
  }
}
