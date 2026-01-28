import 'package:dotto/data/db/course_db.dart';
import 'package:dotto/data/firebase/room_api.dart';
import 'package:dotto/data/firebase/timetable_api.dart';
import 'package:dotto/data/json/model/one_week_schedule.dart';
import 'package:dotto/data/json/timetable_json.dart';
import 'package:dotto/data/preference/timetable_preference.dart';
import 'package:dotto/domain/timetable.dart';
import 'package:dotto/domain/timetable_course.dart';
import 'package:dotto/domain/timetable_course_type.dart';
import 'package:dotto/domain/timetable_slot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>(
  (_) => TimetableRepositoryImpl(),
);

/// 時間割リポジトリのインターフェース
abstract class TimetableRepository {
  /// 2週間分の時間割を取得
  Future<List<Timetable>> getTimetables();

  /// ログイン時に個人時間割リストを読み込み・同期
  ///
  /// 戻り値の[TimetableSyncResult]を使用して、UI層で適切な処理を行う。
  /// - [TimetableSynced]: 同期完了、追加の処理は不要
  /// - [TimetableConflictDetected]: 競合が検出された。
  ///   元の処理ではAlertDialogを表示して、アカウント側とローカル側のどちらを
  ///   残すかユーザーに選択させていた。UI層で同様の処理を実装すること。
  Future<TimetableSyncResult> loadPersonalTimetableListOnLogin();

  /// 個人時間割リストを読み込み
  ///
  /// ログイン状態に応じてFirestoreまたはローカルからデータを取得し、
  /// 必要に応じて同期を行う。
  Future<List<int>> loadPersonalTimetableList();

  /// Firestoreからアカウント側のデータを採用して同期を完了
  Future<void> resolveConflictWithFirestore(TimetableSyncResult result);

  /// ローカル側のデータを採用して同期を完了
  Future<void> resolveConflictWithLocal(TimetableSyncResult result);

  /// 個人時間割に科目を追加
  Future<void> addLesson(int lessonId);

  /// 個人時間割から科目を削除
  Future<void> removeLesson(int lessonId);

  /// 授業名とlessonIdのマップを取得
  Future<Map<String, int>> getPersonalTimetableMapString();
}

/// 時間割同期結果
sealed class TimetableSyncResult {
  const TimetableSyncResult();
}

/// 同期完了（競合なし）
final class TimetableSynced extends TimetableSyncResult {
  const TimetableSynced(this.lessonIds);
  final List<int> lessonIds;
}

/// 競合が検出された
final class TimetableConflictDetected extends TimetableSyncResult {
  const TimetableConflictDetected({
    required this.firestoreList,
    required this.localList,
    required this.firestoreOnlyIds,
    required this.localOnlyIds,
  });

  /// Firestore側の時間割リスト
  final List<int> firestoreList;

  /// ローカル側の時間割リスト
  final List<int> localList;

  /// Firestoreにのみ存在するlessonId
  final List<int> firestoreOnlyIds;

  /// ローカルにのみ存在するlessonId
  final List<int> localOnlyIds;
}

final class TimetableRepositoryImpl implements TimetableRepository {
  /// 現在のユーザーを取得
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Future<List<Timetable>> getTimetables() async {
    try {
      final response = await _getTimetables();

      return response.entries.map((dateEntry) {
        final date = dateEntry.key;
        final periodMap = dateEntry.value;

        final courses = <TimetableCourse>[];
        for (final periodEntry in periodMap.entries) {
          courses.addAll(periodEntry.value);
        }

        return Timetable(date: date, courses: courses);
      }).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  @override
  Future<TimetableSyncResult> loadPersonalTimetableListOnLogin() async {
    final user = _currentUser;
    if (user == null) {
      final localList = await TimetablePreference.getPersonalTimetableList();
      return TimetableSynced(localList);
    }

    final firestoreData = await TimetableAPI.getUserTimetableData(user.uid);

    if (firestoreData == null) {
      // Firestoreにデータがない場合、ローカルデータをアップロード
      final localList = await TimetablePreference.getPersonalTimetableList();
      await TimetableAPI.saveUserTimetable(user.uid, localList);
      return TimetableSynced(localList);
    }

    final firestoreList = firestoreData.lessonIds;
    final localList = await TimetablePreference.getPersonalTimetableList();
    final localLastUpdated = await TimetablePreference.getLastUpdateTimestamp();

    // ローカルが空の場合、Firestoreのデータを採用
    if (localList.isEmpty) {
      await TimetablePreference.savePersonalTimetableList(firestoreList);
      return TimetableSynced(firestoreList);
    }

    // Firestoreが空の場合、ローカルデータをアップロード
    if (firestoreList.isEmpty) {
      await TimetableAPI.saveUserTimetable(user.uid, localList);
      return TimetableSynced(localList);
    }

    // タイムスタンプの差が5分（300000ms）以上の場合、競合チェック
    final firestoreLastUpdated =
        firestoreData.lastUpdated.millisecondsSinceEpoch;
    final diff = (localLastUpdated - firestoreLastUpdated).abs();

    if (diff > 300000) {
      final firestoreSet = firestoreList.toSet();
      final localSet = localList.toSet();

      // 同じIDセットかチェック
      if (!firestoreSet.containsAll(localSet) ||
          !localSet.containsAll(firestoreSet)) {
        // 競合検出
        // 元の処理ではここでAlertDialogを表示して、
        // 「アカウント側に多い科目」「ローカル側に多い科目」を表示し、
        // ユーザーに「アカウント方を残す」「ローカル方を残す」を選択させていた。
        // この選択UIはUI層で実装する必要がある。
        return TimetableConflictDetected(
          firestoreList: firestoreList,
          localList: localList,
          firestoreOnlyIds: firestoreSet.difference(localSet).toList(),
          localOnlyIds: localSet.difference(firestoreSet).toList(),
        );
      }
    }

    // 競合なし、Firestoreのデータを採用
    await TimetablePreference.savePersonalTimetableList(firestoreList);
    return TimetableSynced(firestoreList);
  }

  @override
  Future<List<int>> loadPersonalTimetableList() async {
    final user = _currentUser;

    if (user == null) {
      return TimetablePreference.getPersonalTimetableList();
    }

    final firestoreData = await TimetableAPI.getUserTimetableData(user.uid);

    if (firestoreData == null) {
      // Firestoreにデータがない場合、ローカルデータをアップロード
      final localList = await TimetablePreference.getPersonalTimetableList();
      await TimetableAPI.saveUserTimetable(user.uid, localList);
      await TimetablePreference.savePersonalTimetableList(localList);
      return localList;
    }

    final firestoreList = firestoreData.lessonIds;
    final localList = await TimetablePreference.getPersonalTimetableList();
    final localLastUpdated =
        await TimetablePreference.getLastUpdateTimestamp();
    final firestoreLastUpdated =
        firestoreData.lastUpdated.millisecondsSinceEpoch;
    final diff = localLastUpdated - firestoreLastUpdated;

    // ローカルが空の場合、Firestoreのデータを採用
    if (localList.isEmpty) {
      await TimetablePreference.savePersonalTimetableList(firestoreList);
      return firestoreList;
    }

    // Firestoreが空、またはローカルが10分以上新しい場合、ローカルデータをアップロード
    if (firestoreList.isEmpty || diff > 600000) {
      await TimetableAPI.saveUserTimetable(user.uid, localList);
      await TimetablePreference.savePersonalTimetableList(localList);
      return localList;
    }

    // Firestoreのデータを採用
    await TimetablePreference.savePersonalTimetableList(firestoreList);
    return firestoreList;
  }

  @override
  Future<void> resolveConflictWithFirestore(TimetableSyncResult result) async {
    if (result is! TimetableConflictDetected) {
      return;
    }
    await TimetablePreference.savePersonalTimetableList(result.firestoreList);
  }

  @override
  Future<void> resolveConflictWithLocal(TimetableSyncResult result) async {
    if (result is! TimetableConflictDetected) {
      return;
    }
    final user = _currentUser;
    if (user != null) {
      await TimetableAPI.saveUserTimetable(user.uid, result.localList);
    }
    await TimetablePreference.savePersonalTimetableList(result.localList);
  }

  @override
  Future<void> addLesson(int lessonId) async {
    final currentList = await TimetablePreference.getPersonalTimetableList();
    if (!currentList.contains(lessonId)) {
      currentList.add(lessonId);
      await TimetablePreference.savePersonalTimetableList(currentList);

      final user = _currentUser;
      if (user != null) {
        await TimetableAPI.addLessonToTimetable(user.uid, lessonId);
      }
    }
  }

  @override
  Future<void> removeLesson(int lessonId) async {
    final currentList = await TimetablePreference.getPersonalTimetableList();
    currentList.remove(lessonId);
    await TimetablePreference.savePersonalTimetableList(currentList);

    final user = _currentUser;
    if (user != null) {
      await TimetableAPI.removeLessonFromTimetable(user.uid, lessonId);
    }
  }

  @override
  Future<Map<String, int>> getPersonalTimetableMapString() async {
    final personalTimetableList =
        await TimetablePreference.getPersonalTimetableList();
    return CourseDB.getLessonIdMap(personalTimetableList);
  }

  /// 月曜から次の週の日曜までの日付を返す
  List<DateTime> _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 月曜
    final startDate = today.subtract(Duration(days: today.weekday - 1));

    final dates = <DateTime>[];
    for (var i = 0; i < 14; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    return dates;
  }

  // 施設予約のjsonファイルの中から取得している科目のみに絞り込み
  Future<List<OneWeekSchedule>> _filterTimetable() async {
    try {
      final jsonData = await TimetableJSON.fetchOneWeekSchedule();
      final personalTimetableList =
          await TimetablePreference.getPersonalTimetableList();
      final filteredData = <OneWeekSchedule>[];
      for (final lessonId in personalTimetableList) {
        for (final item in jsonData) {
          if (item.lessonId == lessonId.toString()) {
            filteredData.add(item);
          }
        }
      }
      return filteredData;
    } on Exception {
      return [];
    }
  }

  // 時間を入れたらその日の授業を返す
  Future<Map<int, List<TimetableCourse>>> _dailyLessonSchedule(
    DateTime selectTime,
  ) async {
    final periodData = _initializePeriodData();

    // 部屋IDから部屋名を取得するマップを作成
    final rooms = await RoomAPI.getRooms();
    final roomNameMap = <int, String>{};
    for (final floorRooms in rooms.values) {
      for (final entry in floorRooms.entries) {
        final roomId = int.tryParse(entry.key);
        if (roomId != null) {
          roomNameMap[roomId] = entry.value.header;
        }
      }
    }

    await _processNormalCourses(selectTime, periodData);

    final personalTimetableList =
        await TimetablePreference.getPersonalTimetableList();
    final lessonIdMap = await CourseDB.getLessonIdMap(personalTimetableList);

    await _processCancelledLectures(selectTime, periodData, lessonIdMap);
    await _processSupplementaryLectures(selectTime, periodData, lessonIdMap);

    return _convertPeriodDataToCourses(periodData, roomNameMap);
  }

  /// 時限ごとのデータマップを初期化
  Map<int, Map<int, TimetableCourse>> _initializePeriodData() {
    return {
      1: {},
      2: {},
      3: {},
      4: {},
      5: {},
      6: {},
    };
  }

  /// 通常授業の処理
  Future<void> _processNormalCourses(
    DateTime selectTime,
    Map<int, Map<int, TimetableCourse>> periodData,
  ) async {
    final lessonData = await _filterTimetable();

    for (final item in lessonData) {
      final lessonTime = DateTime.parse(item.start);

      if (selectTime.day == lessonTime.day) {
        final period = item.period;
        final lessonId = int.parse(item.lessonId);
        final resourceIds = _parseResourceId(item.resourceId);

        // 既に同じ授業が登録されている場合は教室情報を追加
        if (periodData[period]?.containsKey(lessonId) ?? false) {
          final existingCourse = periodData[period]![lessonId]!;
          final updatedResourceIds = [
            ...existingCourse.resourceIds,
            ...resourceIds,
          ];
          periodData[period]![lessonId] = existingCourse.copyWith(
            resourceIds: updatedResourceIds,
          );
          continue;
        }

        final courseData = await CourseDB.fetchDB(lessonId);
        periodData[period]![lessonId] = TimetableCourse(
          lessonId: lessonId,
          kakomonLessonId: courseData?.kakomonLessonId,
          slot: TimetableSlot.fromNumber(period),
          courseName: item.title,
          roomName: '',
          resourceIds: resourceIds,
        );
      }
    }
  }

  /// 休講情報の処理
  Future<void> _processCancelledLectures(
    DateTime selectTime,
    Map<int, Map<int, TimetableCourse>> periodData,
    Map<String, int> lessonIdMap,
  ) async {
    final cancelLectureData = await TimetableJSON.fetchCancelLectures();

    for (final cancelLecture in cancelLectureData) {
      if (!_isSameDate(cancelLecture.date, selectTime)) {
        continue;
      }

      final lessonName = cancelLecture.lessonName;
      if (!lessonIdMap.containsKey(lessonName)) {
        continue;
      }

      final lessonId = lessonIdMap[lessonName]!;
      final courseData = await CourseDB.fetchDB(lessonId);

      periodData[cancelLecture.period]![lessonId] = TimetableCourse(
        lessonId: lessonId,
        kakomonLessonId: courseData?.kakomonLessonId,
        slot: TimetableSlot.fromNumber(cancelLecture.period),
        courseName: lessonName,
        roomName: '',
        resourceIds: [],
        type: TimetableCourseType.cancelled,
      );
    }
  }

  /// 補講情報の処理
  Future<void> _processSupplementaryLectures(
    DateTime selectTime,
    Map<int, Map<int, TimetableCourse>> periodData,
    Map<String, int> lessonIdMap,
  ) async {
    final supLectureData = await TimetableJSON.fetchSupLectures();

    for (final supLecture in supLectureData) {
      if (!_isSameDate(supLecture.date, selectTime)) {
        continue;
      }

      final lessonName = supLecture.lessonName;
      if (!lessonIdMap.containsKey(lessonName)) {
        continue;
      }

      final lessonId = lessonIdMap[lessonName]!;
      final existingCourse = periodData[supLecture.period]?[lessonId];

      if (existingCourse != null) {
        periodData[supLecture.period]![lessonId] = existingCourse.copyWith(
          type: TimetableCourseType.madeUp,
        );
      }
    }
  }

  /// リソースIDをパース
  List<int> _parseResourceId(String resourceId) {
    try {
      return [int.parse(resourceId)];
    } on FormatException {
      return [];
    }
  }

  /// 日付が同じかどうかを判定
  bool _isSameDate(String dateString, DateTime target) {
    final date = DateTime.parse(dateString);
    return date.month == target.month && date.day == target.day;
  }

  /// periodDataをTimetableCourseに変換（部屋名を設定）
  Map<int, List<TimetableCourse>> _convertPeriodDataToCourses(
    Map<int, Map<int, TimetableCourse>> periodData,
    Map<int, String> roomNameMap,
  ) {
    final returnData = <int, List<TimetableCourse>>{};
    periodData.forEach((period, courseMap) {
      final courses = courseMap.values.map((course) {
        // 部屋名を取得（複数ある場合はカンマ区切りで結合）
        final roomNames = course.resourceIds
            .map((id) => roomNameMap[id] ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        final roomName = roomNames.isNotEmpty ? roomNames.join(', ') : '';

        return course.copyWith(roomName: roomName);
      }).toList();
      returnData[period] = courses;
    });
    return returnData;
  }

  Future<Map<DateTime, Map<int, List<TimetableCourse>>>>
  _getTimetables() async {
    final dates = _getDateRange();
    final twoWeekLessonSchedule = <DateTime, Map<int, List<TimetableCourse>>>{};
    try {
      for (final date in dates) {
        twoWeekLessonSchedule[date] = await _dailyLessonSchedule(date);
      }
      return twoWeekLessonSchedule;
    } on Exception {
      return twoWeekLessonSchedule;
    }
  }
}
