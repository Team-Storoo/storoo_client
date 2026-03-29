import 'package:flutter/material.dart';
import 'services/db_service.dart'; // DB 초기화 서비스 임포트

// 화면 import
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart'; // FolderScreen
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart'; // MyPageScreen

// 테마 import
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

// widgetsFlutterBinding.ensureInitialized() → DBService.init() → runApp() 순서로 실행
// 앱 실행 전에 lsar DB가 준비되면, 이후 화면에서 바로 DB 사용 가능
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await DBService.init(); // Isar DB 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storoo',
      theme: AppTheme.light, // 공통 테마 적용
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 탭에 연결된 화면 목록 (가운데 + FAB는 화면이 아니므로 제외)
  static const List<Widget> _screens = [
    HomeScreen(),
    FolderScreen(),
    SearchScreen(),
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: 탭 전환 시 각 화면의 스크롤 위치/상태를 유지
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // 가운데 보라색 + 버튼 (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 저장 화면(바텀시트) 열기
        },
        backgroundColor: AppColors.primary,
        // 원 → 둥근 모서리 사각형
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 하단 앱바 (노치 없음, 상단에 그림자만 추가)
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black12,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          children: [
            // Expanded로 감싸서 4개 아이템이 항상 균등한 너비를 가짐
            Expanded(
              child: _NavItem(
                index: 0,
                selectedIndex: _selectedIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                onTap: _onItemTapped,
              ),
            ),
            Expanded(
              child: _NavItem(
                index: 1,
                selectedIndex: _selectedIndex,
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: '폴더',
                onTap: _onItemTapped,
              ),
            ),
            const SizedBox(width: 64), // FAB 중앙 공간
            Expanded(
              child: _NavItem(
                index: 2,
                selectedIndex: _selectedIndex,
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: '검색',
                onTap: _onItemTapped,
              ),
            ),
            Expanded(
              child: _NavItem(
                index: 3,
                selectedIndex: _selectedIndex,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '마이페이지',
                onTap: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 하단 내비게이션 아이템
/// 선택 여부에 따라 아이콘(outline ↔ filled)과 색상이 자동으로 변경됨
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final Color color =
        isSelected ? AppColors.navSelected : AppColors.navUnselected;

    // GestureDetector: hover/ripple 효과 없이 탭만 인식
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // 투명 영역도 탭 인식
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.navLabel.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
