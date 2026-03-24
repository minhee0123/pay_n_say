import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('accent 색상', () {
      expect(AppColors.accent, const Color(0xFF6C63FF));
    });

    test('income 색상', () {
      expect(AppColors.income, const Color(0xFF34C759));
    });

    test('expense 색상', () {
      expect(AppColors.expense, const Color(0xFFFF3B30));
    });

    test('background는 흰색', () {
      expect(AppColors.background, Colors.white);
    });
  });

  group('AppTheme', () {
    test('light 테마 생성', () {
      final theme = AppTheme.light;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('scaffoldBackgroundColor가 흰색', () {
      expect(AppTheme.light.scaffoldBackgroundColor, Colors.white);
    });

    test('primary 색상이 accent', () {
      expect(AppTheme.light.colorScheme.primary, AppColors.accent);
    });

    test('cardShadow 존재', () {
      expect(AppTheme.cardShadow, isNotEmpty);
      expect(AppTheme.cardShadow.first, isA<BoxShadow>());
    });

    test('headerGradient 존재', () {
      expect(AppTheme.headerGradient, isA<LinearGradient>());
    });

    test('appBarTheme 흰색 배경', () {
      expect(
        AppTheme.light.appBarTheme.backgroundColor,
        Colors.white,
      );
    });

    test('FAB 테마 accent 색상', () {
      expect(
        AppTheme.light.floatingActionButtonTheme.backgroundColor,
        AppColors.accent,
      );
    });
  });
}
