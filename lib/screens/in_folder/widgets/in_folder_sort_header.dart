import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 정렬 방식 (최신순 / 오래된순)
enum InFolderSort { newest, oldest }

/// 폴더 내부 화면 — 검색결과 개수 + 정렬 옵션 헤더
///
/// 좌측: "검색결과 N" — N은 기본 보라색으로 강조
/// 우측: "최신순 | 오래된순" — 선택된 항목 bold
class InFolderSortHeader extends StatelessWidget {
  final int count;
  final InFolderSort sort;
  final ValueChanged<InFolderSort> onSortChanged;

  const InFolderSortHeader({
    super.key,
    required this.count,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
            onTap: () => onSortChanged(InFolderSort.newest),
            behavior: HitTestBehavior.opaque,
            child: Text(
              '최신순',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: sort == InFolderSort.newest
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: sort == InFolderSort.newest
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '|',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.divider,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onSortChanged(InFolderSort.oldest),
            behavior: HitTestBehavior.opaque,
            child: Text(
              '오래된순',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: sort == InFolderSort.oldest
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: sort == InFolderSort.oldest
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
