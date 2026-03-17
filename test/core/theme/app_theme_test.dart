import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('accent 색상', () {
      expect(AppColors.accent, const Color(0xFF6C63FF));
    });

    test('income 색상', () {
      expect(AppColors.income, const Color(0xFF00C896));
    });

    test('expense 색상', () {
      expect(AppColors.expense, const Color(0xFFFF4D6D));
    });

    test('background 색상', () {
      expect(AppColors.background, const Color(0xFFF7F8FC));
    });
  });

  group('AppTheme', () {
    test('light 테마 생성', () {
      final theme = AppTheme.light;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('scaffoldBackgroundColor가 AppColors.background', () {
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
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
      expect(AppTheme.headerGradient.colors,
          contains(AppColors.gradientStart));
    });

    test('appBarTheme 투명 배경', () {
      expect(
        AppTheme.light.appBarTheme.backgroundColor,
        Colors.transparent,
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
