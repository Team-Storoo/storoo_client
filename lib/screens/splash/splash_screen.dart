import 'package:flutter/material.dart';

import '../../services/db_service.dart';
import '../../shared/app_shell.dart';
import '../login/login_screen.dart';

/// 앱 최초 진입 스플래시 화면
/// - DB 체크 + 최소 1.5초 대기를 동시에 수행
/// - 온보딩 완료 → AppShell, 미완료 → LoginScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1500)),
      DBService.hasCompletedOnboarding(),
    ]);

    if (!mounted) return;

    final completed = results[1] as bool;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => completed ? const AppShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 중앙 로고
          const Center(
            child: Text(
              'Storoo',
              style: TextStyle(
                fontFamily: 'A2GExtraBold',
                fontSize: 52,
                color: Colors.black,
                letterSpacing: 0,
              ),
            ),
          ),
          // 하단 크레딧
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'made by',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
                Text(
                  'LemonPie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
