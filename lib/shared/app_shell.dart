import 'package:flutter/material.dart';
import 'widgets/nav_bar.dart';
import '../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/folder/folder_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/my_page/my_page_screen.dart';

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
              child: Center(child: _SaveFab(onTap: () {})),
            ),
          ],
        ),
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
