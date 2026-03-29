import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 폴더 화면 (탐색 탭)
/// ─ 상단: '내 폴더' 제목 + + / ⋮ 버튼
/// ─ 정렬 필터 칩: 버튼만 구성, 기능은 추후 구현
/// ─ 폴더 그리드: 2열 구성, 실제 데이터는 추후 연결
class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  // 현재 선택된 정렬 필터 인덱스 (0 = 전체)
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['전체', '이름순', '최신순', '사용자 지정순'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내 폴더'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}, // TODO: 폴더 추가 구현
            tooltip: '폴더 추가',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, // TODO: 더보기 메뉴 구현
            tooltip: '더보기',
          ),
        ],
      ),
      body: Column(
        children: [
          // 정렬 필터 버튼 행
          _FilterRow(
            filters: _filters,
            selectedIndex: _selectedFilterIndex,
            onSelected: (i) => setState(() => _selectedFilterIndex = i),
          ),
          // 폴더 그리드
          const Expanded(child: _FolderGrid()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 정렬 필터 버튼 행
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      width: double.infinity, // 화면 너비가 변해도 항상 전체 너비를 채움
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: List.generate(filters.length, (i) {
            final bool isSelected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    // '전체' 필터에는 개수 표시 (TODO: 실제 값으로 교체)
                    i == 0 ? '${filters[i]} 0' : filters[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// 폴더 그리드 (2열)
class _FolderGrid extends StatelessWidget {
  const _FolderGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2열
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4, // 커드 가로:세로 비율
      ),
      itemCount: 6, // TODO: 실제 폴더 목록으로 교체
      itemBuilder: (_, index) => _FolderCard(index: index),
    );
  }
}

// 폴더 카드
class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '폴더 ${index + 1}', // TODO: 실제 폴더 이름으로 교체
                  style: AppTextStyles.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {}, // TODO: 폴더 옵션 메뉴 구현
                child: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            '저장된 항목 0개', // TODO: 실제 개수로 교체
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
