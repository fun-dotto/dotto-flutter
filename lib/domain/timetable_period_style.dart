import 'package:collection/collection.dart';

enum TimetablePeriodStyle {
  numberOnly(key: 'number_only', label: '時限のみ'),
  numberAndTime(key: 'number_and_time', label: '時限と時刻');

  const TimetablePeriodStyle({required this.key, required this.label});

  final String key;
  final String label;

  static TimetablePeriodStyle? fromKey(String key) {
    return TimetablePeriodStyle.values.firstWhereOrNull(
      (style) => style.key == key,
    );
  }
}
