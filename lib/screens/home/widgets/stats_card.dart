import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 홈 상단 통계 카드
/// "저장된 내 자료는 총 N 개" 표시
/// TODO: DB 연결 후 count 파라미터로 실제 개수 전달
class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '저장된 내 자료는 총',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '-', // TODO: DB 연결 후 실제 개수로 교체
                style: AppTextStyles.headline1.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(' 개', style: AppTextStyles.body),
            ],
          ),
        ],
      ),
    );
  }
}
