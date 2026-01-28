import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotto/controller/config_controller.dart';
import 'package:dotto/controller/user_controller.dart';
import 'package:dotto/domain/tab_item.dart';
import 'package:dotto/domain/user_preference_keys.dart';
import 'package:dotto/feature/root/root_viewmodel_state.dart';
import 'package:dotto/feature/setting/controller/settings_controller.dart';
import 'package:dotto/helper/logger.dart';
import 'package:dotto/helper/notification_helper.dart';
import 'package:dotto/helper/remote_config_helper.dart';
import 'package:dotto/helper/user_preference_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'root_viewmodel.g.dart';

@riverpod
class RootViewModel extends _$RootViewModel {
  @override
  Future<RootViewModelState> build() async {
    // Setup Remote Config
    await ref.read(remoteConfigHelperProvider).setup();
    // Setup Notification
    await ref.read(notificationHelperProvider).setupInteractedMessage();
    // Setup Logger
    await ref.read(loggerProvider).setup();
    // Setup Universal Links
    AppLinks().uriLinkStream
        .listen((event) {
          if (event.path != '/config/' || !event.hasQuery) return;
          final query = event.queryParameters;
          if (!query.containsKey('userkey')) return;
          final userKey = query['userkey'];
          if (userKey == null) return;
          final userKeyPattern = RegExp(r'^[a-zA-Z0-9]{16}$');
          if (userKey.isEmpty ||
              (userKey.length == 16 && userKeyPattern.hasMatch(userKey))) {
            UserPreferenceRepository.setString(
              UserPreferenceKeys.userKey,
              userKey,
            );
            ref.invalidate(settingsUserKeyProvider);
          }
        })
        .onError((Object error, StackTrace stackTrace) {
          debugPrint(error.toString());
        });
    // FCM Token
    await _saveFCMToken();

    final hasShownAppTutorial =
        await UserPreferenceRepository.getBool(
          UserPreferenceKeys.isAppTutorialComplete,
        ) ??
        false;

    final config = ref.read(configProvider);

    return RootViewModelState(
      selectedTab: TabItem.home,
      hasShownAppTutorial: hasShownAppTutorial,
      hasShownUpdateAlert: false,
      isValidAppVersion: config.isValidAppVersion,
      isLatestAppVersion: config.isLatestAppVersion,
      appStorePageUrl: config.appStorePageUrl,
      navigatorStates: {
        for (final tabItem in TabItem.values)
          tabItem: GlobalKey<NavigatorState>(),
      },
    );
  }

  void onTabItemTapped(int index) {
    final selectedTab = TabItem.values.elementAtOrNull(index);
    if (selectedTab == null) {
      return;
    }
    if (state.value?.selectedTab != selectedTab) {
      state = AsyncValue.data(state.value!.copyWith(selectedTab: selectedTab));
      return;
    }
    // 同じタブを押すとルートまでPop
    final navigatorKey = state.value?.navigatorStates[selectedTab];
    if (navigatorKey == null) {
      return;
    }
    final currentState = navigatorKey.currentState;
    if (currentState == null) {
      return;
    }
    currentState.popUntil((Route<dynamic> route) => route.isFirst);

    ref.read(loggerProvider).logChangedTab(tabItem: selectedTab);
  }

  void onGoToSettingButtonTapped() {
    state = AsyncValue.data(
      state.value!.copyWith(selectedTab: TabItem.setting),
    );
  }

  void onAppTutorialDismissed() {
    state = AsyncValue.data(state.value!.copyWith(hasShownAppTutorial: true));
    UserPreferenceRepository.setBool(
      UserPreferenceKeys.isAppTutorialComplete,
      value: true,
    );
  }

  Future<void> _saveFCMToken() async {
    final didSave =
        await UserPreferenceRepository.getBool(
          UserPreferenceKeys.didSaveFCMToken,
        ) ??
        false;
    if (didSave) {
      return;
    }
    final user = ref.read(userProvider);

    // APNsトークンはiOSシミュレータでは取得できないことがある
    // 実機でも通知許可がない場合などは失敗する可能性がある
    String? apnsToken;
    try {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('APNs Token取得エラー: $e');
      }
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'APNs Token取得に失敗',
        fatal: false,
      );
    }
    if (kDebugMode) {
      debugPrint('APNs Token: ${_maskToken(apnsToken)}');
    }

    // FCMトークンの取得もシミュレータや通知許可がない場合は失敗する可能性がある
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM Token取得エラー: $e');
      }
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'FCM Token取得に失敗',
        fatal: false,
      );
    }
    if (kDebugMode) {
      debugPrint('FCM Token: ${_maskToken(fcmToken)}');
    }

    if (fcmToken != null && user != null) {
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
  }

  void onUpdateAlertShown() {
    state = AsyncValue.data(state.value!.copyWith(hasShownUpdateAlert: true));
  }

  /// トークンをマスキングして末尾8文字のみ表示する
  String _maskToken(String? token) {
    if (token == null) return 'null';
    if (token.length <= 8) return '***';
    return '***${token.substring(token.length - 8)}';
  }
}
