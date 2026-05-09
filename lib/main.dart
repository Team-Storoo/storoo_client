import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/db_service.dart';
import 'services/share_intent_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/share/share_save_screen.dart';

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

// ──────────────────────────────────────────────────────────────────────
// 공유 진입점: 외부 앱에서 공유 시 앱 본체 없이 바텀시트만 표시
// ──────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void shareMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.init();
  runApp(const _ShareEntryApp());
}

class _ShareEntryApp extends StatelessWidget {
  const _ShareEntryApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light.copyWith(scaffoldBackgroundColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      home: const _ShareEntryPoint(),
    );
  }
}

class _ShareEntryPoint extends StatefulWidget {
  const _ShareEntryPoint();

  @override
  State<_ShareEntryPoint> createState() => _ShareEntryPointState();
}

class _ShareEntryPointState extends State<_ShareEntryPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSheet());
  }

  Future<void> _openSheet() async {
    final type = await ShareIntentService.getShareType();
    final sharedText = await ShareIntentService.getInitialSharedText();

    String? url;
    String? noteText;
    String? imageFilePath;

    if (type == 'link') {
      // 멀티라인 공유 텍스트("제목\nURL")에서 URL만 추출
      url = ShareIntentService.extractUrl(sharedText);
    } else if (type == 'note') {
      noteText = sharedText;
    } else if (type == 'image') {
      imageFilePath = await ShareIntentService.getImagePath();
    }

    if (!mounted) return;
    await ShareSaveScreen.show(
      context,
      type: type,
      initialUrl: url,
      initialNote: noteText,
      imageFilePath: imageFilePath,
    );
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
