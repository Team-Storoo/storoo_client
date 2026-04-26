import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 메모 입력 필드 (최대 200자, 선택 입력)
class MemoField extends StatelessWidget {
  const MemoField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  static const int _maxLength = 200;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '메모',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: _maxLength,
          maxLines: 4,
          buildCounter:
              (
                _, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => null,
          onChanged: (_) => onChanged(),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: '어떤 게시물인지 메모를 작성할 수 있어요!',
            hintStyle: AppTextStyles.caption,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${controller.text.length}/$_maxLength',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
