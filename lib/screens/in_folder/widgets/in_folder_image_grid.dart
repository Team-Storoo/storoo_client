import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 이미지 탭 컨텐츠 — 2열 그리드
///
/// 저장된 이미지 목록을 2열 그리드로 표시합니다.
/// 데이터가 없을 경우 빈 상태 메시지를 표시합니다.
class InFolderImageGrid extends StatelessWidget {
  final String searchQuery;

  const InFolderImageGrid({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 이미지 데이터 연결 시 List<ImageItem>으로 교체
    const items = <String>[];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '저장된 이미지가 없습니다.',
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
