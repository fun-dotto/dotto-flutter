import 'dart:async';

import 'package:dotto/app.dart';
import 'package:dotto/firebase_options.dart';
import 'package:dotto/helper/firebase_storage_repository.dart';
import 'package:dotto/helper/location_helper.dart';
import 'package:dotto/helper/logger.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseの初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Crashlyticsの初期化
  FlutterError.onError = (errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
    );
    return true;
  };

  // Firebase App Checkの初期化
  await FirebaseAppCheck.instance.activate(
    providerApple: kReleaseMode
        ? const AppleAppAttestProvider()
        : const AppleDebugProvider(),
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
  );

  // Firebase Realtime Databaseのパーシステンスを有効化
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // 画面の向きを固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ローカルタイムゾーンの設定
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

  // Firebase Messagingの通知許可をリクエスト
  await FirebaseMessaging.instance.requestPermission(
    provisional: true,
  );

  // Firebase Messagingのバックグラウンドハンドラーを設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 位置情報の許可をリクエスト
  await LocationHelperImpl().requestLocationPermission();

  // ファイルをダウンロード
  try {
    await Future(() {
      // Firebaseからファイルをダウンロード
      <String>[
        'funch/menu.json',
        'home/cancel_lecture.json',
        'home/sup_lecture.json',
        'map/oneweek_schedule.json',
      ].forEach(FirebaseStorageRepository().download);
    });
  } on Exception catch (e) {
    debugPrint(e.toString());
  }

  await LoggerImpl().logAppOpen();

  // アプリの起動
  runApp(const ProviderScope(child: MyApp()));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
