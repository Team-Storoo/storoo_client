import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ──────────────────────────────────────────────────────────────────────
/// ★★★ 커스텀 폰트를 적용하는 방법 (직접 해야 하는 작업) ★★★
///
/// [STEP 1] 폰트 파일 다운로드
///   • Google Fonts 추천: https://fonts.google.com/
///   • 국내 무료 폰트 추천: 프리텐다드(Pretendard)
///     → https://github.com/orioncactus/pretendard/releases
///   • .ttf 또는 .otf 파일을 다운로드
///
/// [STEP 2] 프로젝트에 폰트 파일 추가
///   • 프로젝트 루트(pubspec.yaml과 같은 위치)에
///     assets/fonts/ 폴더를 새로 만들고 파일을 넣어줘
///   • 예시 경로:
///       assets/fonts/Pretendard-Regular.ttf
///       assets/fonts/Pretendard-Medium.ttf
///       assets/fonts/Pretendard-Bold.ttf
///
/// [STEP 3] pubspec.yaml에 폰트 등록
///   flutter: 항목 아래에 아래 내용을 추가해줘
///   (들여쓰기가 정확해야 해 - 공백 2칸씩 사용)
///
///   flutter:
///     fonts:
///       - family: Pretendard         ← 폰트 이름 (아무 이름이나 가능)
///         fonts:
///           - asset: assets/fonts/Pretendard-Regular.ttf
///           - asset: assets/fonts/Pretendard-Medium.ttf
///             weight: 500
///           - asset: assets/fonts/Pretendard-Bold.ttf
///             weight: 700
///
/// [STEP 4] 이 파일에서 _fontFamily 값을 폰트 이름으로 변경
///   • pubspec.yaml에서 family: 뒤에 쓴 이름과 정확히 일치해야 함
///   • 예) const String _fontFamily = 'Pretendard';
///
/// ※ 폰트 파일을 넣기 전까지는 기기 기본 폰트가 적용됩니다. 오류는 없어요.
/// ──────────────────────────────────────────────────────────────────────

/// TODO: 폰트 파일 추가 후 아래 이름을 pubspec.yaml의 family 이름과 일치시켜줘
const String _fontFamily = 'Pretendard';

/// 앱 전체에서 사용하는 텍스트 스타일 모음
///
/// 새로운 스타일이 필요하면 여기에만 추가하면 됩니다.
abstract final class AppTextStyles {
  // ── 제목 계열 ────────────────────────────────────────────

  /// 큰 제목 - 앱바 타이틀, 섹션 헤더 등
  static const TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// 중간 제목 - 카드 제목, 다이얼로그 타이틀 등
  static const TextStyle headline2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// 소제목 - 리스트 아이템 제목 등
  static const TextStyle subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ── 본문 계열 ────────────────────────────────────────────

  /// 기본 본문 텍스트
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5, // 줄 간격
  );

  /// 보조 설명 텍스트 (힌트, 날짜, 카테고리 등)
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── 버튼 계열 ────────────────────────────────────────────

  /// 버튼 라벨 텍스트
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ── 내비게이션 바 ─────────────────────────────────────────

  /// 하단 탭 바 라벨
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
