import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/db_service.dart';
import '../../shared/app_shell.dart';
import '../intro/intro_screen.dart';
import '../login/login_screen.dart';

// ─── 타이밍 상수 (ms) ───────────────────────────────────────────────────────
const _kWord = 'Storoo';
const _kPerCharDelayMs = 80; // 글자 간 딜레이
const _kCharDurationMs = 260; // 각 글자 슬라이드 인 시간
// charCtrl 전체 길이 = 80*5 + 260 = 660ms
const _kCharTotalMs = _kPerCharDelayMs * 5 + _kCharDurationMs;
const _kBgDelayMs = 680; // 배경 확장 시작 (글자 완료 직후)
const _kBgDurationMs = 600; // 배경 원형 확장 시간
const _kNavigateMs = 2400; // 내비게이션 (+0.5초 여유)
const _kFontSize = 52.0;

// ─── SplashScreen ────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _charCtrl;
  late final AnimationController _bgCtrl;
  late final Animation<double> _bgAnim;

  // 온보딩 완료 여부 + 인트로 표시 여부를 앱 시작과 동시에 병렬 조회
  late final Future<List<bool>> _initFuture = Future.wait([
    DBService.hasCompletedOnboarding(),
    DBService.hasSeenIntro(),
  ]);

  @override
  void initState() {
    super.initState();

    // 글자 슬라이드 인 컨트롤러 (forward는 첫 프레임 이후에)
    _charCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kCharTotalMs),
    );

    // 배경 원형 확장 컨트롤러
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kBgDurationMs),
    );
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    // 첫 프레임이 실제로 그려진 후 애니메이션 시작 → 앞부분 잘림 방지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _charCtrl.forward();

      Future.delayed(const Duration(milliseconds: _kBgDelayMs), () {
        if (mounted) _bgCtrl.forward();
      });

      _navigate();
    });
  }

  Future<void> _navigate() async {
    // 타이머 + DB 병렬 처리
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: _kNavigateMs)),
      _initFuture,
    ]);
    if (!mounted) return;

    final flags = results[1] as List<bool>;
    final completed = flags[0]; // 온보딩 완료 여부
    final seenIntro = flags[1]; // 인트로 화면 표시 여부

    Widget next;
    if (completed) {
      next = const AppShell();
    } else if (!seenIntro) {
      next = const IntroScreen(); // 최초 실행 → 인트로
    } else {
      next = const LoginScreen();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() {
    _charCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_charCtrl, _bgAnim]),
        builder: (context, _) {
          final bg = _bgAnim.value;
          return Stack(
            children: [
              // ① 흰 배경
              Container(color: Colors.white),

              // ② primary 색상 원형 확장 (CustomPaint)
              Positioned.fill(child: CustomPaint(painter: _CirclePainter(bg))),

              // ③ 검정 Storoo 텍스트 (기저 레이어)
              Center(
                child: _StorooText(controller: _charCtrl, color: Colors.black),
              ),

              // ④ 흰 Storoo 텍스트 — 원형 영역에만 클리핑
              if (bg > 0)
                Positioned.fill(
                  child: ClipPath(
                    clipper: _CircleClipper(bg),
                    child: Center(
                      child: _StorooText(
                        controller: _charCtrl,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── 글자 슬라이드 인 위젯 ────────────────────────────────────────────────────

class _StorooText extends StatelessWidget {
  const _StorooText({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_kWord.length, (i) {
        final startFrac = (i * _kPerCharDelayMs) / _kCharTotalMs;
        final endFrac =
            ((i * _kPerCharDelayMs) + _kCharDurationMs) / _kCharTotalMs;
        final endClamped = endFrac.clamp(0.0, 1.0);

        // 위에서 아래로 슬라이드
        final slide = Tween<Offset>(
          begin: const Offset(0, -1.6),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(startFrac, endClamped, curve: Curves.easeOutBack),
          ),
        );

        // 등장 시 빠른 페이드 인
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(startFrac, (startFrac + 0.10).clamp(0.0, 1.0)),
          ),
        );

        // ClipRect: 슬라이드 영역 밖으로 삐져나오지 않도록 clipping
        return ClipRect(
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: Text(
                _kWord[i],
                style: TextStyle(
                  fontFamily: 'A2GExtraBold',
                  fontSize: _kFontSize,
                  color: color,
                  height: 1.15,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── 원형 배경 페인터 ─────────────────────────────────────────────────────────

class _CirclePainter extends CustomPainter {
  const _CirclePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    // 화면 모서리까지 완전히 채우는 최대 반지름
    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    canvas.drawCircle(
      center,
      maxRadius * progress,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.progress != progress;
}

// ─── 원형 클리퍼 (흰 텍스트용) ───────────────────────────────────────────────

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * progress));
  }

  @override
  bool shouldReclip(_CircleClipper old) => old.progress != progress;
}
