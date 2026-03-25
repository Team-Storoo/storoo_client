import 'package:flutter/material.dart';
import 'services/db_service.dart'; // DB 초기화 서비스 임포트

// 우리가 만든 화면들 import
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/save_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
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

  // 화면 리스트
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SaveScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '탐색'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: '저장'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
