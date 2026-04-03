import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import './my_page_menu_item.dart';

/// 마이페이지 메뉴 섹션
/// 상단 구분선 + 섹션 제목 + 메뉴 항목 목록
///
/// [title]   섹션 제목 (예: '고객 지원')
/// [items]   메뉴 항목 이름 목록
/// [onTaps]  각 항목 탭 콜백 목록 (items와 길이 동일해야 함)
class MyPageMenuSection extends StatelessWidget {
  const MyPageMenuSection({
    super.key,
    required this.title,
    required this.items,
    required this.onTaps,
  });

  final String title;
  final List<String> items;
  final List<VoidCallback> onTaps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 상단 구분선
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        // 섹션 제목
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            title,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // 메뉴 항목 목록
        ...List.generate(
          items.length,
          (i) => MyPageMenuItem(label: items[i], onTap: onTaps[i]),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
