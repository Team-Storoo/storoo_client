import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// 섹션 헤더 (여러 화면에서 공용으로 사용하는 소제목 위젯)
///
/// [title]      표시할 제목 텍스트
/// [topPadding] 상단 여백 (기본값 0)
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.topPadding = 0});

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 10),
      child: Text(title, style: AppTextStyles.subtitle),
    );
  }
}
