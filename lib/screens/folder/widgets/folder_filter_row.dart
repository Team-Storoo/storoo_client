import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ── 정렬 필터 열거형 ────────────────────────────────────────────────────
enum FolderSortFilter { total, name, recent, custom }

/// 폴더 화면 정렬 필터 버튼 행
class FolderFilterRow extends StatelessWidget {
  const FolderFilterRow({
    super.key,
    required this.total,
    required this.selectedFilter,
    required this.onSelected,
  });

  final int total;
  final FolderSortFilter selectedFilter;
  final ValueChanged<FolderSortFilter> onSelected;

  // ── 화면 빌드 ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final items = [
      (FolderSortFilter.total, '전체 $total'),
      (FolderSortFilter.name, '이름순'),
      (FolderSortFilter.recent, '최신순'),
      (FolderSortFilter.custom, '사용자 지정순'),
    ];

    return Container(
      color: Colors.white,
      width: double.infinity,
      // 가로 스크롤 필터 목록
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children:
              items.map((item) {
                final (filter, label) = item;
                final isSelected = filter == selectedFilter;
                // 개별 필터 칩
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSelected(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
