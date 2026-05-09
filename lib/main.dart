import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/db_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

/// 전체 앱에서 스크롤바를 숨기는 ScrollBehavior
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // 스크롤바 위젯 없이 그냥 child 반환
  }
}

// widgetsFl
// utterBinding.ensureInitialized() → DBService.init() → runApp() 순서로 실행
// 앱 실행 전에 Isar DB가 준비되면, 이후 화면에서 바로 DB 사용 가능
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storoo',
      theme: AppTheme.light,
      scrollBehavior: _NoScrollbarBehavior(),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
