import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 검색 초기 상태 / 결과 없음 안내
class SearchEmptyView extends StatelessWidget {
  /// 초기 상태 (검색어 없음)
  const SearchEmptyView.initial({super.key}) : _query = null;

  /// 결과 없음 상태
  const SearchEmptyView.noResults({super.key, required String query})
    : _query = query;

  final String? _query;

  @override
  Widget build(BuildContext context) {
    if (_query == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: AppColors.navUnselected),
            SizedBox(height: 12),
            Text('폴더명이나 저장된 내용을 검색해보세요', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.navUnselected,
          ),
          const SizedBox(height: 12),
          Text('"$_query" 검색 결과가 없어요', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
