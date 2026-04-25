import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 메모 탭 컨텐츠
///
/// 저장된 메모 목록을 표시합니다.
/// 데이터가 없을 경우 빈 상태 메시지를 표시합니다.
class InFolderMemoList extends StatelessWidget {
  final String searchQuery;

  const InFolderMemoList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 메모 데이터 연결 시 List<MemoItem>으로 교체
    const items = <String>[];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '저장된 메모가 없습니다.',
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
