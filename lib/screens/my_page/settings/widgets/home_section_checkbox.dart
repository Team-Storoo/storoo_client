import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/home_section.dart';

/// 홈화면 설정 섹션 선택 체크박스 항목 (SRP)
///
/// [section]     표시할 섹션
/// [isChecked]   현재 선택 여부
/// [isDisabled]  비활성화 여부 (최대 개수 초과 시 미선택 항목 비활성)
/// [onChanged]   체크 상태 변경 콜백
class HomeSectionCheckbox extends StatelessWidget {
  const HomeSectionCheckbox({
    super.key,
    required this.section,
    required this.isChecked,
    required this.isDisabled,
    required this.onChanged,
  });

  final HomeSection section;
  final bool isChecked;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isDisabled && !isChecked
            ? AppColors.textSecondary
            : AppColors.textPrimary;

    return GestureDetector(
      onTap: isDisabled && !isChecked ? null : () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 체크박스 아이콘
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isChecked
                          ? AppColors.primary
                          : (isDisabled
                              ? AppColors.divider
                              : AppColors.textSecondary),
                  width: 1.5,
                ),
              ),
              child:
                  isChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 14),
            // 섹션 이름
            Expanded(
              child: Text(
                section.label,
                style: AppTextStyles.body.copyWith(color: effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
