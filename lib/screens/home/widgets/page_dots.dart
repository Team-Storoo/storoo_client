import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 배너 페이지 인디케이터 (점 N개)
///
/// [count]       점의 총 개수
/// [activeIndex] 현재 활성화된 점의 인덱스 (굵고 길게 표시)
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == activeIndex;
        return Container(
          width: isActive ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
