import 'package:flutter/material.dart';

enum TimetableSlot {
  first(
    startTime: TimeOfDay(hour: 9, minute: 0),
    endTime: TimeOfDay(hour: 10, minute: 30),
  ),
  second(
    startTime: TimeOfDay(hour: 10, minute: 40),
    endTime: TimeOfDay(hour: 12, minute: 10),
  ),
  third(
    startTime: TimeOfDay(hour: 13, minute: 10),
    endTime: TimeOfDay(hour: 14, minute: 40),
  ),
  fourth(
    startTime: TimeOfDay(hour: 14, minute: 50),
    endTime: TimeOfDay(hour: 16, minute: 20),
  ),
  fifth(
    startTime: TimeOfDay(hour: 16, minute: 30),
    endTime: TimeOfDay(hour: 18, minute: 0),
  ),
  sixth(
    startTime: TimeOfDay(hour: 18, minute: 10),
    endTime: TimeOfDay(hour: 19, minute: 40),
  );

  const TimetableSlot({required this.startTime, required this.endTime});

  final TimeOfDay startTime;
  final TimeOfDay endTime;

  int get number => index + 1;

  static TimetableSlot fromNumber(int number) {
    return TimetableSlot.values[number - 1];
  }
}
