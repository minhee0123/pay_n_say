import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pay_n_say/core/router/app_router.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/english_learning/presentation/providers/english_learning_provider.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox('transactions');
  final learningBox = await Hive.openBox('learning_progress');

  runApp(
    ProviderScope(
      overrides: [
        hiveBoxProvider.overrideWithValue(box),
        learningBoxProvider.overrideWithValue(learningBox),
      ],
      child: const PayNSayApp(),
    ),
  );
}

class PayNSayApp extends StatelessWidget {
  const PayNSayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pay N Say',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
