import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 상세 화면의 읽기 전용 필드 박스 (흰 배경 + 얇은 테두리)
class DetailReadField extends StatelessWidget {
  final String text;
  final String? placeholder;
  final int maxLines;

  const DetailReadField({
    super.key,
    required this.text,
    this.placeholder,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.isEmpty;
    final display = isEmpty && placeholder != null ? placeholder! : text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        display,
        maxLines: maxLines,
        overflow: maxLines == 1 ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          color: isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
