import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 버그 제보하기 내용 위젯 (준비 중)
class BugReportContent extends StatelessWidget {
  const BugReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction, size: 52, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            '버그 제보 기능을 준비 중이에요 🛠️',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '불편하신 점은 서비스 문의로 알려주세요',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
