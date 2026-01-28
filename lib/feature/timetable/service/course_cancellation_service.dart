import 'package:dotto/data/json/model/cancel_lecture.dart';
import 'package:dotto/data/json/timetable_json.dart';
import 'package:dotto/repository/timetable_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CourseCancellationService {
  CourseCancellationService(this.ref);

  final Ref ref;

  // TODO: ドメインモデルを作成
  // TODO: TimetableRepositoryに移行
  Future<List<CancelLecture>> getCourseCancellations({
    required bool isFilteredOnlyTaking,
  }) async {
    final canceledLectures = await TimetableJSON.fetchCancelLectures();
    if (!isFilteredOnlyTaking) {
      return canceledLectures;
    }
    final repository = ref.read(timetableRepositoryProvider);
    final personalTimetableMap = await repository
        .getPersonalTimetableMapString();
    return canceledLectures.where((courseCancellation) {
      return personalTimetableMap.keys.contains(courseCancellation.lessonName);
    }).toList();
  }
}
