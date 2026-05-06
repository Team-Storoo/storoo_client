import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 상세 화면의 섹션 레이블 (제목 / 메모 / 태그 / 저장 폴더)
class DetailSectionLabel extends StatelessWidget {
  final String label;
  const DetailSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
