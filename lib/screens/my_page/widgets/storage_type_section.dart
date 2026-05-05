import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/db_service.dart';

class StorageTypeSection extends StatefulWidget {
  const StorageTypeSection({super.key});

  @override
  State<StorageTypeSection> createState() => _StorageTypeSectionState();
}

class _StorageTypeSectionState extends State<StorageTypeSection> {
  int _linkCount = 0;
  int _imageCount = 0;
  int _memoCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final counts = await DBService.getContentCountsByType();
    if (mounted) {
      setState(() {
        _linkCount = counts['link'] ?? 0;
        _imageCount = counts['image'] ?? 0;
        _memoCount = counts['memo'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _linkCount + _imageCount + _memoCount;

    double linkRatio = 0;
    double imageRatio = 0;
    double memoRatio = 0;
    String linkPercent = '0%';
    String imagePercent = '0%';
    String memoPercent = '0%';

    if (total > 0) {
      linkRatio = _linkCount / total;
      imageRatio = _imageCount / total;
      memoRatio = _memoCount / total;
      linkPercent = '${(linkRatio * 100).round()}%';
      imagePercent = '${(imageRatio * 100).round()}%';
      memoPercent = '${(memoRatio * 100).round()}%';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('저장 유형 분포', style: AppTextStyles.subtitle),
              const Spacer(),
              Text(
                '총 $total개',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StorageTypeRow(
            icon: Icons.link,
            label: '링크',
            ratio: linkRatio,
            percent: linkPercent,
          ),
          const SizedBox(height: 12),
          _StorageTypeRow(
            icon: Icons.image_outlined,
            label: '이미지',
            ratio: imageRatio,
            percent: imagePercent,
          ),
          const SizedBox(height: 12),
          _StorageTypeRow(
            icon: Icons.note_outlined,
            label: '메모',
            ratio: memoRatio,
            percent: memoPercent,
          ),
        ],
      ),
    );
  }
}

class _StorageTypeRow extends StatelessWidget {
  const _StorageTypeRow({
    required this.icon,
    required this.label,
    required this.ratio,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final double ratio;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
