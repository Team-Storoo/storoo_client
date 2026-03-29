import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 하단 네비게이션 바 (전체 화면에서 공용)
///
/// [selectedIndex] 현재 선택된 탭 인덱스
/// [onTap]         탭 선택 시 호출되는 콜백
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black12,
      padding: EdgeInsets.zero,
      height: 64,
      child: Row(
        children: [
          // Expanded: 4개 아이템이 항상 균등한 너비를 가짐
          Expanded(
            child: _NavItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: '홈',
              onTap: onTap,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.folder_outlined,
              activeIcon: Icons.folder,
              label: '폴더',
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 64), // FAB 중앙 공간
          Expanded(
            child: _NavItem(
              index: 2,
              selectedIndex: selectedIndex,
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: '검색',
              onTap: onTap,
            ),
          ),
          Expanded(
            child: _NavItem(
              index: 3,
              selectedIndex: selectedIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: '마이페이지',
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// 네비게이션 단일 아이템 (AppNavBar 내부 전용)
///
/// 선택 여부에 따라 아이콘(outline ↔ filled)과 색상이 자동 변경
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final Color color =
        isSelected ? AppColors.navSelected : AppColors.navUnselected;

    // GestureDetector: hover/ripple 효과 없이 탭만 인식
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.navLabel.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
