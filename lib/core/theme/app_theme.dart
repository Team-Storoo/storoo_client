import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// ──────────────────────────────────────────────────────────
/// 앱 전체 테마 정의
///
/// main.dart의 MaterialApp(theme: AppTheme.light) 에 전달됩니다.
/// 테마를 조정하려면 이 파일만 수정하면 됩니다.
/// ──────────────────────────────────────────────────────────
abstract final class AppTheme {
  /// 라이트 테마
  static ThemeData get light => ThemeData(
    useMaterial3: true,

    // ── 폰트 기본값 ──────────────────────────────────────
    // app_text_styles.dart의 _fontFamily와 일치해야 합니다
    fontFamily: 'Pretendard',

    // ── 색상 시스템 ──────────────────────────────────────
    // primary 색을 기반으로 Flutter가 자동으로 연관 색상을 생성합니다
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    ),

    // ── 전체 배경 ─────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,

    // ── 앱바 ─────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0, // 그림자 없음 (플랫 디자인)
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline1,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    // ── 하단 내비게이션 바 ────────────────────────────────
    // 선택 시 navSelected(보라색), 비선택 시 navUnselected(회색)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.navSelected, // 선택된 아이콘 색
      unselectedItemColor: AppColors.navUnselected, // 비선택 아이콘 색
      selectedLabelStyle: AppTextStyles.navLabel,
      unselectedLabelStyle: AppTextStyles.navLabel,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // ── 텍스트 테마 ──────────────────────────────────────
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.headline1,
      headlineMedium: AppTextStyles.headline2,
      titleMedium: AppTextStyles.subtitle,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
    ),

    // ── 카드 ─────────────────────────────────────────────
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── 구분선 ────────────────────────────────────────────
    dividerColor: AppColors.divider,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
  );
}
