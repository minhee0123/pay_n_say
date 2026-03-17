import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';
import 'package:pay_n_say/main.dart';

void main() {
  testWidgets('앱 정상 실행 스모크 테스트', (WidgetTester tester) async {
    final tempDir = await Directory.systemTemp.createTemp('hive_widget_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox('widget_test_${DateTime.now().millisecondsSinceEpoch}');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveBoxProvider.overrideWithValue(box),
        ],
        child: const PayNSayApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 메인 화면(가계부) 로드 확인
    expect(find.textContaining('월'), findsWidgets);

    await box.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });
}
