import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

/// 로그인 화면
/// 소셜 로그인 버튼 → OnboardingScreen으로 진입
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // ── 중앙 로고 + 버튼 영역 ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 서브타이틀
                      Text(
                        '나만의 작은 저장소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Storoo 로고
                      const Text(
                        'Storoo',
                        style: TextStyle(
                          fontFamily: 'A2GExtraBold',
                          fontSize: 48,
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // ── 카카오 버튼 ──
                      _SocialButton(
                        onTap: () => _goToOnboarding(context),
                        backgroundColor: const Color(0xFFFEE500),
                        icon: _KakaoIcon(),
                        label: '카카오로 시작하기',
                        labelColor: const Color(0xFF191919),
                      ),
                      const SizedBox(height: 12),
                      // ── 네이버 버튼 ──
                      _SocialButton(
                        onTap: () => _goToOnboarding(context),
                        backgroundColor: const Color(0xFF03C75A),
                        icon: _NaverIcon(),
                        label: '네이버로 시작하기',
                        labelColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      // ── 구글 버튼 ──
                      _SocialButton(
                        onTap: () => _goToOnboarding(context),
                        backgroundColor: Colors.white,
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        icon: _GoogleIcon(),
                        label: '구글로 시작하기',
                        labelColor: const Color(0xFF191919),
                      ),
                    ],
                  ),
                ),
              ),
              // ── 하단 크레딧 ──
              const Positioned(
                bottom: 32,
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
        ),
      ),
    );
  }
}

/// 공용 소셜 로그인 버튼
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.labelColor,
    this.border,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget icon;
  final String label;
  final Color labelColor;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카카오 아이콘 (말풍선 두 개 겹친 형태)
class _KakaoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chat_bubble, color: Color(0xFF191919), size: 22);
  }
}

/// 네이버 아이콘 ('N' 흰 글자)
class _NaverIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'N',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.3,
      ),
    );
  }
}

/// 구글 아이콘 (멀티컬러 'G')
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4285F4), // blue
              Color(0xFFEA4335), // red
              Color(0xFFFBBC05), // yellow
              Color(0xFF34A853), // green
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ).createShader(bounds),
      child: const Text(
        'G',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}
