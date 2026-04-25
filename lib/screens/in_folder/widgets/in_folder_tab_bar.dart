import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 폴더 내부 화면 — 링크 / 이미지 / 메모 탭 바
///
/// 선택된 탭: 기본 보라색 텍스트(bold) + 두꺼운 보라색 하단 선
/// 비선택 탭: 보조 텍스트(regular) + 얇은 회색 하단 선
class InFolderTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const InFolderTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const _labels = ['링크', '이미지', '메모'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final selected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTabChanged(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? AppColors.primary : AppColors.divider,
                    width: selected ? 2.5 : 1.0,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[i],
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
