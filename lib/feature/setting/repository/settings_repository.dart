import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotto/data/db/course_db.dart';
import 'package:dotto/domain/user_preference_keys.dart';
import 'package:dotto/feature/setting/controller/settings_controller.dart';
import 'package:dotto/helper/firebase_auth_repository.dart';
import 'package:dotto/helper/user_preference_repository.dart';
import 'package:dotto/repository/timetable_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SettingsRepository {
  factory SettingsRepository() {
    return _instance;
  }
  SettingsRepository._internal();
  static final SettingsRepository _instance = SettingsRepository._internal();

  Future<void> setUserKey(String userKey, WidgetRef ref) async {
    final userKeyPattern = RegExp(r'^[a-zA-Z0-9]{16}$');
    if (userKey.length == 16 && userKeyPattern.hasMatch(userKey)) {
      await UserPreferenceRepository.setString(
        UserPreferenceKeys.userKey,
        userKey,
      );
      ref.invalidate(settingsUserKeyProvider);
      return;
    }
    if (userKey.isEmpty) {
      await UserPreferenceRepository.setString(
        UserPreferenceKeys.userKey,
        userKey,
      );
      ref.invalidate(settingsUserKeyProvider);
    }
  }

  Future<void> saveFCMToken(User user) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      return;
    }
    final db = FirebaseFirestore.instance;
    final tokenRef = db.collection('fcm_token');
    final tokenQuery = tokenRef
        .where('uid', isEqualTo: user.uid)
        .where('token', isEqualTo: fcmToken);
    final tokenQuerySnapshot = await tokenQuery.get();
    final tokenDocs = tokenQuerySnapshot.docs;
    if (tokenDocs.isEmpty) {
      await tokenRef.add({
        'uid': user.uid,
        'token': fcmToken,
        'last_updated': Timestamp.now(),
      });
    }
    await UserPreferenceRepository.setBool(
      UserPreferenceKeys.didSaveFCMToken,
      value: true,
    );
  }

  Future<void> onLogin(
    BuildContext context,
    WidgetRef ref,
    void Function(User?) callback,
  ) async {
    final user = await FirebaseAuthRepository().signIn();
    if (user != null) {
      callback(user);
      await saveFCMToken(user);
      if (context.mounted) {
        final repository = ref.read(timetableRepositoryProvider);
        final result = await repository.loadPersonalTimetableListOnLogin();
        if (result is TimetableConflictDetected && context.mounted) {
          await _showConflictDialog(context, ref, repository, result);
        }
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ログインできませんでした。')));
    }
  }

  Future<void> _showConflictDialog(
    BuildContext context,
    WidgetRef ref,
    TimetableRepository repository,
    TimetableConflictDetected conflict,
  ) async {
    final firestoreLessonNameList = await CourseDB.getLessonNameList(
      conflict.firestoreOnlyIds,
    );
    final localLessonNameList = await CourseDB.getLessonNameList(
      conflict.localOnlyIds,
    );

    if (!context.mounted) return;

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('データの同期'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text(
                  'クラウドに保存された時間割と端末に保存された時間割が異なっています。どちらを残しますか？',
                ),
                const Text('-- クラウドにのみ存在する科目 --'),
                ...firestoreLessonNameList.map(Text.new),
                const SizedBox(height: 10),
                const Text('-- 端末にのみ存在する科目 --'),
                ...localLessonNameList.map(Text.new),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await repository.resolveConflictWithFirestore(conflict);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('クラウドに保存された時間割を残す'),
            ),
            TextButton(
              onPressed: () async {
                await repository.resolveConflictWithLocal(conflict);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('端末に保存された時間割を残す'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onLogout(void Function() logout) async {
    await FirebaseAuthRepository().signOut();
    logout();
  }
}
