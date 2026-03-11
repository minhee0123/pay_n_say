import 'package:go_router/go_router.dart';
import 'package:pay_n_say/features/ledger/presentation/pages/day_detail_page.dart';
import 'package:pay_n_say/features/ledger/presentation/pages/ledger_main_page.dart';
import 'package:pay_n_say/features/ledger/presentation/pages/manual_entry_page.dart';
import 'package:pay_n_say/features/ocr/presentation/pages/ocr_scan_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LedgerMainPage(),
    ),
    GoRoute(
      path: '/ocr',
      builder: (context, state) => const OcrScanPage(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) {
        final initialDate = state.extra as DateTime?;
        return ManualEntryPage(initialDate: initialDate);
      },
    ),
    GoRoute(
      path: '/day/:date',
      builder: (context, state) {
        final dateStr = state.pathParameters['date']!;
        final date = DateTime.parse(dateStr);
        return DayDetailPage(date: date);
      },
    ),
  ],
);
