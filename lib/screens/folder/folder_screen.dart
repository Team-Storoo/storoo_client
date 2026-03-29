import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import './widgets/folder_filter_row.dart';
import './widgets/folder_grid.dart';

/// 폴더 화면
/// 고정 AppBar + 고정 필터 행 + 스크롤 그리드 구조
class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  static const List<String> _filters = ['전체', '최신순', '이름순'];
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          '내 폴더',
          style: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {}, // TODO: 폴더 추가
            icon: Icon(Icons.add, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {}, // TODO: 폴더 옵션
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 행: 스크롤과 분리되어 항상 상단에 고정
          FolderFilterRow(
            filters: _filters,
            selectedIndex: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
          ),
          // 그리드: 남은 공간을 채워 스크롤
          const Expanded(child: FolderGrid()),
        ],
      ),
    );
  }
}
