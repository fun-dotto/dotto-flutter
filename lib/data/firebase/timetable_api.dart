import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestoreのユーザー時間割データ
final class UserTimetableData {
  UserTimetableData({
    required this.lessonIds,
    required this.lastUpdated,
  });

  final List<int> lessonIds;
  final DateTime lastUpdated;
}

/// 時間割に関するFirebase APIクラス
final class TimetableAPI {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'user_taking_course';
  static const String _yearKey = '2025';

  /// Firestoreからユーザーの時間割データを取得
  /// ドキュメントが存在しない場合はnullを返す
  static Future<UserTimetableData?> getUserTimetableData(String uid) async {
    final doc = _db.collection(_collection).doc(uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final timestamp = data['last_updated'] as Timestamp?;
    final lessonIds = data[_yearKey] as List<dynamic>?;

    return UserTimetableData(
      lessonIds: lessonIds != null ? List<int>.from(lessonIds) : [],
      lastUpdated:
          timestamp?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Firestoreにユーザーの時間割データを保存（上書き）
  static Future<void> saveUserTimetable(
    String uid,
    List<int> lessonIds,
  ) async {
    final doc = _db.collection(_collection).doc(uid);
    await doc.set({
      _yearKey: lessonIds,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  /// Firestoreに科目を追加
  static Future<void> addLessonToTimetable(String uid, int lessonId) async {
    final doc = _db.collection(_collection).doc(uid);
    await doc.update({
      _yearKey: FieldValue.arrayUnion([lessonId]),
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  /// Firestoreから科目を削除
  static Future<void> removeLessonFromTimetable(
    String uid,
    int lessonId,
  ) async {
    final doc = _db.collection(_collection).doc(uid);
    await doc.update({
      _yearKey: FieldValue.arrayRemove([lessonId]),
      'last_updated': FieldValue.serverTimestamp(),
    });
  }
}
