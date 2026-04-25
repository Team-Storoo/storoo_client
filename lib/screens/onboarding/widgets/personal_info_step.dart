import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 온보딩 Step 2: 성별 + 출생년도
class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({
    super.key,
    required this.gender,
    required this.onGenderChanged,
    required this.birthYearController,
    required this.onChanged,
  });

  final String? gender;
  final ValueChanged<String> onGenderChanged;
  final TextEditingController birthYearController;
  final VoidCallback onChanged;

  bool get _hasError {
    final v = birthYearController.text.trim();
    if (v.isEmpty) return false;
    if (v.length < 4) return true;
    final year = int.tryParse(v);
    if (year == null) return true;
    return year < 1900 || year > DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('성별', style: AppTextStyles.caption),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _GenderButton(
                label: '남성',
                selected: gender == 'male',
                onTap: () => onGenderChanged('male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderButton(
                label: '여성',
                selected: gender == 'female',
                onTap: () => onGenderChanged('female'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('출생년도', style: AppTextStyles.caption),
        const SizedBox(height: 10),
        TextField(
          controller: birthYearController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          buildCounter:
              (
                _, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            hintText: '출생년도를 입력해주세요. (예. 1999)',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            errorText:
                _hasError
                    ? '1900 ~ ${DateTime.now().year} 사이의 연도를 입력해주세요.'
                    : null,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontSize: 11,
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.divider,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.primary,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: AppTextStyles.body,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

/// 성별 선택 버튼
class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
