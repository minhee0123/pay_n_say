import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pay_n_say/core/router/app_router.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PayNSayApp(),
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
