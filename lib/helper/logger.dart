import 'package:dotto/domain/tab_item.dart';
import 'package:dotto/domain/timetable_period_style.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loggerProvider = Provider<Logger>((ref) => LoggerImpl());

abstract class Logger {
  Future<void> setup();
  Future<void> logAppOpen();
  Future<void> logLogin();
  Future<void> logChangedTab({required TabItem tabItem});
  Future<void> logBuiltTimetableSetting({
    required TimetablePeriodStyle timetablePeriodStyle,
  });
  Future<void> logSetTimetableSetting({
    required TimetablePeriodStyle timetablePeriodStyle,
  });
  Future<void> logSetHopeUserKey({required String userKey});
  Future<void> logSetAssignmentStatus({
    required String assignmentId,
    bool? isDone,
    bool? isHidden,
    bool? isAlertScheduled,
  });
}

final class LoggerImpl implements Logger {
  factory LoggerImpl() {
    return _instance;
  }
  LoggerImpl._internal();
  static final LoggerImpl _instance = LoggerImpl._internal();

  @override
  Future<void> setup() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseAnalytics.instance.setUserId(id: userId);
    }
    debugPrint('[Logger] setup');
    debugPrint('User ID: $userId');
  }

  @override
  Future<void> logAppOpen() async {
    await FirebaseAnalytics.instance.logAppOpen();
    debugPrint('[Logger] app_open');
  }

  @override
  Future<void> logLogin() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await FirebaseAnalytics.instance.setUserId(id: userId);
    await FirebaseAnalytics.instance.logLogin();
    debugPrint('[Logger] login');
    debugPrint('User ID: $userId');
  }

  @override
  Future<void> logChangedTab({required TabItem tabItem}) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: tabItem.key);
  }

  @override
  Future<void> logBuiltTimetableSetting({
    required TimetablePeriodStyle timetablePeriodStyle,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'built_timetable_setting',
      parameters: {'timetable_period_style': timetablePeriodStyle.key},
    );
    debugPrint('[Logger] built_timetable_setting');
    debugPrint('timetable_period_style: ${timetablePeriodStyle.key}');
  }

  @override
  Future<void> logSetTimetableSetting({
    required TimetablePeriodStyle timetablePeriodStyle,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'set_timetable_setting',
      parameters: {'timetable_period_style': timetablePeriodStyle.key},
    );
    debugPrint('[Logger] set_timetable_setting');
    debugPrint('timetable_period_style: ${timetablePeriodStyle.key}');
  }

  @override
  Future<void> logSetHopeUserKey({required String userKey}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'set_hope_user_key',
      parameters: {'user_key': userKey},
    );
    debugPrint('[Logger] set_hope_user_key');
    debugPrint('user_key: $userKey');
  }

  @override
  Future<void> logSetAssignmentStatus({
    required String assignmentId,
    bool? isDone,
    bool? isHidden,
    bool? isAlertScheduled,
  }) async {
    final parameters = <String, Object>{'assignment_id': assignmentId};
    if (isDone != null) {
      parameters['is_done'] = isDone.toString();
    }
    if (isHidden != null) {
      parameters['is_hidden'] = isHidden.toString();
    }
    if (isAlertScheduled != null) {
      parameters['is_alert_scheduled'] = isAlertScheduled.toString();
    }
    await FirebaseAnalytics.instance.logEvent(
      name: 'set_assignment_status',
      parameters: parameters,
    );
    debugPrint('[Logger] set_assignment_status');
    debugPrint('assignment_id: $assignmentId');
    debugPrint('is_done: $isDone');
    debugPrint('is_hidden: $isHidden');
  }
}
