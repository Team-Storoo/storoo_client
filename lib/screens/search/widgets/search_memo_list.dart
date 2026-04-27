import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 검색 화면 — 메모 탭 컨텐츠
///
/// 검색어가 없으면 안내 문구, 검색 결과가 없으면 빈 상태를 표시합니다.
class SearchMemoList extends StatelessWidget {
  final String searchQuery;

  const SearchMemoList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return const Center(
        child: Text(
          '검색어를 입력해 보세요.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // TODO: 실제 메모 데이터 연결 시 검색 결과로 교체
    const items = <String>[];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
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
