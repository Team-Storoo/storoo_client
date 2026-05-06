import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 상세 화면의 태그 칩 목록 또는 빈 안내 문구
class DetailTagChips extends StatelessWidget {
  final List<String> tags;
  const DetailTagChips({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Text(
        '저장된 태그가 없습니다.',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _TagChip(tag: tag)).toList(),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
