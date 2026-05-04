import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 검색 화면 전용 검색 바
/// 입력 중일 때 우측에 X 버튼이 나타나 한 번에 초기화합니다.
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '폴더명 또는 저장된 내용 검색',
            hintStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.navUnselected,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.navUnselected,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.navUnselected,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 0,
            ),
          ),
        ),
      ),
    );
  }
}
