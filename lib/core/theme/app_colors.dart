import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────────────
/// 앱 전체에서 사용하는 색상 상수 모음
///
/// 색상을 바꾸고 싶으면 이 파일만 수정하면 됩니다.
/// 절대로 화면 파일에 Color(0xFF...)를 직접 쓰지 마세요.
/// ──────────────────────────────────────────────────────────
abstract final class AppColors {
  // ── 브랜드 색상 ─────────────────────────────────────────

  /// 기본 브랜드 색상 (보라색 #9138FF)
  static const Color primary = Color(0xFF9138FF);

  /// 기본 색상의 연한 버전 - 배경, 뱃지 등에 활용
  static const Color primaryLight = Color(0xFFEDE0FF);

  // ── 배경 / 표면 ─────────────────────────────────────────

  /// 앱 전체 배경색
  static const Color background = Colors.white;

  /// 카드, 시트, 앱바 등 표면 색상
  static const Color surface = Color(0xFFFFFFFF);

  // ── 텍스트 ──────────────────────────────────────────────

  /// 제목, 본문 등 기본 텍스트 색상
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// 힌트, 설명 등 보조 텍스트 색상
  static const Color textSecondary = Color(0xFF6B6B6B);

  // ── 내비게이션 바 ────────────────────────────────────────

  /// 선택된 아이콘 / 탭 색상
  static const Color navSelected = primary;

  /// 비선택 아이콘 색상
  static const Color navUnselected = Color(0xFFAAAAAA);

  // ── 기타 ────────────────────────────────────────────────

  /// 구분선 색상
  static const Color divider = Color(0xFFE0E0E0);

  /// 에러 색상
  static const Color error = Color(0xFFE53935);
}
