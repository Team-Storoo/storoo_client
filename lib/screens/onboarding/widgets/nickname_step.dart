import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 온보딩 Step 1: 닉네임 설정
class NicknameStep extends StatelessWidget {
  const NicknameStep({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('닉네임', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: 15,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => null,
          decoration: InputDecoration(
            suffixText: '${controller.text.length}/15',
            suffixStyle: AppTextStyles.caption,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: AppTextStyles.body,
          keyboardType: TextInputType.text,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        Text(
          '한글, 영문 대소문자, 숫자, 특수문자 밑줄(_), 마침표를 포함하여 2~15자 이내로 작성해 주시길 바랍니다.',
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 8),
        Text(
          '닉네임은 마이페이지 > 프로필 설정에서 언제든지 변경하실 수 있습니다.',
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
