import 'package:flutter/material.dart';
import 'widgets/nav_bar.dart';
import '../core/theme/app_colors.dart';
import '../models/folder_item.dart';
import '../screens/home/home_screen.dart';
import '../screens/folder/folder_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/my_page/my_page_screen.dart';
import '../screens/save/save_content_sheet.dart';
import '../services/db_service.dart';

/// 앱의 메인 레이아웃 셸
///
/// 역할: 화면 목록 조립 + 네비게이션 바 + 가운데 저장 FAB
/// 각 화면의 내용은 screens/ 폴더 안에서 책임짐
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    const FolderScreen(),
    const SearchScreen(),
    const MyPageScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 0) {
      _homeKey.currentState?.refresh();
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _onSaveFabTapped() async {
    final folders = await DBService.getFolders();
    if (!mounted) return;

    if (folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '먼저 폴더를 만들어 주세요.',
            style: TextStyle(fontFamily: 'Pretendard'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<FolderItem>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FolderPickerSheet(folders: folders),
    );
    if (selected == null || !mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SaveContentSheet(
        folderId: selected.id,
        folderName: selected.name,
        onSaved: () => _homeKey.currentState?.refresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // IndexedStack: 탭 전환 시 각 화면의 스크롤 위치/상태 유지
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // bottomNavigationBar 안에 FAB를 함께 배치
      // - SizedBox 높이 92 = nav bar 64 + FAB 상단 28(절반)
      // - Positioned(bottom:36): FAB 중심이 nav bar 상단과 일치
      bottomNavigationBar: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 하단 네비게이션 바 (하단 고정)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavBar(
                selectedIndex: _selectedIndex,
                onTap: _onTabTapped,
              ),
            ),
            // 저장 FAB
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(child: _SaveFab(onTap: () => _onSaveFabTapped())),
            ),
          ],
        ),
      ),
    );
  }
}

/// 폴더 선택 바텀시트 (FAB 저장 흐름 전용)
class _FolderPickerSheet extends StatelessWidget {
  final List<FolderItem> folders;

  const _FolderPickerSheet({required this.folders});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '저장할 폴더 선택',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: folders.length,
            itemBuilder: (_, i) {
              final folder = folders[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  folder.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${folder.itemCount}개',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(folder),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 저장 FAB 버튼 (AppShell 전용)
class _SaveFab extends StatelessWidget {
  const _SaveFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
