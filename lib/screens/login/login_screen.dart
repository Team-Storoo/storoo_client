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
                        iconPath: 'assets/icons/kakao.png',
                        label: '카카오로 시작하기',
                        labelColor: const Color(0xFF191919),
                      ),
                      const SizedBox(height: 12),
                      // ── 네이버 버튼 ──
                      _SocialButton(
                        onTap: () => _goToOnboarding(context),
                        backgroundColor: const Color(0xFF03C75A),
                        iconPath: 'assets/icons/naver.png',
                        label: '네이버로 시작하기',
                        labelColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      // ── 구글 버튼 ──
                      _SocialButton(
                        onTap: () => _goToOnboarding(context),
                        backgroundColor: Colors.white,
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        iconPath: 'assets/icons/google.png',
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
///
/// [iconPath] assets/icons/ 하위 파일 경로 (예: 'assets/icons/kakao.png')
/// 이미지 파일이 없으면 빈 SizedBox로 대체됩니다.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.backgroundColor,
    required this.iconPath,
    required this.label,
    required this.labelColor,
    this.border,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final String iconPath;
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
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
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
