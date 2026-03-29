import 'package:flutter/material.dart';
import 'services/db_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/app_shell.dart';

// widgetsFlutterBinding.ensureInitialized() → DBService.init() → runApp() 순서로 실행
// 앱 실행 전에 Isar DB가 준비되면, 이후 화면에서 바로 DB 사용 가능
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
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
