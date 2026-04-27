import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/search_tab_bar.dart';
import 'widgets/search_input_bar.dart';
import 'widgets/search_sort_header.dart';
import 'widgets/search_link_list.dart';
import 'widgets/search_image_grid.dart';
import 'widgets/search_memo_list.dart';

/// 검색 화면
///
/// 탭: 링크(0) / 이미지(1) / 메모(2)
/// 구성: 탭 바 → 검색 바 → 정렬 헤더 → 탭 컨텐츠
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedTab = 0;
  SearchSort _sort = SearchSort.newest;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return SearchLinkList(searchQuery: _searchQuery);
      case 1:
        return SearchImageGrid(searchQuery: _searchQuery);
      case 2:
        return SearchMemoList(searchQuery: _searchQuery);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            '검색',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            SearchTabBar(
              selectedIndex: _selectedTab,
              onTabChanged: (i) => setState(() {
                _selectedTab = i;
                _searchCtrl.clear();
                _searchQuery = '';
              }),
            ),
            SearchInputBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            SearchSortHeader(
              count: 0,
              sort: _sort,
              onSortChanged: (s) => setState(() => _sort = s),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }
}
