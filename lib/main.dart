import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pay_n_say/core/router/app_router.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/english_learning/presentation/providers/english_learning_provider.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 릴리즈 모드 글로벌 에러 핸들러
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    try {
      await Hive.initFlutter();
    } catch (e) {
      debugPrint('Hive 초기화 실패: $e');
    }

    Box box;
    Box learningBox;

    try {
      box = await Hive.openBox('transactions');
    } catch (e) {
      debugPrint('transactions 박스 열기 실패: $e');
      await Hive.deleteBoxFromDisk('transactions');
      box = await Hive.openBox('transactions');
    }

    try {
      learningBox = await Hive.openBox('learning_progress');
    } catch (e) {
      debugPrint('learning_progress 박스 열기 실패: $e');
      await Hive.deleteBoxFromDisk('learning_progress');
      learningBox = await Hive.openBox('learning_progress');
    }

    runApp(
      ProviderScope(
        overrides: [
          hiveBoxProvider.overrideWithValue(box),
          learningBoxProvider.overrideWithValue(learningBox),
        ],
        child: const PayNSayApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class PayNSayApp extends StatelessWidget {
  const PayNSayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pay N Say',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
