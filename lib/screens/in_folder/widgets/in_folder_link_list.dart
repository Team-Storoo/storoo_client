import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 링크 탭 컨텐츠
///
/// 저장된 링크 목록을 표시합니다.
/// 데이터가 없을 경우 빈 상태 메시지를 표시합니다.
class InFolderLinkList extends StatelessWidget {
  final String searchQuery;

  const InFolderLinkList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 링크 데이터 연결 시 List<LinkItem>으로 교체
    const items = <String>[];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '저장된 링크가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => const SizedBox.shrink(),
    );
  }
}
