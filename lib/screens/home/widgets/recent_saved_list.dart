import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 홈 화면 최근 저장 가로 스크롤 목록
/// TODO: DB 연결 후 실제 Content 목록 데이터 연결
class RecentSavedList extends StatelessWidget {
  const RecentSavedList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3, // TODO: 실제 데이터 개수로 교체
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: Text(
              '최근 항목 ${index + 1}\n(추후 구현)',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          );
        },
      ),
    );
  }
}
