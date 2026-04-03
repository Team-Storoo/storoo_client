import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 폴더 화면 정렬 필터 버튼 행
///
/// [filters]       필터 이름 목록
/// [selectedIndex] 현재 선택된 필터 인덱스
/// [onSelected]    필터 선택 시 호출되는 콜백
class FolderFilterRow extends StatelessWidget {
  const FolderFilterRow({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      width: double.infinity, // 화면 너비가 변해도 항상 전체 너비를 채움
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: List.generate(filters.length, (i) {
            final bool isSelected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    // '전체' 필터에는 개수 표시 (TODO: 실제 값으로 교체)
                    i == 0 ? '${filters[i]} 0' : filters[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
