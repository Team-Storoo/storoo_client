import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 테마 설정 내용 위젯 (준비 중)
class ThemeContent extends StatelessWidget {
  const ThemeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.palette_outlined, size: 52, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            '테마 설정 기능을 준비 중이에요 🎨',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 라이트 / 다크 모드를 선택할 수 있어요',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
