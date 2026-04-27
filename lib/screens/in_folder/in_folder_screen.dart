import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../folder/folder_item.dart';
import 'widgets/in_folder_tab_bar.dart';
import 'widgets/in_folder_search_bar.dart';
import 'widgets/in_folder_sort_header.dart';
import 'widgets/in_folder_link_list.dart';
import 'widgets/in_folder_image_grid.dart';
import 'widgets/in_folder_memo_list.dart';

/// 폴더 내부 화면
///
/// 탭: 링크(0) / 이미지(1) / 메모(2) — 디폴트 링크
/// AppBar: 뒤로가기 | 폴더명 | 설정(⋮)
/// 본문: 탭 바 → 검색 바 → 검색결과/정렬 헤더 → 탭 컨텐츠
class InFolderScreen extends StatefulWidget {
  final FolderItem folder;

  const InFolderScreen({super.key, required this.folder});

  @override
  State<InFolderScreen> createState() => _InFolderScreenState();
}

class _InFolderScreenState extends State<InFolderScreen> {
  int _selectedTab = 0;
  InFolderSort _sort = InFolderSort.newest;
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
        return InFolderLinkList(searchQuery: _searchQuery);
      case 1:
        return InFolderImageGrid(searchQuery: _searchQuery);
      case 2:
        return InFolderMemoList(searchQuery: _searchQuery);
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
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          title: Text(
            widget.folder.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            InFolderTabBar(
              selectedIndex: _selectedTab,
              onTabChanged:
                  (i) => setState(() {
                    _selectedTab = i;
                    _searchCtrl.clear();
                    _searchQuery = '';
                  }),
            ),
            InFolderSearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            InFolderSortHeader(
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
