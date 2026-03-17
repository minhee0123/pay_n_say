import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pay_n_say/core/router/app_router.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox('transactions');

  runApp(
    ProviderScope(
      overrides: [
        hiveBoxProvider.overrideWithValue(box),
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
