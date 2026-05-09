import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Share 저장 시트 상단 헤더
/// SRP: 취소/타이틀/확인 버튼 UI만 담당
class ShareSaveHeader extends StatelessWidget {
  const ShareSaveHeader({
    super.key,
    required this.canSave,
    required this.isSaving,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool canSave;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onCancel,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  '취소',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              else
                GestureDetector(
                  onTap: canSave ? onConfirm : null,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    '저장',
                    style: AppTextStyles.body.copyWith(
                      color: canSave ? AppColors.primary : AppColors.divider,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Storoo',
            style: AppTextStyles.storooTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }
}
