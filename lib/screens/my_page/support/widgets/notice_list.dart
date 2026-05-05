import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 공지사항 목록 위젯
/// TODO: DB 연동 후 실제 데이터 연결
class NoticeList extends StatelessWidget {
  const NoticeList({super.key});

  static const _items = [
    (date: '2025.04.28', title: 'Storoo v1.0.0 출시', body: '• 폴더 생성 및 관리 기능\n• 링크 / 이미지 / 노트 저장\n• 검색 기능\n\n이용해 주셔서 감사합니다 🎉'),
    (date: '2025.04.10', title: '서비스 점검 안내', body: '안정적인 서비스 제공을 위해 점검을 진행합니다.\n점검 시간: 2025.04.10 새벽 2시 ~ 4시\n이용에 불편을 드려 죄송합니다.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder: (_, i) => _NoticeCard(item: _items[i]),
    );
  }
}

class _NoticeCard extends StatefulWidget {
  const _NoticeCard({required this.item});

  final ({String date, String title, String body}) item;

  @override
  State<_NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<_NoticeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.item.title, style: AppTextStyles.subtitle),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(widget.item.date, style: AppTextStyles.caption),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(widget.item.body, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    );
  }
}
