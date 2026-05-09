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

  // DB 초기화 + 공유 데이터 수집을 병렬로 처리
  final results = await Future.wait([
    DBService.init(),
    ShareIntentService.getShareType(),
    ShareIntentService.getInitialSharedText(),
    ShareIntentService.getImagePath(),
  ]);

  final type = (results[1] as String?) ?? 'link';
  final sharedText = results[2] as String?;
  final imagePath = results[3] as String?;

  String? url;
  String? noteText;
  String? imageFilePath;

  if (type == 'link') {
    url = ShareIntentService.extractUrl(sharedText);
  } else if (type == 'note') {
    noteText = sharedText;
  } else if (type == 'image') {
    imageFilePath = imagePath;
  }

  // 모든 데이터가 준비된 상태로 runApp → 첫 프레임에 즉시 바텀시트 표시
  runApp(
    _ShareEntryApp(
      type: type,
      initialUrl: url,
      initialNote: noteText,
      imageFilePath: imageFilePath,
    ),
  );
}

class _ShareEntryApp extends StatelessWidget {
  const _ShareEntryApp({
    this.type = 'link',
    this.initialUrl,
    this.initialNote,
    this.imageFilePath,
  });

  final String type;
  final String? initialUrl;
  final String? initialNote;
  final String? imageFilePath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: _ShareEntryPoint(
        type: type,
        initialUrl: initialUrl,
        initialNote: initialNote,
        imageFilePath: imageFilePath,
      ),
    );
  }
}

class _ShareEntryPoint extends StatefulWidget {
  const _ShareEntryPoint({
    this.type = 'link',
    this.initialUrl,
    this.initialNote,
    this.imageFilePath,
  });

  final String type;
  final String? initialUrl;
  final String? initialNote;
  final String? imageFilePath;

  @override
  State<_ShareEntryPoint> createState() => _ShareEntryPointState();
}

class _ShareEntryPointState extends State<_ShareEntryPoint> {
  @override
  void initState() {
    super.initState();
    // 데이터가 이미 준비됐으므로 첫 프레임에 바로 바텀시트 표시
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSheet());
  }

  Future<void> _openSheet() async {
    if (!mounted) return;
    await ShareSaveScreen.show(
      context,
      type: widget.type,
      initialUrl: widget.initialUrl,
      initialNote: widget.initialNote,
      imageFilePath: widget.imageFilePath,
    );
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
