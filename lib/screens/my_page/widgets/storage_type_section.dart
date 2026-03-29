import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 저장 유형 분포 섹션
/// 링크 / 이미지 / 메모 각각 아이콘 + 프로그레스 바 + 퍼센트 표시
/// TODO: DB 연결 후 실제 비율 데이터 연결
class StorageTypeSection extends StatelessWidget {
  const StorageTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('저장 유형 분포', style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          _StorageTypeRow(
            icon: Icons.link,
            label: '링크',
            ratio: 0.55, // TODO: 실제 값 연결
            percent: '55%',
          ),
          const SizedBox(height: 12),
          _StorageTypeRow(
            icon: Icons.image_outlined,
            label: '이미지',
            ratio: 0.33,
            percent: '33%',
          ),
          const SizedBox(height: 12),
          _StorageTypeRow(
            icon: Icons.note_outlined,
            label: '메모',
            ratio: 0.12,
            percent: '12%',
          ),
        ],
      ),
    );
  }
}

/// 저장 유형 단일 행 (StorageTypeSection 전용)
class _StorageTypeRow extends StatelessWidget {
  const _StorageTypeRow({
    required this.icon,
    required this.label,
    required this.ratio,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final double ratio; // 0.0 ~ 1.0
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 아이콘 + 라벨
        SizedBox(
          width: 70,
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.body),
            ],
          ),
        ),
        // 프로그레스 바
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 퍼센트 텍스트
        SizedBox(
          width: 36,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
