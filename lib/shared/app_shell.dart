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

  // 탭에 연결된 화면 목록 (FAB는 화면이 아니므로 제외)
  static const List<Widget> _screens = [
    HomeScreen(),
    FolderScreen(),
    SearchScreen(),
    MyPageScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: 탭 전환 시 각 화면의 스크롤 위치/상태 유지
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // 가운데 저장 버튼 (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 저장 바텀시트 열기
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 공용 네비게이션 바
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
