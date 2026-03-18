import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

import 'helpers/fake_box.dart';

void main() {
  testWidgets('앱 테마 및 기본 위젯 스모크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveBoxProvider.overrideWithValue(FakeBox()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(child: Text('Pay N Say')),
          ),
        ),
      ),
    );

    expect(find.text('Pay N Say'), findsOneWidget);
  });
}
