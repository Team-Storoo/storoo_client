import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum InFolderSort { relevant, newest, oldest }

class InFolderSortHeader extends StatelessWidget {
  final int count;
  final InFolderSort sort;
  final ValueChanged<InFolderSort> onSortChanged;
  final VoidCallback? onFilterTap;

  const InFolderSortHeader({
    super.key,
    required this.count,
    required this.sort,
    required this.onSortChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '검색결과 ',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: '$count',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onFilterTap,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  children: [
                    Text(
                      '필터',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SortOption(
                label: '관련순',
                selected: sort == InFolderSort.relevant,
                onTap: () => onSortChanged(InFolderSort.relevant),
              ),
              const _Divider(),
              _SortOption(
                label: '최신순',
                selected: sort == InFolderSort.newest,
                onTap: () => onSortChanged(InFolderSort.newest),
              ),
              const _Divider(),
              _SortOption(
                label: '오래된순',
                selected: sort == InFolderSort.oldest,
                onTap: () => onSortChanged(InFolderSort.oldest),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          color: AppColors.divider,
        ),
      ),
    );
  }
}
