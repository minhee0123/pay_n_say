import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pay_n_say/main.dart';

void main() {
  testWidgets('앱 정상 실행 스모크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PayNSayApp()));
    await tester.pumpAndSettle();

    // 메인 화면(가계부) 로드 확인
    expect(find.textContaining('월'), findsWidgets);
  });
}
