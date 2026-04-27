import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 검색 화면 — 이미지 탭 컨텐츠 (2열 그리드)
///
/// 검색어가 없으면 안내 문구, 검색 결과가 없으면 빈 상태를 표시합니다.
class SearchImageGrid extends StatelessWidget {
  final String searchQuery;

  const SearchImageGrid({super.key, required this.searchQuery});

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

    // TODO: 실제 이미지 데이터 연결 시 검색 결과로 교체
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => const SizedBox.shrink(),
    );
  }
}
