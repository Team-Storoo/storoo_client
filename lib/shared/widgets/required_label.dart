import 'package:flutter/material.dart';

/// 필수 입력란 레이블 — 텍스트 옆에 빨간 * 표시
///
/// 사용 예:
/// ```dart
/// const RequiredLabel('링크')
/// const RequiredLabel('제목')
/// ```
class RequiredLabel extends StatelessWidget {
  const RequiredLabel(this.text, {super.key});

  final String text;

  static const _labelStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF888888),
  );

  static const _asteriskStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE53935),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: _labelStyle),
        const SizedBox(width: 3),
        const Text('*', style: _asteriskStyle),
      ],
    );
  }
}
